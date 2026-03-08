import 'package:openclaw_gateway/src/protocol.dart';

class GatewayHealthSummary {
  const GatewayHealthSummary({
    required this.ok,
    required this.ts,
    required this.channels,
    required this.channelOrder,
    required this.channelLabels,
    required this.agents,
    required this.sessions,
    this.durationMs,
    this.heartbeatSeconds,
    this.defaultAgentId,
    this.raw = const <String, Object?>{},
  });

  factory GatewayHealthSummary.fromJson(JsonMap json) {
    return GatewayHealthSummary(
      ok: readRequiredBool(json, 'ok', context: 'health'),
      ts: readRequiredInt(json, 'ts', context: 'health'),
      durationMs: readNullableInt(json['durationMs']),
      channels: _readJsonMap(json['channels'], context: 'health.channels'),
      channelOrder: json['channelOrder'] == null
          ? const <String>[]
          : readStringList(json['channelOrder'],
              context: 'health.channelOrder'),
      channelLabels: _readStringMap(
        json['channelLabels'],
        context: 'health.channelLabels',
      ),
      heartbeatSeconds: readNullableInt(json['heartbeatSeconds']),
      defaultAgentId: readNullableString(json['defaultAgentId']),
      agents: json['agents'],
      sessions: json['sessions'],
      raw: json,
    );
  }

  final bool ok;
  final int ts;
  final int? durationMs;
  final JsonMap channels;
  final List<String> channelOrder;
  final Map<String, String> channelLabels;
  final int? heartbeatSeconds;
  final String? defaultAgentId;
  final Object? agents;
  final Object? sessions;
  final JsonMap raw;
}

class GatewayStatusSnapshot {
  const GatewayStatusSnapshot(this.raw);

  factory GatewayStatusSnapshot.fromJson(JsonMap json) {
    return GatewayStatusSnapshot(json);
  }

  final JsonMap raw;
}

class GatewayChannelUiMeta {
  const GatewayChannelUiMeta({
    required this.id,
    required this.label,
    required this.detailLabel,
    this.systemImage,
  });

  factory GatewayChannelUiMeta.fromJson(JsonMap json) {
    return GatewayChannelUiMeta(
      id: readRequiredString(json, 'id', context: 'channel meta'),
      label: readRequiredString(json, 'label', context: 'channel meta'),
      detailLabel: readRequiredString(
        json,
        'detailLabel',
        context: 'channel meta',
      ),
      systemImage: readNullableString(json['systemImage']),
    );
  }

  final String id;
  final String label;
  final String detailLabel;
  final String? systemImage;
}

class GatewayChannelAccountSnapshot {
  const GatewayChannelAccountSnapshot({
    required this.accountId,
    required this.raw,
    this.name,
    this.enabled,
    this.configured,
    this.linked,
    this.running,
    this.connected,
    this.lastError,
    this.mode,
    this.lastProbeAt,
    this.lastInboundAt,
    this.lastOutboundAt,
  });

  factory GatewayChannelAccountSnapshot.fromJson(JsonMap json) {
    return GatewayChannelAccountSnapshot(
      accountId:
          readRequiredString(json, 'accountId', context: 'channel account'),
      raw: json,
      name: readNullableString(json['name']),
      enabled: _readNullableBool(json['enabled']),
      configured: _readNullableBool(json['configured']),
      linked: _readNullableBool(json['linked']),
      running: _readNullableBool(json['running']),
      connected: _readNullableBool(json['connected']),
      lastError: readNullableString(json['lastError']),
      mode: readNullableString(json['mode']),
      lastProbeAt: readNullableInt(json['lastProbeAt']),
      lastInboundAt: readNullableInt(json['lastInboundAt']),
      lastOutboundAt: readNullableInt(json['lastOutboundAt']),
    );
  }

  final String accountId;
  final JsonMap raw;
  final String? name;
  final bool? enabled;
  final bool? configured;
  final bool? linked;
  final bool? running;
  final bool? connected;
  final String? lastError;
  final String? mode;
  final int? lastProbeAt;
  final int? lastInboundAt;
  final int? lastOutboundAt;
}

class GatewayChannelsStatusResult {
  const GatewayChannelsStatusResult({
    required this.ts,
    required this.channelOrder,
    required this.channelLabels,
    required this.channelAccounts,
    required this.channelDefaultAccountId,
    required this.channels,
    this.channelDetailLabels = const <String, String>{},
    this.channelSystemImages = const <String, String>{},
    this.channelMeta = const <GatewayChannelUiMeta>[],
  });

