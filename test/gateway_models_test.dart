import 'package:openclaw_gateway/openclaw_gateway.dart';
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
}
