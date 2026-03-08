import 'package:openclaw_gateway/src/protocol.dart';

class GatewayOkResult {
  const GatewayOkResult({
    required this.ok,
    required this.raw,
  });

  factory GatewayOkResult.fromJson(JsonMap json) {
    return GatewayOkResult(
      ok: readRequiredBool(json, 'ok', context: 'ok result'),
      raw: json,
    );
  }

  final bool ok;
  final JsonMap raw;
}

class GatewayEnabledResult {
  const GatewayEnabledResult({
    required this.enabled,
    this.raw = const <String, Object?>{},
  });

  factory GatewayEnabledResult.fromJson(JsonMap json) {
    return GatewayEnabledResult(
      enabled: readRequiredBool(json, 'enabled', context: 'enabled result'),
      raw: json,
    );
  }

  final bool enabled;
  final JsonMap raw;
}

class GatewayProviderResult {
  const GatewayProviderResult({
    required this.provider,
    this.raw = const <String, Object?>{},
  });

  factory GatewayProviderResult.fromJson(JsonMap json) {
    return GatewayProviderResult(
      provider:
          readRequiredString(json, 'provider', context: 'provider result'),
      raw: json,
    );
  }

  final String provider;
  final JsonMap raw;
}

class GatewayExecApprovalsAllowlistEntry {
  const GatewayExecApprovalsAllowlistEntry({
    required this.pattern,
    this.id,
    this.lastUsedAt,
    this.lastUsedCommand,
    this.lastResolvedPath,
  });

  factory GatewayExecApprovalsAllowlistEntry.fromJson(JsonMap json) {
    return GatewayExecApprovalsAllowlistEntry(
      pattern: readRequiredString(
        json,
        'pattern',
        context: 'exec approvals allowlist entry',
      ),
      id: readNullableString(json['id']),
      lastUsedAt: readNullableInt(json['lastUsedAt']),
      lastUsedCommand: readNullableString(json['lastUsedCommand']),
      lastResolvedPath: readNullableString(json['lastResolvedPath']),
    );
  }

  final String pattern;
  final String? id;
  final int? lastUsedAt;
  final String? lastUsedCommand;
  final String? lastResolvedPath;
}

class GatewayExecApprovalsPolicy {
  const GatewayExecApprovalsPolicy({
    this.security,
    this.ask,
    this.askFallback,
    this.autoAllowSkills,
    this.allowlist = const <GatewayExecApprovalsAllowlistEntry>[],
    this.raw = const <String, Object?>{},
  });

  factory GatewayExecApprovalsPolicy.fromJson(JsonMap json) {
    return GatewayExecApprovalsPolicy(
      security: readNullableString(json['security']),
      ask: readNullableString(json['ask']),
      askFallback: readNullableString(json['askFallback']),
      autoAllowSkills: readNullableBool(json['autoAllowSkills']),
      allowlist: json['allowlist'] == null
          ? const <GatewayExecApprovalsAllowlistEntry>[]
          : readJsonMapList(
              json['allowlist'],
              context: 'exec approvals policy.allowlist',
            )
              .map(GatewayExecApprovalsAllowlistEntry.fromJson)
              .toList(growable: false),
      raw: json,
    );
  }

  final String? security;
  final String? ask;
  final String? askFallback;
  final bool? autoAllowSkills;
  final List<GatewayExecApprovalsAllowlistEntry> allowlist;
  final JsonMap raw;
}

class GatewayExecApprovalsFile {
  const GatewayExecApprovalsFile({
    required this.version,
    this.socketPath,
    this.defaults,
    this.agents = const <String, GatewayExecApprovalsPolicy>{},
    this.raw = const <String, Object?>{},
  });

