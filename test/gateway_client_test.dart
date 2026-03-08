import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('GatewayClient', () {
    test('connects through connect.challenge and parses hello-ok', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel, connId: 'conn-1'));

      final client = await _connectClient(channel);

      expect(client.isReady, isTrue);
      expect(client.hello.server.connId, 'conn-1');
      expect(client.hello.features.methods, contains('health'));

      await client.close();
    });

    test('routes requests, events, and incoming request frames', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));

      final client = await _connectClient(channel);

      final healthFuture = client.operator.health();
      final healthRequest = await channel.nextClientJson();
      expect(healthRequest['method'], 'health');
      channel.sendJson({
        'type': 'res',
        'id': healthRequest['id'],
        'ok': true,
        'payload': {'status': 'ok'},
      });

      await expectLater(healthFuture, completion({'status': 'ok'}));

      final eventFuture = client.eventsNamed('chat').first;
      channel.sendJson({
        'type': 'event',
        'event': 'chat',
        'payload': {'runId': 'run-1'},
        'seq': 1,
      });
      final event = await eventFuture;
      expect(event.event, 'chat');
      expect(event.seq, 1);
      expect(event.payload, {'runId': 'run-1'});

      final incomingRequestFuture = client.requests.first;
      channel.sendJson({
        'type': 'req',
        'id': 'server-req-1',
        'method': 'node.invoke.request',
        'params': {'name': 'ping'},
      });
      final incomingRequest = await incomingRequestFuture;
      expect(incomingRequest.id, 'server-req-1');
      expect(incomingRequest.method, 'node.invoke.request');

      await client.close();
    });

    test('throws GatewayResponseException for request errors', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));

      final client = await _connectClient(channel);

      final healthFuture = client.operator.health();
      final healthRequest = await channel.nextClientJson();
      channel.sendJson({
        'type': 'res',
        'id': healthRequest['id'],
        'ok': false,
        'error': {
          'code': 'invalid_request',
          'message': 'nope',
          'retryable': false,
        },
      });

      await expectLater(
        healthFuture,
        throwsA(
          isA<GatewayResponseException>()
              .having((error) => error.code, 'code', 'invalid_request')
              .having((error) => error.message, 'message', 'nope'),
        ),
      );

      await client.close();
    });

    test('fails when the websocket readiness future errors', () async {
      final readyCompleter = Completer<void>();
      final channel = FakeWebSocketChannel(readyCompleter: readyCompleter);

      final connectFuture = _connectClient(channel);
      readyCompleter.completeError(StateError('socket failed'));

      await expectLater(
          connectFuture, throwsA(isA<GatewayProtocolException>()));
    });

    test('times out waiting for connect.challenge', () async {
      final channel = FakeWebSocketChannel();

      await expectLater(
        _connectClient(
          channel,
          connectChallengeTimeout: const Duration(milliseconds: 20),
        ),
        throwsA(isA<GatewayTimeoutException>()),
      );
    });

    test('auto reconnects after socket close and future requests wait for it',
        () async {
      final first = FakeWebSocketChannel();
      final second = FakeWebSocketChannel();
      final channels = Queue<FakeWebSocketChannel>.from([first, second]);
      unawaited(_completeSuccessfulHandshake(first, connId: 'conn-1'));

      final client = await _connectClientWithFactory(
        channelFactory: (_) {
          expect(channels, isNotEmpty);
          return channels.removeFirst();
        },
        autoReconnect: true,
        reconnectInitialDelay: Duration.zero,
        reconnectMaxDelay: Duration.zero,
      );

      final phases = <GatewayConnectionPhase>[];
      final sub = client.connectionStates.listen((state) {
        phases.add(state.phase);
      });

      await first.closeFromServer(1006, 'closed by test');

      final healthFuture = client.operator.health();
      second.sendJson({
        'type': 'event',
        'event': 'connect.challenge',
        'payload': {
          'nonce': 'reconnect-nonce',
          'protocol': 3,
        },
      });
      final reconnectRequest = await second.nextClientJson();
      expect(reconnectRequest['method'], 'connect');
      second.sendJson({
        'type': 'res',
        'id': reconnectRequest['id'],
        'ok': true,
        'payload': _helloPayload(connId: 'conn-2', tickIntervalMs: 1000),
      });

      final healthRequest = await second.nextClientJson();
      expect(healthRequest['method'], 'health');
      second.sendJson({
        'type': 'res',
        'id': healthRequest['id'],
        'ok': true,
        'payload': {'status': 'ok'},
      });

      await expectLater(healthFuture, completion({'status': 'ok'}));
      await _eventually(
        () => client.isReady && client.hello.server.connId == 'conn-2',
      );
      expect(phases, contains(GatewayConnectionPhase.reconnecting));

      await sub.cancel();
      await client.close();
    });

    test('reconnects when ticks stop arriving', () async {
      final first = FakeWebSocketChannel();
      final second = FakeWebSocketChannel();
      final channels = Queue<FakeWebSocketChannel>.from([first, second]);
      unawaited(
        _completeSuccessfulHandshake(first,
            connId: 'conn-1', tickIntervalMs: 20),
      );

      final client = await _connectClientWithFactory(
        channelFactory: (_) {
          expect(channels, isNotEmpty);
          return channels.removeFirst();
        },
        autoReconnect: true,
        reconnectInitialDelay: Duration.zero,
        reconnectMaxDelay: Duration.zero,
        tickWatchMinimumCheckInterval: const Duration(milliseconds: 5),
      );

      second.sendJson({
        'type': 'event',
        'event': 'connect.challenge',
        'payload': {
          'nonce': 'reconnect-nonce',
          'protocol': 3,
        },
      });
      final reconnectRequest =
          await second.nextClientJson().timeout(const Duration(seconds: 1));
      expect(reconnectRequest['method'], 'connect');
      second.sendJson({
        'type': 'res',
        'id': reconnectRequest['id'],
        'ok': true,
        'payload': _helloPayload(connId: 'conn-2', tickIntervalMs: 20),
      });

      await _eventually(
        () => client.isReady && client.hello.server.connId == 'conn-2',
        timeout: const Duration(seconds: 1),
      );

      await client.close();
    });
  });
}

