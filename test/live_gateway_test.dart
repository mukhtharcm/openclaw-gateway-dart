import 'dart:io';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

final bool _liveEnabled =
    Platform.environment['OPENCLAW_GATEWAY_LIVE_TEST'] == '1';
final String? _liveUrl = Platform.environment['OPENCLAW_GATEWAY_URL'];
final String? _liveToken = Platform.environment['OPENCLAW_GATEWAY_TOKEN'];

void main() {
  final skipReason = _liveSkipReason();

  group('live gateway', skip: skipReason, () {
    late Uri uri;
    late String token;

    setUpAll(() {
      uri = Uri.parse(_liveUrl!);
      token = _liveToken!;
    });

    test('typed operator helpers succeed against a live gateway', () async {
      final client = await GatewayClient.connect(
        uri: uri,
        auth: GatewayAuth.token(token),
        autoReconnect: true,
        clientInfo: _clientInfo(
          displayName: 'OpenClaw Dart Live Smoke',
        ),
      );

      try {
        final health = await client.operator.health();
        expect(health['ok'], isTrue);

        final status = await client.operator.status();
        expect(status, contains('sessions'));

        final channels = await client.operator.channelsStatus(probe: true);
        expect(channels, contains('channels'));

        final schema = await client.operator.configSchemaLookup(
          path: 'gateway.mode',
        );
        expect(schema['path'], 'gateway.mode');

        final models = await client.operator.modelsList();
        expect(models, contains('models'));

        final tools = await client.operator.toolsCatalog(includePlugins: true);
        expect(tools, contains('profiles'));
        expect(tools, contains('groups'));

        final agents = await client.operator.agentsList();
        expect(agents, contains('agents'));

        final voiceWake = await client.operator.voiceWakeGet();
        expect(voiceWake, contains('triggers'));

        final cronStatus = await client.operator.cronStatus();
        expect(cronStatus, contains('enabled'));

        final cronList = await client.operator.cronList(limit: 3);
        expect(cronList, contains('jobs'));

        final devicePairs = await client.devices.pairList();
        expect(devicePairs, contains('paired'));
        expect(devicePairs, contains('pending'));

        final nodes = await client.nodes.list();
        expect(nodes, isA<List<GatewayNodeSummary>>());

        if (nodes.isNotEmpty) {
          final described = await client.nodes.describe(
            nodeId: nodes.first.nodeId,
          );
          expect(described.nodeId, nodes.first.nodeId);
        }
      } finally {
        await client.close();
      }
    });

    test('device identities receive and reuse cached device tokens', () async {
      final identity = await GatewayEd25519Identity.generate();
      final store = GatewayMemoryDeviceTokenStore();
      var paired = false;
      final cleanupClient = await GatewayClient.connect(
        uri: uri,
        auth: GatewayAuth.token(token),
        autoReconnect: true,
        clientInfo: _clientInfo(
          displayName: 'OpenClaw Dart Device Cleanup',
        ),
      );

      try {
        GatewayClient? seededClient;
        try {
          seededClient = await GatewayClient.connect(
            uri: uri,
            auth: GatewayAuth.token(token),
            deviceIdentity: identity,
            deviceTokenStore: store,
            autoReconnect: true,
            clientInfo: _clientInfo(
              displayName: 'OpenClaw Dart Device Seed',
            ),
          );
        } on GatewayResponseException catch (error) {
          expect(error.code, 'NOT_PAIRED');
          expect(
            readGatewayConnectErrorDetailCode(error.details),
            GatewayConnectErrorDetailCodes.pairingRequired,
          );

          final requestId = _readPairingRequestId(error.details);
          expect(requestId, isNotNull);

          final approved = await cleanupClient.devices.pairApprove(
            requestId: requestId!,
          );
          expect(approved, contains('device'));
          paired = true;

          seededClient = await GatewayClient.connect(
            uri: uri,
            auth: GatewayAuth.token(token),
            deviceIdentity: identity,
            deviceTokenStore: store,
            autoReconnect: true,
            clientInfo: _clientInfo(
              displayName: 'OpenClaw Dart Device Seed',
            ),
          );
        }

        expect(seededClient, isNotNull);
        paired = true;
        final connectedClient = seededClient;

        try {
          final health = await connectedClient.operator.health();
          expect(health['ok'], isTrue);
        } finally {
          await connectedClient.close();
        }

        final stored = await store.read(
          deviceId: identity.deviceId,
          role: gatewayOperatorRole,
        );
        expect(stored, isNotNull);
        expect(stored!.token, isNotEmpty);

        final reusedClient = await GatewayClient.connect(
          uri: uri,
          auth: const GatewayAuth.none(),
          deviceIdentity: identity,
          deviceTokenStore: store,
          autoReconnect: true,
          clientInfo: _clientInfo(
            displayName: 'OpenClaw Dart Device Reuse',
          ),
        );

        try {
          final health = await reusedClient.operator.health();
          expect(health['ok'], isTrue);
        } finally {
          await reusedClient.close();
        }
      } finally {
        if (paired) {
          await cleanupClient.devices.pairRemove(deviceId: identity.deviceId);
        }
        await cleanupClient.close();
      }
    });
  });
}

String? _liveSkipReason() {
  if (!_liveEnabled) {
    return 'Set OPENCLAW_GATEWAY_LIVE_TEST=1 to enable live gateway tests.';
  }
  if (_liveUrl == null || _liveUrl!.isEmpty) {
    return 'Set OPENCLAW_GATEWAY_URL to the live gateway WebSocket URL.';
  }
  if (_liveToken == null || _liveToken!.isEmpty) {
    return 'Set OPENCLAW_GATEWAY_TOKEN to a shared gateway token.';
  }
  return null;
}

GatewayClientInfo _clientInfo({
  required String displayName,
}) {
  return GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
    displayName: displayName,
  );
}

String? _readPairingRequestId(Object? details) {
  if (details is! Map) {
    return null;
  }
  final requestId = details['requestId'];
  if (requestId is String && requestId.isNotEmpty) {
    return requestId;
  }
  return null;
}
