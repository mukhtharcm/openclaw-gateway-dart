import 'dart:async';
import 'dart:convert';

import 'package:openclaw_gateway/src/auth.dart';
import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
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
    unawaited(_readyCompleter.future.catchError((Object _) => null));
    unawaited(_challengeCompleter.future.catchError((Object _) => ''));
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
    String? locale,
    String? userAgent,
    Duration connectChallengeTimeout = const Duration(seconds: 6),
    Duration connectResponseTimeout = const Duration(seconds: 12),
    Duration requestTimeout = const Duration(seconds: 15),
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
        locale: locale,
        userAgent: userAgent,
        connectChallengeTimeout: connectChallengeTimeout,
        connectResponseTimeout: connectResponseTimeout,
        requestTimeout: requestTimeout,
      ),
      channelFactory: channelFactory,
    );
    await client._connect();
    return client;
  }

  /// Opens a gateway connection from a prebuilt options object.
  static Future<GatewayClient> connectWithOptions(
    GatewayConnectOptions options, {
    GatewayChannelFactory? channelFactory,
  }) async {
    final client = GatewayClient._(options, channelFactory: channelFactory);
    await client._connect();
    return client;
  }

  final GatewayConnectOptions options;
  final GatewayChannelFactory _channelFactory;
  final StreamController<GatewayEventFrame> _eventsController =
      StreamController<GatewayEventFrame>.broadcast();
  final StreamController<GatewayIncomingRequestFrame> _requestsController =
      StreamController<GatewayIncomingRequestFrame>.broadcast();
  final Map<String, Completer<GatewayResponseFrame>> _pendingResponses =
      <String, Completer<GatewayResponseFrame>>{};

  WebSocketChannel? _channel;
  StreamSubscription<Object?>? _subscription;
  final Completer<void> _readyCompleter = Completer<void>();
  final Completer<String> _challengeCompleter = Completer<String>();
  GatewayHelloOk? _hello;
  GatewayException? _terminalError;
  int _requestCounter = 0;
  int _idempotencyCounter = 0;
  bool _closed = false;

  Stream<GatewayEventFrame> get events => _eventsController.stream;

  Stream<GatewayIncomingRequestFrame> get requests =>
      _requestsController.stream;

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
    await ready;
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
  }) {
    final message = reason ?? 'gateway client closed';
    return _shutdown(
      GatewayClosedException(message),
      closeCode: closeCode,
      reason: reason,
    );
  }

  Future<void> _connect() async {
    _ensureOpenForConnect();
    try {
      _channel = _channelFactory(options.uri);
      _subscription = _channel!.stream.listen(
        _handleSocketMessage,
        onError: _handleSocketError,
        onDone: _handleSocketDone,
        cancelOnError: true,
      );
      await _channel!.ready.timeout(
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

      final response = await _dispatchRequest(
        method: 'connect',
        params: _buildConnectParams(nonce),
        timeout: options.connectResponseTimeout,
      );
      if (!response.ok) {
        throw _responseException(response);
      }

      final payload = asJsonMap(response.payload, context: 'connect payload');
      _hello = GatewayHelloOk.fromJson(payload);
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }
    } catch (error) {
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException(
              'Failed to connect to ${options.uri}.',
              cause: error,
            );
      await _shutdown(wrapped, reason: wrapped.message);
      throw wrapped;
    }
  }

  JsonMap _buildConnectParams(String nonce) {
    final params = options.toConnectParams();
    if (nonce.isEmpty) {
      throw GatewayProtocolException('Gateway connect nonce was empty.');
    }
    return params;
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

  void _handleSocketMessage(Object? data) {
    try {
      final decoded = _decodeFrame(data);
      final type = readRequiredString(decoded, 'type', context: 'socket frame');

      switch (type) {
        case 'event':
          _handleEventFrame(decoded);
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
              'Unsupported gateway frame type "$type".');
      }
    } catch (error) {
      final wrapped = error is GatewayException
          ? error
          : GatewayProtocolException('Invalid gateway frame.', cause: error);
      unawaited(_shutdown(wrapped, reason: wrapped.message));
    }
  }

  void _handleEventFrame(JsonMap json) {
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
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  void _handleSocketError(Object error, [StackTrace? stackTrace]) {
    final wrapped = error is GatewayException
        ? error
        : GatewayClosedException(
            'Gateway socket error.',
            cause: error,
          );
    unawaited(_shutdown(wrapped, reason: wrapped.message));
  }

  void _handleSocketDone() {
    final error =
        _terminalError ?? GatewayClosedException('Gateway socket closed.');
    unawaited(_shutdown(error, reason: error.message));
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

  void _ensureChannelReady() {
    if (_closed) {
      throw _terminalError ??
          GatewayClosedException('Gateway client is closed.');
    }
    if (_channel == null) {
      throw StateError('Gateway channel is not connected.');
    }
  }

  Future<void> _shutdown(
    GatewayException error, {
    int? closeCode,
    String? reason,
  }) async {
    if (_closed) {
      return;
    }
    _closed = true;
    _terminalError = error;

    if (!_challengeCompleter.isCompleted) {
      _challengeCompleter.completeError(error);
    }
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.completeError(error);
    }
    for (final completer in _pendingResponses.values) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }
    _pendingResponses.clear();

    await _subscription?.cancel();
    _subscription = null;

    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await channel.sink.close(closeCode, reason);
    }

    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
    if (!_requestsController.isClosed) {
      await _requestsController.close();
    }
  }
}
