import 'package:openclaw_gateway/src/protocol.dart';

class GatewayAgentSummary {
  const GatewayAgentSummary({
    required this.id,
    this.name,
    this.identity,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentSummary.fromJson(JsonMap json) {
    return GatewayAgentSummary(
      id: readRequiredString(json, 'id', context: 'agent summary'),
      name: readNullableString(json['name']),
      identity: json['identity'] == null
          ? null
          : asJsonMap(json['identity'], context: 'agent summary.identity'),
      raw: json,
    );
  }

  final String id;
  final String? name;
  final JsonMap? identity;
  final JsonMap raw;
}

class GatewayAgentsListResult {
  const GatewayAgentsListResult({
    required this.defaultId,
    required this.mainKey,
    required this.scope,
    required this.agents,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentsListResult.fromJson(JsonMap json) {
    return GatewayAgentsListResult(
      defaultId: readRequiredString(json, 'defaultId', context: 'agents.list'),
      mainKey: readRequiredString(json, 'mainKey', context: 'agents.list'),
      scope: readRequiredString(json, 'scope', context: 'agents.list'),
      agents: readJsonMapList(json['agents'], context: 'agents.list.agents')
          .map(GatewayAgentSummary.fromJson)
          .toList(growable: false),
      raw: json,
    );
  }

  final String defaultId;
  final String mainKey;
  final String scope;
  final List<GatewayAgentSummary> agents;
  final JsonMap raw;
}

class GatewayAgentFileEntry {
  const GatewayAgentFileEntry({
    required this.name,
    required this.path,
    required this.missing,
    this.size,
    this.updatedAtMs,
    this.content,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentFileEntry.fromJson(JsonMap json) {
    return GatewayAgentFileEntry(
      name: readRequiredString(json, 'name', context: 'agent file'),
      path: readRequiredString(json, 'path', context: 'agent file'),
      missing: readRequiredBool(json, 'missing', context: 'agent file'),
      size: readNullableInt(json['size']),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
      content: json['content'] is String ? json['content'] as String : null,
      raw: json,
    );
  }

  final String name;
  final String path;
  final bool missing;
  final int? size;
  final int? updatedAtMs;
  final String? content;
  final JsonMap raw;
}

class GatewayAgentsCreateResult {
  const GatewayAgentsCreateResult({
    required this.ok,
    required this.agentId,
    required this.name,
    required this.workspace,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentsCreateResult.fromJson(JsonMap json) {
    return GatewayAgentsCreateResult(
      ok: readRequiredBool(json, 'ok', context: 'agents.create'),
      agentId: readRequiredString(json, 'agentId', context: 'agents.create'),
      name: readRequiredString(json, 'name', context: 'agents.create'),
      workspace:
          readRequiredString(json, 'workspace', context: 'agents.create'),
      raw: json,
    );
  }

  final bool ok;
  final String agentId;
  final String name;
  final String workspace;
  final JsonMap raw;
}

class GatewayAgentsUpdateResult {
  const GatewayAgentsUpdateResult({
    required this.ok,
    required this.agentId,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentsUpdateResult.fromJson(JsonMap json) {
    return GatewayAgentsUpdateResult(
      ok: readRequiredBool(json, 'ok', context: 'agents.update'),
      agentId: readRequiredString(json, 'agentId', context: 'agents.update'),
      raw: json,
    );
  }

  final bool ok;
  final String agentId;
  final JsonMap raw;
}

class GatewayAgentsDeleteResult {
  const GatewayAgentsDeleteResult({
    required this.ok,
    required this.agentId,
    required this.removedBindings,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentsDeleteResult.fromJson(JsonMap json) {
    return GatewayAgentsDeleteResult(
      ok: readRequiredBool(json, 'ok', context: 'agents.delete'),
      agentId: readRequiredString(json, 'agentId', context: 'agents.delete'),
      removedBindings: readRequiredInt(
        json,
        'removedBindings',
        context: 'agents.delete',
      ),
      raw: json,
    );
  }

  final bool ok;
  final String agentId;
  final int removedBindings;
  final JsonMap raw;
}

class GatewayAgentFilesListResult {
  const GatewayAgentFilesListResult({
    required this.agentId,
    required this.workspace,
    required this.files,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentFilesListResult.fromJson(JsonMap json) {
    return GatewayAgentFilesListResult(
      agentId: readRequiredString(json, 'agentId', context: 'agents.files'),
      workspace: readRequiredString(json, 'workspace', context: 'agents.files'),
      files: readJsonMapList(json['files'], context: 'agents.files.files')
          .map(GatewayAgentFileEntry.fromJson)
          .toList(growable: false),
      raw: json,
    );
  }

  final String agentId;
  final String workspace;
  final List<GatewayAgentFileEntry> files;
  final JsonMap raw;
}

class GatewayAgentFileResult {
  const GatewayAgentFileResult({
    required this.agentId,
    required this.workspace,
    required this.file,
    this.ok,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentFileResult.fromJson(JsonMap json) {
    return GatewayAgentFileResult(
      agentId: readRequiredString(json, 'agentId', context: 'agent file'),
      workspace: readRequiredString(json, 'workspace', context: 'agent file'),
      file: GatewayAgentFileEntry.fromJson(
        asJsonMap(json['file'], context: 'agent file.file'),
      ),
      ok: readNullableBool(json['ok']),
      raw: json,
    );
  }

  final String agentId;
  final String workspace;
  final GatewayAgentFileEntry file;
  final bool? ok;
  final JsonMap raw;
}

class GatewaySkillsStatusResult {
  const GatewaySkillsStatusResult({
    required this.workspaceDir,
    required this.managedSkillsDir,
    required this.skills,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySkillsStatusResult.fromJson(JsonMap json) {
    return GatewaySkillsStatusResult(
      workspaceDir: readRequiredString(
        json,
        'workspaceDir',
        context: 'skills.status',
      ),
      managedSkillsDir: readRequiredString(
        json,
        'managedSkillsDir',
        context: 'skills.status',
      ),
      skills: readJsonMapList(json['skills'], context: 'skills.status.skills'),
      raw: json,
    );
  }

  final String workspaceDir;
  final String managedSkillsDir;
  final List<JsonMap> skills;
  final JsonMap raw;
}

class GatewaySkillsBinsResult {
  const GatewaySkillsBinsResult({
    required this.bins,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySkillsBinsResult.fromJson(JsonMap json) {
    return GatewaySkillsBinsResult(
      bins: readStringList(json['bins'], context: 'skills.bins'),
      raw: json,
    );
  }

  final List<String> bins;
  final JsonMap raw;
}

class GatewaySkillInstallResult {
  const GatewaySkillInstallResult({
    required this.ok,
    required this.message,
    required this.stdout,
    required this.stderr,
    required this.code,
    this.warnings = const <String>[],
    this.raw = const <String, Object?>{},
  });

  factory GatewaySkillInstallResult.fromJson(JsonMap json) {
    return GatewaySkillInstallResult(
      ok: readRequiredBool(json, 'ok', context: 'skills.install'),
      message: readRequiredString(json, 'message', context: 'skills.install'),
      stdout: readNullableString(json['stdout']) ?? '',
      stderr: readNullableString(json['stderr']) ?? '',
      code: readRequiredInt(json, 'code', context: 'skills.install'),
      warnings: json['warnings'] == null
          ? const <String>[]
          : readStringList(json['warnings'],
              context: 'skills.install.warnings'),
      raw: json,
    );
  }

  final bool ok;
  final String message;
  final String stdout;
  final String stderr;
  final int code;
  final List<String> warnings;
  final JsonMap raw;
}

class GatewaySkillUpdateResult {
  const GatewaySkillUpdateResult({
    required this.ok,
    required this.skillKey,
    required this.config,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySkillUpdateResult.fromJson(JsonMap json) {
    return GatewaySkillUpdateResult(
      ok: readRequiredBool(json, 'ok', context: 'skills.update'),
      skillKey: readRequiredString(json, 'skillKey', context: 'skills.update'),
      config: asJsonMap(json['config'], context: 'skills.update.config'),
      raw: json,
    );
  }

  final bool ok;
  final String skillKey;
  final JsonMap config;
  final JsonMap raw;
}

class GatewayUpdateRunResponse {
  const GatewayUpdateRunResponse({
    required this.ok,
    required this.result,
    required this.restart,
    required this.sentinel,
    this.raw = const <String, Object?>{},
  });

  factory GatewayUpdateRunResponse.fromJson(JsonMap json) {
    return GatewayUpdateRunResponse(
      ok: readRequiredBool(json, 'ok', context: 'update.run'),
      result: asJsonMap(json['result'], context: 'update.run.result'),
      restart: asJsonMap(json['restart'], context: 'update.run.restart'),
      sentinel: asJsonMap(json['sentinel'], context: 'update.run.sentinel'),
      raw: json,
    );
  }

  final bool ok;
  final JsonMap result;
  final JsonMap restart;
  final JsonMap sentinel;
  final JsonMap raw;
}

class GatewaySecretsReloadResult {
  const GatewaySecretsReloadResult({
    required this.ok,
    required this.warningCount,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySecretsReloadResult.fromJson(JsonMap json) {
    return GatewaySecretsReloadResult(
      ok: readRequiredBool(json, 'ok', context: 'secrets.reload'),
      warningCount: readRequiredInt(
        json,
        'warningCount',
        context: 'secrets.reload',
      ),
      raw: json,
    );
  }

  final bool ok;
  final int warningCount;
  final JsonMap raw;
}

class GatewaySecretsResolveResult {
  const GatewaySecretsResolveResult({
    required this.ok,
    required this.assignments,
    required this.diagnostics,
    required this.inactiveRefPaths,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySecretsResolveResult.fromJson(JsonMap json) {
    return GatewaySecretsResolveResult(
      ok: readRequiredBool(json, 'ok', context: 'secrets.resolve'),
      assignments: readJsonMapList(
        json['assignments'],
        context: 'secrets.resolve.assignments',
      ),
      diagnostics: json['diagnostics'] == null
          ? const <String>[]
          : readStringList(
              json['diagnostics'],
              context: 'secrets.resolve.diagnostics',
            ),
      inactiveRefPaths: json['inactiveRefPaths'] == null
          ? const <String>[]
          : readStringList(
              json['inactiveRefPaths'],
              context: 'secrets.resolve.inactiveRefPaths',
            ),
      raw: json,
    );
  }

  final bool ok;
  final List<JsonMap> assignments;
  final List<String> diagnostics;
  final List<String> inactiveRefPaths;
  final JsonMap raw;
}

class GatewaySetHeartbeatsResult {
  const GatewaySetHeartbeatsResult({
    required this.ok,
    required this.enabled,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySetHeartbeatsResult.fromJson(JsonMap json) {
    return GatewaySetHeartbeatsResult(
      ok: readRequiredBool(json, 'ok', context: 'set-heartbeats'),
      enabled: readRequiredBool(json, 'enabled', context: 'set-heartbeats'),
      raw: json,
    );
  }

  final bool ok;
  final bool enabled;
  final JsonMap raw;
}

class GatewayWakeResult {
  const GatewayWakeResult({
    required this.ok,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWakeResult.fromJson(JsonMap json) {
    return GatewayWakeResult(
      ok: readRequiredBool(json, 'ok', context: 'wake'),
      raw: json,
    );
  }

  final bool ok;
  final JsonMap raw;
}

class GatewaySendResult {
  const GatewaySendResult({
    required this.runId,
    required this.messageId,
    required this.channel,
    this.chatId,
    this.channelId,
    this.toJid,
    this.conversationId,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySendResult.fromJson(JsonMap json) {
    return GatewaySendResult(
      runId: readRequiredString(json, 'runId', context: 'send'),
      messageId: readRequiredString(json, 'messageId', context: 'send'),
      channel: readRequiredString(json, 'channel', context: 'send'),
      chatId: readNullableString(json['chatId']),
      channelId: readNullableString(json['channelId']),
      toJid: readNullableString(json['toJid']),
      conversationId: readNullableString(json['conversationId']),
      raw: json,
    );
  }

  final String runId;
  final String messageId;
  final String channel;
  final String? chatId;
  final String? channelId;
  final String? toJid;
  final String? conversationId;
  final JsonMap raw;
}

class GatewayAgentRequestResult {
  const GatewayAgentRequestResult({
    required this.runId,
    required this.status,
    this.acceptedAt,
    this.summary,
    this.result,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentRequestResult.fromJson(JsonMap json) {
    return GatewayAgentRequestResult(
      runId: readRequiredString(json, 'runId', context: 'agent'),
      status: readRequiredString(json, 'status', context: 'agent'),
      acceptedAt: readNullableInt(json['acceptedAt']),
      summary: readNullableString(json['summary']),
      result: json['result'],
      raw: json,
    );
  }

  final String runId;
  final String status;
  final int? acceptedAt;
  final String? summary;
  final Object? result;
  final JsonMap raw;
}

class GatewayAgentIdentity {
  const GatewayAgentIdentity({
    required this.agentId,
    this.name,
    this.avatar,
    this.emoji,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentIdentity.fromJson(JsonMap json) {
    return GatewayAgentIdentity(
      agentId: readRequiredString(json, 'agentId', context: 'agent identity'),
      name: readNullableString(json['name']),
      avatar: readNullableString(json['avatar']),
      emoji: readNullableString(json['emoji']),
      raw: json,
    );
  }

  final String agentId;
  final String? name;
  final String? avatar;
  final String? emoji;
  final JsonMap raw;
}

class GatewayAgentWaitResult {
  const GatewayAgentWaitResult({
    required this.runId,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.error,
    this.raw = const <String, Object?>{},
  });

  factory GatewayAgentWaitResult.fromJson(JsonMap json) {
    return GatewayAgentWaitResult(
      runId: readRequiredString(json, 'runId', context: 'agent.wait'),
      status: readRequiredString(json, 'status', context: 'agent.wait'),
      startedAt: readNullableInt(json['startedAt']),
      endedAt: readNullableInt(json['endedAt']),
      error: readNullableString(json['error']),
      raw: json,
    );
  }

  final String runId;
  final String status;
  final int? startedAt;
  final int? endedAt;
  final String? error;
  final JsonMap raw;
}

class GatewayBrowserResponse {
  const GatewayBrowserResponse({
    required this.value,
  });

  factory GatewayBrowserResponse.fromPayload(Object? payload) {
    return GatewayBrowserResponse(value: payload);
  }

  final Object? value;
}
