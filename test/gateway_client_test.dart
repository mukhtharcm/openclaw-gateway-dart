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
  });
}

Future<GatewayClient> _connectClient(
  FakeWebSocketChannel channel, {
  Duration connectChallengeTimeout = const Duration(milliseconds: 100),
  Duration connectResponseTimeout = const Duration(milliseconds: 100),
  Duration requestTimeout = const Duration(milliseconds: 100),
}) {
  return GatewayClient.connect(
    uri: Uri.parse('ws://gateway.test'),
    auth: const GatewayAuth.token('shared-token'),
    clientInfo: const GatewayClientInfo(
      id: 'openclaw-dart-test',
      version: '0.1.0',
      platform: 'dart',
      mode: 'automation',
      displayName: 'OpenClaw Dart Test',
    ),
    connectChallengeTimeout: connectChallengeTimeout,
    connectResponseTimeout: connectResponseTimeout,
    requestTimeout: requestTimeout,
    channelFactory: (_) => channel,
  );
}

Future<void> _completeSuccessfulHandshake(
  FakeWebSocketChannel channel, {
  String connId = 'conn-test',
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
    'payload': _helloPayload(connId: connId),
  });
}

Map<String, Object?> _helloPayload({
  required String connId,
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
      'tickIntervalMs': 30000,
    },
  };
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
