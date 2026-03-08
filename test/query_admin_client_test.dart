import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('GatewayQueryClient', () {
    test('parses typed query responses', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));
      final client = await _connectClient(channel);

      final healthFuture = client.query.health();
      final healthRequest = await channel.nextClientJson();
      expect(healthRequest['method'], 'health');
      channel.sendJson({
        'type': 'res',
        'id': healthRequest['id'],
        'ok': true,
        'payload': {
          'ok': true,
          'ts': 1,
          'channels': {},
          'channelOrder': ['telegram'],
          'channelLabels': {'telegram': 'Telegram'},
          'agents': {},
          'sessions': {},
        },
      });
      final health = await healthFuture;
      expect(health.ok, isTrue);
      expect(health.channelOrder, ['telegram']);

      final presenceFuture = client.query.systemPresence();
      final presenceRequest = await channel.nextClientJson();
      expect(presenceRequest['method'], 'system-presence');
      channel.sendJson({
        'type': 'res',
        'id': presenceRequest['id'],
        'ok': true,
        'payload': [
          {
            'ts': 2,
            'text': 'Node: test',
            'roles': ['operator'],
          },
        ],
      });
      final presence = await presenceFuture;
      expect(presence.single.text, 'Node: test');

      final sessionsFuture = client.query.sessionsList(limit: 1);
      final sessionsRequest = await channel.nextClientJson();
      expect(sessionsRequest['method'], 'sessions.list');
      channel.sendJson({
        'type': 'res',
        'id': sessionsRequest['id'],
        'ok': true,
        'payload': {
          'ts': 2,
          'path': '/tmp/sessions.json',
          'count': 1,
          'defaults': {
            'modelProvider': 'openai',
            'model': 'gpt-5',
            'contextTokens': 64000,
          },
          'sessions': [
            {
              'key': 'main',
              'kind': 'direct',
              'displayName': 'Main',
              'updatedAt': 123,
            },
          ],
        },
      });
      final sessions = await sessionsFuture;
      expect(sessions.count, 1);
      expect(sessions.sessions.single.key, 'main');

      final lookupFuture =
          client.query.configSchemaLookup(path: 'gateway.mode');
      final lookupRequest = await channel.nextClientJson();
      expect(lookupRequest['method'], 'config.schema.lookup');
      channel.sendJson({
        'type': 'res',
        'id': lookupRequest['id'],
        'ok': true,
        'payload': {
          'path': 'gateway.mode',
          'schema': {'type': 'string'},
          'children': [
            {
              'key': 'local',
              'path': 'gateway.mode.local',
              'type': 'string',
              'required': false,
              'hasChildren': false,
            },
          ],
        },
      });
      final lookup = await lookupFuture;
      expect(lookup.path, 'gateway.mode');
      expect(lookup.children.single.key, 'local');

      final modelsFuture = client.query.modelsList();
      final modelsRequest = await channel.nextClientJson();
      expect(modelsRequest['method'], 'models.list');
      channel.sendJson({
        'type': 'res',
        'id': modelsRequest['id'],
        'ok': true,
        'payload': {
          'models': [
            {
              'id': 'gpt-5',
              'name': 'GPT-5',
              'provider': 'openai',
              'contextWindow': 64000,
              'reasoning': true,
            },
          ],
        },
      });
      final models = await modelsFuture;
      expect(models.models.single.provider, 'openai');

      final cronListFuture = client.query.cronList(limit: 1);
      final cronListRequest = await channel.nextClientJson();
      expect(cronListRequest['method'], 'cron.list');
      channel.sendJson({
        'type': 'res',
        'id': cronListRequest['id'],
        'ok': true,
        'payload': {
          'jobs': [
            {
              'id': 'job-1',
              'name': 'Morning',
              'enabled': true,
              'createdAtMs': 10,
              'updatedAtMs': 20,
              'schedule': {'kind': 'cron', 'expr': '0 9 * * *'},
              'sessionTarget': 'main',
              'wakeMode': 'now',
              'payload': {'kind': 'systemEvent', 'text': 'hello'},
              'state': {'nextRunAtMs': 30},
            },
          ],
          'total': 1,
          'offset': 0,
          'limit': 1,
          'hasMore': false,
          'nextOffset': null,
        },
      });
      final cronList = await cronListFuture;
      expect(cronList.jobs.single.id, 'job-1');

      final cronRunsFuture = client.query.cronRuns(limit: 1);
      final cronRunsRequest = await channel.nextClientJson();
      expect(cronRunsRequest['method'], 'cron.runs');
      channel.sendJson({
        'type': 'res',
        'id': cronRunsRequest['id'],
        'ok': true,
        'payload': {
          'entries': [
            {
              'ts': 50,
              'jobId': 'job-1',
              'action': 'finished',
              'status': 'ok',
            },
          ],
          'total': 1,
          'offset': 0,
          'limit': 1,
          'hasMore': false,
          'nextOffset': null,
        },
      });
      final cronRuns = await cronRunsFuture;
      expect(cronRuns.entries.single.status, 'ok');

      await client.close();
    });
  });

  group('GatewayAdminClient', () {
    test('parses typed admin responses', () async {
      final channel = FakeWebSocketChannel();
      unawaited(_completeSuccessfulHandshake(channel));
      final client = await _connectClient(channel);

      final approvalsFuture = client.admin.execApprovalsGet();
      final approvalsRequest = await channel.nextClientJson();
      expect(approvalsRequest['method'], 'exec.approvals.get');
      channel.sendJson({
        'type': 'res',
        'id': approvalsRequest['id'],
        'ok': true,
        'payload': {
          'path': '/tmp/approvals.json',
          'exists': true,
          'hash': 'abc123',
          'file': {
            'version': 1,
            'defaults': {
              'security': 'default',
              'ask': 'always',
            },
          },
        },
      });
      final approvals = await approvalsFuture;
      expect(approvals.exists, isTrue);
      expect(approvals.file?.defaults?.security, 'default');

      final configPatchFuture = client.admin.configPatch(
        raw: '{"gateway":{"mode":"local"}}',
      );
      final configPatchRequest = await channel.nextClientJson();
      expect(configPatchRequest['method'], 'config.patch');
      channel.sendJson({
        'type': 'res',
        'id': configPatchRequest['id'],
        'ok': true,
        'payload': {
          'ok': true,
          'path': '/tmp/openclaw.json',
          'config': {
            'gateway': {'mode': 'local'},
          },
          'restart': {
            'ok': true,
            'pid': 42,
            'signal': 'SIGUSR1',
            'delayMs': 2000,
            'coalesced': false,
            'cooldownMsApplied': 0,
          },
          'sentinel': {
            'path': '/tmp/restart-sentinel.json',
            'payload': {'kind': 'config-patch'},
          },
        },
      });
      final configPatch = await configPatchFuture;
      expect(configPatch.restart?.signal, 'SIGUSR1');
      expect(configPatch.sentinel?.path, '/tmp/restart-sentinel.json');

      final sessionPatchFuture = client.admin.sessionsPatch(
        key: 'main',
        label: 'Pinned',
      );
      final sessionPatchRequest = await channel.nextClientJson();
      expect(sessionPatchRequest['method'], 'sessions.patch');
      channel.sendJson({
        'type': 'res',
        'id': sessionPatchRequest['id'],
        'ok': true,
        'payload': {
          'ok': true,
          'path': '/tmp/sessions.json',
          'key': 'main',
          'entry': {
            'label': 'Pinned',
            'updatedAt': 123,
          },
          'resolved': {
            'modelProvider': 'openai',
            'model': 'gpt-5',
          },
        },
      });
      final sessionPatch = await sessionPatchFuture;
      expect(sessionPatch.key, 'main');
      expect(sessionPatch.resolved?.model, 'gpt-5');

      final wizardFuture = client.admin.wizardStart(mode: 'local');
      final wizardRequest = await channel.nextClientJson();
      expect(wizardRequest['method'], 'wizard.start');
      channel.sendJson({
        'type': 'res',
        'id': wizardRequest['id'],
        'ok': true,
        'payload': {
          'sessionId': 'wiz-1',
          'done': false,
          'step': {
            'id': 'step-1',
            'type': 'text',
            'title': 'Workspace',
          },
        },
      });
      final wizard = await wizardFuture;
      expect(wizard.sessionId, 'wiz-1');
      expect(wizard.step?.title, 'Workspace');

      final usageFuture = client.admin.usageStatus();
      final usageRequest = await channel.nextClientJson();
      expect(usageRequest['method'], 'usage.status');
      channel.sendJson({
        'type': 'res',
        'id': usageRequest['id'],
        'ok': true,
        'payload': {
          'updatedAt': '2026-03-08T00:00:00Z',
          'providers': [
            {
              'provider': 'openai',
              'displayName': 'OpenAI',
              'windows': [
                {'label': 'daily', 'usedPercent': 15},
              ],
            },
          ],
        },
      });
      final usage = await usageFuture;
      expect(usage.providers.single.provider, 'openai');

      final ttsEnableFuture = client.admin.ttsEnable();
      final ttsEnableRequest = await channel.nextClientJson();
      expect(ttsEnableRequest['method'], 'tts.enable');
      channel.sendJson({
        'type': 'res',
        'id': ttsEnableRequest['id'],
        'ok': true,
        'payload': {'enabled': true},
      });
      final ttsEnable = await ttsEnableFuture;
      expect(ttsEnable.enabled, isTrue);

      final agentsListFuture = client.admin.agentsList();
      final agentsListRequest = await channel.nextClientJson();
      expect(agentsListRequest['method'], 'agents.list');
      channel.sendJson({
        'type': 'res',
        'id': agentsListRequest['id'],
        'ok': true,
        'payload': {
          'defaultId': 'default',
          'mainKey': 'main',
          'scope': 'per-sender',
          'agents': [
            {
              'id': 'default',
              'name': 'Default',
            },
          ],
        },
      });
      final agentsList = await agentsListFuture;
      expect(agentsList.agents.single.id, 'default');

      final heartbeatFuture = client.admin.lastHeartbeat();
      final heartbeatRequest = await channel.nextClientJson();
      expect(heartbeatRequest['method'], 'last-heartbeat');
      channel.sendJson({
        'type': 'res',
        'id': heartbeatRequest['id'],
        'ok': true,
        'payload': {
          'ts': 99,
          'status': 'ok-empty',
          'channel': 'telegram',
        },
      });
      final heartbeat = await heartbeatFuture;
      expect(heartbeat?.status, 'ok-empty');

      final sendFuture = client.admin.send(
        to: 'user',
        message: 'hello',
      );
      final sendRequest = await channel.nextClientJson();
      expect(sendRequest['method'], 'send');
      channel.sendJson({
        'type': 'res',
        'id': sendRequest['id'],
        'ok': true,
        'payload': {
          'runId': 'run-1',
          'messageId': 'msg-1',
          'channel': 'telegram',
        },
      });
      final send = await sendFuture;
      expect(send.messageId, 'msg-1');

      final browserFuture = client.admin.browserRequest(
        method: 'GET',
        path: '/status',
      );
      final browserRequest = await channel.nextClientJson();
      expect(browserRequest['method'], 'browser.request');
      channel.sendJson({
        'type': 'res',
        'id': browserRequest['id'],
        'ok': true,
        'payload': {
          'ok': true,
        },
      });
      final browser = await browserFuture;
      expect(browser.value, {'ok': true});

      final systemEventFuture = client.admin.systemEvent(text: 'hello');
      final systemEventRequest = await channel.nextClientJson();
      expect(systemEventRequest['method'], 'system-event');
      channel.sendJson({
        'type': 'res',
        'id': systemEventRequest['id'],
        'ok': true,
        'payload': {'ok': true},
      });
      final systemEvent = await systemEventFuture;
      expect(systemEvent.ok, isTrue);

      await client.close();
    });
  });
}

