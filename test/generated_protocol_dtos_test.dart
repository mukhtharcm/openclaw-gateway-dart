import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

void main() {
  group('Generated protocol DTOs', () {
    test('parse and round-trip top-level object schemas', () {
      final params = GatewaySchemaConnectParams.fromJson(
        <String, Object?>{
          'minProtocol': gatewayProtocolVersion,
          'maxProtocol': gatewayProtocolVersion,
          'client': <String, Object?>{
            'id': GatewayClientIds.cli,
            'version': '0.1.0',
            'platform': 'dart',
            'mode': GatewayClientModes.cli,
          },
          'auth': <String, Object?>{
            'token': 'secret',
          },
        },
      );

      expect(params.client.id, GatewayClientIds.cli);
      expect(params.auth?.token, 'secret');
      expect(params.toJson()['client'], isA<Map<String, Object?>>());
    });

    test('wrap top-level anyOf schemas as raw JSON objects', () {
      final params = GatewaySchemaCronRemoveParams.fromJson(
        <String, Object?>{'jobId': 'cron-1'},
      );

      expect(params.toJson(), <String, Object?>{'jobId': 'cron-1'});
    });

    test('parse nested generated objects', () {
      final hello = GatewaySchemaHelloOk.fromJson(
        <String, Object?>{
          'type': 'hello-ok',
          'protocol': gatewayProtocolVersion,
          'server': <String, Object?>{
            'version': '2026.3.8',
            'connId': 'conn-1',
          },
          'features': <String, Object?>{
            'methods': <String>['health'],
            'events': <String>['chat'],
          },
          'snapshot': <String, Object?>{
            'presence': <Object?>[],
            'health': <String, Object?>{'ok': true},
            'stateVersion': <String, Object?>{
              'presence': 1,
              'health': 1,
            },
            'uptimeMs': 10,
          },
          'policy': <String, Object?>{
            'maxPayload': 1000,
            'maxBufferedBytes': 1000,
            'tickIntervalMs': 5000,
          },
        },
      );

      expect(hello.server.connId, 'conn-1');
      expect(hello.features.methods, <String>['health']);
      expect(hello.policy.tickIntervalMs, 5000);
      expect(hello.toJson()['server'], isA<Map<String, Object?>>());
    });
  });
}