  factory GatewayExecApprovalsFile.fromJson(JsonMap json) {
    final agentsValue = json['agents'] == null
        ? const <String, Object?>{}
        : asJsonMap(
            json['agents'],
            context: 'exec approvals file.agents',
          );
    final agents = <String, GatewayExecApprovalsPolicy>{};
    for (final entry in agentsValue.entries) {
      agents[entry.key] = GatewayExecApprovalsPolicy.fromJson(
        asJsonMap(
          entry.value,
          context: 'exec approvals file.agents.${entry.key}',
        ),
      );
    }
    return GatewayExecApprovalsFile(
      version: readRequiredInt(json, 'version', context: 'exec approvals file'),
      socketPath: json['socket'] == null
          ? null
          : readNullableString(
              asJsonMap(json['socket'],
                  context: 'exec approvals file.socket')['path'],
            ),
      defaults: json['defaults'] == null
          ? null
          : GatewayExecApprovalsPolicy.fromJson(
              asJsonMap(
                json['defaults'],
                context: 'exec approvals file.defaults',
              ),
            ),
      agents: Map<String, GatewayExecApprovalsPolicy>.unmodifiable(agents),
      raw: json,
    );
  }

  final int version;
  final String? socketPath;
  final GatewayExecApprovalsPolicy? defaults;
  final Map<String, GatewayExecApprovalsPolicy> agents;
  final JsonMap raw;
}

class GatewayExecApprovalsSnapshot {
  const GatewayExecApprovalsSnapshot({
    required this.path,
    required this.exists,
    required this.file,
    this.hash,
    this.raw = const <String, Object?>{},
  });

  factory GatewayExecApprovalsSnapshot.fromJson(JsonMap json) {
    return GatewayExecApprovalsSnapshot(
      path: readRequiredString(json, 'path', context: 'exec approvals'),
      exists: readRequiredBool(json, 'exists', context: 'exec approvals'),
      hash: readNullableString(json['hash']),
      file: json['file'] == null
          ? null
          : GatewayExecApprovalsFile.fromJson(
              asJsonMap(json['file'], context: 'exec approvals.file'),
            ),
      raw: json,
    );
  }

  final String path;
  final bool exists;
  final String? hash;
  final GatewayExecApprovalsFile? file;
  final JsonMap raw;
}

class GatewayExecApprovalRequestStatus {
  const GatewayExecApprovalRequestStatus({
    required this.id,
    this.status,
    this.decision,
    this.createdAtMs,
    this.expiresAtMs,
    this.raw = const <String, Object?>{},
  });

  factory GatewayExecApprovalRequestStatus.fromJson(JsonMap json) {
    return GatewayExecApprovalRequestStatus(
      id: readRequiredString(json, 'id', context: 'exec approval request'),
      status: readNullableString(json['status']),
      decision: readNullableString(json['decision']),
      createdAtMs: readNullableInt(json['createdAtMs']),
      expiresAtMs: readNullableInt(json['expiresAtMs']),
      raw: json,
    );
  }

  final String id;
  final String? status;
  final String? decision;
  final int? createdAtMs;
  final int? expiresAtMs;
  final JsonMap raw;
}