  factory GatewayChannelsStatusResult.fromJson(JsonMap json) {
    final accountsValue = _readJsonMap(
      json['channelAccounts'],
      context: 'channels.status.channelAccounts',
    );
    final accountEntries = <String, List<GatewayChannelAccountSnapshot>>{};
    for (final entry in accountsValue.entries) {
      accountEntries[entry.key] = asJsonList(
        entry.value,
        context: 'channels.status.channelAccounts.${entry.key}',
      )
          .map(
            (item) => GatewayChannelAccountSnapshot.fromJson(
              _readJsonMap(
                item,
                context: 'channels.status.channelAccounts.${entry.key}[]',
              ),
            ),
          )
          .toList(growable: false);
    }

    return GatewayChannelsStatusResult(
      ts: readRequiredInt(json, 'ts', context: 'channels.status'),
      channelOrder: readStringList(
        json['channelOrder'],
        context: 'channels.status.channelOrder',
      ),
      channelLabels: _readStringMap(
        json['channelLabels'],
        context: 'channels.status.channelLabels',
      ),
      channelDetailLabels: _readStringMap(
        json['channelDetailLabels'],
        context: 'channels.status.channelDetailLabels',
      ),
      channelSystemImages: _readStringMap(
        json['channelSystemImages'],
        context: 'channels.status.channelSystemImages',
      ),
      channelMeta: json['channelMeta'] == null
          ? const <GatewayChannelUiMeta>[]
          : asJsonList(json['channelMeta'],
                  context: 'channels.status.channelMeta')
              .map(
                (item) => GatewayChannelUiMeta.fromJson(
                  _readJsonMap(item, context: 'channels.status.channelMeta[]'),
                ),
              )
              .toList(growable: false),
      channels:
          _readJsonMap(json['channels'], context: 'channels.status.channels'),
      channelAccounts: accountEntries,
      channelDefaultAccountId: _readStringMap(
        json['channelDefaultAccountId'],
        context: 'channels.status.channelDefaultAccountId',
      ),
    );
  }

  final int ts;
  final List<String> channelOrder;
  final Map<String, String> channelLabels;
  final Map<String, String> channelDetailLabels;
  final Map<String, String> channelSystemImages;
  final List<GatewayChannelUiMeta> channelMeta;
  final JsonMap channels;
  final Map<String, List<GatewayChannelAccountSnapshot>> channelAccounts;
  final Map<String, String> channelDefaultAccountId;
}

class GatewayConfigSnapshot {
  const GatewayConfigSnapshot({
    required this.path,
    required this.exists,
    required this.valid,
    required this.issues,
    required this.warnings,
    required this.legacyIssues,
    this.rawText,
    this.hash,
    this.parsed,
    this.resolved,
    this.config,
  });

  factory GatewayConfigSnapshot.fromJson(JsonMap json) {
    return GatewayConfigSnapshot(
      path: readRequiredString(json, 'path', context: 'config.get'),
      exists: readRequiredBool(json, 'exists', context: 'config.get'),
      rawText: json['raw'] is String ? json['raw'] as String : null,
      parsed: json['parsed'],
      resolved: _readNullableJsonMap(json['resolved'],
          context: 'config.get.resolved'),
      valid: readRequiredBool(json, 'valid', context: 'config.get'),
      config:
          _readNullableJsonMap(json['config'], context: 'config.get.config'),
      hash: readNullableString(json['hash']),
      issues: _readJsonMapList(json['issues'], context: 'config.get.issues'),
      warnings:
          _readJsonMapList(json['warnings'], context: 'config.get.warnings'),
      legacyIssues: _readJsonMapList(
        json['legacyIssues'],
        context: 'config.get.legacyIssues',
      ),
    );
  }

  final String path;
  final bool exists;
  final String? rawText;
  final Object? parsed;
  final JsonMap? resolved;
  final bool valid;
  final JsonMap? config;
  final String? hash;
  final List<JsonMap> issues;
  final List<JsonMap> warnings;
  final List<JsonMap> legacyIssues;
}

class GatewayConfigUiHint {
  const GatewayConfigUiHint({
    this.label,
    this.help,
    this.tags = const <String>[],
    this.group,
    this.order,
    this.advanced,
    this.sensitive,
    this.placeholder,
    this.itemTemplate,
    this.raw = const <String, Object?>{},
  });

