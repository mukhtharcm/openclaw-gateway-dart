import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:openclaw_gateway/src/auth.dart';
import 'package:openclaw_gateway/src/connect_error_details.dart';
import 'package:openclaw_gateway/src/connect_payload.dart';
import 'package:openclaw_gateway/src/devices_client.dart';
import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/node_client.dart';
import 'package:openclaw_gateway/src/nodes_client.dart';
import 'package:openclaw_gateway/src/operator_client.dart';
import 'package:openclaw_gateway/src/protocol.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Factory for constructing the underlying WebSocket channel.
typedef GatewayChannelFactory = WebSocketChannel Function(Uri uri);

/// High-level OpenClaw gateway client.
///
/// The client owns a single WebSocket connection, performs the gateway
/// handshake, and exposes request/response helpers plus event streams.
class GatewayClient {
  GatewayClient._(
    this.options, {
    GatewayChannelFactory? channelFactory,
  }) : _channelFactory = channelFactory ?? WebSocketChannel.connect {
    _resetReadyCompleter();
    _resetChallengeCompleter();
  }

  /// Opens a gateway connection using the provided connect parameters.
  static Future<GatewayClient> connect({
    required Uri uri,
    required GatewayAuth auth,
    required GatewayClientInfo clientInfo,
    String role = gatewayDefaultRole,
    List<String>? scopes,
    List<String>? caps,
    List<String>? commands,
    Map<String, bool>? permissions,
    String? pathEnv,
    String? locale,
    String? userAgent,
    GatewayDeviceIdentity? deviceIdentity,
    GatewayDeviceTokenStore? deviceTokenStore,
    Duration connectChallengeTimeout = const Duration(seconds: 6),
    Duration connectResponseTimeout = const Duration(seconds: 12),
    Duration requestTimeout = const Duration(seconds: 15),
    bool autoReconnect = false,
    Duration reconnectInitialDelay = const Duration(milliseconds: 500),
    Duration reconnectMaxDelay = const Duration(seconds: 30),
    bool tickWatchEnabled = true,
    Duration tickWatchMinimumCheckInterval = const Duration(seconds: 1),
    int tickWatchMissedIntervals = 2,
    GatewayChannelFactory? channelFactory,
  }) async {
    final client = GatewayClient._(
      GatewayConnectOptions(
        uri: uri,
        auth: auth,
        clientInfo: clientInfo,
        role: role,
        scopes: scopes,
        caps: caps,
        commands: commands,
        permissions: permissions,
        pathEnv: pathEnv,
        locale: locale,
        userAgent: userAgent,
        deviceIdentity: deviceIdentity,
        deviceTokenStore: deviceTokenStore,
        connectChallengeTimeout: connectChallengeTimeout,
        connectResponseTimeout: connectResponseTimeout,
        requestTimeout: requestTimeout,
        autoReconnect: autoReconnect,
        reconnectInitialDelay: reconnectInitialDelay,
        reconnectMaxDelay: reconnectMaxDelay,
        tickWatchEnabled: tickWatchEnabled,
        tickWatchMinimumCheckInterval: tickWatchMinimumCheckInterval,
        tickWatchMissedIntervals: tickWatchMissedIntervals,
      ),
      channelFactory: channelFactory,
    );
    await client._connectInitially();
    return client;
  }

  /// Opens a gateway connection from a prebuilt options object.
  static Future<GatewayClient> connectWithOptions(
    GatewayConnectOptions options, {
    GatewayChannelFactory? channelFactory,
  }) async {
    final client = GatewayClient._(options, channelFactory: channelFactory);
    await client._connectInitially();
    return client;
  }

