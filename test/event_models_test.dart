import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

void main() {
  test('parses typed gateway operator events', () {
    final presenceEvent = GatewayPresenceEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'presence',
        'seq': 7,
        'stateVersion': {
          'presence': 2,
          'health': 1,
        },
        'payload': {
          'presence': [
            {
              'host': 'gateway-host',
              'platform': 'macos',
              'mode': 'desktop',
              'ts': 1234,
              'roles': ['operator'],
            },
          ],
        },
      }),
    );
    expect(presenceEvent.seq, 7);
    expect(presenceEvent.stateVersion?.presence, 2);
    expect(presenceEvent.presence.single.host, 'gateway-host');

    final shutdownEvent = GatewayShutdownEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'shutdown',
        'payload': {
          'reason': 'restart',
          'restartExpectedMs': 5000,
        },
      }),
    );
    expect(shutdownEvent.reason, 'restart');
    expect(shutdownEvent.restartExpectedMs, 5000);

    final heartbeatEvent = GatewayHeartbeatEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'heartbeat',
        'payload': {
          'ts': 55,
          'status': 'sent',
          'channel': 'telegram',
          'indicatorType': 'ok',
        },
      }),
    );
    expect(heartbeatEvent.status, 'sent');
    expect(heartbeatEvent.channel, 'telegram');

    final execRequested = GatewayExecApprovalRequestedEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'exec.approval.requested',
        'payload': {
          'id': 'approval-1',
          'createdAtMs': 10,
          'expiresAtMs': 20,
          'request': {
            'command': 'ls',
            'commandArgv': ['-la'],
            'envKeys': ['PATH'],
            'cwd': '/tmp',
          },
        },
      }),
    );
    expect(execRequested.request.command, 'ls');
    expect(execRequested.request.envKeys, ['PATH']);

    final updateEvent = GatewayUpdateAvailableEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'update.available',
        'payload': {
          'updateAvailable': {
            'currentVersion': '2026.3.8',
            'latestVersion': '2026.3.9',
            'channel': 'stable',
          },
        },
      }),
    );
    expect(updateEvent.updateAvailable?.latestVersion, '2026.3.9');
  });

  test('parses typed node, device, cron, and agent events', () {
    final nodePairRequested = GatewayNodePairRequestedEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'node.pair.requested',
        'payload': {
          'requestId': 'node-request-1',
          'nodeId': 'node-1',
          'displayName': 'Node One',
          'caps': ['camera'],
          'commands': ['camera.list'],
          'permissions': {'camera': true},
          'ts': 1,
        },
      }),
    );
    expect(nodePairRequested.nodeId, 'node-1');
    expect(nodePairRequested.permissions, {'camera': true});

    final devicePairRequested = GatewayDevicePairRequestedEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'device.pair.requested',
        'payload': {
          'requestId': 'device-request-1',
          'deviceId': 'device-1',
          'publicKey': 'public-key',
          'clientId': 'gateway-client',
          'roles': ['operator'],
          'scopes': ['operator.read'],
          'ts': 2,
        },
      }),
    );
    expect(devicePairRequested.deviceId, 'device-1');
    expect(devicePairRequested.scopes, ['operator.read']);

    final cronEvent = GatewayCronEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'cron',
        'payload': {
          'jobId': 'job-1',
          'action': 'finished',
          'status': 'ok',
          'jobName': 'Wake Up',
        },
      }),
    );
    expect(cronEvent.jobId, 'job-1');
    expect(cronEvent.jobName, 'Wake Up');

    final agentEvent = GatewayAgentEvent.fromEventFrame(
      GatewayEventFrame.fromJson({
        'type': 'event',
        'event': 'agent',
        'payload': {
          'runId': 'run-1',
          'stream': 'tool',
          'ts': 99,
          'data': {
            'phase': 'result',
            'name': 'shell',
            'toolCallId': 'tool-1',
            'isError': false,
            'result': {'ok': true},
          },
        },
      }),
    );
    expect(agentEvent.streamName, 'tool');
    expect(agentEvent.toolData?.phase, 'result');
    expect(agentEvent.toolData?.name, 'shell');
  });
}