  factory GatewayConfigUiHint.fromJson(JsonMap json) {
    return GatewayConfigUiHint(
      label: readNullableString(json['label']),
      help: readNullableString(json['help']),
      tags: json['tags'] == null
          ? const <String>[]
          : readStringList(json['tags'], context: 'config ui hint.tags'),
      group: readNullableString(json['group']),
      order: readNullableInt(json['order']),
      advanced: _readNullableBool(json['advanced']),
      sensitive: _readNullableBool(json['sensitive']),
      placeholder: readNullableString(json['placeholder']),
      itemTemplate: json['itemTemplate'],
      raw: json,
    );
  }

  final String? label;
  final String? help;
  final List<String> tags;
  final String? group;
  final int? order;
  final bool? advanced;
  final bool? sensitive;
  final String? placeholder;
  final Object? itemTemplate;
  final JsonMap raw;
}

class GatewayConfigSchemaResponse {
  const GatewayConfigSchemaResponse({
    required this.schema,
    required this.uiHints,
    required this.version,
    required this.generatedAt,
  });

  factory GatewayConfigSchemaResponse.fromJson(JsonMap json) {
    final hints = <String, GatewayConfigUiHint>{};
    final hintsRaw =
        _readJsonMap(json['uiHints'], context: 'config.schema.uiHints');
    for (final entry in hintsRaw.entries) {
      hints[entry.key] = GatewayConfigUiHint.fromJson(
        _readJsonMap(entry.value,
            context: 'config.schema.uiHints.${entry.key}'),
      );
    }
    return GatewayConfigSchemaResponse(
      schema: json['schema'],
      uiHints: hints,
      version: readRequiredString(json, 'version', context: 'config.schema'),
      generatedAt: readRequiredString(
        json,
        'generatedAt',
        context: 'config.schema',
      ),
    );
  }

  final Object? schema;
  final Map<String, GatewayConfigUiHint> uiHints;
  final String version;
  final String generatedAt;
}

class GatewayConfigSchemaLookupChild {
  const GatewayConfigSchemaLookupChild({
    required this.key,
    required this.path,
    required this.required,
    required this.hasChildren,
    this.type = const <String>[],
    this.hint,
    this.hintPath,
  });

  factory GatewayConfigSchemaLookupChild.fromJson(JsonMap json) {
    final typeValue = json['type'];
    return GatewayConfigSchemaLookupChild(
      key: readRequiredString(json, 'key',
          context: 'config.schema.lookup child'),
      path: readRequiredString(json, 'path',
          context: 'config.schema.lookup child'),
      type: typeValue is String
          ? <String>[typeValue]
          : typeValue == null
              ? const <String>[]
              : readStringList(typeValue,
                  context: 'config.schema.lookup child.type'),
      required: readRequiredBool(
        json,
        'required',
        context: 'config.schema.lookup child',
      ),
      hasChildren: readRequiredBool(
        json,
        'hasChildren',
        context: 'config.schema.lookup child',
      ),
      hint: json['hint'] == null
          ? null
          : GatewayConfigUiHint.fromJson(
              _readJsonMap(json['hint'],
                  context: 'config.schema.lookup child.hint'),
            ),
      hintPath: readNullableString(json['hintPath']),
    );
  }

  final String key;
  final String path;
  final List<String> type;
  final bool required;
  final bool hasChildren;
  final GatewayConfigUiHint? hint;
  final String? hintPath;
}

class GatewayConfigSchemaLookupResult {
  const GatewayConfigSchemaLookupResult({
    required this.path,
    required this.schema,
    required this.children,
    this.hint,
    this.hintPath,
  });

