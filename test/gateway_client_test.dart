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

    test('provides typed chat events and preserves explicit null patch fields',
        () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));

      final client = await _connectClient(channel);

      final chatEventFuture = client.operator.chatEvents.first;
      channel.sendJson({
        'type': 'event',
        'event': 'chat',
        'payload': {
          'runId': 'run-1',
          'sessionKey': 'main',
          'seq': 2,
          'state': 'final',
          'message': {'role': 'assistant', 'content': 'done'},
        },
      });
      final chatEvent = await chatEventFuture;
      expect(chatEvent.runId, 'run-1');
      expect(chatEvent.isTerminal, isTrue);

      final patchFuture = client.operator.sessionsPatch(
        key: 'main',
        label: null,
        execNode: 'node-1',
      );
      final patchRequest = await channel.nextClientJson();
      expect(patchRequest['method'], 'sessions.patch');
      expect(
        patchRequest['params'],
        containsPair('label', isNull),
      );
      expect(
        patchRequest['params'],
        containsPair('execNode', 'node-1'),
      );
      channel.sendJson({
        'type': 'res',
        'id': patchRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });
      await expectLater(patchFuture, completion({'ok': true}));

      await client.close();
    });

    test('parses node list, describe, and invoke results', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));

      final client = await _connectClient(channel);

      final listFuture = client.nodes.list();
      final listRequest = await channel.nextClientJson();
      expect(listRequest['method'], 'node.list');
      channel.sendJson({
        'type': 'res',
        'id': listRequest['id'],
        'ok': true,
        'payload': {
          'ts': 1,
          'nodes': [
            {
              'nodeId': 'node-1',
              'displayName': 'Node One',
              'platform': 'android',
              'caps': ['camera'],
              'commands': ['ping'],
              'paired': true,
              'connected': true,
            },
          ],
        },
      });
      final nodes = await listFuture;
      expect(nodes, hasLength(1));
      expect(nodes.first.nodeId, 'node-1');

      final describeFuture = client.nodes.describe(nodeId: 'node-1');
      final describeRequest = await channel.nextClientJson();
      expect(describeRequest['method'], 'node.describe');
      channel.sendJson({
        'type': 'res',
        'id': describeRequest['id'],
        'ok': true,
        'payload': {
          'nodeId': 'node-1',
          'displayName': 'Node One',
          'platform': 'android',
          'caps': ['camera'],
          'commands': ['ping'],
          'paired': true,
          'connected': true,
        },
      });
      final describedNode = await describeFuture;
      expect(describedNode.displayName, 'Node One');

      final invokeFuture = client.nodes.invoke(
        nodeId: 'node-1',
        command: 'ping',
      );
      final invokeRequest = await channel.nextClientJson();
      expect(invokeRequest['method'], 'node.invoke');
      final invokeParams =
          Map<String, Object?>.from(invokeRequest['params'] as Map);
      expect(invokeParams['idempotencyKey'], isA<String>());
      channel.sendJson({
        'type': 'res',
        'id': invokeRequest['id'],
        'ok': true,
        'payload': {
          'ok': true,
          'nodeId': 'node-1',
          'command': 'ping',
          'payload': {'pong': true},
        },
      });
      final invokeResult = await invokeFuture;
      expect(invokeResult.nodeId, 'node-1');
      expect(invokeResult.payload, {'pong': true});

      await client.close();
    });

    test('handles typed node invoke requests and node-role responses',
        () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));

      final client = await _connectClient(channel);

      final invokeRequestFuture = client.node.invokeRequests.first;
      channel.sendJson({
        'type': 'event',
        'event': 'node.invoke.request',
        'payload': {
          'id': 'invoke-1',
          'nodeId': 'node-1',
          'command': 'camera.capture',
          'paramsJSON': '{"quality":"high"}',
          'timeoutMs': 5000,
          'idempotencyKey': 'idem-1',
        },
      });
      final invokeRequest = await invokeRequestFuture;
      expect(invokeRequest.command, 'camera.capture');
      expect(invokeRequest.params, {'quality': 'high'});

      final invokeResultFuture = client.node.sendInvokeResult(
        id: 'invoke-1',
        nodeId: 'node-1',
        ok: true,
        payload: {'ok': true},
      );
      final invokeResultRequest = await channel.nextClientJson();
      expect(invokeResultRequest['method'], 'node.invoke.result');
      channel.sendJson({
        'type': 'res',
        'id': invokeResultRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });
      await expectLater(invokeResultFuture, completion({'ok': true}));

      final refreshFuture = client.node.refreshCanvasCapability();
      final refreshRequest = await channel.nextClientJson();
      expect(refreshRequest['method'], 'node.canvas.capability.refresh');
      channel.sendJson({
        'type': 'res',
        'id': refreshRequest['id'],
        'ok': true,
        'payload': {
          'canvasCapability': 'cap-1',
          'canvasCapabilityExpiresAtMs': 1234,
          'canvasHostUrl': 'https://canvas.example/cap-1',
        },
      });
      final refreshResult = await refreshFuture;
      expect(refreshResult.canvasCapability, 'cap-1');

      final eventFuture = client.node.sendEvent(
        event: 'system-presence',
        payload: {'awake': true},
      );
      final eventRequest = await channel.nextClientJson();
      expect(eventRequest['method'], 'node.event');
      channel.sendJson({
        'type': 'res',
        'id': eventRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });
      await expectLater(eventFuture, completion({'ok': true}));

      await client.close();
    });

    test('node capability registry snapshots connect metadata', () async {
      final registry = GatewayNodeCapabilityRegistry(
        capabilities: const [
          GatewayNodeCapability(name: 'camera'),
          GatewayNodeCapability(name: 'camera'),
          GatewayNodeCapability(
            name: 'location',
            isEnabled: _disabledAvailability,
          ),
        ],
        commands: const [
          GatewayNodeCommand(
            name: 'camera.list',
            capabilities: ['camera'],
            handler: _noopNodeCommand,
          ),
          GatewayNodeCommand(
            name: 'location.get',
            capabilities: ['location'],
            isAvailable: _disabledAvailability,
            handler: _noopNodeCommand,
          ),
        ],
        permissionsResolver: () async => const {
          'notifications': false,
          'camera': true,
        },
      );

      final snapshot = await registry.snapshot();
      expect(snapshot.capabilities, ['camera']);
      expect(snapshot.commands, ['camera.list']);
      expect(snapshot.permissions, {'camera': true, 'notifications': false});

      final options = await registry.buildConnectOptions(
        uri: Uri.parse('ws://gateway.test'),
        auth: const GatewayAuth.token('shared-token'),
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.nodeHost,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.node,
        ),
      );
      expect(options.role, gatewayNodeRole);
      expect(options.commands, ['camera.list']);
    });

    test('node capability registry dispatches invoke requests', () async {
      final channel = FakeWebSocketChannel();
      unawaited(
        _completeSuccessfulHandshake(
          channel,
          expectedRole: gatewayNodeRole,
        ),
      );

      final client = await _connectClient(
        channel,
        role: gatewayNodeRole,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.nodeHost,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.node,
        ),
      );
      final registry = GatewayNodeCapabilityRegistry(
        commands: [
          GatewayNodeCommand(
            name: 'echo',
            handler: (context) async => GatewayNodeCommandResult.ok(
              payload: {'echo': context.params},
            ),
          ),
        ],
      );
      final subscription = registry.attach(client);

      channel.sendJson({
        'type': 'event',
        'event': 'node.invoke.request',
        'payload': {
          'id': 'invoke-echo',
          'nodeId': 'node-1',
          'command': 'echo',
          'params': {'hello': 'world'},
        },
      });
      final invokeResultRequest = await channel.nextClientJson();
      expect(invokeResultRequest['method'], 'node.invoke.result');
      expect(invokeResultRequest['params'], {
        'id': 'invoke-echo',
        'nodeId': 'node-1',
        'ok': true,
        'payload': {
          'echo': {'hello': 'world'}
        },
      });
      channel.sendJson({
        'type': 'res',
        'id': invokeResultRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });

      channel.sendJson({
        'type': 'event',
        'event': 'node.invoke.request',
        'payload': {
          'id': 'invoke-fail',
          'nodeId': 'node-1',
          'command': 'explode',
          'params': {'boom': true},
        },
      });
      final unsupportedResultRequest = await channel.nextClientJson();
      expect(unsupportedResultRequest['method'], 'node.invoke.result');
      expect(
        unsupportedResultRequest['params'],
        containsPair(
          'error',
          containsPair('code', 'unsupported_command'),
        ),
      );
      channel.sendJson({
        'type': 'res',
        'id': unsupportedResultRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });

      await subscription.cancel();
      await client.close();
    });

    test('node capability registry turns handler exceptions into errors',
        () async {
      final channel = FakeWebSocketChannel();
      unawaited(
        _completeSuccessfulHandshake(
          channel,
          expectedRole: gatewayNodeRole,
        ),
      );

      final client = await _connectClient(
        channel,
        role: gatewayNodeRole,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.nodeHost,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.node,
        ),
      );
      final registry = GatewayNodeCapabilityRegistry(
        commands: [
          GatewayNodeCommand(
            name: 'explode',
            handler: (context) => throw StateError('boom'),
          ),
        ],
      );
      final subscription = registry.attach(client);

      channel.sendJson({
        'type': 'event',
        'event': 'node.invoke.request',
        'payload': {
          'id': 'invoke-explode',
          'nodeId': 'node-1',
          'command': 'explode',
        },
      });
      final invokeResultRequest = await channel.nextClientJson();
      expect(invokeResultRequest['method'], 'node.invoke.result');
      expect(
        invokeResultRequest['params'],
        containsPair(
          'error',
          containsPair('code', 'handler_error'),
        ),
      );
      channel.sendJson({
        'type': 'res',
        'id': invokeResultRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });

      await subscription.cancel();
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

    test(
        'uses device identity with cached device token and persists hello auth',
        () async {
      final channel = FakeWebSocketChannel();
      final identity = await GatewayEd25519Identity.generate();
      final store = GatewayMemoryDeviceTokenStore();
      await store.write(
        GatewayStoredDeviceToken(
          deviceId: identity.deviceId,
          role: gatewayDefaultRole,
          token: 'cached-device-token',
          scopes: const ['operator.read'],
        ),
      );

      final connectFuture = _connectClient(
        channel,
        auth: const GatewayAuth.none(),
        deviceIdentity: identity,
        deviceTokenStore: store,
      );

      channel.sendJson(_connectChallengeEvent());
      final connectRequest = await channel.nextClientJson();
      final params = Map<String, Object?>.from(connectRequest['params'] as Map);
      expect(params['auth'], {
        'token': 'cached-device-token',
        'deviceToken': 'cached-device-token',
      });
      final device = Map<String, Object?>.from(params['device'] as Map);
      expect(device['id'], identity.deviceId);
      expect(device['publicKey'], identity.publicKey);
      expect(device['nonce'], 'nonce-1');
      expect(device['signature'],
          isA<String>().having((v) => v.isNotEmpty, 'non-empty', isTrue));

      channel.sendJson({
        'type': 'res',
        'id': connectRequest['id'],
        'ok': true,
        'payload': _helloPayload(
          connId: 'conn-identity',
          deviceToken: 'fresh-device-token',
          scopes: const ['operator.admin', 'operator.read'],
        ),
      });

      final client = await connectFuture;
      final storedToken = await store.read(
        deviceId: identity.deviceId,
        role: gatewayDefaultRole,
      );
      expect(storedToken?.token, 'fresh-device-token');
      expect(storedToken?.scopes, contains('operator.admin'));

      await client.close();
    });

    test('prefers explicit shared auth over cached device token', () async {
      final channel = FakeWebSocketChannel();
      final identity = await GatewayEd25519Identity.generate();
      final store = GatewayMemoryDeviceTokenStore();
      await store.write(
        GatewayStoredDeviceToken(
          deviceId: identity.deviceId,
          role: gatewayDefaultRole,
          token: 'cached-device-token',
          scopes: const ['operator.read'],
        ),
      );

      final connectFuture = _connectClient(
        channel,
        auth: const GatewayAuth.token('shared-token'),
        deviceIdentity: identity,
        deviceTokenStore: store,
      );

      channel.sendJson(_connectChallengeEvent());
      final connectRequest = await channel.nextClientJson();
      final params = Map<String, Object?>.from(connectRequest['params'] as Map);
      expect(params['auth'], {
        'token': 'shared-token',
      });

      channel.sendJson({
        'type': 'res',
        'id': connectRequest['id'],
        'ok': true,
        'payload': _helloPayload(connId: 'conn-shared'),
      });

      final client = await connectFuture;
      await client.close();
    });

    test('clears stale stored device token on device token mismatch', () async {
      final channel = FakeWebSocketChannel();
      final identity = await GatewayEd25519Identity.generate();
      final store = GatewayMemoryDeviceTokenStore();
      await store.write(
        GatewayStoredDeviceToken(
          deviceId: identity.deviceId,
          role: gatewayDefaultRole,
          token: 'stale-device-token',
          scopes: const ['operator.read'],
        ),
      );

      final connectFuture = _connectClient(
        channel,
        auth: const GatewayAuth.none(),
        deviceIdentity: identity,
        deviceTokenStore: store,
      );

      channel.sendJson(_connectChallengeEvent());
      final connectRequest = await channel.nextClientJson();
      channel.sendJson({
        'type': 'res',
        'id': connectRequest['id'],
        'ok': false,
        'error': {
          'code': 'unauthorized',
          'message': 'device token mismatch',
          'details': {
            'code': GatewayConnectErrorDetailCodes.authDeviceTokenMismatch,
          },
        },
      });

      await expectLater(
        connectFuture,
        throwsA(isA<GatewayResponseException>()),
      );
      final storedToken = await store.read(
        deviceId: identity.deviceId,
        role: gatewayDefaultRole,
      );
      expect(storedToken, isNull);
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

Future<bool> _disabledAvailability() async => false;

Future<GatewayNodeCommandResult> _noopNodeCommand(
  GatewayNodeCommandContext context,
) async {
  return const GatewayNodeCommandResult.ok();
}

Future<GatewayClient> _connectClient(
  FakeWebSocketChannel channel, {
  GatewayAuth auth = const GatewayAuth.token('shared-token'),
  GatewayClientInfo clientInfo = const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
    displayName: 'OpenClaw Dart Test',
  ),
  GatewayDeviceIdentity? deviceIdentity,
  GatewayDeviceTokenStore? deviceTokenStore,
  String role = gatewayDefaultRole,
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
    auth: auth,
    clientInfo: clientInfo,
    deviceIdentity: deviceIdentity,
    deviceTokenStore: deviceTokenStore,
    role: role,
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
  GatewayAuth auth = const GatewayAuth.token('shared-token'),
  GatewayClientInfo clientInfo = const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
    displayName: 'OpenClaw Dart Test',
  ),
  GatewayDeviceIdentity? deviceIdentity,
  GatewayDeviceTokenStore? deviceTokenStore,
  String role = gatewayDefaultRole,
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
    auth: auth,
    clientInfo: clientInfo,
    role: role,
    deviceIdentity: deviceIdentity,
    deviceTokenStore: deviceTokenStore,
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
  String expectedRole = gatewayDefaultRole,
}) async {
  await Future<void>.delayed(Duration.zero);
  channel.sendJson(_connectChallengeEvent());

  final connectRequest = await channel.nextClientJson();
  expect(connectRequest['type'], 'req');
  expect(connectRequest['method'], 'connect');

  final params = Map<String, Object?>.from(connectRequest['params'] as Map);
  expect(params['minProtocol'], gatewayProtocolVersion);
  expect(params['role'], expectedRole);

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
  String? deviceToken,
  String role = gatewayDefaultRole,
  List<String> scopes = const <String>['operator.read'],
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
    'auth': deviceToken == null
        ? null
        : {
            'deviceToken': deviceToken,
            'role': role,
            'scopes': scopes,
            'issuedAtMs': 1234,
          },
    'policy': {
      'maxPayload': 1000,
      'maxBufferedBytes': 2000,
      'tickIntervalMs': tickIntervalMs,
    },
  };
}

Map<String, Object?> _connectChallengeEvent() {
  return {
    'type': 'event',
    'event': 'connect.challenge',
    'payload': {
      'nonce': 'nonce-1',
      'ts': 1,
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
