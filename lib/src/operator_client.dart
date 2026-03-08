import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/chat_models.dart';
import 'package:openclaw_gateway/src/event_models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Typed wrappers for common operator-side gateway methods.
class GatewayOperatorClient {
  const GatewayOperatorClient(this._client);

  static const Object _omitted = Object();

  final GatewayClient _client;

  /// Typed `chat` event payloads.
  Stream<GatewayChatEvent> get chatEvents =>
      _client.eventsNamed('chat').map(GatewayChatEvent.fromEventFrame);

  Stream<GatewayPresenceEvent> get presenceEvents =>
      _client.eventsNamed('presence').map(GatewayPresenceEvent.fromEventFrame);

  Stream<GatewayTickEvent> get tickEvents =>
      _client.eventsNamed('tick').map(GatewayTickEvent.fromEventFrame);

  Stream<GatewayShutdownEvent> get shutdownEvents =>
      _client.eventsNamed('shutdown').map(GatewayShutdownEvent.fromEventFrame);

  Stream<GatewayHealthEvent> get healthEvents =>
      _client.eventsNamed('health').map(GatewayHealthEvent.fromEventFrame);

  Stream<GatewayHeartbeatEvent> get heartbeatEvents => _client
      .eventsNamed('heartbeat')
      .map(GatewayHeartbeatEvent.fromEventFrame);

  Stream<GatewayCronEvent> get cronEvents =>
      _client.eventsNamed('cron').map(GatewayCronEvent.fromEventFrame);

  Stream<GatewayTalkModeEvent> get talkModeEvents =>
      _client.eventsNamed('talk.mode').map(GatewayTalkModeEvent.fromEventFrame);

  Stream<GatewayNodePairRequestedEvent> get nodePairRequestedEvents => _client
      .eventsNamed('node.pair.requested')
      .map(GatewayNodePairRequestedEvent.fromEventFrame);

  Stream<GatewayNodePairResolvedEvent> get nodePairResolvedEvents =>
      _client.eventsNamed('node.pair.resolved').map(
            GatewayNodePairResolvedEvent.fromEventFrame,
          );

  Stream<GatewayDevicePairRequestedEvent> get devicePairRequestedEvents =>
      _client.eventsNamed('device.pair.requested').map(
            GatewayDevicePairRequestedEvent.fromEventFrame,
          );

  Stream<GatewayDevicePairResolvedEvent> get devicePairResolvedEvents =>
      _client.eventsNamed('device.pair.resolved').map(
            GatewayDevicePairResolvedEvent.fromEventFrame,
          );

  Stream<GatewayVoiceWakeChangedEvent> get voiceWakeChangedEvents => _client
      .eventsNamed('voicewake.changed')
      .map(GatewayVoiceWakeChangedEvent.fromEventFrame);

  Stream<GatewayExecApprovalRequestedEvent> get execApprovalRequestedEvents =>
      _client.eventsNamed('exec.approval.requested').map(
            GatewayExecApprovalRequestedEvent.fromEventFrame,
          );

  Stream<GatewayExecApprovalResolvedEvent> get execApprovalResolvedEvents =>
      _client.eventsNamed('exec.approval.resolved').map(
            GatewayExecApprovalResolvedEvent.fromEventFrame,
          );

  Stream<GatewayUpdateAvailableEvent> get updateAvailableEvents => _client
      .eventsNamed('update.available')
      .map(GatewayUpdateAvailableEvent.fromEventFrame);

  Stream<GatewayAgentEvent> get agentEvents =>
      _client.eventsNamed('agent').map(GatewayAgentEvent.fromEventFrame);

  /// Calls `health`.
  Future<JsonMap> health({bool probe = false}) {
    return _client.requestJsonMap(
      'health',
      params: probe ? const {'probe': true} : null,
    );
  }

  /// Calls `status`.
  Future<JsonMap> status() {
    return _client.requestJsonMap('status');
  }

  /// Calls `channels.status`.
  Future<JsonMap> channelsStatus({
    bool? probe,
    int? timeoutMs,
  }) {
    return _client.requestJsonMap(
      'channels.status',
      params: withoutNulls({
        'probe': probe,
        'timeoutMs': timeoutMs,
      }),
    );
  }

  /// Calls `channels.logout`.
  Future<JsonMap> channelsLogout({
    required String channel,
    String? accountId,
  }) {
    return _client.requestJsonMap(
      'channels.logout',
      params: withoutNulls({
        'channel': channel,
        'accountId': accountId,
      }),
    );
  }