  final GatewayConnectOptions options;
  final GatewayChannelFactory _channelFactory;
  final StreamController<GatewayEventFrame> _eventsController =
      StreamController<GatewayEventFrame>.broadcast();
  final StreamController<GatewayIncomingRequestFrame> _requestsController =
      StreamController<GatewayIncomingRequestFrame>.broadcast();
  final StreamController<GatewayConnectionState> _connectionStatesController =
      StreamController<GatewayConnectionState>.broadcast();
  final Map<String, Completer<GatewayResponseFrame>> _pendingResponses =
      <String, Completer<GatewayResponseFrame>>{};

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  Completer<void> _readyCompleter = Completer<void>();
  Completer<String> _challengeCompleter = Completer<String>();
  GatewayHelloOk? _hello;
  GatewayConnectionState _connectionState = const GatewayConnectionState(
    phase: GatewayConnectionPhase.disconnected,
  );
  GatewayException? _terminalError;
  int _requestCounter = 0;
  int _idempotencyCounter = 0;
  int _connectionGeneration = 0;
  int? _disconnectGeneration;
  bool _closed = false;
  bool _everConnected = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;
  Timer? _tickWatchTimer;
  DateTime? _lastTickAt;
  GatewayPreparedConnectParams? _preparedConnectParams;

  Stream<GatewayEventFrame> get events => _eventsController.stream;

  Stream<GatewayIncomingRequestFrame> get requests =>
      _requestsController.stream;

  /// Stream of lifecycle transitions for the current connection.
  Stream<GatewayConnectionState> get connectionStates =>
      _connectionStatesController.stream;

  /// Last known lifecycle state for the current connection.
  GatewayConnectionState get connectionState => _connectionState;

  /// Completes once the client has received and parsed `hello-ok`.
  Future<void> get ready => _readyCompleter.future;

  /// Whether the client has completed the gateway handshake.
  bool get isReady => _hello != null;

  /// Parsed `hello-ok` payload from the connected gateway.
  GatewayHelloOk get hello {
    final value = _hello;
    if (value == null) {
      throw StateError('Gateway client is not connected yet.');
    }
    return value;
  }

  /// Operator-oriented helper methods on top of raw gateway RPC.
  GatewayOperatorClient get operator => GatewayOperatorClient(this);

  /// Operator-side node management helpers.
  GatewayNodesClient get nodes => GatewayNodesClient(this);

  /// Operator-side device pairing and device-token helpers.
  GatewayDevicesClient get devices => GatewayDevicesClient(this);

  /// Node-role helpers for node-host sessions.
  GatewayNodeClient get node => GatewayNodeClient(this);

  /// Filters the event stream by event name.
  Stream<GatewayEventFrame> eventsNamed(String eventName) {
    return events.where((event) => event.event == eventName);
  }

  /// Creates a process-local idempotency key suitable for chat requests.
  String createIdempotencyKey({String prefix = 'chat'}) {
    _idempotencyCounter += 1;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-$_idempotencyCounter';
  }

  /// Sends a raw gateway request and returns the response payload.
  Future<Object?> request(
    String method, {
    Object? params,
    Duration? timeout,
  }) async {
    await _waitUntilReadyForRequest();
    final response = await _dispatchRequest(
      method: method,
      params: params,
      timeout: timeout ?? options.requestTimeout,
    );
    if (!response.ok) {
      throw _responseException(response);
    }
    return response.payload;
  }

  /// Sends a raw gateway request and coerces the payload into a JSON object.
  Future<JsonMap> requestJsonMap(
    String method, {
    Object? params,
    Duration? timeout,
  }) async {
    final payload = await request(method, params: params, timeout: timeout);
    return asJsonMap(payload, context: '$method response');
  }

  /// Sends a raw gateway request and coerces the payload into a JSON array.
  Future<JsonList> requestJsonList(
    String method, {
    Object? params,
    Duration? timeout,
  }) async {
    final payload = await request(method, params: params, timeout: timeout);
    return asJsonList(payload, context: '$method response');
  }

  /// Sends a raw gateway request and ignores the response payload.
  Future<void> requestVoid(
    String method, {
    Object? params,
    Duration? timeout,
  }) async {
    await request(method, params: params, timeout: timeout);
  }