Future<GatewayClient> _connectClient(FakeWebSocketChannel channel) {
  return GatewayClient.connect(
    uri: Uri.parse('ws://gateway.test'),
    auth: const GatewayAuth.token('shared-token'),
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'dart',
      mode: GatewayClientModes.backend,
      displayName: 'OpenClaw Dart Test',
    ),
    connectChallengeTimeout: const Duration(milliseconds: 100),
    connectResponseTimeout: const Duration(milliseconds: 100),
    requestTimeout: const Duration(milliseconds: 100),
    channelFactory: (_) => channel,
  );
}

Future<void> _completeSuccessfulHandshake(FakeWebSocketChannel channel) async {
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
  channel.sendJson({
    'type': 'res',
    'id': connectRequest['id'],
    'ok': true,
    'payload': {
      'type': 'hello-ok',
      'protocol': gatewayProtocolVersion,
      'server': {
        'version': '2026.3.7',
        'connId': 'conn-query-admin',
      },
      'features': {
        'methods': ['health'],
        'events': ['tick'],
      },
      'snapshot': {
        'health': {'status': 'ok'},
      },
      'policy': {
        'maxPayload': 1000,
        'maxBufferedBytes': 2000,
        'tickIntervalMs': 30000,
      },
    },
  });
}

class FakeWebSocketChannel extends StreamChannelMixin<Object?>
    implements WebSocketChannel {
  FakeWebSocketChannel() : _readyCompleter = (Completer<void>()..complete()) {
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