Future<GatewayClient> _connectClient(
  FakeWebSocketChannel channel, {
  Duration connectChallengeTimeout = const Duration(milliseconds: 100),
  Duration connectResponseTimeout = const Duration(milliseconds: 100),
  Duration requestTimeout = const Duration(milliseconds: 100),
  bool autoReconnect = false,
  Duration reconnectInitialDelay = const Duration(milliseconds: 1),
  Duration reconnectMaxDelay = const Duration(milliseconds: 10),
  Duration tickWatchMinimumCheckInterval = const Duration(milliseconds: 10),
}) {
  return _connectClientWithFactory(
    channelFactory: (_) => channel,
    connectChallengeTimeout: connectChallengeTimeout,
    connectResponseTimeout: connectResponseTimeout,
    requestTimeout: requestTimeout,
    autoReconnect: autoReconnect,
    reconnectInitialDelay: reconnectInitialDelay,
    reconnectMaxDelay: reconnectMaxDelay,
    tickWatchMinimumCheckInterval: tickWatchMinimumCheckInterval,
  );
}

Future<GatewayClient> _connectClientWithFactory({
  required GatewayChannelFactory channelFactory,
  Duration connectChallengeTimeout = const Duration(milliseconds: 100),
  Duration connectResponseTimeout = const Duration(milliseconds: 100),
  Duration requestTimeout = const Duration(milliseconds: 100),
  bool autoReconnect = false,
  Duration reconnectInitialDelay = const Duration(milliseconds: 1),
  Duration reconnectMaxDelay = const Duration(milliseconds: 10),
  Duration tickWatchMinimumCheckInterval = const Duration(milliseconds: 10),
}) {
  return GatewayClient.connect(
    uri: Uri.parse('ws://gateway.test'),
    auth: const GatewayAuth.token('shared-token'),
    clientInfo: const GatewayClientInfo(
      id: 'gateway-client',
      version: '0.1.0',
      platform: 'dart',
      mode: 'backend',
      displayName: 'OpenClaw Dart Test',
    ),
    connectChallengeTimeout: connectChallengeTimeout,
    connectResponseTimeout: connectResponseTimeout,
    requestTimeout: requestTimeout,
    autoReconnect: autoReconnect,
    reconnectInitialDelay: reconnectInitialDelay,
    reconnectMaxDelay: reconnectMaxDelay,
    tickWatchMinimumCheckInterval: tickWatchMinimumCheckInterval,
    channelFactory: channelFactory,
  );
}

Future<void> _completeSuccessfulHandshake(
  FakeWebSocketChannel channel, {
  String connId = 'conn-test',
  int tickIntervalMs = 30000,
}) async {
  await Future<void>.delayed(Duration.zero);
  channel.sendJson({
    'type': 'event',
    'event': 'connect.challenge',
    'payload': {
      'nonce': 'nonce-1',
      'ts': 1,
    },
  });

  final connectRequest = await channel.nextClientJson();
  expect(connectRequest['type'], 'req');
  expect(connectRequest['method'], 'connect');

  final params = Map<String, Object?>.from(connectRequest['params'] as Map);
  expect(params['minProtocol'], gatewayProtocolVersion);
  expect(params['role'], 'operator');

  channel.sendJson({
    'type': 'res',
    'id': connectRequest['id'],
    'ok': true,
    'payload': _helloPayload(connId: connId, tickIntervalMs: tickIntervalMs),
  });
}