  /// Closes the gateway socket and terminates all pending work.
  Future<void> close({
    int? closeCode,
    String? reason,
  }) async {
    final message = reason ?? 'gateway client closed';
    await _shutdownTerminal(
      GatewayClosedException(message),
      closeCode: closeCode,
      reason: reason,
    );
  }

  Future<void> _connectInitially() async {
    _ensureOpenForConnect();
    _emitConnectionState(
      const GatewayConnectionState(phase: GatewayConnectionPhase.connecting),
    );
    try {
      await _openConnectionAttempt(isReconnect: false);
    } catch (error) {
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException(
              'Failed to connect to ${options.uri}.',
              cause: error,
            );
      await _shutdownTerminal(wrapped, reason: wrapped.message);
      throw wrapped;
    }
  }

  Future<void> _openConnectionAttempt({
    required bool isReconnect,
  }) async {
    _ensureNotClosed();
    _cancelTickWatch();
    _lastTickAt = null;
    _hello = null;

    if (isReconnect) {
      _resetChallengeCompleter();
    }

    final generation = ++_connectionGeneration;
    _disconnectGeneration = null;

    final channel = _channelFactory(options.uri);
    _channel = channel;
    _subscription = channel.stream.listen(
      (data) => _handleSocketMessage(data, generation),
      onError: (Object error, StackTrace stackTrace) {
        _handleSocketError(error, generation);
      },
      onDone: () => _handleSocketDone(generation),
      cancelOnError: true,
    );

    try {
      await channel.ready.timeout(
        options.connectResponseTimeout,
        onTimeout: () => throw GatewayTimeoutException(
          'Timed out establishing a WebSocket connection to ${options.uri}.',
        ),
      );

      final nonce = await _challengeCompleter.future.timeout(
        options.connectChallengeTimeout,
        onTimeout: () => throw GatewayTimeoutException(
          'Timed out waiting for connect.challenge from ${options.uri}.',
        ),
      );

      final preparedConnectParams = await prepareGatewayConnectParams(
        options: options,
        nonce: nonce,
      );
      _preparedConnectParams = preparedConnectParams;

      final response = await _dispatchRequest(
        method: 'connect',
        params: preparedConnectParams.params,
        timeout: options.connectResponseTimeout,
      );
      if (!response.ok) {
        throw _responseException(response);
      }

      final payload = asJsonMap(response.payload, context: 'connect payload');
      final hello = GatewayHelloOk.fromJson(payload);
      if (_closed || generation != _connectionGeneration) {
        return;
      }

      _hello = hello;
      _terminalError = null;
      _everConnected = true;
      _reconnectAttempt = 0;
      _lastTickAt = DateTime.now();
      await _persistHelloAuth(hello);
      _completeReady();
      _startTickWatch();
      _emitConnectionState(
        GatewayConnectionState(
          phase: GatewayConnectionPhase.connected,
          hello: hello,
        ),
      );
    } catch (error) {
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException(
              'Failed to connect to ${options.uri}.',
              cause: error,
            );
      await _clearStaleDeviceTokenIfNeeded(error: wrapped);
      _disconnectGeneration = generation;
      await _closeCurrentTransport(closeCode: 1008, reason: wrapped.message);
      _completeChallengeError(wrapped);
      if (!isReconnect) {
        _completeReadyError(wrapped);
      }
      throw wrapped;
    }
  }

  Future<void> _waitUntilReadyForRequest() async {
    _ensureNotClosed();
    if (isReady) {
      return;
    }
    if (_everConnected && !options.autoReconnect) {
      throw _terminalError ??
          GatewayClosedException('Gateway client is disconnected.');
    }
    await ready;
  }

  Future<GatewayResponseFrame> _dispatchRequest({
    required String method,
    Object? params,
    required Duration timeout,
  }) async {
    _ensureChannelReady();
    final requestId = _nextRequestId();
    final completer = Completer<GatewayResponseFrame>();
    _pendingResponses[requestId] = completer;

    try {
      final frame = withoutNulls({
        'type': 'req',
        'id': requestId,
        'method': method,
        'params': params,
      });
      _channel!.sink.add(jsonEncode(frame));
      return await completer.future.timeout(
        timeout,
        onTimeout: () => throw GatewayTimeoutException(
          'Timed out waiting for "$method" response.',
        ),
      );
    } catch (error) {
      if (error is GatewayException) {
        rethrow;
      }
      throw GatewayProtocolException(
        'Failed to send "$method" request.',
        cause: error,
      );
    } finally {
      _pendingResponses.remove(requestId);
    }
  }