class GatewayWizardOption {
  const GatewayWizardOption({
    required this.label,
    this.value,
    this.description,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWizardOption.fromJson(JsonMap json) {
    return GatewayWizardOption(
      label: readRequiredString(json, 'label', context: 'wizard option'),
      value: json['value'],
      description: readNullableString(json['description']),
      raw: json,
    );
  }

  final String label;
  final Object? value;
  final String? description;
  final JsonMap raw;
}

class GatewayWizardStep {
  const GatewayWizardStep({
    required this.id,
    required this.type,
    this.title,
    this.message,
    this.options = const <GatewayWizardOption>[],
    this.initialValue,
    this.placeholder,
    this.sensitive,
    this.executor,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWizardStep.fromJson(JsonMap json) {
    return GatewayWizardStep(
      id: readRequiredString(json, 'id', context: 'wizard step'),
      type: readRequiredString(json, 'type', context: 'wizard step'),
      title: readNullableString(json['title']),
      message: readNullableString(json['message']),
      options: json['options'] == null
          ? const <GatewayWizardOption>[]
          : readJsonMapList(json['options'], context: 'wizard step.options')
              .map(GatewayWizardOption.fromJson)
              .toList(growable: false),
      initialValue: json['initialValue'],
      placeholder: readNullableString(json['placeholder']),
      sensitive: readNullableBool(json['sensitive']),
      executor: readNullableString(json['executor']),
      raw: json,
    );
  }

  final String id;
  final String type;
  final String? title;
  final String? message;
  final List<GatewayWizardOption> options;
  final Object? initialValue;
  final String? placeholder;
  final bool? sensitive;
  final String? executor;
  final JsonMap raw;
}

class GatewayWizardStatus {
  const GatewayWizardStatus({
    required this.status,
    this.error,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWizardStatus.fromJson(JsonMap json) {
    return GatewayWizardStatus(
      status: readRequiredString(json, 'status', context: 'wizard status'),
      error: readNullableString(json['error']),
      raw: json,
    );
  }

  final String status;
  final String? error;
  final JsonMap raw;
}

class GatewayWizardStepResult extends GatewayWizardStatus {
  const GatewayWizardStepResult({
    required super.status,
    required this.done,
    this.sessionId,
    this.step,
    super.error,
    super.raw,
  });

  factory GatewayWizardStepResult.fromJson(JsonMap json) {
    return GatewayWizardStepResult(
      status: readNullableString(json['status']) ??
          (json['done'] == true ? 'done' : 'running'),
      done: readRequiredBool(json, 'done', context: 'wizard step result'),
      sessionId: readNullableString(json['sessionId']),
      step: json['step'] == null
          ? null
          : GatewayWizardStep.fromJson(
              asJsonMap(json['step'], context: 'wizard step result.step'),
            ),
      error: readNullableString(json['error']),
      raw: json,
    );
  }

  final bool done;
  final String? sessionId;
  final GatewayWizardStep? step;
}

class GatewayTalkConfig {
  const GatewayTalkConfig({
    required this.config,
  });

  factory GatewayTalkConfig.fromJson(JsonMap json) {
    return GatewayTalkConfig(
      config: json['config'] == null
          ? const <String, Object?>{}
          : asJsonMap(json['config'], context: 'talk.config.config'),
    );
  }

  final JsonMap config;
}

class GatewayTalkModeState {
  const GatewayTalkModeState({
    required this.enabled,
    required this.ts,
    this.phase,
    this.raw = const <String, Object?>{},
  });

  factory GatewayTalkModeState.fromJson(JsonMap json) {
    return GatewayTalkModeState(
      enabled: readRequiredBool(json, 'enabled', context: 'talk.mode'),
      ts: readRequiredInt(json, 'ts', context: 'talk.mode'),
      phase: readNullableString(json['phase']),
      raw: json,
    );
  }

  final bool enabled;
  final int ts;
  final String? phase;
  final JsonMap raw;
}

class GatewayWebLoginStartResult {
  const GatewayWebLoginStartResult({
    required this.message,
    this.qrDataUrl,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWebLoginStartResult.fromJson(JsonMap json) {
    return GatewayWebLoginStartResult(
      message: readRequiredString(json, 'message', context: 'web.login.start'),
      qrDataUrl: readNullableString(json['qrDataUrl']),
      raw: json,
    );
  }

  final String message;
  final String? qrDataUrl;
  final JsonMap raw;
}

class GatewayWebLoginWaitResult {
  const GatewayWebLoginWaitResult({
    required this.connected,
    required this.message,
    this.raw = const <String, Object?>{},
  });

  factory GatewayWebLoginWaitResult.fromJson(JsonMap json) {
    return GatewayWebLoginWaitResult(
      connected: readRequiredBool(json, 'connected', context: 'web.login.wait'),
      message: readRequiredString(json, 'message', context: 'web.login.wait'),
      raw: json,
    );
  }

  final bool connected;
  final String message;
  final JsonMap raw;
}

class GatewayUsageProviderWindow {
  const GatewayUsageProviderWindow({
    required this.label,
    required this.usedPercent,
    this.resetAt,
  });

  factory GatewayUsageProviderWindow.fromJson(JsonMap json) {
    return GatewayUsageProviderWindow(
      label: readRequiredString(json, 'label', context: 'usage window'),
      usedPercent:
          readRequiredInt(json, 'usedPercent', context: 'usage window'),
      resetAt: readNullableInt(json['resetAt']),
    );
  }

  final String label;
  final int usedPercent;
  final int? resetAt;
}

class GatewayUsageProviderSummary {
  const GatewayUsageProviderSummary({
    required this.provider,
    required this.displayName,
    required this.windows,
    this.plan,
    this.error,
  });

  factory GatewayUsageProviderSummary.fromJson(JsonMap json) {
    return GatewayUsageProviderSummary(
      provider: readRequiredString(json, 'provider', context: 'usage provider'),
      displayName: readRequiredString(
        json,
        'displayName',
        context: 'usage provider',
      ),
      windows:
          readJsonMapList(json['windows'], context: 'usage provider.windows')
              .map(GatewayUsageProviderWindow.fromJson)
              .toList(growable: false),
      plan: readNullableString(json['plan']),
      error: readNullableString(json['error']),
    );
  }

  final String provider;
  final String displayName;
  final List<GatewayUsageProviderWindow> windows;
  final String? plan;
  final String? error;
}

class GatewayUsageStatusResult {
  const GatewayUsageStatusResult({
    required this.updatedAt,
    required this.providers,
    this.raw = const <String, Object?>{},
  });

  factory GatewayUsageStatusResult.fromJson(JsonMap json) {
    final updatedAtValue = json['updatedAt'];
    return GatewayUsageStatusResult(
      updatedAt: updatedAtValue?.toString(),
      providers: readJsonMapList(
        json['providers'],
        context: 'usage.status.providers',
      ).map(GatewayUsageProviderSummary.fromJson).toList(growable: false),
      raw: json,
    );
  }

  final String? updatedAt;
  final List<GatewayUsageProviderSummary> providers;
  final JsonMap raw;
}

class GatewayUsageCostLine {
  const GatewayUsageCostLine({
    this.date,
    required this.input,
    required this.output,
    required this.cacheRead,
    required this.cacheWrite,
    required this.totalTokens,
    required this.totalCost,
    required this.inputCost,
    required this.outputCost,
    required this.cacheReadCost,
    required this.cacheWriteCost,
    required this.missingCostEntries,
  });

  factory GatewayUsageCostLine.fromJson(JsonMap json) {
    return GatewayUsageCostLine(
      date: readNullableString(json['date']),
      input: readRequiredInt(json, 'input', context: 'usage.cost line'),
      output: readRequiredInt(json, 'output', context: 'usage.cost line'),
      cacheRead: readRequiredInt(json, 'cacheRead', context: 'usage.cost line'),
      cacheWrite: readRequiredInt(
        json,
        'cacheWrite',
        context: 'usage.cost line',
      ),
      totalTokens: readRequiredInt(
        json,
        'totalTokens',
        context: 'usage.cost line',
      ),
      totalCost: json['totalCost'] as num,
      inputCost: json['inputCost'] as num,
      outputCost: json['outputCost'] as num,
      cacheReadCost: json['cacheReadCost'] as num,
      cacheWriteCost: json['cacheWriteCost'] as num,
      missingCostEntries: readRequiredInt(
        json,
        'missingCostEntries',
        context: 'usage.cost line',
      ),
    );
  }

  final String? date;
  final int input;
  final int output;
  final int cacheRead;
  final int cacheWrite;
  final int totalTokens;
  final num totalCost;
  final num inputCost;
  final num outputCost;
  final num cacheReadCost;
  final num cacheWriteCost;
  final int missingCostEntries;
}

class GatewayUsageCostResult {
  const GatewayUsageCostResult({
    required this.updatedAt,
    required this.days,
    required this.daily,
    required this.totals,
    this.raw = const <String, Object?>{},
  });

  factory GatewayUsageCostResult.fromJson(JsonMap json) {
    return GatewayUsageCostResult(
      updatedAt: readRequiredInt(json, 'updatedAt', context: 'usage.cost'),
      days: readRequiredInt(json, 'days', context: 'usage.cost'),
      daily: readJsonMapList(json['daily'], context: 'usage.cost.daily')
          .map(GatewayUsageCostLine.fromJson)
          .toList(growable: false),
      totals: GatewayUsageCostLine.fromJson(
        asJsonMap(json['totals'], context: 'usage.cost.totals'),
      ),
      raw: json,
    );
  }

  final int updatedAt;
  final int days;
  final List<GatewayUsageCostLine> daily;
  final GatewayUsageCostLine totals;
  final JsonMap raw;
}

class GatewayTtsStatus {
  const GatewayTtsStatus({
    required this.enabled,
    this.auto,
    this.provider,
    this.fallbackProvider,
    this.fallbackProviders = const <String>[],
    this.prefsPath,
    this.hasOpenAIKey,
    this.hasElevenLabsKey,
    this.edgeEnabled,
    this.raw = const <String, Object?>{},
  });

  factory GatewayTtsStatus.fromJson(JsonMap json) {
    return GatewayTtsStatus(
      enabled: readRequiredBool(json, 'enabled', context: 'tts.status'),
      auto: readNullableBool(json['auto']),
      provider: readNullableString(json['provider']),
      fallbackProvider: readNullableString(json['fallbackProvider']),
      fallbackProviders: json['fallbackProviders'] == null
          ? const <String>[]
          : readStringList(
              json['fallbackProviders'],
              context: 'tts.status.fallbackProviders',
            ),
      prefsPath: readNullableString(json['prefsPath']),
      hasOpenAIKey: readNullableBool(json['hasOpenAIKey']),
      hasElevenLabsKey: readNullableBool(json['hasElevenLabsKey']),
      edgeEnabled: readNullableBool(json['edgeEnabled']),
      raw: json,
    );
  }

  final bool enabled;
  final bool? auto;
  final String? provider;
  final String? fallbackProvider;
  final List<String> fallbackProviders;
  final String? prefsPath;
  final bool? hasOpenAIKey;
  final bool? hasElevenLabsKey;
  final bool? edgeEnabled;

  bool? get autoEnabled {
    final value = auto;
    if (value is bool) {
      return value;
    }
    if (value is String) {
      switch (value) {
        case 'on':
        case 'auto':
        case 'enabled':
          return true;
        case 'off':
        case 'disabled':
          return false;
      }
    }
    return null;
  }

  final JsonMap raw;
}

class GatewayTtsProviderInfo {
  const GatewayTtsProviderInfo({
    required this.id,
    required this.name,
    required this.configured,
    required this.models,
    this.voices = const <Object?>[],
    this.raw = const <String, Object?>{},
  });

  factory GatewayTtsProviderInfo.fromJson(JsonMap json) {
    return GatewayTtsProviderInfo(
      id: readRequiredString(json, 'id', context: 'tts provider'),
      name: readRequiredString(json, 'name', context: 'tts provider'),
      configured: readRequiredBool(json, 'configured', context: 'tts provider'),
      models: readStringList(json['models'], context: 'tts provider.models'),
      voices: json['voices'] == null
          ? const <Object?>[]
          : asJsonList(json['voices'], context: 'tts provider.voices'),
      raw: json,
    );
  }

  final String id;
  final String name;
  final bool configured;
  final List<String> models;
  final List<Object?> voices;
  final JsonMap raw;
}

class GatewayTtsProvidersResult {
  const GatewayTtsProvidersResult({
    required this.providers,
    this.active,
    this.raw = const <String, Object?>{},
  });

  factory GatewayTtsProvidersResult.fromJson(JsonMap json) {
    return GatewayTtsProvidersResult(
      providers: readJsonMapList(json['providers'], context: 'tts.providers')
          .map(GatewayTtsProviderInfo.fromJson)
          .toList(growable: false),
      active: readNullableString(json['active']),
      raw: json,
    );
  }

  final List<GatewayTtsProviderInfo> providers;
  final String? active;
  final JsonMap raw;
}

class GatewayTtsEnabledResult {
  const GatewayTtsEnabledResult({
    required this.enabled,
    this.raw = const <String, Object?>{},
  });

  factory GatewayTtsEnabledResult.fromJson(JsonMap json) {
    return GatewayTtsEnabledResult(
      enabled: readRequiredBool(json, 'enabled', context: 'tts toggle'),
      raw: json,
    );
  }

  final bool enabled;
  final JsonMap raw;
}

class GatewayTtsConvertResult {
  const GatewayTtsConvertResult({
    required this.audioPath,
    required this.provider,
    required this.outputFormat,
    required this.voiceCompatible,
    this.raw = const <String, Object?>{},
  });

  factory GatewayTtsConvertResult.fromJson(JsonMap json) {
    return GatewayTtsConvertResult(
      audioPath: readRequiredString(json, 'audioPath', context: 'tts.convert'),
      provider: readRequiredString(json, 'provider', context: 'tts.convert'),
      outputFormat: readRequiredString(
        json,
        'outputFormat',
        context: 'tts.convert',
      ),
      voiceCompatible: readRequiredBool(
        json,
        'voiceCompatible',
        context: 'tts.convert',
      ),
      raw: json,
    );
  }

  final String audioPath;
  final String provider;
  final String outputFormat;
  final bool voiceCompatible;
  final JsonMap raw;
}

class GatewayLogsTailResult {
  const GatewayLogsTailResult({
    required this.file,
    required this.cursor,
    required this.size,
    required this.lines,
    this.truncated,
    this.reset,
    this.raw = const <String, Object?>{},
  });

  factory GatewayLogsTailResult.fromJson(JsonMap json) {
    return GatewayLogsTailResult(
      file: readRequiredString(json, 'file', context: 'logs.tail'),
      cursor: readRequiredInt(json, 'cursor', context: 'logs.tail'),
      size: readRequiredInt(json, 'size', context: 'logs.tail'),
      lines: readStringList(json['lines'], context: 'logs.tail.lines'),
      truncated: readNullableBool(json['truncated']),
      reset: readNullableBool(json['reset']),
      raw: json,
    );
  }

  final String file;
  final int cursor;
  final int size;
  final List<String> lines;
  final bool? truncated;
  final bool? reset;
  final JsonMap raw;
}

class GatewayDoctorMemoryStatus {
  const GatewayDoctorMemoryStatus({
    required this.agentId,
    required this.embedding,
    this.provider,
    this.raw = const <String, Object?>{},
  });

  factory GatewayDoctorMemoryStatus.fromJson(JsonMap json) {
    return GatewayDoctorMemoryStatus(
      agentId: readRequiredString(
        json,
        'agentId',
        context: 'doctor.memory.status',
      ),
      provider: readNullableString(json['provider']),
      embedding: asJsonMap(
        json['embedding'],
        context: 'doctor.memory.status.embedding',
      ),
      raw: json,
    );
  }

  final String agentId;
  final String? provider;
  final JsonMap embedding;
  final JsonMap raw;
}

class GatewayLastHeartbeatResult {
  const GatewayLastHeartbeatResult({
    required this.ts,
    required this.status,
    this.to,
    this.accountId,
    this.preview,
    this.durationMs,
    this.hasMedia,
    this.reason,
    this.channel,
    this.silent,
    this.indicatorType,
    this.raw = const <String, Object?>{},
  });

  factory GatewayLastHeartbeatResult.fromJson(JsonMap json) {
    return GatewayLastHeartbeatResult(
      ts: readRequiredInt(json, 'ts', context: 'last-heartbeat'),
      status: readRequiredString(json, 'status', context: 'last-heartbeat'),
      to: readNullableString(json['to']),
      accountId: readNullableString(json['accountId']),
      preview: readNullableString(json['preview']),
      durationMs: readNullableInt(json['durationMs']),
      hasMedia: readNullableBool(json['hasMedia']),
      reason: readNullableString(json['reason']),
      channel: readNullableString(json['channel']),
      silent: readNullableBool(json['silent']),
      indicatorType: readNullableString(json['indicatorType']),
      raw: json,
    );
  }

  final int ts;
  final String status;
  final String? to;
  final String? accountId;
  final String? preview;
  final int? durationMs;
  final bool? hasMedia;
  final String? reason;
  final String? channel;
  final bool? silent;
  final String? indicatorType;
  final JsonMap raw;
}