  /// Calls `config.get`.
  Future<JsonMap> configGet() {
    return _client.requestJsonMap('config.get');
  }

  /// Calls `config.set`.
  Future<JsonMap> configSet({
    required String raw,
    String? baseHash,
  }) {
    return _client.requestJsonMap(
      'config.set',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
      }),
    );
  }

  /// Calls `config.apply`.
  Future<JsonMap> configApply({
    required String raw,
    String? baseHash,
    String? sessionKey,
    String? note,
    int? restartDelayMs,
  }) {
    return _client.requestJsonMap(
      'config.apply',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
        'sessionKey': sessionKey,
        'note': note,
        'restartDelayMs': restartDelayMs,
      }),
    );
  }

  /// Calls `config.patch`.
  Future<JsonMap> configPatch({
    required String raw,
    String? baseHash,
    String? sessionKey,
    String? note,
    int? restartDelayMs,
  }) {
    return _client.requestJsonMap(
      'config.patch',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
        'sessionKey': sessionKey,
        'note': note,
        'restartDelayMs': restartDelayMs,
      }),
    );
  }

  /// Calls `config.schema`.
  Future<JsonMap> configSchema() {
    return _client.requestJsonMap('config.schema');
  }

  /// Calls `config.schema.lookup`.
  Future<JsonMap> configSchemaLookup({
    required String path,
  }) {
    return _client.requestJsonMap(
      'config.schema.lookup',
      params: <String, Object?>{
        'path': path,
      },
    );
  }

  /// Calls `sessions.list`.
  Future<JsonMap> sessionsList({
    int? limit,
    int? activeMinutes,
    bool? includeGlobal,
    bool? includeUnknown,
    bool? includeDerivedTitles,
    bool? includeLastMessage,
    String? label,
    String? spawnedBy,
    String? agentId,
    String? search,
  }) {
    return _client.requestJsonMap(
      'sessions.list',
      params: withoutNulls({
        'limit': limit,
        'activeMinutes': activeMinutes,
        'includeGlobal': includeGlobal,
        'includeUnknown': includeUnknown,
        'includeDerivedTitles': includeDerivedTitles,
        'includeLastMessage': includeLastMessage,
        'label': label,
        'spawnedBy': spawnedBy,
        'agentId': agentId,
        'search': search,
      }),
    );
  }

  /// Calls `sessions.preview`.
  Future<JsonMap> sessionsPreview({
    required List<String> keys,
    int? limit,
    int? maxChars,
  }) {
    return _client.requestJsonMap(
      'sessions.preview',
      params: withoutNulls({
        'keys': keys,
        'limit': limit,
        'maxChars': maxChars,
      }),
    );
  }

  /// Calls `sessions.patch`.
  Future<JsonMap> sessionsPatch({
    required String key,
    Object? label = _omitted,
    Object? thinkingLevel = _omitted,
    Object? verboseLevel = _omitted,
    Object? reasoningLevel = _omitted,
    Object? responseUsage = _omitted,
    Object? elevatedLevel = _omitted,
    Object? execHost = _omitted,
    Object? execSecurity = _omitted,
    Object? execAsk = _omitted,
    Object? execNode = _omitted,
    Object? model = _omitted,
    Object? spawnedBy = _omitted,
    Object? spawnDepth = _omitted,
    Object? sendPolicy = _omitted,
    Object? groupActivation = _omitted,
  }) {
    final params = <String, Object?>{
      'key': key,
    };
    _putIfProvided(params, 'label', label);
    _putIfProvided(params, 'thinkingLevel', thinkingLevel);
    _putIfProvided(params, 'verboseLevel', verboseLevel);
    _putIfProvided(params, 'reasoningLevel', reasoningLevel);
    _putIfProvided(params, 'responseUsage', responseUsage);
    _putIfProvided(params, 'elevatedLevel', elevatedLevel);
    _putIfProvided(params, 'execHost', execHost);
    _putIfProvided(params, 'execSecurity', execSecurity);
    _putIfProvided(params, 'execAsk', execAsk);
    _putIfProvided(params, 'execNode', execNode);
    _putIfProvided(params, 'model', model);
    _putIfProvided(params, 'spawnedBy', spawnedBy);
    _putIfProvided(params, 'spawnDepth', spawnDepth);
    _putIfProvided(params, 'sendPolicy', sendPolicy);
    _putIfProvided(params, 'groupActivation', groupActivation);
    return _client.requestJsonMap('sessions.patch', params: params);
  }

  /// Calls `sessions.reset`.
  Future<JsonMap> sessionsReset({
    required String key,
    String? reason,
  }) {
    return _client.requestJsonMap(
      'sessions.reset',
      params: withoutNulls({
        'key': key,
        'reason': reason,
      }),
    );
  }

  /// Calls `sessions.delete`.
  Future<JsonMap> sessionsDelete({
    required String key,
    bool? deleteTranscript,
    bool? emitLifecycleHooks,
  }) {
    return _client.requestJsonMap(
      'sessions.delete',
      params: withoutNulls({
        'key': key,
        'deleteTranscript': deleteTranscript,
        'emitLifecycleHooks': emitLifecycleHooks,
      }),
    );
  }

  /// Calls `sessions.compact`.
  Future<JsonMap> sessionsCompact({
    required String key,
    int? maxLines,
  }) {
    return _client.requestJsonMap(
      'sessions.compact',
      params: withoutNulls({
        'key': key,
        'maxLines': maxLines,
      }),
    );
  }

  /// Calls `chat.history`.
  Future<JsonMap> chatHistory({
    required String sessionKey,
    int? limit,
  }) {
    return _client.requestJsonMap(
      'chat.history',
      params: withoutNulls({
        'sessionKey': sessionKey,
        'limit': limit,
      }),
    );
  }

  /// Calls `chat.send`.
  Future<JsonMap> chatSend({
    required String sessionKey,
    required String message,
    String? thinking,
    bool? deliver,
    List<Object?>? attachments,
    int? timeoutMs,
    String? idempotencyKey,
  }) {
    return _client.requestJsonMap(
      'chat.send',
      params: withoutNulls({
        'sessionKey': sessionKey,
        'message': message,
        'thinking': thinking,
        'deliver': deliver,
        'attachments': attachments,
        'timeoutMs': timeoutMs,
        'idempotencyKey':
            idempotencyKey ?? _client.createIdempotencyKey(prefix: 'chat'),
      }),
    );
  }

  /// Calls `chat.abort`.
  Future<JsonMap> chatAbort({
    required String sessionKey,
    String? runId,
  }) {
    return _client.requestJsonMap(
      'chat.abort',
      params: withoutNulls({
        'sessionKey': sessionKey,
        'runId': runId,
      }),
    );
  }

  /// Calls `models.list`.
  Future<JsonMap> modelsList() {
    return _client.requestJsonMap('models.list');
  }

  /// Calls `tools.catalog`.
  Future<JsonMap> toolsCatalog({
    String? agentId,
    bool? includePlugins,
  }) {
    return _client.requestJsonMap(
      'tools.catalog',
      params: withoutNulls({
        'agentId': agentId,
        'includePlugins': includePlugins,
      }),
    );
  }

  /// Calls `agents.list`.
  Future<JsonMap> agentsList() {
    return _client.requestJsonMap('agents.list');
  }

  /// Calls `voicewake.get`.
  Future<JsonMap> voiceWakeGet() {
    return _client.requestJsonMap('voicewake.get');
  }

  /// Calls `voicewake.set`.
  Future<JsonMap> voiceWakeSet({
    required List<String> triggers,
  }) {
    return _client.requestJsonMap(
      'voicewake.set',
      params: <String, Object?>{
        'triggers': triggers,
      },
    );
  }

  /// Calls `cron.list`.
  Future<JsonMap> cronList({
    bool? includeDisabled,
    int? limit,
    int? offset,
    String? query,
    String? enabled,
    String? sortBy,
    String? sortDir,
  }) {
    return _client.requestJsonMap(
      'cron.list',
      params: withoutNulls({
        'includeDisabled': includeDisabled,
        'limit': limit,
        'offset': offset,
        'query': query,
        'enabled': enabled,
        'sortBy': sortBy,
        'sortDir': sortDir,
      }),
    );
  }

  /// Calls `cron.status`.
  Future<JsonMap> cronStatus() {
    return _client.requestJsonMap('cron.status');
  }

  static void _putIfProvided(
    Map<String, Object?> params,
    String key,
    Object? value,
  ) {
    if (!identical(value, _omitted)) {
      params[key] = value;
    }
  }
}