  factory GatewayConfigSchemaLookupResult.fromJson(JsonMap json) {
    return GatewayConfigSchemaLookupResult(
      path: readRequiredString(json, 'path', context: 'config.schema.lookup'),
      schema: json['schema'],
      hint: json['hint'] == null
          ? null
          : GatewayConfigUiHint.fromJson(
              _readJsonMap(json['hint'], context: 'config.schema.lookup.hint'),
            ),
      hintPath: readNullableString(json['hintPath']),
      children: asJsonList(json['children'],
              context: 'config.schema.lookup.children')
          .map(
            (item) => GatewayConfigSchemaLookupChild.fromJson(
              _readJsonMap(item, context: 'config.schema.lookup.children[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final String path;
  final Object? schema;
  final GatewayConfigUiHint? hint;
  final String? hintPath;
  final List<GatewayConfigSchemaLookupChild> children;
}

class GatewaySessionsDefaults {
  const GatewaySessionsDefaults({
    this.modelProvider,
    this.model,
    this.contextTokens,
  });

  factory GatewaySessionsDefaults.fromJson(JsonMap json) {
    return GatewaySessionsDefaults(
      modelProvider: readNullableString(json['modelProvider']),
      model: readNullableString(json['model']),
      contextTokens: readNullableInt(json['contextTokens']),
    );
  }

  final String? modelProvider;
  final String? model;
  final int? contextTokens;
}

class GatewaySessionRow {
  const GatewaySessionRow({
    required this.key,
    required this.kind,
    required this.raw,
    this.label,
    this.displayName,
    this.derivedTitle,
    this.lastMessagePreview,
    this.channel,
    this.subject,
    this.groupChannel,
    this.space,
    this.chatType,
    this.updatedAt,
    this.sessionId,
    this.thinkingLevel,
    this.verboseLevel,
    this.reasoningLevel,
    this.elevatedLevel,
    this.sendPolicy,
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
    this.totalTokensFresh,
    this.responseUsage,
    this.modelProvider,
    this.model,
    this.contextTokens,
    this.lastTo,
    this.lastAccountId,
  });

  factory GatewaySessionRow.fromJson(JsonMap json) {
    return GatewaySessionRow(
      key: readRequiredString(json, 'key', context: 'session row'),
      kind: readRequiredString(json, 'kind', context: 'session row'),
      raw: json,
      label: readNullableString(json['label']),
      displayName: readNullableString(json['displayName']),
      derivedTitle: readNullableString(json['derivedTitle']),
      lastMessagePreview: readNullableString(json['lastMessagePreview']),
      channel: readNullableString(json['channel']),
      subject: readNullableString(json['subject']),
      groupChannel: readNullableString(json['groupChannel']),
      space: readNullableString(json['space']),
      chatType: readNullableString(json['chatType']),
      updatedAt: readNullableInt(json['updatedAt']),
      sessionId: readNullableString(json['sessionId']),
      thinkingLevel: readNullableString(json['thinkingLevel']),
      verboseLevel: readNullableString(json['verboseLevel']),
      reasoningLevel: readNullableString(json['reasoningLevel']),
      elevatedLevel: readNullableString(json['elevatedLevel']),
      sendPolicy: readNullableString(json['sendPolicy']),
      inputTokens: readNullableInt(json['inputTokens']),
      outputTokens: readNullableInt(json['outputTokens']),
      totalTokens: readNullableInt(json['totalTokens']),
      totalTokensFresh: _readNullableBool(json['totalTokensFresh']),
      responseUsage: readNullableString(json['responseUsage']),
      modelProvider: readNullableString(json['modelProvider']),
      model: readNullableString(json['model']),
      contextTokens: readNullableInt(json['contextTokens']),
      lastTo: readNullableString(json['lastTo']),
      lastAccountId: readNullableString(json['lastAccountId']),
    );
  }

  final String key;
  final String kind;
  final JsonMap raw;
  final String? label;
  final String? displayName;
  final String? derivedTitle;
  final String? lastMessagePreview;
  final String? channel;
  final String? subject;
  final String? groupChannel;
  final String? space;
  final String? chatType;
  final int? updatedAt;
  final String? sessionId;
  final String? thinkingLevel;
  final String? verboseLevel;
  final String? reasoningLevel;
  final String? elevatedLevel;
  final String? sendPolicy;
  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;
  final bool? totalTokensFresh;
  final String? responseUsage;
  final String? modelProvider;
  final String? model;
  final int? contextTokens;
  final String? lastTo;
  final String? lastAccountId;
}

class GatewaySessionsListResult {
  const GatewaySessionsListResult({
    required this.ts,
    required this.path,
    required this.count,
    required this.defaults,
    required this.sessions,
  });

  factory GatewaySessionsListResult.fromJson(JsonMap json) {
    return GatewaySessionsListResult(
      ts: readRequiredInt(json, 'ts', context: 'sessions.list'),
      path: readRequiredString(json, 'path', context: 'sessions.list'),
      count: readRequiredInt(json, 'count', context: 'sessions.list'),
      defaults: GatewaySessionsDefaults.fromJson(
        _readJsonMap(json['defaults'], context: 'sessions.list.defaults'),
      ),
      sessions: asJsonList(json['sessions'], context: 'sessions.list.sessions')
          .map(
            (item) => GatewaySessionRow.fromJson(
              _readJsonMap(item, context: 'sessions.list.sessions[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final int ts;
  final String path;
  final int count;
  final GatewaySessionsDefaults defaults;
  final List<GatewaySessionRow> sessions;
}

class GatewaySessionPreviewItem {
  const GatewaySessionPreviewItem({
    required this.role,
    required this.text,
  });

  factory GatewaySessionPreviewItem.fromJson(JsonMap json) {
    return GatewaySessionPreviewItem(
      role: readRequiredString(json, 'role', context: 'session preview item'),
      text: readRequiredString(json, 'text', context: 'session preview item'),
    );
  }

  final String role;
  final String text;
}

class GatewaySessionsPreviewEntry {
  const GatewaySessionsPreviewEntry({
    required this.key,
    required this.status,
    required this.items,
  });

  factory GatewaySessionsPreviewEntry.fromJson(JsonMap json) {
    return GatewaySessionsPreviewEntry(
      key: readRequiredString(json, 'key', context: 'sessions.preview entry'),
      status: readRequiredString(
        json,
        'status',
        context: 'sessions.preview entry',
      ),
      items: asJsonList(json['items'], context: 'sessions.preview entry.items')
          .map(
            (item) => GatewaySessionPreviewItem.fromJson(
              _readJsonMap(item, context: 'sessions.preview entry.items[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final String key;
  final String status;
  final List<GatewaySessionPreviewItem> items;
}

class GatewaySessionsPreviewResult {
  const GatewaySessionsPreviewResult({
    required this.ts,
    required this.previews,
  });

  factory GatewaySessionsPreviewResult.fromJson(JsonMap json) {
    return GatewaySessionsPreviewResult(
      ts: readRequiredInt(json, 'ts', context: 'sessions.preview'),
      previews:
          asJsonList(json['previews'], context: 'sessions.preview.previews')
              .map(
                (item) => GatewaySessionsPreviewEntry.fromJson(
                  _readJsonMap(item, context: 'sessions.preview.previews[]'),
                ),
              )
              .toList(growable: false),
    );
  }

  final int ts;
  final List<GatewaySessionsPreviewEntry> previews;
}

class GatewayModelChoice {
  const GatewayModelChoice({
    required this.id,
    required this.name,
    required this.provider,
    this.contextWindow,
    this.reasoning,
  });

  factory GatewayModelChoice.fromJson(JsonMap json) {
    return GatewayModelChoice(
      id: readRequiredString(json, 'id', context: 'model'),
      name: readRequiredString(json, 'name', context: 'model'),
      provider: readRequiredString(json, 'provider', context: 'model'),
      contextWindow: readNullableInt(json['contextWindow']),
      reasoning: _readNullableBool(json['reasoning']),
    );
  }

  final String id;
  final String name;
  final String provider;
  final int? contextWindow;
  final bool? reasoning;
}

class GatewayModelsListResult {
  const GatewayModelsListResult({
    required this.models,
  });

  factory GatewayModelsListResult.fromJson(JsonMap json) {
    return GatewayModelsListResult(
      models: asJsonList(json['models'], context: 'models.list.models')
          .map(
            (item) => GatewayModelChoice.fromJson(
              _readJsonMap(item, context: 'models.list.models[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final List<GatewayModelChoice> models;
}

class GatewayToolCatalogProfile {
  const GatewayToolCatalogProfile({
    required this.id,
    required this.label,
  });

  factory GatewayToolCatalogProfile.fromJson(JsonMap json) {
    return GatewayToolCatalogProfile(
      id: readRequiredString(json, 'id', context: 'tool profile'),
      label: readRequiredString(json, 'label', context: 'tool profile'),
    );
  }

  final String id;
  final String label;
}

class GatewayToolCatalogEntry {
  const GatewayToolCatalogEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.source,
    required this.defaultProfiles,
    this.pluginId,
    this.optional,
  });

  factory GatewayToolCatalogEntry.fromJson(JsonMap json) {
    return GatewayToolCatalogEntry(
      id: readRequiredString(json, 'id', context: 'tool'),
      label: readRequiredString(json, 'label', context: 'tool'),
      description: readRequiredString(json, 'description', context: 'tool'),
      source: readRequiredString(json, 'source', context: 'tool'),
      pluginId: readNullableString(json['pluginId']),
      optional: _readNullableBool(json['optional']),
      defaultProfiles: readStringList(
        json['defaultProfiles'],
        context: 'tool.defaultProfiles',
      ),
    );
  }

  final String id;
  final String label;
  final String description;
  final String source;
  final String? pluginId;
  final bool? optional;
  final List<String> defaultProfiles;
}

class GatewayToolCatalogGroup {
  const GatewayToolCatalogGroup({
    required this.id,
    required this.label,
    required this.source,
    required this.tools,
    this.pluginId,
  });

  factory GatewayToolCatalogGroup.fromJson(JsonMap json) {
    return GatewayToolCatalogGroup(
      id: readRequiredString(json, 'id', context: 'tool group'),
      label: readRequiredString(json, 'label', context: 'tool group'),
      source: readRequiredString(json, 'source', context: 'tool group'),
      pluginId: readNullableString(json['pluginId']),
      tools: asJsonList(json['tools'], context: 'tool group.tools')
          .map(
            (item) => GatewayToolCatalogEntry.fromJson(
              _readJsonMap(item, context: 'tool group.tools[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String source;
  final String? pluginId;
  final List<GatewayToolCatalogEntry> tools;
}

class GatewayToolsCatalogResult {
  const GatewayToolsCatalogResult({
    required this.agentId,
    required this.profiles,
    required this.groups,
  });

  factory GatewayToolsCatalogResult.fromJson(JsonMap json) {
    return GatewayToolsCatalogResult(
      agentId: readRequiredString(json, 'agentId', context: 'tools.catalog'),
      profiles: asJsonList(json['profiles'], context: 'tools.catalog.profiles')
          .map(
            (item) => GatewayToolCatalogProfile.fromJson(
              _readJsonMap(item, context: 'tools.catalog.profiles[]'),
            ),
          )
          .toList(growable: false),
      groups: asJsonList(json['groups'], context: 'tools.catalog.groups')
          .map(
            (item) => GatewayToolCatalogGroup.fromJson(
              _readJsonMap(item, context: 'tools.catalog.groups[]'),
            ),
          )
          .toList(growable: false),
    );
  }

  final String agentId;
  final List<GatewayToolCatalogProfile> profiles;
  final List<GatewayToolCatalogGroup> groups;
}

class GatewayVoiceWakeConfig {
  const GatewayVoiceWakeConfig({
    required this.triggers,
    this.updatedAtMs,
  });

  factory GatewayVoiceWakeConfig.fromJson(JsonMap json) {
    return GatewayVoiceWakeConfig(
      triggers: readStringList(json['triggers'], context: 'voicewake'),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
    );
  }

  final List<String> triggers;
  final int? updatedAtMs;
}

class GatewayCronJobState {
  const GatewayCronJobState({
    this.nextRunAtMs,
    this.runningAtMs,
    this.lastRunAtMs,
    this.lastRunStatus,
    this.lastStatus,
    this.lastError,
    this.lastDurationMs,
    this.consecutiveErrors,
    this.lastFailureAlertAtMs,
    this.scheduleErrorCount,
    this.lastDeliveryStatus,
    this.lastDeliveryError,
    this.lastDelivered,
  });

  factory GatewayCronJobState.fromJson(JsonMap json) {
    return GatewayCronJobState(
      nextRunAtMs: readNullableInt(json['nextRunAtMs']),
      runningAtMs: readNullableInt(json['runningAtMs']),
      lastRunAtMs: readNullableInt(json['lastRunAtMs']),
      lastRunStatus: readNullableString(json['lastRunStatus']),
      lastStatus: readNullableString(json['lastStatus']),
      lastError: readNullableString(json['lastError']),
      lastDurationMs: readNullableInt(json['lastDurationMs']),
      consecutiveErrors: readNullableInt(json['consecutiveErrors']),
      lastFailureAlertAtMs: readNullableInt(json['lastFailureAlertAtMs']),
      scheduleErrorCount: readNullableInt(json['scheduleErrorCount']),
      lastDeliveryStatus: readNullableString(json['lastDeliveryStatus']),
      lastDeliveryError: readNullableString(json['lastDeliveryError']),
      lastDelivered: _readNullableBool(json['lastDelivered']),
    );
  }

  final int? nextRunAtMs;
  final int? runningAtMs;
  final int? lastRunAtMs;
  final String? lastRunStatus;
  final String? lastStatus;
  final String? lastError;
  final int? lastDurationMs;
  final int? consecutiveErrors;
  final int? lastFailureAlertAtMs;
  final int? scheduleErrorCount;
  final String? lastDeliveryStatus;
  final String? lastDeliveryError;
  final bool? lastDelivered;
}

class GatewayCronJob {
  const GatewayCronJob({
    required this.id,
    required this.name,
    required this.enabled,
    required this.createdAtMs,
    required this.updatedAtMs,
    required this.schedule,
    required this.sessionTarget,
    required this.wakeMode,
    required this.payload,
    required this.state,
    required this.raw,
    this.agentId,
    this.sessionKey,
    this.description,
    this.deleteAfterRun,
    this.delivery,
    this.failureAlert,
  });

  factory GatewayCronJob.fromJson(JsonMap json) {
    return GatewayCronJob(
      id: readRequiredString(json, 'id', context: 'cron job'),
      agentId: readNullableString(json['agentId']),
      sessionKey: readNullableString(json['sessionKey']),
      name: readRequiredString(json, 'name', context: 'cron job'),
      description: readNullableString(json['description']),
      enabled: readRequiredBool(json, 'enabled', context: 'cron job'),
      deleteAfterRun: _readNullableBool(json['deleteAfterRun']),
      createdAtMs: readRequiredInt(json, 'createdAtMs', context: 'cron job'),
      updatedAtMs: readRequiredInt(json, 'updatedAtMs', context: 'cron job'),
      schedule: _readJsonMap(json['schedule'], context: 'cron job.schedule'),
      sessionTarget:
          readRequiredString(json, 'sessionTarget', context: 'cron job'),
      wakeMode: readRequiredString(json, 'wakeMode', context: 'cron job'),
      payload: _readJsonMap(json['payload'], context: 'cron job.payload'),
      delivery:
          _readNullableJsonMap(json['delivery'], context: 'cron job.delivery'),
      failureAlert: json['failureAlert'] is bool
          ? json['failureAlert'] as bool
          : _readNullableJsonMap(json['failureAlert'],
              context: 'cron job.failureAlert'),
      state: GatewayCronJobState.fromJson(
        _readJsonMap(json['state'], context: 'cron job.state'),
      ),
      raw: json,
    );
  }

  final String id;
  final String? agentId;
  final String? sessionKey;
  final String name;
  final String? description;
  final bool enabled;
  final bool? deleteAfterRun;
  final int createdAtMs;
  final int updatedAtMs;
  final JsonMap schedule;
  final String sessionTarget;
  final String wakeMode;
  final JsonMap payload;
  final Object? delivery;
  final Object? failureAlert;
  final GatewayCronJobState state;
  final JsonMap raw;
}

class GatewayCronStatusSummary {
  const GatewayCronStatusSummary({
    required this.enabled,
    required this.storePath,
    required this.jobs,
    this.nextWakeAtMs,
  });

  factory GatewayCronStatusSummary.fromJson(JsonMap json) {
    return GatewayCronStatusSummary(
      enabled: readRequiredBool(json, 'enabled', context: 'cron.status'),
      storePath: readRequiredString(json, 'storePath', context: 'cron.status'),
      jobs: readRequiredInt(json, 'jobs', context: 'cron.status'),
      nextWakeAtMs: readNullableInt(json['nextWakeAtMs']),
    );
  }

  final bool enabled;
  final String storePath;
  final int jobs;
  final int? nextWakeAtMs;
}

class GatewayCronRunResult {
  const GatewayCronRunResult({
    required this.ok,
    required this.ran,
    this.reason,
    this.raw = const <String, Object?>{},
  });

  factory GatewayCronRunResult.fromJson(JsonMap json) {
    return GatewayCronRunResult(
      ok: readRequiredBool(json, 'ok', context: 'cron.run'),
      ran: readRequiredBool(json, 'ran', context: 'cron.run'),
      reason: readNullableString(json['reason']),
      raw: json,
    );
  }

  final bool ok;
  final bool ran;
  final String? reason;
  final JsonMap raw;
}

class GatewayCronRemoveResult {
  const GatewayCronRemoveResult({
    required this.ok,
    required this.removed,
  });

  factory GatewayCronRemoveResult.fromJson(JsonMap json) {
    return GatewayCronRemoveResult(
      ok: readRequiredBool(json, 'ok', context: 'cron.remove'),
      removed: readRequiredBool(json, 'removed', context: 'cron.remove'),
    );
  }

  final bool ok;
  final bool removed;
}

class GatewayCronRunLogEntry {
  const GatewayCronRunLogEntry({
    required this.ts,
    required this.jobId,
    required this.action,
    required this.raw,
    this.status,
    this.error,
    this.summary,
    this.delivered,
    this.deliveryStatus,
    this.deliveryError,
    this.sessionId,
    this.sessionKey,
    this.runAtMs,
    this.durationMs,
    this.nextRunAtMs,
    this.model,
    this.provider,
    this.usage,
    this.jobName,
  });

  factory GatewayCronRunLogEntry.fromJson(JsonMap json) {
    return GatewayCronRunLogEntry(
      ts: readRequiredInt(json, 'ts', context: 'cron.runs entry'),
      jobId: readRequiredString(json, 'jobId', context: 'cron.runs entry'),
      action: readRequiredString(json, 'action', context: 'cron.runs entry'),
      raw: json,
      status: readNullableString(json['status']),
      error: readNullableString(json['error']),
      summary: readNullableString(json['summary']),
      delivered: _readNullableBool(json['delivered']),
      deliveryStatus: readNullableString(json['deliveryStatus']),
      deliveryError: readNullableString(json['deliveryError']),
      sessionId: readNullableString(json['sessionId']),
      sessionKey: readNullableString(json['sessionKey']),
      runAtMs: readNullableInt(json['runAtMs']),
      durationMs: readNullableInt(json['durationMs']),
      nextRunAtMs: readNullableInt(json['nextRunAtMs']),
      model: readNullableString(json['model']),
      provider: readNullableString(json['provider']),
      usage:
          _readNullableJsonMap(json['usage'], context: 'cron.runs entry.usage'),
      jobName: readNullableString(json['jobName']),
    );
  }

  final int ts;
  final String jobId;
  final String action;
  final JsonMap raw;
  final String? status;
  final String? error;
  final String? summary;
  final bool? delivered;
  final String? deliveryStatus;
  final String? deliveryError;
  final String? sessionId;
  final String? sessionKey;
  final int? runAtMs;
  final int? durationMs;
  final int? nextRunAtMs;
  final String? model;
  final String? provider;
  final JsonMap? usage;
  final String? jobName;
}

class GatewayCronRunsResult {
  const GatewayCronRunsResult({
    required this.entries,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.nextOffset,
    required this.raw,
  });

  factory GatewayCronRunsResult.fromJson(JsonMap json) {
    return GatewayCronRunsResult(
      entries: asJsonList(
        json['entries'],
        context: 'cron.runs.entries',
      )
          .map(
            (item) => GatewayCronRunLogEntry.fromJson(
              _readJsonMap(item, context: 'cron.runs.entries[]'),
            ),
          )
          .toList(growable: false),
      total: readRequiredInt(json, 'total', context: 'cron.runs'),
      limit: readRequiredInt(json, 'limit', context: 'cron.runs'),
      offset: readRequiredInt(json, 'offset', context: 'cron.runs'),
      hasMore: readRequiredBool(json, 'hasMore', context: 'cron.runs'),
      nextOffset: readNullableInt(json['nextOffset']),
      raw: json,
    );
  }

  final List<GatewayCronRunLogEntry> entries;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final int? nextOffset;
  final JsonMap raw;
}

class GatewayCronListResult {
  const GatewayCronListResult({
    required this.jobs,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.nextOffset,
  });

  factory GatewayCronListResult.fromJson(JsonMap json) {
    return GatewayCronListResult(
      jobs: asJsonList(json['jobs'], context: 'cron.list.jobs')
          .map(
            (item) => GatewayCronJob.fromJson(
              asJsonMap(item, context: 'cron.list.jobs[]'),
            ),
          )
          .toList(growable: false),
      total: readRequiredInt(json, 'total', context: 'cron.list'),
      limit: readRequiredInt(json, 'limit', context: 'cron.list'),
      offset: readRequiredInt(json, 'offset', context: 'cron.list'),
      hasMore: readRequiredBool(json, 'hasMore', context: 'cron.list'),
      nextOffset: readNullableInt(json['nextOffset']),
    );
  }

  final List<GatewayCronJob> jobs;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final int? nextOffset;
}

JsonMap _readJsonMap(
  Object? value, {
  required String context,
}) {
  return asJsonMap(value, context: context);
}

JsonMap? _readNullableJsonMap(
  Object? value, {
  required String context,
}) {
  if (value == null) {
    return null;
  }
  return asJsonMap(value, context: context);
}

List<JsonMap> _readJsonMapList(
  Object? value, {
  required String context,
}) {
  if (value == null) {
    return const <JsonMap>[];
  }
  return asJsonList(value, context: context)
      .map((item) => asJsonMap(item, context: '$context[]'))
      .toList(growable: false);
}

Map<String, String> _readStringMap(
  Object? value, {
  required String context,
}) {
  if (value == null) {
    return const <String, String>{};
  }
  final json = asJsonMap(value, context: context);
  final out = <String, String>{};
  for (final entry in json.entries) {
    if (entry.value is String) {
      out[entry.key] = entry.value! as String;
    }
  }
  return out;
}

bool? _readNullableBool(Object? value) {
  if (value is bool) {
    return value;
  }
  return null;
}