  void _handleSocketMessage(Object? data, int generation) {
    if (_closed || generation != _connectionGeneration) {
      return;
    }

    try {
      final decoded = _decodeFrame(data);
      final type = readRequiredString(decoded, 'type', context: 'socket frame');

      switch (type) {
        case 'event':
          _handleEventFrame(decoded, generation);
          return;
        case 'res':
          final response = GatewayResponseFrame.fromJson(decoded);
          final waiter = _pendingResponses.remove(response.id);
          waiter?.complete(response);
          return;
        case 'req':
          final request = GatewayIncomingRequestFrame.fromJson(decoded);
          if (!_requestsController.isClosed) {
            _requestsController.add(request);
          }
          return;
        default:
          throw GatewayProtocolException(
            'Unsupported gateway frame type "$type".',
          );
      }
    } catch (error) {
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException('Invalid gateway frame.', cause: error);
      unawaited(_handleDisconnect(wrapped, generation: generation));
    }
  }

  void _handleEventFrame(JsonMap json, int generation) {
    final eventName = readRequiredString(json, 'event', context: 'event frame');
    if (eventName == gatewayConnectChallengeEvent) {
      final payload =
          asJsonMap(json['payload'], context: 'connect.challenge payload');
      final nonce = readRequiredString(
        payload,
        'nonce',
        context: 'connect.challenge payload',
      );
      if (!_challengeCompleter.isCompleted) {
        _challengeCompleter.complete(nonce);
      }
      return;
    }

    final event = GatewayEventFrame.fromJson(json);
    if (event.event == 'tick') {
      _lastTickAt = DateTime.now();
    }
    if (generation != _connectionGeneration) {
      return;
    }
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  void _handleSocketError(Object error, int generation) {
    final wrapped = error is GatewayException
        ? error
        : GatewayClosedException(
            'Gateway socket error.',
            cause: error,
          );
    unawaited(_handleDisconnect(wrapped, generation: generation));
  }

  void _handleSocketDone(int generation) {
    final channel = _channel;
    final closeCode = channel?.closeCode;
    final closeReason = channel?.closeReason;
    final error = _terminalError ??
        GatewayClosedException(
          closeReason == null || closeReason.isEmpty
              ? 'Gateway socket closed.'
              : 'Gateway socket closed: $closeReason',
        );
    unawaited(
      _handleDisconnect(
        error,
        generation: generation,
        closeCode: closeCode,
        reason: closeReason,
      ),
    );
  }

  Future<void> _handleDisconnect(
    GatewayException error, {
    required int generation,
    int? closeCode,
    String? reason,
  }) async {
    if (_closed || generation != _connectionGeneration) {
      return;
    }
    if (_disconnectGeneration == generation) {
      return;
    }
    _disconnectGeneration = generation;
    final shouldReconnect = options.autoReconnect && _everConnected;
    if (shouldReconnect && _readyCompleter.isCompleted) {
      _resetReadyCompleter();
    }
    _terminalError = error;
    _hello = null;
    _lastTickAt = null;
    _cancelTickWatch();
    _failPendingResponses(error);
    await _clearStaleDeviceTokenIfNeeded(
      error: error,
      closeCode: closeCode,
      reason: reason,
    );
    await _closeCurrentTransport(closeCode: closeCode, reason: reason);

    if (shouldReconnect) {
      _scheduleReconnect(error);
      return;
    }

    _emitConnectionState(
      GatewayConnectionState(
        phase: GatewayConnectionPhase.disconnected,
        error: error,
      ),
    );
  }

  void _scheduleReconnect(GatewayException error) {
    if (_closed || _reconnectTimer != null) {
      return;
    }

    _reconnectAttempt += 1;
    final delay = _nextReconnectDelay(_reconnectAttempt);
    _emitConnectionState(
      GatewayConnectionState(
        phase: GatewayConnectionPhase.reconnecting,
        attempt: _reconnectAttempt,
        error: error,
      ),
    );
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_runReconnectAttempt());
    });
  }

  Duration _nextReconnectDelay(int attempt) {
    final initialMs = math.max(1, options.reconnectInitialDelay.inMilliseconds);
    final maxMs = math.max(initialMs, options.reconnectMaxDelay.inMilliseconds);
    final multiplier = math.max(0, attempt - 1);
    final computedMs = initialMs * (1 << math.min(multiplier, 30));
    return Duration(milliseconds: math.min(computedMs, maxMs));
  }

  Future<void> _runReconnectAttempt() async {
    if (_closed) {
      return;
    }

    try {
      await _openConnectionAttempt(isReconnect: true);
    } catch (error) {
      if (_closed) {
        return;
      }
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException(
              'Failed to reconnect to ${options.uri}.',
              cause: error,
            );
      _scheduleReconnect(wrapped);
    }
  }

  void _startTickWatch() {
    _cancelTickWatch();
    if (!options.tickWatchEnabled) {
      return;
    }
    final hello = _hello;
    if (hello == null) {
      return;
    }

    final tickIntervalMs = hello.policy.tickIntervalMs;
    final checkIntervalMs = math.max(
      tickIntervalMs,
      options.tickWatchMinimumCheckInterval.inMilliseconds,
    );
    final thresholdMs =
        tickIntervalMs * math.max(1, options.tickWatchMissedIntervals);

    _tickWatchTimer = Timer.periodic(
      Duration(milliseconds: checkIntervalMs),
      (_) {
        if (_closed || !isReady) {
          return;
        }
        final lastTickAt = _lastTickAt;
        if (lastTickAt == null) {
          return;
        }
        final gapMs = DateTime.now().difference(lastTickAt).inMilliseconds;
        if (gapMs > thresholdMs) {
          unawaited(_handleDisconnect(
            GatewayClosedException('Gateway tick timeout.'),
            generation: _connectionGeneration,
            closeCode: 4000,
            reason: 'tick timeout',
          ));
        }
      },
    );
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _cancelTickWatch() {
    _tickWatchTimer?.cancel();
    _tickWatchTimer = null;
  }

  Future<void> _closeCurrentTransport({
    int? closeCode,
    String? reason,
  }) async {
    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();

    final channel = _channel;
    _channel = null;
    if (channel != null) {
      try {
        await channel.sink.close(closeCode, reason);
      } catch (_) {
        // Ignore close failures while tearing down the transport.
      }
    }
  }

  JsonMap _decodeFrame(Object? data) {
    final String raw;
    if (data is String) {
      raw = data;
    } else if (data is List<int>) {
      raw = utf8.decode(data);
    } else {
      throw GatewayProtocolException(
        'Unsupported gateway socket payload type ${data.runtimeType}.',
      );
    }

    final decoded = jsonDecode(raw);
    return asJsonMap(decoded, context: 'socket frame');
  }

  GatewayResponseException _responseException(GatewayResponseFrame response) {
    final error = response.error;
    if (error == null) {
      return GatewayResponseException(
        code: 'gateway_error',
        message: 'Gateway request failed without an error payload.',
      );
    }
    return GatewayResponseException(
      code: error.code,
      message: error.message,
      details: error.details,
      retryable: error.retryable,
      retryAfterMs: error.retryAfterMs,
    );
  }

  String _nextRequestId() {
    _requestCounter += 1;
    return 'req-${DateTime.now().microsecondsSinceEpoch}-$_requestCounter';
  }

  void _ensureOpenForConnect() {
    if (_closed) {
      throw GatewayClosedException('Gateway client is already closed.');
    }
    if (_channel != null) {
      throw StateError('Gateway client is already connected.');
    }
  }

  void _ensureNotClosed() {
    if (_closed) {
      throw _terminalError ??
          GatewayClosedException('Gateway client is closed.');
    }
  }

  void _ensureChannelReady() {
    _ensureNotClosed();
    if (_channel == null) {
      throw GatewayClosedException('Gateway channel is not connected.');
    }
  }

  void _resetReadyCompleter() {
    _readyCompleter = Completer<void>();
    unawaited(_readyCompleter.future.catchError((Object _) => null));
  }

  void _resetChallengeCompleter() {
    _challengeCompleter = Completer<String>();
    unawaited(_challengeCompleter.future.catchError((Object _) => ''));
  }

  void _completeReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  void _completeReadyError(GatewayException error) {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error);
    }
  }

  void _completeChallengeError(GatewayException error) {
    if (!_challengeCompleter.isCompleted) {
      _challengeCompleter.completeError(error);
    }
  }

  void _failPendingResponses(GatewayException error) {
    for (final completer in _pendingResponses.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingResponses.clear();
  }

  void _emitConnectionState(GatewayConnectionState state) {
    _connectionState = state;
    if (!_connectionStatesController.isClosed) {
      _connectionStatesController.add(state);
    }
  }

  Future<void> _shutdownTerminal(
    GatewayException error, {
    int? closeCode,
    String? reason,
  }) async {
    if (_closed) {
      return;
    }
    _closed = true;
    _terminalError = error;
    _cancelReconnectTimer();
    _cancelTickWatch();
    _hello = null;
    _lastTickAt = null;

    _completeChallengeError(error);
    _completeReadyError(error);
    _failPendingResponses(error);

    await _closeCurrentTransport(closeCode: closeCode, reason: reason);

    _emitConnectionState(
      GatewayConnectionState(
        phase: GatewayConnectionPhase.closed,
        error: error,
      ),
    );
    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
    if (!_requestsController.isClosed) {
      await _requestsController.close();
    }
    if (!_connectionStatesController.isClosed) {
      await _connectionStatesController.close();
    }
  }

  Future<void> _persistHelloAuth(GatewayHelloOk hello) async {
    final auth = hello.auth;
    final deviceIdentity = options.deviceIdentity;
    final deviceTokenStore = options.deviceTokenStore;
    if (auth == null || deviceIdentity == null || deviceTokenStore == null) {
      return;
    }

    await deviceTokenStore.write(
      GatewayStoredDeviceToken(
        deviceId: deviceIdentity.deviceId,
        role: auth.role,
        token: auth.deviceToken,
        scopes: auth.scopes,
        issuedAtMs: auth.issuedAtMs,
      ),
    );
  }

  Future<void> _clearStaleDeviceTokenIfNeeded({
    GatewayException? error,
    int? closeCode,
    String? reason,
  }) async {
    final preparedConnectParams = _preparedConnectParams;
    final deviceIdentity = options.deviceIdentity;
    final deviceTokenStore = options.deviceTokenStore;
    if (preparedConnectParams == null ||
        !preparedConnectParams.usesDeviceTokenOnly ||
        deviceIdentity == null ||
        deviceTokenStore == null) {
      return;
    }

    final detailCode = error is GatewayResponseException
        ? readGatewayConnectErrorDetailCode(error.details)
        : null;
    final normalizedReason = reason?.toLowerCase();
    final normalizedMessage = error?.message.toLowerCase();
    final looksLikeDeviceTokenMismatch =
        detailCode == GatewayConnectErrorDetailCodes.authDeviceTokenMismatch ||
            (closeCode == 1008 &&
                normalizedReason != null &&
                normalizedReason.contains('device token mismatch')) ||
            (normalizedMessage != null &&
                normalizedMessage.contains('device token mismatch'));
    if (!looksLikeDeviceTokenMismatch) {
      return;
    }

    await deviceTokenStore.delete(
      deviceId: deviceIdentity.deviceId,
      role: options.role,
    );
  }
}
