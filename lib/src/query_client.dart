import 'package:openclaw_gateway/src/admin_models.dart';
import 'package:openclaw_gateway/src/automation_models.dart';
import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/event_models.dart';
import 'package:openclaw_gateway/src/protocol.dart';
import 'package:openclaw_gateway/src/query_models.dart';

/// Typed read/query wrappers for common operator-side gateway methods.
class GatewayQueryClient {
  const GatewayQueryClient(this._client);

  final GatewayClient _client;

  Future<GatewayHealthSummary> health({
    bool probe = false,
  }) async {
    final payload = await _client.requestJsonMap(
      'health',
      params: probe ? const {'probe': true} : null,
    );
    return GatewayHealthSummary.fromJson(payload);
  }

  Future<GatewayStatusSnapshot> status() async {
    final payload = await _client.requestJsonMap('status');
    return GatewayStatusSnapshot.fromJson(payload);
  }

  Future<List<GatewayPresenceEntry>> systemPresence() async {
    final payload = await _client.requestJsonList('system-presence');
    return payload
        .map(
          (entry) => GatewayPresenceEntry.fromJson(
            asJsonMap(entry, context: 'system-presence entry'),
          ),
        )
        .toList(growable: false);
  }

  Future<GatewayChannelsStatusResult> channelsStatus({
    bool? probe,
    int? timeoutMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'channels.status',
      params: withoutNulls({
        'probe': probe,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewayChannelsStatusResult.fromJson(payload);
  }

  Future<GatewayConfigSnapshot> configGet() async {
    final payload = await _client.requestJsonMap('config.get');
    return GatewayConfigSnapshot.fromJson(payload);
  }

  Future<GatewayConfigSchemaResponse> configSchema() async {
    final payload = await _client.requestJsonMap('config.schema');
    return GatewayConfigSchemaResponse.fromJson(payload);
  }

  Future<GatewayConfigSchemaLookupResult> configSchemaLookup({
    required String path,
  }) async {
    final payload = await _client.requestJsonMap(
      'config.schema.lookup',
      params: <String, Object?>{
        'path': path,
      },
    );
    return GatewayConfigSchemaLookupResult.fromJson(payload);
  }

  Future<GatewaySessionsListResult> sessionsList({
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
  }) async {
    final payload = await _client.requestJsonMap(
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
    return GatewaySessionsListResult.fromJson(payload);
  }

  Future<GatewaySessionsPreviewResult> sessionsPreview({
    required List<String> keys,
    int? limit,
    int? maxChars,
  }) async {
    final payload = await _client.requestJsonMap(
      'sessions.preview',
      params: withoutNulls({
        'keys': keys,
        'limit': limit,
        'maxChars': maxChars,
      }),
    );
    return GatewaySessionsPreviewResult.fromJson(payload);
  }

  Future<GatewayModelsListResult> modelsList() async {
    final payload = await _client.requestJsonMap('models.list');
    return GatewayModelsListResult.fromJson(payload);
  }

  Future<GatewayToolsCatalogResult> toolsCatalog({
    String? agentId,
    bool? includePlugins,
  }) async {
    final payload = await _client.requestJsonMap(
      'tools.catalog',
      params: withoutNulls({
        'agentId': agentId,
        'includePlugins': includePlugins,
      }),
    );
    return GatewayToolsCatalogResult.fromJson(payload);
  }

  Future<GatewayVoiceWakeConfig> voiceWakeGet() async {
    final payload = await _client.requestJsonMap('voicewake.get');
    return GatewayVoiceWakeConfig.fromJson(payload);
  }

  Future<GatewayCronListResult> cronList({
    bool? includeDisabled,
    int? limit,
    int? offset,
    String? query,
    String? enabled,
    String? sortBy,
    String? sortDir,
  }) async {
    final payload = await _client.requestJsonMap(
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
    return GatewayCronListResult.fromJson(payload);
  }

  Future<GatewayCronStatusSummary> cronStatus() async {
    final payload = await _client.requestJsonMap('cron.status');
    return GatewayCronStatusSummary.fromJson(payload);
  }

  Future<GatewayCronRunsResult> cronRuns({
    String? scope,
    String? id,
    String? jobId,
    int? limit,
    int? offset,
    List<String>? statuses,
    String? status,
    List<String>? deliveryStatuses,
    String? deliveryStatus,
    String? query,
    String? sortDir,
  }) async {
    final payload = await _client.requestJsonMap(
      'cron.runs',
      params: withoutNulls({
        'scope': scope,
        'id': id,
        'jobId': jobId,
        'limit': limit,
        'offset': offset,
        'statuses': statuses,
        'status': status,
        'deliveryStatuses': deliveryStatuses,
        'deliveryStatus': deliveryStatus,
        'query': query,
        'sortDir': sortDir,
      }),
    );
    return GatewayCronRunsResult.fromJson(payload);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsGet() async {
    final payload = await _client.requestJsonMap('exec.approvals.get');
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsNodeGet({
    required String nodeId,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approvals.node.get',
      params: <String, Object?>{
        'nodeId': nodeId,
      },
    );
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayWizardStatus> wizardStatus({
    required String sessionId,
  }) async {
    final payload = await _client.requestJsonMap(
      'wizard.status',
      params: <String, Object?>{
        'sessionId': sessionId,
      },
    );
    return GatewayWizardStatus.fromJson(payload);
  }

  Future<GatewayTalkConfig> talkConfig({
    bool? includeSecrets,
  }) async {
    final payload = await _client.requestJsonMap(
      'talk.config',
      params: includeSecrets == null
          ? null
          : <String, Object?>{
              'includeSecrets': includeSecrets,
            },
    );
    return GatewayTalkConfig.fromJson(payload);
  }

  Future<GatewayUsageStatusResult> usageStatus() async {
    final payload = await _client.requestJsonMap('usage.status');
    return GatewayUsageStatusResult.fromJson(payload);
  }

  Future<GatewayUsageCostResult> usageCost({
    String? startDate,
    String? endDate,
    int? days,
    String? mode,
    String? utcOffset,
  }) async {
    final payload = await _client.requestJsonMap(
      'usage.cost',
      params: withoutNulls({
        'startDate': startDate,
        'endDate': endDate,
        'days': days,
        'mode': mode,
        'utcOffset': utcOffset,
      }),
    );
    return GatewayUsageCostResult.fromJson(payload);
  }

  Future<GatewayTtsStatus> ttsStatus() async {
    final payload = await _client.requestJsonMap('tts.status');
    return GatewayTtsStatus.fromJson(payload);
  }

  Future<GatewayTtsProvidersResult> ttsProviders() async {
    final payload = await _client.requestJsonMap('tts.providers');
    return GatewayTtsProvidersResult.fromJson(payload);
  }

  Future<GatewayLogsTailResult> logsTail({
    int? cursor,
    int? limit,
    int? maxBytes,
  }) async {
    final payload = await _client.requestJsonMap(
      'logs.tail',
      params: withoutNulls({
        'cursor': cursor,
        'limit': limit,
        'maxBytes': maxBytes,
      }),
    );
    return GatewayLogsTailResult.fromJson(payload);
  }

  Future<GatewayDoctorMemoryStatus> doctorMemoryStatus() async {
    final payload = await _client.requestJsonMap('doctor.memory.status');
    return GatewayDoctorMemoryStatus.fromJson(payload);
  }

  Future<GatewayAgentFilesListResult> agentFilesList({
    required String agentId,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.files.list',
      params: <String, Object?>{
        'agentId': agentId,
      },
    );
    return GatewayAgentFilesListResult.fromJson(payload);
  }

  Future<GatewayAgentFileResult> agentFileGet({
    required String agentId,
    required String name,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.files.get',
      params: <String, Object?>{
        'agentId': agentId,
        'name': name,
      },
    );
    return GatewayAgentFileResult.fromJson(payload);
  }

  Future<GatewaySkillsStatusResult> skillsStatus({
    String? agentId,
  }) async {
    final payload = await _client.requestJsonMap(
      'skills.status',
      params: agentId == null
          ? null
          : <String, Object?>{
              'agentId': agentId,
            },
    );
    return GatewaySkillsStatusResult.fromJson(payload);
  }

  Future<GatewayLastHeartbeatResult?> lastHeartbeat() async {
    final payload = await _client.request('last-heartbeat');
    if (payload == null) {
      return null;
    }
    return GatewayLastHeartbeatResult.fromJson(
      asJsonMap(payload, context: 'last-heartbeat'),
    );
  }

  Future<GatewayAgentIdentity> agentIdentityGet({
    String? agentId,
    String? sessionKey,
  }) async {
    final payload = await _client.requestJsonMap(
      'agent.identity.get',
      params: withoutNulls({
        'agentId': agentId,
        'sessionKey': sessionKey,
      }),
    );
    return GatewayAgentIdentity.fromJson(payload);
  }

  Future<GatewayAgentWaitResult> agentWait({
    required String runId,
    int? timeoutMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'agent.wait',
      params: withoutNulls({
        'runId': runId,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewayAgentWaitResult.fromJson(payload);
  }
}