Map<String, Object?> _helloPayload({
  required String connId,
  int tickIntervalMs = 30000,
}) {
  return {
    'type': 'hello-ok',
    'protocol': gatewayProtocolVersion,
    'server': {
      'version': '2026.3.7',
      'connId': connId,
    },
    'features': {
      'methods': ['health', 'chat.send'],
      'events': ['chat', 'tick', 'node.invoke.request'],
    },
    'snapshot': {
      'health': {'status': 'ok'},
    },
    'policy': {
      'maxPayload': 1000,
      'maxBufferedBytes': 2000,
      'tickIntervalMs': tickIntervalMs,
    },
  };
}

Future<void> _eventually(
  bool Function() predicate, {
  Duration timeout = const Duration(milliseconds: 500),
  Duration interval = const Duration(milliseconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (predicate()) {
      return;
    }
    await Future<void>.delayed(interval);
  }
  expect(predicate(), isTrue, reason: 'Condition did not become true in time.');
}

class FakeWebSocketChannel extends StreamChannelMixin<Object?>
    implements WebSocketChannel {
  FakeWebSocketChannel({
    Completer<void>? readyCompleter,
  }) : _readyCompleter = readyCompleter ?? (Completer<void>()..complete()) {
    _outgoing.stream.listen(
      _handleOutgoingMessage,
      onDone: _handleOutgoingDone,
    );
  }

  final StreamController<Object?> _incoming = StreamController<Object?>();
  final StreamController<Object?> _outgoing = StreamController<Object?>();
  final Completer<void> _readyCompleter;
  final ListQueue<Object?> _bufferedClientMessages = ListQueue<Object?>();
  final ListQueue<Completer<Object?>> _clientMessageWaiters =
      ListQueue<Completer<Object?>>();
  bool _closed = false;

  late final WebSocketSink _sink = FakeWebSocketSink(
    onAdd: _outgoing.add,
    onAddError: _outgoing.addError,
    onAddStream: _outgoing.addStream,
    onClose: _close,
    done: _outgoing.done,
  );

  @override
  int? closeCode;

  @override
  String? closeReason;

  @override
  String? protocol;

  @override
  Future<void> get ready => _readyCompleter.future;

  @override
  WebSocketSink get sink => _sink;

  @override
  Stream<Object?> get stream => _incoming.stream;

  Future<JsonMap> nextClientJson() async {
    final raw = await _nextClientMessage();
    expect(raw, isA<String>());
    return Map<String, Object?>.from(jsonDecode(raw as String) as Map);
  }

  void sendJson(Object value) {
    _incoming.add(jsonEncode(value));
  }

  Future<void> closeFromServer([int? code, String? reason]) {
    return _close(code, reason);
  }

  Future<Object?> _nextClientMessage() {
    if (_bufferedClientMessages.isNotEmpty) {
      return Future<Object?>.value(_bufferedClientMessages.removeFirst());
    }
    final completer = Completer<Object?>();
    _clientMessageWaiters.addLast(completer);
    return completer.future;
  }

  void _handleOutgoingMessage(Object? event) {
    if (_clientMessageWaiters.isNotEmpty) {
      _clientMessageWaiters.removeFirst().complete(event);
      return;
    }
    _bufferedClientMessages.addLast(event);
  }

  void _handleOutgoingDone() {
    final error = StateError('Fake WebSocket channel closed.');
    while (_clientMessageWaiters.isNotEmpty) {
      _clientMessageWaiters.removeFirst().completeError(error);
    }
  }

  Future<void> _close([int? code, String? reason]) async {
    if (_closed) {
      return;
    }
    _closed = true;
    closeCode = code;
    closeReason = reason;
    await _outgoing.close();
    await _incoming.close();
  }
}

class FakeWebSocketSink implements WebSocketSink {
  FakeWebSocketSink({
    required this.onAdd,
    required this.onAddError,
    required this.onAddStream,
    required this.onClose,
    required this.done,
  });

  final void Function(Object?) onAdd;
  final void Function(Object, [StackTrace?]) onAddError;
  final Future<void> Function(Stream<Object?>) onAddStream;
  final Future<void> Function([int?, String?]) onClose;

  @override
  final Future<void> done;

  @override
  void add(Object? event) {
    onAdd(event);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    onAddError(error, stackTrace);
  }

  @override
  Future<void> addStream(Stream<Object?> stream) {
    return onAddStream(stream);
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) {
    return onClose(closeCode, closeReason);
  }
}
