import 'dart:io';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:openclaw_gateway/openclaw_gateway_io.dart';
import 'package:test/test.dart';

void main() {
  test('parses hello-ok payload', () {
    final hello = GatewayHelloOk.fromJson({
      'type': 'hello-ok',
      'protocol': gatewayProtocolVersion,
      'server': {
        'version': '2026.3.7',
        'connId': 'conn-123',
      },
      'features': {
        'methods': ['health', 'chat.send'],
        'events': ['chat', 'tick'],
      },
      'snapshot': {
        'health': {'status': 'ok'},
      },
      'canvasHostUrl': 'https://canvas.example',
      'auth': {
        'deviceToken': 'device-token',
        'role': 'operator',
        'scopes': ['operator.read'],
        'issuedAtMs': 1234,
      },
      'policy': {
        'maxPayload': 1000,
        'maxBufferedBytes': 2000,
        'tickIntervalMs': 30000,
      },
    });

    expect(hello.server.version, '2026.3.7');
    expect(hello.features.methods, contains('health'));
    expect(hello.auth?.deviceToken, 'device-token');
    expect(hello.policy.tickIntervalMs, 30000);
  });

  test('serializes shared-token auth', () {
    const auth = GatewayAuth.token('secret');
    expect(auth.toJson(), {'token': 'secret'});
  });

  test('defaults operator connect options', () {
    final options = GatewayConnectOptions.forOperator(
      uri: Uri.parse('wss://gateway.example'),
      auth: const GatewayAuth.none(),
      clientInfo: const GatewayClientInfo(
        id: GatewayClientIds.gatewayClient,
        version: '0.1.0',
        platform: 'dart',
        mode: GatewayClientModes.backend,
      ),
    );

    expect(options.role, 'operator');
    expect(options.scopes, contains('operator.read'));
    expect(options.toConnectParams()['minProtocol'], gatewayProtocolVersion);
  });

  test('defaults node connect options', () {
    final options = GatewayConnectOptions.forNode(
      uri: Uri.parse('wss://gateway.example'),
      auth: const GatewayAuth.none(),
      clientInfo: const GatewayClientInfo(
        id: GatewayClientIds.nodeHost,
        version: '0.1.0',
        platform: 'dart',
        mode: GatewayClientModes.node,
      ),
      caps: const ['camera'],
      commands: const ['camera.list'],
      permissions: const {'camera': true},
    );

    expect(options.role, gatewayNodeRole);
    expect(options.scopes, isEmpty);
    expect(options.caps, ['camera']);
    expect(options.commands, ['camera.list']);
    expect(options.permissions, {'camera': true});
    expect(
      options.toConnectParams(),
      containsPair('commands', ['camera.list']),
    );
  });

  test('node registry forwards tls policy into connect options', () async {
    final registry = GatewayNodeCapabilityRegistry(
      capabilities: const <GatewayNodeCapability>[
        GatewayNodeCapability(name: 'system'),
      ],
      commands: <GatewayNodeCommand>[
        GatewayNodeCommand(
          name: 'system.notify',
          capabilities: const <String>['system'],
          handler: (_) async => const GatewayNodeCommandResult.ok(),
        ),
      ],
    );
    final tlsPolicy = GatewayTlsPolicy.trustOnFirstUse(
      stableId: 'gateway.example',
      fingerprintStore: GatewayMemoryTlsFingerprintStore(),
    );

    final options = await registry.buildConnectOptions(
      uri: Uri.parse('wss://gateway.example'),
      auth: const GatewayAuth.none(),
      clientInfo: const GatewayClientInfo(
        id: GatewayClientIds.nodeHost,
        version: '0.1.0',
        platform: 'dart',
        mode: GatewayClientModes.node,
      ),
      tlsPolicy: tlsPolicy,
    );

    expect(options.role, gatewayNodeRole);
    expect(options.commands, contains('system.notify'));
    expect(options.tlsPolicy?.stableId, 'gateway.example');
  });

  test('exposes canonical gateway client ids and modes', () {
    expect(GatewayClientIds.values, contains(GatewayClientIds.gatewayClient));
    expect(GatewayClientIds.values, contains(GatewayClientIds.nodeHost));
    expect(GatewayClientModes.values, contains(GatewayClientModes.backend));
    expect(GatewayClientModes.values, contains(GatewayClientModes.node));
  });

  test('round-trips Ed25519 device identities', () async {
    final identity = await GatewayEd25519Identity.generate();
    final exported = await identity.exportData();
    final restored = GatewayEd25519Identity.fromData(exported);

    expect(restored.deviceId, identity.deviceId);
    expect(restored.publicKey, identity.publicKey);
    expect(
      gatewayDeviceIdFromPublicKey(restored.publicKey),
      restored.deviceId,
    );
  });

  test('round-trips auth state through a string store', () async {
    final backingStore = GatewayMemoryStringStore();
    final store = GatewayJsonAuthStateStore(store: backingStore);

    final identity = await store.readOrCreateIdentity();
    final restoredIdentity = await store.readIdentity();
    expect(restoredIdentity?.deviceId, identity.deviceId);

    const token = GatewayStoredDeviceToken(
      deviceId: 'device-1',
      role: gatewayNodeRole,
      token: 'device-token-1',
      scopes: <String>['node.invoke'],
      issuedAtMs: 7,
    );
    await store.write(token);
    final restoredToken = await store.read(
      deviceId: token.deviceId,
      role: token.role,
    );
    expect(restoredToken?.token, token.token);
    expect(restoredToken?.scopes, token.scopes);

    final raw = await backingStore.readString(store.key);
    expect(raw, isNotNull);

    await store.delete(deviceId: token.deviceId, role: token.role);
    await store.deleteIdentity();
    expect(await store.readIdentity(), isNull);
    expect(
        await store.read(deviceId: token.deviceId, role: token.role), isNull);
  });

  test('round-trips auth state through the file-backed store', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'openclaw_gateway_auth_state_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    final store = GatewayJsonFileAuthStateStore(
      path: '${tempDir.path}/state.json',
    );

    final identity = await store.readOrCreateIdentity();
    final restoredIdentity = await store.readIdentity();
    expect(restoredIdentity?.deviceId, identity.deviceId);

    const token = GatewayStoredDeviceToken(
      deviceId: 'device-file',
      role: gatewayDefaultRole,
      token: 'file-token',
    );
    await store.write(token);
    expect(
      await store.read(deviceId: token.deviceId, role: token.role),
      isNotNull,
    );

    await store.delete(deviceId: token.deviceId, role: token.role);
    await store.deleteIdentity();
    expect(await store.readIdentity(), isNull);
  });
}
