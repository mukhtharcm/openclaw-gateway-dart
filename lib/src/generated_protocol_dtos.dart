// GENERATED CODE - DO NOT MODIFY BY HAND.
// ignore_for_file: unused_element
//
// Regenerate with:
// dart run tool/sync_openclaw_protocol_dtos.dart

import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/protocol.dart';

class GatewaySchemaAgentEvent {
  const GatewaySchemaAgentEvent({
    required this.runId,
    required this.seq,
    required this.stream,
    required this.ts,
    required this.data,
  });

  factory GatewaySchemaAgentEvent.fromJson(JsonMap json) {
    return GatewaySchemaAgentEvent(
      runId: _generatedReadRequiredString(json, 'runId',
          context: 'AgentEvent.runId', allowEmpty: false),
      seq: readRequiredInt(json, 'seq', context: 'AgentEvent.seq'),
      stream: _generatedReadRequiredString(json, 'stream',
          context: 'AgentEvent.stream', allowEmpty: false),
      ts: readRequiredInt(json, 'ts', context: 'AgentEvent.ts'),
      data: Map<String, JsonMap>.unmodifiable({
        for (final entry
            in asJsonMap(json['data'], context: 'AgentEvent.data').entries)
          entry.key:
              asJsonMap(entry.value, context: 'AgentEvent.data.${entry.key}')
      }),
    );
  }

  final String runId;
  final int seq;
  final String stream;
  final int ts;
  final Map<String, JsonMap> data;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'runId': runId,
      'seq': seq,
      'stream': stream,
      'ts': ts,
      'data': data,
    });
  }
}

class GatewaySchemaAgentIdentityParams {
  const GatewaySchemaAgentIdentityParams({
    this.agentId,
    this.sessionKey,
  });

  factory GatewaySchemaAgentIdentityParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentIdentityParams(
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
    );
  }

  final String? agentId;
  final String? sessionKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'sessionKey': sessionKey,
    });
  }
}

class GatewaySchemaAgentIdentityResult {
  const GatewaySchemaAgentIdentityResult({
    required this.agentId,
    this.name,
    this.avatar,
    this.emoji,
  });

  factory GatewaySchemaAgentIdentityResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentIdentityResult(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentIdentityResult.agentId', allowEmpty: false),
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      avatar: _generatedReadNullableString(json['avatar'], allowEmpty: false),
      emoji: _generatedReadNullableString(json['emoji'], allowEmpty: false),
    );
  }

  final String agentId;
  final String? name;
  final String? avatar;
  final String? emoji;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'name': name,
      'avatar': avatar,
      'emoji': emoji,
    });
  }
}

class GatewaySchemaAgentParamsInternalEventsItem {
  const GatewaySchemaAgentParamsInternalEventsItem({
    required this.type,
    required this.source,
    required this.childSessionKey,
    this.childSessionId,
    required this.announceType,
    required this.taskLabel,
    required this.status,
    required this.statusLabel,
    required this.result,
    this.statsLine,
    required this.replyInstruction,
  });

  factory GatewaySchemaAgentParamsInternalEventsItem.fromJson(JsonMap json) {
    return GatewaySchemaAgentParamsInternalEventsItem(
      type: _generatedReadRequiredString(json, 'type',
          context: 'GatewaySchemaAgentParams.internalEventsItem.type',
          allowEmpty: true),
      source: _generatedReadRequiredString(json, 'source',
          context: 'GatewaySchemaAgentParams.internalEventsItem.source',
          allowEmpty: true),
      childSessionKey: _generatedReadRequiredString(json, 'childSessionKey',
          context:
              'GatewaySchemaAgentParams.internalEventsItem.childSessionKey',
          allowEmpty: true),
      childSessionId: _generatedReadNullableString(json['childSessionId'],
          allowEmpty: true),
      announceType: _generatedReadRequiredString(json, 'announceType',
          context: 'GatewaySchemaAgentParams.internalEventsItem.announceType',
          allowEmpty: true),
      taskLabel: _generatedReadRequiredString(json, 'taskLabel',
          context: 'GatewaySchemaAgentParams.internalEventsItem.taskLabel',
          allowEmpty: true),
      status: _generatedReadRequiredString(json, 'status',
          context: 'GatewaySchemaAgentParams.internalEventsItem.status',
          allowEmpty: true),
      statusLabel: _generatedReadRequiredString(json, 'statusLabel',
          context: 'GatewaySchemaAgentParams.internalEventsItem.statusLabel',
          allowEmpty: true),
      result: _generatedReadRequiredString(json, 'result',
          context: 'GatewaySchemaAgentParams.internalEventsItem.result',
          allowEmpty: true),
      statsLine:
          _generatedReadNullableString(json['statsLine'], allowEmpty: true),
      replyInstruction: _generatedReadRequiredString(json, 'replyInstruction',
          context:
              'GatewaySchemaAgentParams.internalEventsItem.replyInstruction',
          allowEmpty: true),
    );
  }

  final String type;
  final String source;
  final String childSessionKey;
  final String? childSessionId;
  final String announceType;
  final String taskLabel;
  final String status;
  final String statusLabel;
  final String result;
  final String? statsLine;
  final String replyInstruction;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'type': type,
      'source': source,
      'childSessionKey': childSessionKey,
      'childSessionId': childSessionId,
      'announceType': announceType,
      'taskLabel': taskLabel,
      'status': status,
      'statusLabel': statusLabel,
      'result': result,
      'statsLine': statsLine,
      'replyInstruction': replyInstruction,
    });
  }
}

class GatewaySchemaAgentParamsInputProvenance {
  const GatewaySchemaAgentParamsInputProvenance({
    required this.kind,
    this.sourceSessionKey,
    this.sourceChannel,
    this.sourceTool,
  });

  factory GatewaySchemaAgentParamsInputProvenance.fromJson(JsonMap json) {
    return GatewaySchemaAgentParamsInputProvenance(
      kind: _generatedReadRequiredString(json, 'kind',
          context: 'GatewaySchemaAgentParams.inputProvenance.kind',
          allowEmpty: true),
      sourceSessionKey: _generatedReadNullableString(json['sourceSessionKey'],
          allowEmpty: true),
      sourceChannel:
          _generatedReadNullableString(json['sourceChannel'], allowEmpty: true),
      sourceTool:
          _generatedReadNullableString(json['sourceTool'], allowEmpty: true),
    );
  }

  final String kind;
  final String? sourceSessionKey;
  final String? sourceChannel;
  final String? sourceTool;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'kind': kind,
      'sourceSessionKey': sourceSessionKey,
      'sourceChannel': sourceChannel,
      'sourceTool': sourceTool,
    });
  }
}

class GatewaySchemaAgentParams {
  const GatewaySchemaAgentParams({
    required this.message,
    this.agentId,
    this.to,
    this.replyTo,
    this.sessionId,
    this.sessionKey,
    this.thinking,
    this.deliver,
    this.attachments,
    this.channel,
    this.replyChannel,
    this.accountId,
    this.replyAccountId,
    this.threadId,
    this.groupId,
    this.groupChannel,
    this.groupSpace,
    this.timeout,
    this.bestEffortDeliver,
    this.lane,
    this.extraSystemPrompt,
    this.internalEvents,
    this.inputProvenance,
    required this.idempotencyKey,
    this.label,
    this.spawnedBy,
  });

  factory GatewaySchemaAgentParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentParams(
      message: _generatedReadRequiredString(json, 'message',
          context: 'AgentParams.message', allowEmpty: false),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      to: _generatedReadNullableString(json['to'], allowEmpty: true),
      replyTo: _generatedReadNullableString(json['replyTo'], allowEmpty: true),
      sessionId:
          _generatedReadNullableString(json['sessionId'], allowEmpty: true),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      thinking:
          _generatedReadNullableString(json['thinking'], allowEmpty: true),
      deliver: readNullableBool(json['deliver']),
      attachments: json['attachments'] == null
          ? null
          : asJsonList(json['attachments'], context: 'AgentParams.attachments')
              .map((entry) => entry)
              .toList(growable: false),
      channel: _generatedReadNullableString(json['channel'], allowEmpty: true),
      replyChannel:
          _generatedReadNullableString(json['replyChannel'], allowEmpty: true),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
      replyAccountId: _generatedReadNullableString(json['replyAccountId'],
          allowEmpty: true),
      threadId:
          _generatedReadNullableString(json['threadId'], allowEmpty: true),
      groupId: _generatedReadNullableString(json['groupId'], allowEmpty: true),
      groupChannel:
          _generatedReadNullableString(json['groupChannel'], allowEmpty: true),
      groupSpace:
          _generatedReadNullableString(json['groupSpace'], allowEmpty: true),
      timeout: readNullableInt(json['timeout']),
      bestEffortDeliver: readNullableBool(json['bestEffortDeliver']),
      lane: _generatedReadNullableString(json['lane'], allowEmpty: true),
      extraSystemPrompt: _generatedReadNullableString(json['extraSystemPrompt'],
          allowEmpty: true),
      internalEvents: json['internalEvents'] == null
          ? null
          : asJsonList(json['internalEvents'],
                  context: 'AgentParams.internalEvents')
              .map((entry) =>
                  GatewaySchemaAgentParamsInternalEventsItem.fromJson(asJsonMap(
                      entry,
                      context: 'AgentParams.internalEvents[]')))
              .toList(growable: false),
      inputProvenance: json['inputProvenance'] == null
          ? null
          : GatewaySchemaAgentParamsInputProvenance.fromJson(asJsonMap(
              json['inputProvenance'],
              context: 'AgentParams.inputProvenance')),
      idempotencyKey: _generatedReadRequiredString(json, 'idempotencyKey',
          context: 'AgentParams.idempotencyKey', allowEmpty: false),
      label: _generatedReadNullableString(json['label'], allowEmpty: false),
      spawnedBy:
          _generatedReadNullableString(json['spawnedBy'], allowEmpty: true),
    );
  }

  final String message;
  final String? agentId;
  final String? to;
  final String? replyTo;
  final String? sessionId;
  final String? sessionKey;
  final String? thinking;
  final bool? deliver;
  final List<Object?>? attachments;
  final String? channel;
  final String? replyChannel;
  final String? accountId;
  final String? replyAccountId;
  final String? threadId;
  final String? groupId;
  final String? groupChannel;
  final String? groupSpace;
  final int? timeout;
  final bool? bestEffortDeliver;
  final String? lane;
  final String? extraSystemPrompt;
  final List<GatewaySchemaAgentParamsInternalEventsItem>? internalEvents;
  final GatewaySchemaAgentParamsInputProvenance? inputProvenance;
  final String idempotencyKey;
  final String? label;
  final String? spawnedBy;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'message': message,
      'agentId': agentId,
      'to': to,
      'replyTo': replyTo,
      'sessionId': sessionId,
      'sessionKey': sessionKey,
      'thinking': thinking,
      'deliver': deliver,
      'attachments': attachments?.map((entry) => entry).toList(growable: false),
      'channel': channel,
      'replyChannel': replyChannel,
      'accountId': accountId,
      'replyAccountId': replyAccountId,
      'threadId': threadId,
      'groupId': groupId,
      'groupChannel': groupChannel,
      'groupSpace': groupSpace,
      'timeout': timeout,
      'bestEffortDeliver': bestEffortDeliver,
      'lane': lane,
      'extraSystemPrompt': extraSystemPrompt,
      'internalEvents': internalEvents
          ?.map((entry) => entry.toJson())
          .toList(growable: false),
      'inputProvenance': inputProvenance?.toJson(),
      'idempotencyKey': idempotencyKey,
      'label': label,
      'spawnedBy': spawnedBy,
    });
  }
}

class GatewaySchemaAgentSummaryIdentity {
  const GatewaySchemaAgentSummaryIdentity({
    this.name,
    this.theme,
    this.emoji,
    this.avatar,
    this.avatarUrl,
  });

  factory GatewaySchemaAgentSummaryIdentity.fromJson(JsonMap json) {
    return GatewaySchemaAgentSummaryIdentity(
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      theme: _generatedReadNullableString(json['theme'], allowEmpty: false),
      emoji: _generatedReadNullableString(json['emoji'], allowEmpty: false),
      avatar: _generatedReadNullableString(json['avatar'], allowEmpty: false),
      avatarUrl:
          _generatedReadNullableString(json['avatarUrl'], allowEmpty: false),
    );
  }

  final String? name;
  final String? theme;
  final String? emoji;
  final String? avatar;
  final String? avatarUrl;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'theme': theme,
      'emoji': emoji,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
    });
  }
}

class GatewaySchemaAgentSummary {
  const GatewaySchemaAgentSummary({
    required this.id,
    this.name,
    this.identity,
  });

  factory GatewaySchemaAgentSummary.fromJson(JsonMap json) {
    return GatewaySchemaAgentSummary(
      id: _generatedReadRequiredString(json, 'id',
          context: 'AgentSummary.id', allowEmpty: false),
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      identity: json['identity'] == null
          ? null
          : GatewaySchemaAgentSummaryIdentity.fromJson(
              asJsonMap(json['identity'], context: 'AgentSummary.identity')),
    );
  }

  final String id;
  final String? name;
  final GatewaySchemaAgentSummaryIdentity? identity;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'name': name,
      'identity': identity?.toJson(),
    });
  }
}

class GatewaySchemaAgentWaitParams {
  const GatewaySchemaAgentWaitParams({
    required this.runId,
    this.timeoutMs,
  });

  factory GatewaySchemaAgentWaitParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentWaitParams(
      runId: _generatedReadRequiredString(json, 'runId',
          context: 'AgentWaitParams.runId', allowEmpty: false),
      timeoutMs: readNullableInt(json['timeoutMs']),
    );
  }

  final String runId;
  final int? timeoutMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'runId': runId,
      'timeoutMs': timeoutMs,
    });
  }
}

class GatewaySchemaAgentsCreateParams {
  const GatewaySchemaAgentsCreateParams({
    required this.name,
    required this.workspace,
    this.emoji,
    this.avatar,
  });

  factory GatewaySchemaAgentsCreateParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsCreateParams(
      name: _generatedReadRequiredString(json, 'name',
          context: 'AgentsCreateParams.name', allowEmpty: false),
      workspace: _generatedReadRequiredString(json, 'workspace',
          context: 'AgentsCreateParams.workspace', allowEmpty: false),
      emoji: _generatedReadNullableString(json['emoji'], allowEmpty: true),
      avatar: _generatedReadNullableString(json['avatar'], allowEmpty: true),
    );
  }

  final String name;
  final String workspace;
  final String? emoji;
  final String? avatar;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'workspace': workspace,
      'emoji': emoji,
      'avatar': avatar,
    });
  }
}

class GatewaySchemaAgentsCreateResult {
  const GatewaySchemaAgentsCreateResult({
    required this.ok,
    required this.agentId,
    required this.name,
    required this.workspace,
  });

  factory GatewaySchemaAgentsCreateResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsCreateResult(
      ok: readRequiredBool(json, 'ok', context: 'AgentsCreateResult.ok'),
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsCreateResult.agentId', allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'AgentsCreateResult.name', allowEmpty: false),
      workspace: _generatedReadRequiredString(json, 'workspace',
          context: 'AgentsCreateResult.workspace', allowEmpty: false),
    );
  }

  final bool ok;
  final String agentId;
  final String name;
  final String workspace;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'agentId': agentId,
      'name': name,
      'workspace': workspace,
    });
  }
}

class GatewaySchemaAgentsDeleteParams {
  const GatewaySchemaAgentsDeleteParams({
    required this.agentId,
    this.deleteFiles,
  });

  factory GatewaySchemaAgentsDeleteParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsDeleteParams(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsDeleteParams.agentId', allowEmpty: false),
      deleteFiles: readNullableBool(json['deleteFiles']),
    );
  }

  final String agentId;
  final bool? deleteFiles;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'deleteFiles': deleteFiles,
    });
  }
}

class GatewaySchemaAgentsDeleteResult {
  const GatewaySchemaAgentsDeleteResult({
    required this.ok,
    required this.agentId,
    required this.removedBindings,
  });

  factory GatewaySchemaAgentsDeleteResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsDeleteResult(
      ok: readRequiredBool(json, 'ok', context: 'AgentsDeleteResult.ok'),
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsDeleteResult.agentId', allowEmpty: false),
      removedBindings: readRequiredInt(json, 'removedBindings',
          context: 'AgentsDeleteResult.removedBindings'),
    );
  }

  final bool ok;
  final String agentId;
  final int removedBindings;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'agentId': agentId,
      'removedBindings': removedBindings,
    });
  }
}

class GatewaySchemaAgentsFileEntry {
  const GatewaySchemaAgentsFileEntry({
    required this.name,
    required this.path,
    required this.missing,
    this.size,
    this.updatedAtMs,
    this.content,
  });

  factory GatewaySchemaAgentsFileEntry.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFileEntry(
      name: _generatedReadRequiredString(json, 'name',
          context: 'AgentsFileEntry.name', allowEmpty: false),
      path: _generatedReadRequiredString(json, 'path',
          context: 'AgentsFileEntry.path', allowEmpty: false),
      missing:
          readRequiredBool(json, 'missing', context: 'AgentsFileEntry.missing'),
      size: readNullableInt(json['size']),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
      content: _generatedReadNullableString(json['content'], allowEmpty: true),
    );
  }

  final String name;
  final String path;
  final bool missing;
  final int? size;
  final int? updatedAtMs;
  final String? content;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'path': path,
      'missing': missing,
      'size': size,
      'updatedAtMs': updatedAtMs,
      'content': content,
    });
  }
}

class GatewaySchemaAgentsFilesGetParams {
  const GatewaySchemaAgentsFilesGetParams({
    required this.agentId,
    required this.name,
  });

  factory GatewaySchemaAgentsFilesGetParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesGetParams(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesGetParams.agentId', allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'AgentsFilesGetParams.name', allowEmpty: false),
    );
  }

  final String agentId;
  final String name;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'name': name,
    });
  }
}

class GatewaySchemaAgentsFilesGetResultFile {
  const GatewaySchemaAgentsFilesGetResultFile({
    required this.name,
    required this.path,
    required this.missing,
    this.size,
    this.updatedAtMs,
    this.content,
  });

  factory GatewaySchemaAgentsFilesGetResultFile.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesGetResultFile(
      name: _generatedReadRequiredString(json, 'name',
          context: 'GatewaySchemaAgentsFilesGetResult.file.name',
          allowEmpty: false),
      path: _generatedReadRequiredString(json, 'path',
          context: 'GatewaySchemaAgentsFilesGetResult.file.path',
          allowEmpty: false),
      missing: readRequiredBool(json, 'missing',
          context: 'GatewaySchemaAgentsFilesGetResult.file.missing'),
      size: readNullableInt(json['size']),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
      content: _generatedReadNullableString(json['content'], allowEmpty: true),
    );
  }

  final String name;
  final String path;
  final bool missing;
  final int? size;
  final int? updatedAtMs;
  final String? content;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'path': path,
      'missing': missing,
      'size': size,
      'updatedAtMs': updatedAtMs,
      'content': content,
    });
  }
}

class GatewaySchemaAgentsFilesGetResult {
  const GatewaySchemaAgentsFilesGetResult({
    required this.agentId,
    required this.workspace,
    required this.file,
  });

  factory GatewaySchemaAgentsFilesGetResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesGetResult(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesGetResult.agentId', allowEmpty: false),
      workspace: _generatedReadRequiredString(json, 'workspace',
          context: 'AgentsFilesGetResult.workspace', allowEmpty: false),
      file: GatewaySchemaAgentsFilesGetResultFile.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'file',
              context: 'AgentsFilesGetResult'),
          context: 'AgentsFilesGetResult.file')),
    );
  }

  final String agentId;
  final String workspace;
  final GatewaySchemaAgentsFilesGetResultFile file;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'workspace': workspace,
      'file': file.toJson(),
    });
  }
}

class GatewaySchemaAgentsFilesListParams {
  const GatewaySchemaAgentsFilesListParams({
    required this.agentId,
  });

  factory GatewaySchemaAgentsFilesListParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesListParams(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesListParams.agentId', allowEmpty: false),
    );
  }

  final String agentId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
    });
  }
}

class GatewaySchemaAgentsFilesListResultFilesItem {
  const GatewaySchemaAgentsFilesListResultFilesItem({
    required this.name,
    required this.path,
    required this.missing,
    this.size,
    this.updatedAtMs,
    this.content,
  });

  factory GatewaySchemaAgentsFilesListResultFilesItem.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesListResultFilesItem(
      name: _generatedReadRequiredString(json, 'name',
          context: 'GatewaySchemaAgentsFilesListResult.filesItem.name',
          allowEmpty: false),
      path: _generatedReadRequiredString(json, 'path',
          context: 'GatewaySchemaAgentsFilesListResult.filesItem.path',
          allowEmpty: false),
      missing: readRequiredBool(json, 'missing',
          context: 'GatewaySchemaAgentsFilesListResult.filesItem.missing'),
      size: readNullableInt(json['size']),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
      content: _generatedReadNullableString(json['content'], allowEmpty: true),
    );
  }

  final String name;
  final String path;
  final bool missing;
  final int? size;
  final int? updatedAtMs;
  final String? content;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'path': path,
      'missing': missing,
      'size': size,
      'updatedAtMs': updatedAtMs,
      'content': content,
    });
  }
}

class GatewaySchemaAgentsFilesListResult {
  const GatewaySchemaAgentsFilesListResult({
    required this.agentId,
    required this.workspace,
    required this.files,
  });

  factory GatewaySchemaAgentsFilesListResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesListResult(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesListResult.agentId', allowEmpty: false),
      workspace: _generatedReadRequiredString(json, 'workspace',
          context: 'AgentsFilesListResult.workspace', allowEmpty: false),
      files: asJsonList(json['files'], context: 'AgentsFilesListResult.files')
          .map((entry) => GatewaySchemaAgentsFilesListResultFilesItem.fromJson(
              asJsonMap(entry, context: 'AgentsFilesListResult.files[]')))
          .toList(growable: false),
    );
  }

  final String agentId;
  final String workspace;
  final List<GatewaySchemaAgentsFilesListResultFilesItem> files;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'workspace': workspace,
      'files': files.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaAgentsFilesSetParams {
  const GatewaySchemaAgentsFilesSetParams({
    required this.agentId,
    required this.name,
    required this.content,
  });

  factory GatewaySchemaAgentsFilesSetParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesSetParams(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesSetParams.agentId', allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'AgentsFilesSetParams.name', allowEmpty: false),
      content: _generatedReadRequiredString(json, 'content',
          context: 'AgentsFilesSetParams.content', allowEmpty: true),
    );
  }

  final String agentId;
  final String name;
  final String content;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'name': name,
      'content': content,
    });
  }
}

class GatewaySchemaAgentsFilesSetResultFile {
  const GatewaySchemaAgentsFilesSetResultFile({
    required this.name,
    required this.path,
    required this.missing,
    this.size,
    this.updatedAtMs,
    this.content,
  });

  factory GatewaySchemaAgentsFilesSetResultFile.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesSetResultFile(
      name: _generatedReadRequiredString(json, 'name',
          context: 'GatewaySchemaAgentsFilesSetResult.file.name',
          allowEmpty: false),
      path: _generatedReadRequiredString(json, 'path',
          context: 'GatewaySchemaAgentsFilesSetResult.file.path',
          allowEmpty: false),
      missing: readRequiredBool(json, 'missing',
          context: 'GatewaySchemaAgentsFilesSetResult.file.missing'),
      size: readNullableInt(json['size']),
      updatedAtMs: readNullableInt(json['updatedAtMs']),
      content: _generatedReadNullableString(json['content'], allowEmpty: true),
    );
  }

  final String name;
  final String path;
  final bool missing;
  final int? size;
  final int? updatedAtMs;
  final String? content;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'path': path,
      'missing': missing,
      'size': size,
      'updatedAtMs': updatedAtMs,
      'content': content,
    });
  }
}

class GatewaySchemaAgentsFilesSetResult {
  const GatewaySchemaAgentsFilesSetResult({
    required this.ok,
    required this.agentId,
    required this.workspace,
    required this.file,
  });

  factory GatewaySchemaAgentsFilesSetResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsFilesSetResult(
      ok: readRequiredBool(json, 'ok', context: 'AgentsFilesSetResult.ok'),
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsFilesSetResult.agentId', allowEmpty: false),
      workspace: _generatedReadRequiredString(json, 'workspace',
          context: 'AgentsFilesSetResult.workspace', allowEmpty: false),
      file: GatewaySchemaAgentsFilesSetResultFile.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'file',
              context: 'AgentsFilesSetResult'),
          context: 'AgentsFilesSetResult.file')),
    );
  }

  final bool ok;
  final String agentId;
  final String workspace;
  final GatewaySchemaAgentsFilesSetResultFile file;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'agentId': agentId,
      'workspace': workspace,
      'file': file.toJson(),
    });
  }
}

class GatewaySchemaAgentsListParams {
  const GatewaySchemaAgentsListParams(this.value);

  factory GatewaySchemaAgentsListParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsListParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaAgentsListResultAgentsItemIdentity {
  const GatewaySchemaAgentsListResultAgentsItemIdentity({
    this.name,
    this.theme,
    this.emoji,
    this.avatar,
    this.avatarUrl,
  });

  factory GatewaySchemaAgentsListResultAgentsItemIdentity.fromJson(
      JsonMap json) {
    return GatewaySchemaAgentsListResultAgentsItemIdentity(
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      theme: _generatedReadNullableString(json['theme'], allowEmpty: false),
      emoji: _generatedReadNullableString(json['emoji'], allowEmpty: false),
      avatar: _generatedReadNullableString(json['avatar'], allowEmpty: false),
      avatarUrl:
          _generatedReadNullableString(json['avatarUrl'], allowEmpty: false),
    );
  }

  final String? name;
  final String? theme;
  final String? emoji;
  final String? avatar;
  final String? avatarUrl;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'theme': theme,
      'emoji': emoji,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
    });
  }
}

class GatewaySchemaAgentsListResultAgentsItem {
  const GatewaySchemaAgentsListResultAgentsItem({
    required this.id,
    this.name,
    this.identity,
  });

  factory GatewaySchemaAgentsListResultAgentsItem.fromJson(JsonMap json) {
    return GatewaySchemaAgentsListResultAgentsItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaAgentsListResult.agentsItem.id',
          allowEmpty: false),
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      identity: json['identity'] == null
          ? null
          : GatewaySchemaAgentsListResultAgentsItemIdentity.fromJson(asJsonMap(
              json['identity'],
              context: 'GatewaySchemaAgentsListResult.agentsItem.identity')),
    );
  }

  final String id;
  final String? name;
  final GatewaySchemaAgentsListResultAgentsItemIdentity? identity;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'name': name,
      'identity': identity?.toJson(),
    });
  }
}

class GatewaySchemaAgentsListResult {
  const GatewaySchemaAgentsListResult({
    required this.defaultId,
    required this.mainKey,
    required this.scope,
    required this.agents,
  });

  factory GatewaySchemaAgentsListResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsListResult(
      defaultId: _generatedReadRequiredString(json, 'defaultId',
          context: 'AgentsListResult.defaultId', allowEmpty: false),
      mainKey: _generatedReadRequiredString(json, 'mainKey',
          context: 'AgentsListResult.mainKey', allowEmpty: false),
      scope: _generatedReadRequiredString(json, 'scope',
          context: 'AgentsListResult.scope', allowEmpty: true),
      agents: asJsonList(json['agents'], context: 'AgentsListResult.agents')
          .map((entry) => GatewaySchemaAgentsListResultAgentsItem.fromJson(
              asJsonMap(entry, context: 'AgentsListResult.agents[]')))
          .toList(growable: false),
    );
  }

  final String defaultId;
  final String mainKey;
  final String scope;
  final List<GatewaySchemaAgentsListResultAgentsItem> agents;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'defaultId': defaultId,
      'mainKey': mainKey,
      'scope': scope,
      'agents': agents.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaAgentsUpdateParams {
  const GatewaySchemaAgentsUpdateParams({
    required this.agentId,
    this.name,
    this.workspace,
    this.model,
    this.avatar,
  });

  factory GatewaySchemaAgentsUpdateParams.fromJson(JsonMap json) {
    return GatewaySchemaAgentsUpdateParams(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsUpdateParams.agentId', allowEmpty: false),
      name: _generatedReadNullableString(json['name'], allowEmpty: false),
      workspace:
          _generatedReadNullableString(json['workspace'], allowEmpty: false),
      model: _generatedReadNullableString(json['model'], allowEmpty: false),
      avatar: _generatedReadNullableString(json['avatar'], allowEmpty: true),
    );
  }

  final String agentId;
  final String? name;
  final String? workspace;
  final String? model;
  final String? avatar;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'name': name,
      'workspace': workspace,
      'model': model,
      'avatar': avatar,
    });
  }
}

class GatewaySchemaAgentsUpdateResult {
  const GatewaySchemaAgentsUpdateResult({
    required this.ok,
    required this.agentId,
  });

  factory GatewaySchemaAgentsUpdateResult.fromJson(JsonMap json) {
    return GatewaySchemaAgentsUpdateResult(
      ok: readRequiredBool(json, 'ok', context: 'AgentsUpdateResult.ok'),
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'AgentsUpdateResult.agentId', allowEmpty: false),
    );
  }

  final bool ok;
  final String agentId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'agentId': agentId,
    });
  }
}

class GatewaySchemaChannelsLogoutParams {
  const GatewaySchemaChannelsLogoutParams({
    required this.channel,
    this.accountId,
  });

  factory GatewaySchemaChannelsLogoutParams.fromJson(JsonMap json) {
    return GatewaySchemaChannelsLogoutParams(
      channel: _generatedReadRequiredString(json, 'channel',
          context: 'ChannelsLogoutParams.channel', allowEmpty: false),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
    );
  }

  final String channel;
  final String? accountId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'channel': channel,
      'accountId': accountId,
    });
  }
}

class GatewaySchemaChannelsStatusParams {
  const GatewaySchemaChannelsStatusParams({
    this.probe,
    this.timeoutMs,
  });

  factory GatewaySchemaChannelsStatusParams.fromJson(JsonMap json) {
    return GatewaySchemaChannelsStatusParams(
      probe: readNullableBool(json['probe']),
      timeoutMs: readNullableInt(json['timeoutMs']),
    );
  }

  final bool? probe;
  final int? timeoutMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'probe': probe,
      'timeoutMs': timeoutMs,
    });
  }
}

class GatewaySchemaChannelsStatusResultChannelMetaItem {
  const GatewaySchemaChannelsStatusResultChannelMetaItem({
    required this.id,
    required this.label,
    required this.detailLabel,
    this.systemImage,
  });

  factory GatewaySchemaChannelsStatusResultChannelMetaItem.fromJson(
      JsonMap json) {
    return GatewaySchemaChannelsStatusResultChannelMetaItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaChannelsStatusResult.channelMetaItem.id',
          allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaChannelsStatusResult.channelMetaItem.label',
          allowEmpty: false),
      detailLabel: _generatedReadRequiredString(json, 'detailLabel',
          context:
              'GatewaySchemaChannelsStatusResult.channelMetaItem.detailLabel',
          allowEmpty: false),
      systemImage:
          _generatedReadNullableString(json['systemImage'], allowEmpty: true),
    );
  }

  final String id;
  final String label;
  final String detailLabel;
  final String? systemImage;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'detailLabel': detailLabel,
      'systemImage': systemImage,
    });
  }
}

class GatewaySchemaChannelsStatusResult {
  const GatewaySchemaChannelsStatusResult({
    required this.ts,
    required this.channelOrder,
    required this.channelLabels,
    this.channelDetailLabels,
    this.channelSystemImages,
    this.channelMeta,
    required this.channels,
    required this.channelAccounts,
    required this.channelDefaultAccountId,
  });

  factory GatewaySchemaChannelsStatusResult.fromJson(JsonMap json) {
    return GatewaySchemaChannelsStatusResult(
      ts: readRequiredInt(json, 'ts', context: 'ChannelsStatusResult.ts'),
      channelOrder: asJsonList(json['channelOrder'],
              context: 'ChannelsStatusResult.channelOrder')
          .map((entry) => _generatedReadItemString(entry,
              context: 'ChannelsStatusResult.channelOrder[]'))
          .toList(growable: false),
      channelLabels: Map<String, String>.unmodifiable({
        for (final entry in asJsonMap(json['channelLabels'],
                context: 'ChannelsStatusResult.channelLabels')
            .entries)
          entry.key: _generatedReadItemString(entry.value,
              context: 'ChannelsStatusResult.channelLabels.${entry.key}')
      }),
      channelDetailLabels: json['channelDetailLabels'] == null
          ? null
          : Map<String, String>.unmodifiable({
              for (final entry in asJsonMap(json['channelDetailLabels'],
                      context: 'ChannelsStatusResult.channelDetailLabels')
                  .entries)
                entry.key: _generatedReadItemString(entry.value,
                    context:
                        'ChannelsStatusResult.channelDetailLabels.${entry.key}')
            }),
      channelSystemImages: json['channelSystemImages'] == null
          ? null
          : Map<String, String>.unmodifiable({
              for (final entry in asJsonMap(json['channelSystemImages'],
                      context: 'ChannelsStatusResult.channelSystemImages')
                  .entries)
                entry.key: _generatedReadItemString(entry.value,
                    context:
                        'ChannelsStatusResult.channelSystemImages.${entry.key}')
            }),
      channelMeta: json['channelMeta'] == null
          ? null
          : asJsonList(json['channelMeta'],
                  context: 'ChannelsStatusResult.channelMeta')
              .map((entry) =>
                  GatewaySchemaChannelsStatusResultChannelMetaItem.fromJson(
                      asJsonMap(entry,
                          context: 'ChannelsStatusResult.channelMeta[]')))
              .toList(growable: false),
      channels: Map<String, JsonMap>.unmodifiable({
        for (final entry in asJsonMap(json['channels'],
                context: 'ChannelsStatusResult.channels')
            .entries)
          entry.key: asJsonMap(entry.value,
              context: 'ChannelsStatusResult.channels.${entry.key}')
      }),
      channelAccounts: Map<String, JsonMap>.unmodifiable({
        for (final entry in asJsonMap(json['channelAccounts'],
                context: 'ChannelsStatusResult.channelAccounts')
            .entries)
          entry.key: asJsonMap(entry.value,
              context: 'ChannelsStatusResult.channelAccounts.${entry.key}')
      }),
      channelDefaultAccountId: Map<String, String>.unmodifiable({
        for (final entry in asJsonMap(json['channelDefaultAccountId'],
                context: 'ChannelsStatusResult.channelDefaultAccountId')
            .entries)
          entry.key: _generatedReadItemString(entry.value,
              context:
                  'ChannelsStatusResult.channelDefaultAccountId.${entry.key}')
      }),
    );
  }

  final int ts;
  final List<String> channelOrder;
  final Map<String, String> channelLabels;
  final Map<String, String>? channelDetailLabels;
  final Map<String, String>? channelSystemImages;
  final List<GatewaySchemaChannelsStatusResultChannelMetaItem>? channelMeta;
  final Map<String, JsonMap> channels;
  final Map<String, JsonMap> channelAccounts;
  final Map<String, String> channelDefaultAccountId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ts': ts,
      'channelOrder':
          channelOrder.map((entry) => entry).toList(growable: false),
      'channelLabels': channelLabels,
      'channelDetailLabels': channelDetailLabels,
      'channelSystemImages': channelSystemImages,
      'channelMeta':
          channelMeta?.map((entry) => entry.toJson()).toList(growable: false),
      'channels': channels,
      'channelAccounts': channelAccounts,
      'channelDefaultAccountId': channelDefaultAccountId,
    });
  }
}

class GatewaySchemaChatAbortParams {
  const GatewaySchemaChatAbortParams({
    required this.sessionKey,
    this.runId,
  });

  factory GatewaySchemaChatAbortParams.fromJson(JsonMap json) {
    return GatewaySchemaChatAbortParams(
      sessionKey: _generatedReadRequiredString(json, 'sessionKey',
          context: 'ChatAbortParams.sessionKey', allowEmpty: false),
      runId: _generatedReadNullableString(json['runId'], allowEmpty: false),
    );
  }

  final String sessionKey;
  final String? runId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionKey': sessionKey,
      'runId': runId,
    });
  }
}

class GatewaySchemaChatEvent {
  const GatewaySchemaChatEvent({
    required this.runId,
    required this.sessionKey,
    required this.seq,
    required this.state,
    this.message,
    this.errorMessage,
    this.usage,
    this.stopReason,
  });

  factory GatewaySchemaChatEvent.fromJson(JsonMap json) {
    return GatewaySchemaChatEvent(
      runId: _generatedReadRequiredString(json, 'runId',
          context: 'ChatEvent.runId', allowEmpty: false),
      sessionKey: _generatedReadRequiredString(json, 'sessionKey',
          context: 'ChatEvent.sessionKey', allowEmpty: false),
      seq: readRequiredInt(json, 'seq', context: 'ChatEvent.seq'),
      state: _generatedReadRequiredString(json, 'state',
          context: 'ChatEvent.state', allowEmpty: true),
      message: json['message'],
      errorMessage:
          _generatedReadNullableString(json['errorMessage'], allowEmpty: true),
      usage: json['usage'],
      stopReason:
          _generatedReadNullableString(json['stopReason'], allowEmpty: true),
    );
  }

  final String runId;
  final String sessionKey;
  final int seq;
  final String state;
  final Object? message;
  final String? errorMessage;
  final Object? usage;
  final String? stopReason;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'runId': runId,
      'sessionKey': sessionKey,
      'seq': seq,
      'state': state,
      'message': message,
      'errorMessage': errorMessage,
      'usage': usage,
      'stopReason': stopReason,
    });
  }
}

class GatewaySchemaChatHistoryParams {
  const GatewaySchemaChatHistoryParams({
    required this.sessionKey,
    this.limit,
  });

  factory GatewaySchemaChatHistoryParams.fromJson(JsonMap json) {
    return GatewaySchemaChatHistoryParams(
      sessionKey: _generatedReadRequiredString(json, 'sessionKey',
          context: 'ChatHistoryParams.sessionKey', allowEmpty: false),
      limit: readNullableInt(json['limit']),
    );
  }

  final String sessionKey;
  final int? limit;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionKey': sessionKey,
      'limit': limit,
    });
  }
}

class GatewaySchemaChatInjectParams {
  const GatewaySchemaChatInjectParams({
    required this.sessionKey,
    required this.message,
    this.label,
  });

  factory GatewaySchemaChatInjectParams.fromJson(JsonMap json) {
    return GatewaySchemaChatInjectParams(
      sessionKey: _generatedReadRequiredString(json, 'sessionKey',
          context: 'ChatInjectParams.sessionKey', allowEmpty: false),
      message: _generatedReadRequiredString(json, 'message',
          context: 'ChatInjectParams.message', allowEmpty: false),
      label: _generatedReadNullableString(json['label'], allowEmpty: true),
    );
  }

  final String sessionKey;
  final String message;
  final String? label;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionKey': sessionKey,
      'message': message,
      'label': label,
    });
  }
}

class GatewaySchemaChatSendParams {
  const GatewaySchemaChatSendParams({
    required this.sessionKey,
    required this.message,
    this.thinking,
    this.deliver,
    this.attachments,
    this.timeoutMs,
    required this.idempotencyKey,
  });

  factory GatewaySchemaChatSendParams.fromJson(JsonMap json) {
    return GatewaySchemaChatSendParams(
      sessionKey: _generatedReadRequiredString(json, 'sessionKey',
          context: 'ChatSendParams.sessionKey', allowEmpty: false),
      message: _generatedReadRequiredString(json, 'message',
          context: 'ChatSendParams.message', allowEmpty: true),
      thinking:
          _generatedReadNullableString(json['thinking'], allowEmpty: true),
      deliver: readNullableBool(json['deliver']),
      attachments: json['attachments'] == null
          ? null
          : asJsonList(json['attachments'],
                  context: 'ChatSendParams.attachments')
              .map((entry) => entry)
              .toList(growable: false),
      timeoutMs: readNullableInt(json['timeoutMs']),
      idempotencyKey: _generatedReadRequiredString(json, 'idempotencyKey',
          context: 'ChatSendParams.idempotencyKey', allowEmpty: false),
    );
  }

  final String sessionKey;
  final String message;
  final String? thinking;
  final bool? deliver;
  final List<Object?>? attachments;
  final int? timeoutMs;
  final String idempotencyKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionKey': sessionKey,
      'message': message,
      'thinking': thinking,
      'deliver': deliver,
      'attachments': attachments?.map((entry) => entry).toList(growable: false),
      'timeoutMs': timeoutMs,
      'idempotencyKey': idempotencyKey,
    });
  }
}

class GatewaySchemaConfigApplyParams {
  const GatewaySchemaConfigApplyParams({
    required this.raw,
    this.baseHash,
    this.sessionKey,
    this.note,
    this.restartDelayMs,
  });

  factory GatewaySchemaConfigApplyParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigApplyParams(
      raw: _generatedReadRequiredString(json, 'raw',
          context: 'ConfigApplyParams.raw', allowEmpty: false),
      baseHash:
          _generatedReadNullableString(json['baseHash'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      note: _generatedReadNullableString(json['note'], allowEmpty: true),
      restartDelayMs: readNullableInt(json['restartDelayMs']),
    );
  }

  final String raw;
  final String? baseHash;
  final String? sessionKey;
  final String? note;
  final int? restartDelayMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'raw': raw,
      'baseHash': baseHash,
      'sessionKey': sessionKey,
      'note': note,
      'restartDelayMs': restartDelayMs,
    });
  }
}

class GatewaySchemaConfigGetParams {
  const GatewaySchemaConfigGetParams(this.value);

  factory GatewaySchemaConfigGetParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigGetParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaConfigPatchParams {
  const GatewaySchemaConfigPatchParams({
    required this.raw,
    this.baseHash,
    this.sessionKey,
    this.note,
    this.restartDelayMs,
  });

  factory GatewaySchemaConfigPatchParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigPatchParams(
      raw: _generatedReadRequiredString(json, 'raw',
          context: 'ConfigPatchParams.raw', allowEmpty: false),
      baseHash:
          _generatedReadNullableString(json['baseHash'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      note: _generatedReadNullableString(json['note'], allowEmpty: true),
      restartDelayMs: readNullableInt(json['restartDelayMs']),
    );
  }

  final String raw;
  final String? baseHash;
  final String? sessionKey;
  final String? note;
  final int? restartDelayMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'raw': raw,
      'baseHash': baseHash,
      'sessionKey': sessionKey,
      'note': note,
      'restartDelayMs': restartDelayMs,
    });
  }
}

class GatewaySchemaConfigSchemaLookupParams {
  const GatewaySchemaConfigSchemaLookupParams({
    required this.path,
  });

  factory GatewaySchemaConfigSchemaLookupParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigSchemaLookupParams(
      path: _generatedReadRequiredString(json, 'path',
          context: 'ConfigSchemaLookupParams.path', allowEmpty: false),
    );
  }

  final String path;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
    });
  }
}

class GatewaySchemaConfigSchemaLookupResultHint {
  const GatewaySchemaConfigSchemaLookupResultHint({
    this.label,
    this.help,
    this.tags,
    this.group,
    this.order,
    this.advanced,
    this.sensitive,
    this.placeholder,
    this.itemTemplate,
  });

  factory GatewaySchemaConfigSchemaLookupResultHint.fromJson(JsonMap json) {
    return GatewaySchemaConfigSchemaLookupResultHint(
      label: _generatedReadNullableString(json['label'], allowEmpty: true),
      help: _generatedReadNullableString(json['help'], allowEmpty: true),
      tags: json['tags'] == null
          ? null
          : asJsonList(json['tags'],
                  context: 'GatewaySchemaConfigSchemaLookupResult.hint.tags')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaConfigSchemaLookupResult.hint.tags[]'))
              .toList(growable: false),
      group: _generatedReadNullableString(json['group'], allowEmpty: true),
      order: readNullableInt(json['order']),
      advanced: readNullableBool(json['advanced']),
      sensitive: readNullableBool(json['sensitive']),
      placeholder:
          _generatedReadNullableString(json['placeholder'], allowEmpty: true),
      itemTemplate: json['itemTemplate'],
    );
  }

  final String? label;
  final String? help;
  final List<String>? tags;
  final String? group;
  final int? order;
  final bool? advanced;
  final bool? sensitive;
  final String? placeholder;
  final Object? itemTemplate;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'label': label,
      'help': help,
      'tags': tags?.map((entry) => entry).toList(growable: false),
      'group': group,
      'order': order,
      'advanced': advanced,
      'sensitive': sensitive,
      'placeholder': placeholder,
      'itemTemplate': itemTemplate,
    });
  }
}

class GatewaySchemaConfigSchemaLookupResultChildrenItemHint {
  const GatewaySchemaConfigSchemaLookupResultChildrenItemHint({
    this.label,
    this.help,
    this.tags,
    this.group,
    this.order,
    this.advanced,
    this.sensitive,
    this.placeholder,
    this.itemTemplate,
  });

  factory GatewaySchemaConfigSchemaLookupResultChildrenItemHint.fromJson(
      JsonMap json) {
    return GatewaySchemaConfigSchemaLookupResultChildrenItemHint(
      label: _generatedReadNullableString(json['label'], allowEmpty: true),
      help: _generatedReadNullableString(json['help'], allowEmpty: true),
      tags: json['tags'] == null
          ? null
          : asJsonList(json['tags'],
                  context:
                      'GatewaySchemaConfigSchemaLookupResultChildrenItem.hint.tags')
              .map((entry) => _generatedReadItemString(entry,
                  context:
                      'GatewaySchemaConfigSchemaLookupResultChildrenItem.hint.tags[]'))
              .toList(growable: false),
      group: _generatedReadNullableString(json['group'], allowEmpty: true),
      order: readNullableInt(json['order']),
      advanced: readNullableBool(json['advanced']),
      sensitive: readNullableBool(json['sensitive']),
      placeholder:
          _generatedReadNullableString(json['placeholder'], allowEmpty: true),
      itemTemplate: json['itemTemplate'],
    );
  }

  final String? label;
  final String? help;
  final List<String>? tags;
  final String? group;
  final int? order;
  final bool? advanced;
  final bool? sensitive;
  final String? placeholder;
  final Object? itemTemplate;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'label': label,
      'help': help,
      'tags': tags?.map((entry) => entry).toList(growable: false),
      'group': group,
      'order': order,
      'advanced': advanced,
      'sensitive': sensitive,
      'placeholder': placeholder,
      'itemTemplate': itemTemplate,
    });
  }
}

class GatewaySchemaConfigSchemaLookupResultChildrenItem {
  const GatewaySchemaConfigSchemaLookupResultChildrenItem({
    required this.key,
    required this.path,
    this.type,
    required this.required,
    required this.hasChildren,
    this.hint,
    this.hintPath,
  });

  factory GatewaySchemaConfigSchemaLookupResultChildrenItem.fromJson(
      JsonMap json) {
    return GatewaySchemaConfigSchemaLookupResultChildrenItem(
      key: _generatedReadRequiredString(json, 'key',
          context: 'GatewaySchemaConfigSchemaLookupResult.childrenItem.key',
          allowEmpty: false),
      path: _generatedReadRequiredString(json, 'path',
          context: 'GatewaySchemaConfigSchemaLookupResult.childrenItem.path',
          allowEmpty: false),
      type: json['type'],
      required: readRequiredBool(json, 'required',
          context:
              'GatewaySchemaConfigSchemaLookupResult.childrenItem.required'),
      hasChildren: readRequiredBool(json, 'hasChildren',
          context:
              'GatewaySchemaConfigSchemaLookupResult.childrenItem.hasChildren'),
      hint: json['hint'] == null
          ? null
          : GatewaySchemaConfigSchemaLookupResultChildrenItemHint.fromJson(
              asJsonMap(json['hint'],
                  context:
                      'GatewaySchemaConfigSchemaLookupResult.childrenItem.hint')),
      hintPath:
          _generatedReadNullableString(json['hintPath'], allowEmpty: true),
    );
  }

  final String key;
  final String path;
  final Object? type;
  final bool required;
  final bool hasChildren;
  final GatewaySchemaConfigSchemaLookupResultChildrenItemHint? hint;
  final String? hintPath;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'path': path,
      'type': type,
      'required': required,
      'hasChildren': hasChildren,
      'hint': hint?.toJson(),
      'hintPath': hintPath,
    });
  }
}

class GatewaySchemaConfigSchemaLookupResult {
  const GatewaySchemaConfigSchemaLookupResult({
    required this.path,
    this.schema,
    this.hint,
    this.hintPath,
    required this.children,
  });

  factory GatewaySchemaConfigSchemaLookupResult.fromJson(JsonMap json) {
    return GatewaySchemaConfigSchemaLookupResult(
      path: _generatedReadRequiredString(json, 'path',
          context: 'ConfigSchemaLookupResult.path', allowEmpty: false),
      schema: json['schema'],
      hint: json['hint'] == null
          ? null
          : GatewaySchemaConfigSchemaLookupResultHint.fromJson(asJsonMap(
              json['hint'],
              context: 'ConfigSchemaLookupResult.hint')),
      hintPath:
          _generatedReadNullableString(json['hintPath'], allowEmpty: true),
      children: asJsonList(json['children'],
              context: 'ConfigSchemaLookupResult.children')
          .map((entry) =>
              GatewaySchemaConfigSchemaLookupResultChildrenItem.fromJson(
                  asJsonMap(entry,
                      context: 'ConfigSchemaLookupResult.children[]')))
          .toList(growable: false),
    );
  }

  final String path;
  final Object? schema;
  final GatewaySchemaConfigSchemaLookupResultHint? hint;
  final String? hintPath;
  final List<GatewaySchemaConfigSchemaLookupResultChildrenItem> children;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'schema': schema,
      'hint': hint?.toJson(),
      'hintPath': hintPath,
      'children':
          children.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaConfigSchemaParams {
  const GatewaySchemaConfigSchemaParams(this.value);

  factory GatewaySchemaConfigSchemaParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigSchemaParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaConfigSchemaResponse {
  const GatewaySchemaConfigSchemaResponse({
    this.schema,
    required this.uiHints,
    required this.version,
    required this.generatedAt,
  });

  factory GatewaySchemaConfigSchemaResponse.fromJson(JsonMap json) {
    return GatewaySchemaConfigSchemaResponse(
      schema: json['schema'],
      uiHints: Map<String, JsonMap>.unmodifiable({
        for (final entry in asJsonMap(json['uiHints'],
                context: 'ConfigSchemaResponse.uiHints')
            .entries)
          entry.key: asJsonMap(entry.value,
              context: 'ConfigSchemaResponse.uiHints.${entry.key}')
      }),
      version: _generatedReadRequiredString(json, 'version',
          context: 'ConfigSchemaResponse.version', allowEmpty: false),
      generatedAt: _generatedReadRequiredString(json, 'generatedAt',
          context: 'ConfigSchemaResponse.generatedAt', allowEmpty: false),
    );
  }

  final Object? schema;
  final Map<String, JsonMap> uiHints;
  final String version;
  final String generatedAt;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'schema': schema,
      'uiHints': uiHints,
      'version': version,
      'generatedAt': generatedAt,
    });
  }
}

class GatewaySchemaConfigSetParams {
  const GatewaySchemaConfigSetParams({
    required this.raw,
    this.baseHash,
  });

  factory GatewaySchemaConfigSetParams.fromJson(JsonMap json) {
    return GatewaySchemaConfigSetParams(
      raw: _generatedReadRequiredString(json, 'raw',
          context: 'ConfigSetParams.raw', allowEmpty: false),
      baseHash:
          _generatedReadNullableString(json['baseHash'], allowEmpty: false),
    );
  }

  final String raw;
  final String? baseHash;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'raw': raw,
      'baseHash': baseHash,
    });
  }
}

class GatewaySchemaConnectParamsClient {
  const GatewaySchemaConnectParamsClient({
    required this.id,
    this.displayName,
    required this.version,
    required this.platform,
    this.deviceFamily,
    this.modelIdentifier,
    required this.mode,
    this.instanceId,
  });

  factory GatewaySchemaConnectParamsClient.fromJson(JsonMap json) {
    return GatewaySchemaConnectParamsClient(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaConnectParams.client.id', allowEmpty: true),
      displayName:
          _generatedReadNullableString(json['displayName'], allowEmpty: false),
      version: _generatedReadRequiredString(json, 'version',
          context: 'GatewaySchemaConnectParams.client.version',
          allowEmpty: false),
      platform: _generatedReadRequiredString(json, 'platform',
          context: 'GatewaySchemaConnectParams.client.platform',
          allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      modelIdentifier: _generatedReadNullableString(json['modelIdentifier'],
          allowEmpty: false),
      mode: _generatedReadRequiredString(json, 'mode',
          context: 'GatewaySchemaConnectParams.client.mode', allowEmpty: true),
      instanceId:
          _generatedReadNullableString(json['instanceId'], allowEmpty: false),
    );
  }

  final String id;
  final String? displayName;
  final String version;
  final String platform;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String mode;
  final String? instanceId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'displayName': displayName,
      'version': version,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'mode': mode,
      'instanceId': instanceId,
    });
  }
}

class GatewaySchemaConnectParamsDevice {
  const GatewaySchemaConnectParamsDevice({
    required this.id,
    required this.publicKey,
    required this.signature,
    required this.signedAt,
    required this.nonce,
  });

  factory GatewaySchemaConnectParamsDevice.fromJson(JsonMap json) {
    return GatewaySchemaConnectParamsDevice(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaConnectParams.device.id', allowEmpty: false),
      publicKey: _generatedReadRequiredString(json, 'publicKey',
          context: 'GatewaySchemaConnectParams.device.publicKey',
          allowEmpty: false),
      signature: _generatedReadRequiredString(json, 'signature',
          context: 'GatewaySchemaConnectParams.device.signature',
          allowEmpty: false),
      signedAt: readRequiredInt(json, 'signedAt',
          context: 'GatewaySchemaConnectParams.device.signedAt'),
      nonce: _generatedReadRequiredString(json, 'nonce',
          context: 'GatewaySchemaConnectParams.device.nonce',
          allowEmpty: false),
    );
  }

  final String id;
  final String publicKey;
  final String signature;
  final int signedAt;
  final String nonce;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'publicKey': publicKey,
      'signature': signature,
      'signedAt': signedAt,
      'nonce': nonce,
    });
  }
}

class GatewaySchemaConnectParamsAuth {
  const GatewaySchemaConnectParamsAuth({
    this.token,
    this.deviceToken,
    this.password,
  });

  factory GatewaySchemaConnectParamsAuth.fromJson(JsonMap json) {
    return GatewaySchemaConnectParamsAuth(
      token: _generatedReadNullableString(json['token'], allowEmpty: true),
      deviceToken:
          _generatedReadNullableString(json['deviceToken'], allowEmpty: true),
      password:
          _generatedReadNullableString(json['password'], allowEmpty: true),
    );
  }

  final String? token;
  final String? deviceToken;
  final String? password;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'token': token,
      'deviceToken': deviceToken,
      'password': password,
    });
  }
}

class GatewaySchemaConnectParams {
  const GatewaySchemaConnectParams({
    required this.minProtocol,
    required this.maxProtocol,
    required this.client,
    this.caps,
    this.commands,
    this.permissions,
    this.pathEnv,
    this.role,
    this.scopes,
    this.device,
    this.auth,
    this.locale,
    this.userAgent,
  });

  factory GatewaySchemaConnectParams.fromJson(JsonMap json) {
    return GatewaySchemaConnectParams(
      minProtocol: readRequiredInt(json, 'minProtocol',
          context: 'ConnectParams.minProtocol'),
      maxProtocol: readRequiredInt(json, 'maxProtocol',
          context: 'ConnectParams.maxProtocol'),
      client: GatewaySchemaConnectParamsClient.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'client', context: 'ConnectParams'),
          context: 'ConnectParams.client')),
      caps: json['caps'] == null
          ? null
          : asJsonList(json['caps'], context: 'ConnectParams.caps')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'ConnectParams.caps[]'))
              .toList(growable: false),
      commands: json['commands'] == null
          ? null
          : asJsonList(json['commands'], context: 'ConnectParams.commands')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'ConnectParams.commands[]'))
              .toList(growable: false),
      permissions: json['permissions'] == null
          ? null
          : Map<String, bool>.unmodifiable({
              for (final entry in asJsonMap(json['permissions'],
                      context: 'ConnectParams.permissions')
                  .entries)
                entry.key: _generatedReadItemBool(entry.value,
                    context: 'ConnectParams.permissions.${entry.key}')
            }),
      pathEnv: _generatedReadNullableString(json['pathEnv'], allowEmpty: true),
      role: _generatedReadNullableString(json['role'], allowEmpty: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'], context: 'ConnectParams.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'ConnectParams.scopes[]'))
              .toList(growable: false),
      device: json['device'] == null
          ? null
          : GatewaySchemaConnectParamsDevice.fromJson(
              asJsonMap(json['device'], context: 'ConnectParams.device')),
      auth: json['auth'] == null
          ? null
          : GatewaySchemaConnectParamsAuth.fromJson(
              asJsonMap(json['auth'], context: 'ConnectParams.auth')),
      locale: _generatedReadNullableString(json['locale'], allowEmpty: true),
      userAgent:
          _generatedReadNullableString(json['userAgent'], allowEmpty: true),
    );
  }

  final int minProtocol;
  final int maxProtocol;
  final GatewaySchemaConnectParamsClient client;
  final List<String>? caps;
  final List<String>? commands;
  final Map<String, bool>? permissions;
  final String? pathEnv;
  final String? role;
  final List<String>? scopes;
  final GatewaySchemaConnectParamsDevice? device;
  final GatewaySchemaConnectParamsAuth? auth;
  final String? locale;
  final String? userAgent;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'minProtocol': minProtocol,
      'maxProtocol': maxProtocol,
      'client': client.toJson(),
      'caps': caps?.map((entry) => entry).toList(growable: false),
      'commands': commands?.map((entry) => entry).toList(growable: false),
      'permissions': permissions,
      'pathEnv': pathEnv,
      'role': role,
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
      'device': device?.toJson(),
      'auth': auth?.toJson(),
      'locale': locale,
      'userAgent': userAgent,
    });
  }
}

class GatewaySchemaCronAddParams {
  const GatewaySchemaCronAddParams({
    required this.name,
    this.agentId,
    this.sessionKey,
    this.description,
    this.enabled,
    this.deleteAfterRun,
    this.schedule,
    required this.sessionTarget,
    required this.wakeMode,
    this.payload,
    this.delivery,
    this.failureAlert,
  });

  factory GatewaySchemaCronAddParams.fromJson(JsonMap json) {
    return GatewaySchemaCronAddParams(
      name: _generatedReadRequiredString(json, 'name',
          context: 'CronAddParams.name', allowEmpty: false),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: false),
      description:
          _generatedReadNullableString(json['description'], allowEmpty: true),
      enabled: readNullableBool(json['enabled']),
      deleteAfterRun: readNullableBool(json['deleteAfterRun']),
      schedule: json['schedule'],
      sessionTarget: _generatedReadRequiredString(json, 'sessionTarget',
          context: 'CronAddParams.sessionTarget', allowEmpty: true),
      wakeMode: _generatedReadRequiredString(json, 'wakeMode',
          context: 'CronAddParams.wakeMode', allowEmpty: true),
      payload: json['payload'],
      delivery: json['delivery'],
      failureAlert: json['failureAlert'],
    );
  }

  final String name;
  final String? agentId;
  final String? sessionKey;
  final String? description;
  final bool? enabled;
  final bool? deleteAfterRun;
  final Object? schedule;
  final String sessionTarget;
  final String wakeMode;
  final Object? payload;
  final Object? delivery;
  final Object? failureAlert;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'agentId': agentId,
      'sessionKey': sessionKey,
      'description': description,
      'enabled': enabled,
      'deleteAfterRun': deleteAfterRun,
      'schedule': schedule,
      'sessionTarget': sessionTarget,
      'wakeMode': wakeMode,
      'payload': payload,
      'delivery': delivery,
      'failureAlert': failureAlert,
    });
  }
}

class GatewaySchemaCronJobState {
  const GatewaySchemaCronJobState({
    this.nextRunAtMs,
    this.runningAtMs,
    this.lastRunAtMs,
    this.lastRunStatus,
    this.lastStatus,
    this.lastError,
    this.lastDurationMs,
    this.consecutiveErrors,
    this.lastDelivered,
    this.lastDeliveryStatus,
    this.lastDeliveryError,
    this.lastFailureAlertAtMs,
  });

  factory GatewaySchemaCronJobState.fromJson(JsonMap json) {
    return GatewaySchemaCronJobState(
      nextRunAtMs: readNullableInt(json['nextRunAtMs']),
      runningAtMs: readNullableInt(json['runningAtMs']),
      lastRunAtMs: readNullableInt(json['lastRunAtMs']),
      lastRunStatus:
          _generatedReadNullableString(json['lastRunStatus'], allowEmpty: true),
      lastStatus:
          _generatedReadNullableString(json['lastStatus'], allowEmpty: true),
      lastError:
          _generatedReadNullableString(json['lastError'], allowEmpty: true),
      lastDurationMs: readNullableInt(json['lastDurationMs']),
      consecutiveErrors: readNullableInt(json['consecutiveErrors']),
      lastDelivered: readNullableBool(json['lastDelivered']),
      lastDeliveryStatus: _generatedReadNullableString(
          json['lastDeliveryStatus'],
          allowEmpty: true),
      lastDeliveryError: _generatedReadNullableString(json['lastDeliveryError'],
          allowEmpty: true),
      lastFailureAlertAtMs: readNullableInt(json['lastFailureAlertAtMs']),
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
  final bool? lastDelivered;
  final String? lastDeliveryStatus;
  final String? lastDeliveryError;
  final int? lastFailureAlertAtMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nextRunAtMs': nextRunAtMs,
      'runningAtMs': runningAtMs,
      'lastRunAtMs': lastRunAtMs,
      'lastRunStatus': lastRunStatus,
      'lastStatus': lastStatus,
      'lastError': lastError,
      'lastDurationMs': lastDurationMs,
      'consecutiveErrors': consecutiveErrors,
      'lastDelivered': lastDelivered,
      'lastDeliveryStatus': lastDeliveryStatus,
      'lastDeliveryError': lastDeliveryError,
      'lastFailureAlertAtMs': lastFailureAlertAtMs,
    });
  }
}

class GatewaySchemaCronJob {
  const GatewaySchemaCronJob({
    required this.id,
    this.agentId,
    this.sessionKey,
    required this.name,
    this.description,
    required this.enabled,
    this.deleteAfterRun,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.schedule,
    required this.sessionTarget,
    required this.wakeMode,
    this.payload,
    this.delivery,
    this.failureAlert,
    required this.state,
  });

  factory GatewaySchemaCronJob.fromJson(JsonMap json) {
    return GatewaySchemaCronJob(
      id: _generatedReadRequiredString(json, 'id',
          context: 'CronJob.id', allowEmpty: false),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'CronJob.name', allowEmpty: false),
      description:
          _generatedReadNullableString(json['description'], allowEmpty: true),
      enabled: readRequiredBool(json, 'enabled', context: 'CronJob.enabled'),
      deleteAfterRun: readNullableBool(json['deleteAfterRun']),
      createdAtMs:
          readRequiredInt(json, 'createdAtMs', context: 'CronJob.createdAtMs'),
      updatedAtMs:
          readRequiredInt(json, 'updatedAtMs', context: 'CronJob.updatedAtMs'),
      schedule: json['schedule'],
      sessionTarget: _generatedReadRequiredString(json, 'sessionTarget',
          context: 'CronJob.sessionTarget', allowEmpty: true),
      wakeMode: _generatedReadRequiredString(json, 'wakeMode',
          context: 'CronJob.wakeMode', allowEmpty: true),
      payload: json['payload'],
      delivery: json['delivery'],
      failureAlert: json['failureAlert'],
      state: GatewaySchemaCronJobState.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'state', context: 'CronJob'),
          context: 'CronJob.state')),
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
  final Object? schedule;
  final String sessionTarget;
  final String wakeMode;
  final Object? payload;
  final Object? delivery;
  final Object? failureAlert;
  final GatewaySchemaCronJobState state;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'agentId': agentId,
      'sessionKey': sessionKey,
      'name': name,
      'description': description,
      'enabled': enabled,
      'deleteAfterRun': deleteAfterRun,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
      'schedule': schedule,
      'sessionTarget': sessionTarget,
      'wakeMode': wakeMode,
      'payload': payload,
      'delivery': delivery,
      'failureAlert': failureAlert,
      'state': state.toJson(),
    });
  }
}

class GatewaySchemaCronListParams {
  const GatewaySchemaCronListParams({
    this.includeDisabled,
    this.limit,
    this.offset,
    this.query,
    this.enabled,
    this.sortBy,
    this.sortDir,
  });

  factory GatewaySchemaCronListParams.fromJson(JsonMap json) {
    return GatewaySchemaCronListParams(
      includeDisabled: readNullableBool(json['includeDisabled']),
      limit: readNullableInt(json['limit']),
      offset: readNullableInt(json['offset']),
      query: _generatedReadNullableString(json['query'], allowEmpty: true),
      enabled: _generatedReadNullableString(json['enabled'], allowEmpty: true),
      sortBy: _generatedReadNullableString(json['sortBy'], allowEmpty: true),
      sortDir: _generatedReadNullableString(json['sortDir'], allowEmpty: true),
    );
  }

  final bool? includeDisabled;
  final int? limit;
  final int? offset;
  final String? query;
  final String? enabled;
  final String? sortBy;
  final String? sortDir;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'includeDisabled': includeDisabled,
      'limit': limit,
      'offset': offset,
      'query': query,
      'enabled': enabled,
      'sortBy': sortBy,
      'sortDir': sortDir,
    });
  }
}

class GatewaySchemaCronRemoveParams {
  const GatewaySchemaCronRemoveParams(this.value);

  factory GatewaySchemaCronRemoveParams.fromJson(JsonMap json) {
    return GatewaySchemaCronRemoveParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaCronRunLogEntryUsage {
  const GatewaySchemaCronRunLogEntryUsage({
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
    this.cacheReadTokens,
    this.cacheWriteTokens,
  });

  factory GatewaySchemaCronRunLogEntryUsage.fromJson(JsonMap json) {
    return GatewaySchemaCronRunLogEntryUsage(
      inputTokens: _generatedReadNullableNum(json['input_tokens']),
      outputTokens: _generatedReadNullableNum(json['output_tokens']),
      totalTokens: _generatedReadNullableNum(json['total_tokens']),
      cacheReadTokens: _generatedReadNullableNum(json['cache_read_tokens']),
      cacheWriteTokens: _generatedReadNullableNum(json['cache_write_tokens']),
    );
  }

  final num? inputTokens;
  final num? outputTokens;
  final num? totalTokens;
  final num? cacheReadTokens;
  final num? cacheWriteTokens;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'input_tokens': inputTokens,
      'output_tokens': outputTokens,
      'total_tokens': totalTokens,
      'cache_read_tokens': cacheReadTokens,
      'cache_write_tokens': cacheWriteTokens,
    });
  }
}

class GatewaySchemaCronRunLogEntry {
  const GatewaySchemaCronRunLogEntry({
    required this.ts,
    required this.jobId,
    required this.action,
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

  factory GatewaySchemaCronRunLogEntry.fromJson(JsonMap json) {
    return GatewaySchemaCronRunLogEntry(
      ts: readRequiredInt(json, 'ts', context: 'CronRunLogEntry.ts'),
      jobId: _generatedReadRequiredString(json, 'jobId',
          context: 'CronRunLogEntry.jobId', allowEmpty: false),
      action: _generatedReadRequiredString(json, 'action',
          context: 'CronRunLogEntry.action', allowEmpty: true),
      status: _generatedReadNullableString(json['status'], allowEmpty: true),
      error: _generatedReadNullableString(json['error'], allowEmpty: true),
      summary: _generatedReadNullableString(json['summary'], allowEmpty: true),
      delivered: readNullableBool(json['delivered']),
      deliveryStatus: _generatedReadNullableString(json['deliveryStatus'],
          allowEmpty: true),
      deliveryError:
          _generatedReadNullableString(json['deliveryError'], allowEmpty: true),
      sessionId:
          _generatedReadNullableString(json['sessionId'], allowEmpty: false),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: false),
      runAtMs: readNullableInt(json['runAtMs']),
      durationMs: readNullableInt(json['durationMs']),
      nextRunAtMs: readNullableInt(json['nextRunAtMs']),
      model: _generatedReadNullableString(json['model'], allowEmpty: true),
      provider:
          _generatedReadNullableString(json['provider'], allowEmpty: true),
      usage: json['usage'] == null
          ? null
          : GatewaySchemaCronRunLogEntryUsage.fromJson(
              asJsonMap(json['usage'], context: 'CronRunLogEntry.usage')),
      jobName: _generatedReadNullableString(json['jobName'], allowEmpty: true),
    );
  }

  final int ts;
  final String jobId;
  final String action;
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
  final GatewaySchemaCronRunLogEntryUsage? usage;
  final String? jobName;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ts': ts,
      'jobId': jobId,
      'action': action,
      'status': status,
      'error': error,
      'summary': summary,
      'delivered': delivered,
      'deliveryStatus': deliveryStatus,
      'deliveryError': deliveryError,
      'sessionId': sessionId,
      'sessionKey': sessionKey,
      'runAtMs': runAtMs,
      'durationMs': durationMs,
      'nextRunAtMs': nextRunAtMs,
      'model': model,
      'provider': provider,
      'usage': usage?.toJson(),
      'jobName': jobName,
    });
  }
}

class GatewaySchemaCronRunParams {
  const GatewaySchemaCronRunParams(this.value);

  factory GatewaySchemaCronRunParams.fromJson(JsonMap json) {
    return GatewaySchemaCronRunParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaCronRunsParams {
  const GatewaySchemaCronRunsParams({
    this.scope,
    this.id,
    this.jobId,
    this.limit,
    this.offset,
    this.statuses,
    this.status,
    this.deliveryStatuses,
    this.deliveryStatus,
    this.query,
    this.sortDir,
  });

  factory GatewaySchemaCronRunsParams.fromJson(JsonMap json) {
    return GatewaySchemaCronRunsParams(
      scope: _generatedReadNullableString(json['scope'], allowEmpty: true),
      id: _generatedReadNullableString(json['id'], allowEmpty: false),
      jobId: _generatedReadNullableString(json['jobId'], allowEmpty: false),
      limit: readNullableInt(json['limit']),
      offset: readNullableInt(json['offset']),
      statuses: json['statuses'] == null
          ? null
          : asJsonList(json['statuses'], context: 'CronRunsParams.statuses')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'CronRunsParams.statuses[]'))
              .toList(growable: false),
      status: _generatedReadNullableString(json['status'], allowEmpty: true),
      deliveryStatuses: json['deliveryStatuses'] == null
          ? null
          : asJsonList(json['deliveryStatuses'],
                  context: 'CronRunsParams.deliveryStatuses')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'CronRunsParams.deliveryStatuses[]'))
              .toList(growable: false),
      deliveryStatus: _generatedReadNullableString(json['deliveryStatus'],
          allowEmpty: true),
      query: _generatedReadNullableString(json['query'], allowEmpty: true),
      sortDir: _generatedReadNullableString(json['sortDir'], allowEmpty: true),
    );
  }

  final String? scope;
  final String? id;
  final String? jobId;
  final int? limit;
  final int? offset;
  final List<String>? statuses;
  final String? status;
  final List<String>? deliveryStatuses;
  final String? deliveryStatus;
  final String? query;
  final String? sortDir;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'scope': scope,
      'id': id,
      'jobId': jobId,
      'limit': limit,
      'offset': offset,
      'statuses': statuses?.map((entry) => entry).toList(growable: false),
      'status': status,
      'deliveryStatuses':
          deliveryStatuses?.map((entry) => entry).toList(growable: false),
      'deliveryStatus': deliveryStatus,
      'query': query,
      'sortDir': sortDir,
    });
  }
}

class GatewaySchemaCronStatusParams {
  const GatewaySchemaCronStatusParams(this.value);

  factory GatewaySchemaCronStatusParams.fromJson(JsonMap json) {
    return GatewaySchemaCronStatusParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaCronUpdateParams {
  const GatewaySchemaCronUpdateParams(this.value);

  factory GatewaySchemaCronUpdateParams.fromJson(JsonMap json) {
    return GatewaySchemaCronUpdateParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaDevicePairApproveParams {
  const GatewaySchemaDevicePairApproveParams({
    required this.requestId,
  });

  factory GatewaySchemaDevicePairApproveParams.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairApproveParams(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'DevicePairApproveParams.requestId', allowEmpty: false),
    );
  }

  final String requestId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
    });
  }
}

class GatewaySchemaDevicePairListParams {
  const GatewaySchemaDevicePairListParams(this.value);

  factory GatewaySchemaDevicePairListParams.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairListParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaDevicePairRejectParams {
  const GatewaySchemaDevicePairRejectParams({
    required this.requestId,
  });

  factory GatewaySchemaDevicePairRejectParams.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairRejectParams(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'DevicePairRejectParams.requestId', allowEmpty: false),
    );
  }

  final String requestId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
    });
  }
}

class GatewaySchemaDevicePairRemoveParams {
  const GatewaySchemaDevicePairRemoveParams({
    required this.deviceId,
  });

  factory GatewaySchemaDevicePairRemoveParams.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairRemoveParams(
      deviceId: _generatedReadRequiredString(json, 'deviceId',
          context: 'DevicePairRemoveParams.deviceId', allowEmpty: false),
    );
  }

  final String deviceId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'deviceId': deviceId,
    });
  }
}

class GatewaySchemaDevicePairRequestedEvent {
  const GatewaySchemaDevicePairRequestedEvent({
    required this.requestId,
    required this.deviceId,
    required this.publicKey,
    this.displayName,
    this.platform,
    this.deviceFamily,
    this.clientId,
    this.clientMode,
    this.role,
    this.roles,
    this.scopes,
    this.remoteIp,
    this.silent,
    this.isRepair,
    required this.ts,
  });

  factory GatewaySchemaDevicePairRequestedEvent.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairRequestedEvent(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'DevicePairRequestedEvent.requestId', allowEmpty: false),
      deviceId: _generatedReadRequiredString(json, 'deviceId',
          context: 'DevicePairRequestedEvent.deviceId', allowEmpty: false),
      publicKey: _generatedReadRequiredString(json, 'publicKey',
          context: 'DevicePairRequestedEvent.publicKey', allowEmpty: false),
      displayName:
          _generatedReadNullableString(json['displayName'], allowEmpty: false),
      platform:
          _generatedReadNullableString(json['platform'], allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      clientId:
          _generatedReadNullableString(json['clientId'], allowEmpty: false),
      clientMode:
          _generatedReadNullableString(json['clientMode'], allowEmpty: false),
      role: _generatedReadNullableString(json['role'], allowEmpty: false),
      roles: json['roles'] == null
          ? null
          : asJsonList(json['roles'], context: 'DevicePairRequestedEvent.roles')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'DevicePairRequestedEvent.roles[]'))
              .toList(growable: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'],
                  context: 'DevicePairRequestedEvent.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'DevicePairRequestedEvent.scopes[]'))
              .toList(growable: false),
      remoteIp:
          _generatedReadNullableString(json['remoteIp'], allowEmpty: false),
      silent: readNullableBool(json['silent']),
      isRepair: readNullableBool(json['isRepair']),
      ts: readRequiredInt(json, 'ts', context: 'DevicePairRequestedEvent.ts'),
    );
  }

  final String requestId;
  final String deviceId;
  final String publicKey;
  final String? displayName;
  final String? platform;
  final String? deviceFamily;
  final String? clientId;
  final String? clientMode;
  final String? role;
  final List<String>? roles;
  final List<String>? scopes;
  final String? remoteIp;
  final bool? silent;
  final bool? isRepair;
  final int ts;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
      'deviceId': deviceId,
      'publicKey': publicKey,
      'displayName': displayName,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'clientId': clientId,
      'clientMode': clientMode,
      'role': role,
      'roles': roles?.map((entry) => entry).toList(growable: false),
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
      'remoteIp': remoteIp,
      'silent': silent,
      'isRepair': isRepair,
      'ts': ts,
    });
  }
}

class GatewaySchemaDevicePairResolvedEvent {
  const GatewaySchemaDevicePairResolvedEvent({
    required this.requestId,
    required this.deviceId,
    required this.decision,
    required this.ts,
  });

  factory GatewaySchemaDevicePairResolvedEvent.fromJson(JsonMap json) {
    return GatewaySchemaDevicePairResolvedEvent(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'DevicePairResolvedEvent.requestId', allowEmpty: false),
      deviceId: _generatedReadRequiredString(json, 'deviceId',
          context: 'DevicePairResolvedEvent.deviceId', allowEmpty: false),
      decision: _generatedReadRequiredString(json, 'decision',
          context: 'DevicePairResolvedEvent.decision', allowEmpty: false),
      ts: readRequiredInt(json, 'ts', context: 'DevicePairResolvedEvent.ts'),
    );
  }

  final String requestId;
  final String deviceId;
  final String decision;
  final int ts;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
      'deviceId': deviceId,
      'decision': decision,
      'ts': ts,
    });
  }
}

class GatewaySchemaDeviceTokenRevokeParams {
  const GatewaySchemaDeviceTokenRevokeParams({
    required this.deviceId,
    required this.role,
  });

  factory GatewaySchemaDeviceTokenRevokeParams.fromJson(JsonMap json) {
    return GatewaySchemaDeviceTokenRevokeParams(
      deviceId: _generatedReadRequiredString(json, 'deviceId',
          context: 'DeviceTokenRevokeParams.deviceId', allowEmpty: false),
      role: _generatedReadRequiredString(json, 'role',
          context: 'DeviceTokenRevokeParams.role', allowEmpty: false),
    );
  }

  final String deviceId;
  final String role;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'deviceId': deviceId,
      'role': role,
    });
  }
}

class GatewaySchemaDeviceTokenRotateParams {
  const GatewaySchemaDeviceTokenRotateParams({
    required this.deviceId,
    required this.role,
    this.scopes,
  });

  factory GatewaySchemaDeviceTokenRotateParams.fromJson(JsonMap json) {
    return GatewaySchemaDeviceTokenRotateParams(
      deviceId: _generatedReadRequiredString(json, 'deviceId',
          context: 'DeviceTokenRotateParams.deviceId', allowEmpty: false),
      role: _generatedReadRequiredString(json, 'role',
          context: 'DeviceTokenRotateParams.role', allowEmpty: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'],
                  context: 'DeviceTokenRotateParams.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'DeviceTokenRotateParams.scopes[]'))
              .toList(growable: false),
    );
  }

  final String deviceId;
  final String role;
  final List<String>? scopes;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'deviceId': deviceId,
      'role': role,
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaErrorShape {
  const GatewaySchemaErrorShape({
    required this.code,
    required this.message,
    this.details,
    this.retryable,
    this.retryAfterMs,
  });

  factory GatewaySchemaErrorShape.fromJson(JsonMap json) {
    return GatewaySchemaErrorShape(
      code: _generatedReadRequiredString(json, 'code',
          context: 'ErrorShape.code', allowEmpty: false),
      message: _generatedReadRequiredString(json, 'message',
          context: 'ErrorShape.message', allowEmpty: false),
      details: json['details'],
      retryable: readNullableBool(json['retryable']),
      retryAfterMs: readNullableInt(json['retryAfterMs']),
    );
  }

  final String code;
  final String message;
  final Object? details;
  final bool? retryable;
  final int? retryAfterMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'code': code,
      'message': message,
      'details': details,
      'retryable': retryable,
      'retryAfterMs': retryAfterMs,
    });
  }
}

class GatewaySchemaEventFrameStateVersion {
  const GatewaySchemaEventFrameStateVersion({
    required this.presence,
    required this.health,
  });

  factory GatewaySchemaEventFrameStateVersion.fromJson(JsonMap json) {
    return GatewaySchemaEventFrameStateVersion(
      presence: readRequiredInt(json, 'presence',
          context: 'GatewaySchemaEventFrame.stateVersion.presence'),
      health: readRequiredInt(json, 'health',
          context: 'GatewaySchemaEventFrame.stateVersion.health'),
    );
  }

  final int presence;
  final int health;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence': presence,
      'health': health,
    });
  }
}

class GatewaySchemaEventFrame {
  const GatewaySchemaEventFrame({
    required this.type,
    required this.event,
    this.payload,
    this.seq,
    this.stateVersion,
  });

  factory GatewaySchemaEventFrame.fromJson(JsonMap json) {
    return GatewaySchemaEventFrame(
      type: _generatedReadRequiredString(json, 'type',
          context: 'EventFrame.type', allowEmpty: true),
      event: _generatedReadRequiredString(json, 'event',
          context: 'EventFrame.event', allowEmpty: false),
      payload: json['payload'],
      seq: readNullableInt(json['seq']),
      stateVersion: json['stateVersion'] == null
          ? null
          : GatewaySchemaEventFrameStateVersion.fromJson(asJsonMap(
              json['stateVersion'],
              context: 'EventFrame.stateVersion')),
    );
  }

  final String type;
  final String event;
  final Object? payload;
  final int? seq;
  final GatewaySchemaEventFrameStateVersion? stateVersion;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'type': type,
      'event': event,
      'payload': payload,
      'seq': seq,
      'stateVersion': stateVersion?.toJson(),
    });
  }
}

class GatewaySchemaExecApprovalRequestParamsSystemRunPlan {
  const GatewaySchemaExecApprovalRequestParamsSystemRunPlan({
    required this.argv,
    this.cwd,
    this.rawCommand,
    this.agentId,
    this.sessionKey,
  });

  factory GatewaySchemaExecApprovalRequestParamsSystemRunPlan.fromJson(
      JsonMap json) {
    return GatewaySchemaExecApprovalRequestParamsSystemRunPlan(
      argv: asJsonList(json['argv'],
              context:
                  'GatewaySchemaExecApprovalRequestParams.systemRunPlan.argv')
          .map((entry) => _generatedReadItemString(entry,
              context:
                  'GatewaySchemaExecApprovalRequestParams.systemRunPlan.argv[]'))
          .toList(growable: false),
      cwd: _generatedReadNullableString(json['cwd'], allowEmpty: true),
      rawCommand:
          _generatedReadNullableString(json['rawCommand'], allowEmpty: true),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: true),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
    );
  }

  final List<String> argv;
  final String? cwd;
  final String? rawCommand;
  final String? agentId;
  final String? sessionKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'argv': argv.map((entry) => entry).toList(growable: false),
      'cwd': cwd,
      'rawCommand': rawCommand,
      'agentId': agentId,
      'sessionKey': sessionKey,
    });
  }
}

class GatewaySchemaExecApprovalRequestParams {
  const GatewaySchemaExecApprovalRequestParams({
    this.id,
    required this.command,
    this.commandArgv,
    this.systemRunPlan,
    this.env,
    this.cwd,
    this.nodeId,
    this.host,
    this.security,
    this.ask,
    this.agentId,
    this.resolvedPath,
    this.sessionKey,
    this.turnSourceChannel,
    this.turnSourceTo,
    this.turnSourceAccountId,
    this.turnSourceThreadId,
    this.timeoutMs,
    this.twoPhase,
  });

  factory GatewaySchemaExecApprovalRequestParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalRequestParams(
      id: _generatedReadNullableString(json['id'], allowEmpty: false),
      command: _generatedReadRequiredString(json, 'command',
          context: 'ExecApprovalRequestParams.command', allowEmpty: false),
      commandArgv: json['commandArgv'] == null
          ? null
          : asJsonList(json['commandArgv'],
                  context: 'ExecApprovalRequestParams.commandArgv')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'ExecApprovalRequestParams.commandArgv[]'))
              .toList(growable: false),
      systemRunPlan: json['systemRunPlan'] == null
          ? null
          : GatewaySchemaExecApprovalRequestParamsSystemRunPlan.fromJson(
              asJsonMap(json['systemRunPlan'],
                  context: 'ExecApprovalRequestParams.systemRunPlan')),
      env: json['env'] == null
          ? null
          : Map<String, String>.unmodifiable({
              for (final entry in asJsonMap(json['env'],
                      context: 'ExecApprovalRequestParams.env')
                  .entries)
                entry.key: _generatedReadItemString(entry.value,
                    context: 'ExecApprovalRequestParams.env.${entry.key}')
            }),
      cwd: _generatedReadNullableString(json['cwd'], allowEmpty: true),
      nodeId: _generatedReadNullableString(json['nodeId'], allowEmpty: false),
      host: _generatedReadNullableString(json['host'], allowEmpty: true),
      security:
          _generatedReadNullableString(json['security'], allowEmpty: true),
      ask: _generatedReadNullableString(json['ask'], allowEmpty: true),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: true),
      resolvedPath:
          _generatedReadNullableString(json['resolvedPath'], allowEmpty: true),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      turnSourceChannel: _generatedReadNullableString(json['turnSourceChannel'],
          allowEmpty: true),
      turnSourceTo:
          _generatedReadNullableString(json['turnSourceTo'], allowEmpty: true),
      turnSourceAccountId: _generatedReadNullableString(
          json['turnSourceAccountId'],
          allowEmpty: true),
      turnSourceThreadId: json['turnSourceThreadId'],
      timeoutMs: readNullableInt(json['timeoutMs']),
      twoPhase: readNullableBool(json['twoPhase']),
    );
  }

  final String? id;
  final String command;
  final List<String>? commandArgv;
  final GatewaySchemaExecApprovalRequestParamsSystemRunPlan? systemRunPlan;
  final Map<String, String>? env;
  final String? cwd;
  final String? nodeId;
  final String? host;
  final String? security;
  final String? ask;
  final String? agentId;
  final String? resolvedPath;
  final String? sessionKey;
  final String? turnSourceChannel;
  final String? turnSourceTo;
  final String? turnSourceAccountId;
  final Object? turnSourceThreadId;
  final int? timeoutMs;
  final bool? twoPhase;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'command': command,
      'commandArgv': commandArgv?.map((entry) => entry).toList(growable: false),
      'systemRunPlan': systemRunPlan?.toJson(),
      'env': env,
      'cwd': cwd,
      'nodeId': nodeId,
      'host': host,
      'security': security,
      'ask': ask,
      'agentId': agentId,
      'resolvedPath': resolvedPath,
      'sessionKey': sessionKey,
      'turnSourceChannel': turnSourceChannel,
      'turnSourceTo': turnSourceTo,
      'turnSourceAccountId': turnSourceAccountId,
      'turnSourceThreadId': turnSourceThreadId,
      'timeoutMs': timeoutMs,
      'twoPhase': twoPhase,
    });
  }
}

class GatewaySchemaExecApprovalResolveParams {
  const GatewaySchemaExecApprovalResolveParams({
    required this.id,
    required this.decision,
  });

  factory GatewaySchemaExecApprovalResolveParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalResolveParams(
      id: _generatedReadRequiredString(json, 'id',
          context: 'ExecApprovalResolveParams.id', allowEmpty: false),
      decision: _generatedReadRequiredString(json, 'decision',
          context: 'ExecApprovalResolveParams.decision', allowEmpty: false),
    );
  }

  final String id;
  final String decision;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'decision': decision,
    });
  }
}

class GatewaySchemaExecApprovalsGetParams {
  const GatewaySchemaExecApprovalsGetParams(this.value);

  factory GatewaySchemaExecApprovalsGetParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsGetParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaExecApprovalsNodeGetParams {
  const GatewaySchemaExecApprovalsNodeGetParams({
    required this.nodeId,
  });

  factory GatewaySchemaExecApprovalsNodeGetParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsNodeGetParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'ExecApprovalsNodeGetParams.nodeId', allowEmpty: false),
    );
  }

  final String nodeId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
    });
  }
}

class GatewaySchemaExecApprovalsNodeSetParamsFileSocket {
  const GatewaySchemaExecApprovalsNodeSetParamsFileSocket({
    this.path,
    this.token,
  });

  factory GatewaySchemaExecApprovalsNodeSetParamsFileSocket.fromJson(
      JsonMap json) {
    return GatewaySchemaExecApprovalsNodeSetParamsFileSocket(
      path: _generatedReadNullableString(json['path'], allowEmpty: true),
      token: _generatedReadNullableString(json['token'], allowEmpty: true),
    );
  }

  final String? path;
  final String? token;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'token': token,
    });
  }
}

class GatewaySchemaExecApprovalsNodeSetParamsFileDefaults {
  const GatewaySchemaExecApprovalsNodeSetParamsFileDefaults({
    this.security,
    this.ask,
    this.askFallback,
    this.autoAllowSkills,
  });

  factory GatewaySchemaExecApprovalsNodeSetParamsFileDefaults.fromJson(
      JsonMap json) {
    return GatewaySchemaExecApprovalsNodeSetParamsFileDefaults(
      security:
          _generatedReadNullableString(json['security'], allowEmpty: true),
      ask: _generatedReadNullableString(json['ask'], allowEmpty: true),
      askFallback:
          _generatedReadNullableString(json['askFallback'], allowEmpty: true),
      autoAllowSkills: readNullableBool(json['autoAllowSkills']),
    );
  }

  final String? security;
  final String? ask;
  final String? askFallback;
  final bool? autoAllowSkills;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'security': security,
      'ask': ask,
      'askFallback': askFallback,
      'autoAllowSkills': autoAllowSkills,
    });
  }
}

class GatewaySchemaExecApprovalsNodeSetParamsFile {
  const GatewaySchemaExecApprovalsNodeSetParamsFile({
    required this.version,
    this.socket,
    this.defaults,
    this.agents,
  });

  factory GatewaySchemaExecApprovalsNodeSetParamsFile.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsNodeSetParamsFile(
      version: _generatedReadRequiredNum(json, 'version',
          context: 'GatewaySchemaExecApprovalsNodeSetParams.file.version'),
      socket: json['socket'] == null
          ? null
          : GatewaySchemaExecApprovalsNodeSetParamsFileSocket.fromJson(
              asJsonMap(json['socket'],
                  context:
                      'GatewaySchemaExecApprovalsNodeSetParams.file.socket')),
      defaults: json['defaults'] == null
          ? null
          : GatewaySchemaExecApprovalsNodeSetParamsFileDefaults.fromJson(
              asJsonMap(json['defaults'],
                  context:
                      'GatewaySchemaExecApprovalsNodeSetParams.file.defaults')),
      agents: json['agents'] == null
          ? null
          : Map<String, JsonMap>.unmodifiable({
              for (final entry in asJsonMap(json['agents'],
                      context:
                          'GatewaySchemaExecApprovalsNodeSetParams.file.agents')
                  .entries)
                entry.key: asJsonMap(entry.value,
                    context:
                        'GatewaySchemaExecApprovalsNodeSetParams.file.agents.${entry.key}')
            }),
    );
  }

  final num version;
  final GatewaySchemaExecApprovalsNodeSetParamsFileSocket? socket;
  final GatewaySchemaExecApprovalsNodeSetParamsFileDefaults? defaults;
  final Map<String, JsonMap>? agents;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'version': version,
      'socket': socket?.toJson(),
      'defaults': defaults?.toJson(),
      'agents': agents,
    });
  }
}

class GatewaySchemaExecApprovalsNodeSetParams {
  const GatewaySchemaExecApprovalsNodeSetParams({
    required this.nodeId,
    required this.file,
    this.baseHash,
  });

  factory GatewaySchemaExecApprovalsNodeSetParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsNodeSetParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'ExecApprovalsNodeSetParams.nodeId', allowEmpty: false),
      file: GatewaySchemaExecApprovalsNodeSetParamsFile.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'file',
              context: 'ExecApprovalsNodeSetParams'),
          context: 'ExecApprovalsNodeSetParams.file')),
      baseHash:
          _generatedReadNullableString(json['baseHash'], allowEmpty: false),
    );
  }

  final String nodeId;
  final GatewaySchemaExecApprovalsNodeSetParamsFile file;
  final String? baseHash;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'file': file.toJson(),
      'baseHash': baseHash,
    });
  }
}

class GatewaySchemaExecApprovalsSetParamsFileSocket {
  const GatewaySchemaExecApprovalsSetParamsFileSocket({
    this.path,
    this.token,
  });

  factory GatewaySchemaExecApprovalsSetParamsFileSocket.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSetParamsFileSocket(
      path: _generatedReadNullableString(json['path'], allowEmpty: true),
      token: _generatedReadNullableString(json['token'], allowEmpty: true),
    );
  }

  final String? path;
  final String? token;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'token': token,
    });
  }
}

class GatewaySchemaExecApprovalsSetParamsFileDefaults {
  const GatewaySchemaExecApprovalsSetParamsFileDefaults({
    this.security,
    this.ask,
    this.askFallback,
    this.autoAllowSkills,
  });

  factory GatewaySchemaExecApprovalsSetParamsFileDefaults.fromJson(
      JsonMap json) {
    return GatewaySchemaExecApprovalsSetParamsFileDefaults(
      security:
          _generatedReadNullableString(json['security'], allowEmpty: true),
      ask: _generatedReadNullableString(json['ask'], allowEmpty: true),
      askFallback:
          _generatedReadNullableString(json['askFallback'], allowEmpty: true),
      autoAllowSkills: readNullableBool(json['autoAllowSkills']),
    );
  }

  final String? security;
  final String? ask;
  final String? askFallback;
  final bool? autoAllowSkills;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'security': security,
      'ask': ask,
      'askFallback': askFallback,
      'autoAllowSkills': autoAllowSkills,
    });
  }
}

class GatewaySchemaExecApprovalsSetParamsFile {
  const GatewaySchemaExecApprovalsSetParamsFile({
    required this.version,
    this.socket,
    this.defaults,
    this.agents,
  });

  factory GatewaySchemaExecApprovalsSetParamsFile.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSetParamsFile(
      version: _generatedReadRequiredNum(json, 'version',
          context: 'GatewaySchemaExecApprovalsSetParams.file.version'),
      socket: json['socket'] == null
          ? null
          : GatewaySchemaExecApprovalsSetParamsFileSocket.fromJson(asJsonMap(
              json['socket'],
              context: 'GatewaySchemaExecApprovalsSetParams.file.socket')),
      defaults: json['defaults'] == null
          ? null
          : GatewaySchemaExecApprovalsSetParamsFileDefaults.fromJson(asJsonMap(
              json['defaults'],
              context: 'GatewaySchemaExecApprovalsSetParams.file.defaults')),
      agents: json['agents'] == null
          ? null
          : Map<String, JsonMap>.unmodifiable({
              for (final entry in asJsonMap(json['agents'],
                      context:
                          'GatewaySchemaExecApprovalsSetParams.file.agents')
                  .entries)
                entry.key: asJsonMap(entry.value,
                    context:
                        'GatewaySchemaExecApprovalsSetParams.file.agents.${entry.key}')
            }),
    );
  }

  final num version;
  final GatewaySchemaExecApprovalsSetParamsFileSocket? socket;
  final GatewaySchemaExecApprovalsSetParamsFileDefaults? defaults;
  final Map<String, JsonMap>? agents;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'version': version,
      'socket': socket?.toJson(),
      'defaults': defaults?.toJson(),
      'agents': agents,
    });
  }
}

class GatewaySchemaExecApprovalsSetParams {
  const GatewaySchemaExecApprovalsSetParams({
    required this.file,
    this.baseHash,
  });

  factory GatewaySchemaExecApprovalsSetParams.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSetParams(
      file: GatewaySchemaExecApprovalsSetParamsFile.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'file',
              context: 'ExecApprovalsSetParams'),
          context: 'ExecApprovalsSetParams.file')),
      baseHash:
          _generatedReadNullableString(json['baseHash'], allowEmpty: false),
    );
  }

  final GatewaySchemaExecApprovalsSetParamsFile file;
  final String? baseHash;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'file': file.toJson(),
      'baseHash': baseHash,
    });
  }
}

class GatewaySchemaExecApprovalsSnapshotFileSocket {
  const GatewaySchemaExecApprovalsSnapshotFileSocket({
    this.path,
    this.token,
  });

  factory GatewaySchemaExecApprovalsSnapshotFileSocket.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSnapshotFileSocket(
      path: _generatedReadNullableString(json['path'], allowEmpty: true),
      token: _generatedReadNullableString(json['token'], allowEmpty: true),
    );
  }

  final String? path;
  final String? token;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'token': token,
    });
  }
}

class GatewaySchemaExecApprovalsSnapshotFileDefaults {
  const GatewaySchemaExecApprovalsSnapshotFileDefaults({
    this.security,
    this.ask,
    this.askFallback,
    this.autoAllowSkills,
  });

  factory GatewaySchemaExecApprovalsSnapshotFileDefaults.fromJson(
      JsonMap json) {
    return GatewaySchemaExecApprovalsSnapshotFileDefaults(
      security:
          _generatedReadNullableString(json['security'], allowEmpty: true),
      ask: _generatedReadNullableString(json['ask'], allowEmpty: true),
      askFallback:
          _generatedReadNullableString(json['askFallback'], allowEmpty: true),
      autoAllowSkills: readNullableBool(json['autoAllowSkills']),
    );
  }

  final String? security;
  final String? ask;
  final String? askFallback;
  final bool? autoAllowSkills;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'security': security,
      'ask': ask,
      'askFallback': askFallback,
      'autoAllowSkills': autoAllowSkills,
    });
  }
}

class GatewaySchemaExecApprovalsSnapshotFile {
  const GatewaySchemaExecApprovalsSnapshotFile({
    required this.version,
    this.socket,
    this.defaults,
    this.agents,
  });

  factory GatewaySchemaExecApprovalsSnapshotFile.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSnapshotFile(
      version: _generatedReadRequiredNum(json, 'version',
          context: 'GatewaySchemaExecApprovalsSnapshot.file.version'),
      socket: json['socket'] == null
          ? null
          : GatewaySchemaExecApprovalsSnapshotFileSocket.fromJson(asJsonMap(
              json['socket'],
              context: 'GatewaySchemaExecApprovalsSnapshot.file.socket')),
      defaults: json['defaults'] == null
          ? null
          : GatewaySchemaExecApprovalsSnapshotFileDefaults.fromJson(asJsonMap(
              json['defaults'],
              context: 'GatewaySchemaExecApprovalsSnapshot.file.defaults')),
      agents: json['agents'] == null
          ? null
          : Map<String, JsonMap>.unmodifiable({
              for (final entry in asJsonMap(json['agents'],
                      context: 'GatewaySchemaExecApprovalsSnapshot.file.agents')
                  .entries)
                entry.key: asJsonMap(entry.value,
                    context:
                        'GatewaySchemaExecApprovalsSnapshot.file.agents.${entry.key}')
            }),
    );
  }

  final num version;
  final GatewaySchemaExecApprovalsSnapshotFileSocket? socket;
  final GatewaySchemaExecApprovalsSnapshotFileDefaults? defaults;
  final Map<String, JsonMap>? agents;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'version': version,
      'socket': socket?.toJson(),
      'defaults': defaults?.toJson(),
      'agents': agents,
    });
  }
}

class GatewaySchemaExecApprovalsSnapshot {
  const GatewaySchemaExecApprovalsSnapshot({
    required this.path,
    required this.exists,
    required this.hash,
    required this.file,
  });

  factory GatewaySchemaExecApprovalsSnapshot.fromJson(JsonMap json) {
    return GatewaySchemaExecApprovalsSnapshot(
      path: _generatedReadRequiredString(json, 'path',
          context: 'ExecApprovalsSnapshot.path', allowEmpty: false),
      exists: readRequiredBool(json, 'exists',
          context: 'ExecApprovalsSnapshot.exists'),
      hash: _generatedReadRequiredString(json, 'hash',
          context: 'ExecApprovalsSnapshot.hash', allowEmpty: false),
      file: GatewaySchemaExecApprovalsSnapshotFile.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'file',
              context: 'ExecApprovalsSnapshot'),
          context: 'ExecApprovalsSnapshot.file')),
    );
  }

  final String path;
  final bool exists;
  final String hash;
  final GatewaySchemaExecApprovalsSnapshotFile file;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'exists': exists,
      'hash': hash,
      'file': file.toJson(),
    });
  }
}

class GatewaySchemaGatewayFrame {
  const GatewaySchemaGatewayFrame(this.value);

  factory GatewaySchemaGatewayFrame.fromJson(JsonMap json) {
    return GatewaySchemaGatewayFrame(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaHelloOkServer {
  const GatewaySchemaHelloOkServer({
    required this.version,
    required this.connId,
  });

  factory GatewaySchemaHelloOkServer.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkServer(
      version: _generatedReadRequiredString(json, 'version',
          context: 'GatewaySchemaHelloOk.server.version', allowEmpty: false),
      connId: _generatedReadRequiredString(json, 'connId',
          context: 'GatewaySchemaHelloOk.server.connId', allowEmpty: false),
    );
  }

  final String version;
  final String connId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'version': version,
      'connId': connId,
    });
  }
}

class GatewaySchemaHelloOkFeatures {
  const GatewaySchemaHelloOkFeatures({
    required this.methods,
    required this.events,
  });

  factory GatewaySchemaHelloOkFeatures.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkFeatures(
      methods: asJsonList(json['methods'],
              context: 'GatewaySchemaHelloOk.features.methods')
          .map((entry) => _generatedReadItemString(entry,
              context: 'GatewaySchemaHelloOk.features.methods[]'))
          .toList(growable: false),
      events: asJsonList(json['events'],
              context: 'GatewaySchemaHelloOk.features.events')
          .map((entry) => _generatedReadItemString(entry,
              context: 'GatewaySchemaHelloOk.features.events[]'))
          .toList(growable: false),
    );
  }

  final List<String> methods;
  final List<String> events;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'methods': methods.map((entry) => entry).toList(growable: false),
      'events': events.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaHelloOkSnapshotPresenceItem {
  const GatewaySchemaHelloOkSnapshotPresenceItem({
    this.host,
    this.ip,
    this.version,
    this.platform,
    this.deviceFamily,
    this.modelIdentifier,
    this.mode,
    this.lastInputSeconds,
    this.reason,
    this.tags,
    this.text,
    required this.ts,
    this.deviceId,
    this.roles,
    this.scopes,
    this.instanceId,
  });

  factory GatewaySchemaHelloOkSnapshotPresenceItem.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkSnapshotPresenceItem(
      host: _generatedReadNullableString(json['host'], allowEmpty: false),
      ip: _generatedReadNullableString(json['ip'], allowEmpty: false),
      version: _generatedReadNullableString(json['version'], allowEmpty: false),
      platform:
          _generatedReadNullableString(json['platform'], allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      modelIdentifier: _generatedReadNullableString(json['modelIdentifier'],
          allowEmpty: false),
      mode: _generatedReadNullableString(json['mode'], allowEmpty: false),
      lastInputSeconds: readNullableInt(json['lastInputSeconds']),
      reason: _generatedReadNullableString(json['reason'], allowEmpty: false),
      tags: json['tags'] == null
          ? null
          : asJsonList(json['tags'],
                  context: 'GatewaySchemaHelloOkSnapshot.presenceItem.tags')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaHelloOkSnapshot.presenceItem.tags[]'))
              .toList(growable: false),
      text: _generatedReadNullableString(json['text'], allowEmpty: true),
      ts: readRequiredInt(json, 'ts',
          context: 'GatewaySchemaHelloOkSnapshot.presenceItem.ts'),
      deviceId:
          _generatedReadNullableString(json['deviceId'], allowEmpty: false),
      roles: json['roles'] == null
          ? null
          : asJsonList(json['roles'],
                  context: 'GatewaySchemaHelloOkSnapshot.presenceItem.roles')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaHelloOkSnapshot.presenceItem.roles[]'))
              .toList(growable: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'],
                  context: 'GatewaySchemaHelloOkSnapshot.presenceItem.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context:
                      'GatewaySchemaHelloOkSnapshot.presenceItem.scopes[]'))
              .toList(growable: false),
      instanceId:
          _generatedReadNullableString(json['instanceId'], allowEmpty: false),
    );
  }

  final String? host;
  final String? ip;
  final String? version;
  final String? platform;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? mode;
  final int? lastInputSeconds;
  final String? reason;
  final List<String>? tags;
  final String? text;
  final int ts;
  final String? deviceId;
  final List<String>? roles;
  final List<String>? scopes;
  final String? instanceId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'host': host,
      'ip': ip,
      'version': version,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'mode': mode,
      'lastInputSeconds': lastInputSeconds,
      'reason': reason,
      'tags': tags?.map((entry) => entry).toList(growable: false),
      'text': text,
      'ts': ts,
      'deviceId': deviceId,
      'roles': roles?.map((entry) => entry).toList(growable: false),
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
      'instanceId': instanceId,
    });
  }
}

class GatewaySchemaHelloOkSnapshotStateVersion {
  const GatewaySchemaHelloOkSnapshotStateVersion({
    required this.presence,
    required this.health,
  });

  factory GatewaySchemaHelloOkSnapshotStateVersion.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkSnapshotStateVersion(
      presence: readRequiredInt(json, 'presence',
          context: 'GatewaySchemaHelloOkSnapshot.stateVersion.presence'),
      health: readRequiredInt(json, 'health',
          context: 'GatewaySchemaHelloOkSnapshot.stateVersion.health'),
    );
  }

  final int presence;
  final int health;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence': presence,
      'health': health,
    });
  }
}

class GatewaySchemaHelloOkSnapshotSessionDefaults {
  const GatewaySchemaHelloOkSnapshotSessionDefaults({
    required this.defaultAgentId,
    required this.mainKey,
    required this.mainSessionKey,
    this.scope,
  });

  factory GatewaySchemaHelloOkSnapshotSessionDefaults.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkSnapshotSessionDefaults(
      defaultAgentId: _generatedReadRequiredString(json, 'defaultAgentId',
          context:
              'GatewaySchemaHelloOkSnapshot.sessionDefaults.defaultAgentId',
          allowEmpty: false),
      mainKey: _generatedReadRequiredString(json, 'mainKey',
          context: 'GatewaySchemaHelloOkSnapshot.sessionDefaults.mainKey',
          allowEmpty: false),
      mainSessionKey: _generatedReadRequiredString(json, 'mainSessionKey',
          context:
              'GatewaySchemaHelloOkSnapshot.sessionDefaults.mainSessionKey',
          allowEmpty: false),
      scope: _generatedReadNullableString(json['scope'], allowEmpty: false),
    );
  }

  final String defaultAgentId;
  final String mainKey;
  final String mainSessionKey;
  final String? scope;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'defaultAgentId': defaultAgentId,
      'mainKey': mainKey,
      'mainSessionKey': mainSessionKey,
      'scope': scope,
    });
  }
}

class GatewaySchemaHelloOkSnapshotUpdateAvailable {
  const GatewaySchemaHelloOkSnapshotUpdateAvailable({
    required this.currentVersion,
    required this.latestVersion,
    required this.channel,
  });

  factory GatewaySchemaHelloOkSnapshotUpdateAvailable.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkSnapshotUpdateAvailable(
      currentVersion: _generatedReadRequiredString(json, 'currentVersion',
          context:
              'GatewaySchemaHelloOkSnapshot.updateAvailable.currentVersion',
          allowEmpty: false),
      latestVersion: _generatedReadRequiredString(json, 'latestVersion',
          context: 'GatewaySchemaHelloOkSnapshot.updateAvailable.latestVersion',
          allowEmpty: false),
      channel: _generatedReadRequiredString(json, 'channel',
          context: 'GatewaySchemaHelloOkSnapshot.updateAvailable.channel',
          allowEmpty: false),
    );
  }

  final String currentVersion;
  final String latestVersion;
  final String channel;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'currentVersion': currentVersion,
      'latestVersion': latestVersion,
      'channel': channel,
    });
  }
}

class GatewaySchemaHelloOkSnapshot {
  const GatewaySchemaHelloOkSnapshot({
    required this.presence,
    this.health,
    required this.stateVersion,
    required this.uptimeMs,
    this.configPath,
    this.stateDir,
    this.sessionDefaults,
    this.authMode,
    this.updateAvailable,
  });

  factory GatewaySchemaHelloOkSnapshot.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkSnapshot(
      presence: asJsonList(json['presence'],
              context: 'GatewaySchemaHelloOk.snapshot.presence')
          .map((entry) => GatewaySchemaHelloOkSnapshotPresenceItem.fromJson(
              asJsonMap(entry,
                  context: 'GatewaySchemaHelloOk.snapshot.presence[]')))
          .toList(growable: false),
      health: json['health'],
      stateVersion: GatewaySchemaHelloOkSnapshotStateVersion.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'stateVersion',
              context: 'GatewaySchemaHelloOk.snapshot'),
          context: 'GatewaySchemaHelloOk.snapshot.stateVersion')),
      uptimeMs: readRequiredInt(json, 'uptimeMs',
          context: 'GatewaySchemaHelloOk.snapshot.uptimeMs'),
      configPath:
          _generatedReadNullableString(json['configPath'], allowEmpty: false),
      stateDir:
          _generatedReadNullableString(json['stateDir'], allowEmpty: false),
      sessionDefaults: json['sessionDefaults'] == null
          ? null
          : GatewaySchemaHelloOkSnapshotSessionDefaults.fromJson(asJsonMap(
              json['sessionDefaults'],
              context: 'GatewaySchemaHelloOk.snapshot.sessionDefaults')),
      authMode:
          _generatedReadNullableString(json['authMode'], allowEmpty: true),
      updateAvailable: json['updateAvailable'] == null
          ? null
          : GatewaySchemaHelloOkSnapshotUpdateAvailable.fromJson(asJsonMap(
              json['updateAvailable'],
              context: 'GatewaySchemaHelloOk.snapshot.updateAvailable')),
    );
  }

  final List<GatewaySchemaHelloOkSnapshotPresenceItem> presence;
  final Object? health;
  final GatewaySchemaHelloOkSnapshotStateVersion stateVersion;
  final int uptimeMs;
  final String? configPath;
  final String? stateDir;
  final GatewaySchemaHelloOkSnapshotSessionDefaults? sessionDefaults;
  final String? authMode;
  final GatewaySchemaHelloOkSnapshotUpdateAvailable? updateAvailable;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence':
          presence.map((entry) => entry.toJson()).toList(growable: false),
      'health': health,
      'stateVersion': stateVersion.toJson(),
      'uptimeMs': uptimeMs,
      'configPath': configPath,
      'stateDir': stateDir,
      'sessionDefaults': sessionDefaults?.toJson(),
      'authMode': authMode,
      'updateAvailable': updateAvailable?.toJson(),
    });
  }
}

class GatewaySchemaHelloOkAuth {
  const GatewaySchemaHelloOkAuth({
    required this.deviceToken,
    required this.role,
    required this.scopes,
    this.issuedAtMs,
  });

  factory GatewaySchemaHelloOkAuth.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkAuth(
      deviceToken: _generatedReadRequiredString(json, 'deviceToken',
          context: 'GatewaySchemaHelloOk.auth.deviceToken', allowEmpty: false),
      role: _generatedReadRequiredString(json, 'role',
          context: 'GatewaySchemaHelloOk.auth.role', allowEmpty: false),
      scopes: asJsonList(json['scopes'],
              context: 'GatewaySchemaHelloOk.auth.scopes')
          .map((entry) => _generatedReadItemString(entry,
              context: 'GatewaySchemaHelloOk.auth.scopes[]'))
          .toList(growable: false),
      issuedAtMs: readNullableInt(json['issuedAtMs']),
    );
  }

  final String deviceToken;
  final String role;
  final List<String> scopes;
  final int? issuedAtMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'deviceToken': deviceToken,
      'role': role,
      'scopes': scopes.map((entry) => entry).toList(growable: false),
      'issuedAtMs': issuedAtMs,
    });
  }
}

class GatewaySchemaHelloOkPolicy {
  const GatewaySchemaHelloOkPolicy({
    required this.maxPayload,
    required this.maxBufferedBytes,
    required this.tickIntervalMs,
  });

  factory GatewaySchemaHelloOkPolicy.fromJson(JsonMap json) {
    return GatewaySchemaHelloOkPolicy(
      maxPayload: readRequiredInt(json, 'maxPayload',
          context: 'GatewaySchemaHelloOk.policy.maxPayload'),
      maxBufferedBytes: readRequiredInt(json, 'maxBufferedBytes',
          context: 'GatewaySchemaHelloOk.policy.maxBufferedBytes'),
      tickIntervalMs: readRequiredInt(json, 'tickIntervalMs',
          context: 'GatewaySchemaHelloOk.policy.tickIntervalMs'),
    );
  }

  final int maxPayload;
  final int maxBufferedBytes;
  final int tickIntervalMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'maxPayload': maxPayload,
      'maxBufferedBytes': maxBufferedBytes,
      'tickIntervalMs': tickIntervalMs,
    });
  }
}

class GatewaySchemaHelloOk {
  const GatewaySchemaHelloOk({
    required this.type,
    required this.protocol,
    required this.server,
    required this.features,
    required this.snapshot,
    this.canvasHostUrl,
    this.auth,
    required this.policy,
  });

  factory GatewaySchemaHelloOk.fromJson(JsonMap json) {
    return GatewaySchemaHelloOk(
      type: _generatedReadRequiredString(json, 'type',
          context: 'HelloOk.type', allowEmpty: true),
      protocol: readRequiredInt(json, 'protocol', context: 'HelloOk.protocol'),
      server: GatewaySchemaHelloOkServer.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'server', context: 'HelloOk'),
          context: 'HelloOk.server')),
      features: GatewaySchemaHelloOkFeatures.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'features', context: 'HelloOk'),
          context: 'HelloOk.features')),
      snapshot: GatewaySchemaHelloOkSnapshot.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'snapshot', context: 'HelloOk'),
          context: 'HelloOk.snapshot')),
      canvasHostUrl: _generatedReadNullableString(json['canvasHostUrl'],
          allowEmpty: false),
      auth: json['auth'] == null
          ? null
          : GatewaySchemaHelloOkAuth.fromJson(
              asJsonMap(json['auth'], context: 'HelloOk.auth')),
      policy: GatewaySchemaHelloOkPolicy.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'policy', context: 'HelloOk'),
          context: 'HelloOk.policy')),
    );
  }

  final String type;
  final int protocol;
  final GatewaySchemaHelloOkServer server;
  final GatewaySchemaHelloOkFeatures features;
  final GatewaySchemaHelloOkSnapshot snapshot;
  final String? canvasHostUrl;
  final GatewaySchemaHelloOkAuth? auth;
  final GatewaySchemaHelloOkPolicy policy;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'type': type,
      'protocol': protocol,
      'server': server.toJson(),
      'features': features.toJson(),
      'snapshot': snapshot.toJson(),
      'canvasHostUrl': canvasHostUrl,
      'auth': auth?.toJson(),
      'policy': policy.toJson(),
    });
  }
}

class GatewaySchemaLogsTailParams {
  const GatewaySchemaLogsTailParams({
    this.cursor,
    this.limit,
    this.maxBytes,
  });

  factory GatewaySchemaLogsTailParams.fromJson(JsonMap json) {
    return GatewaySchemaLogsTailParams(
      cursor: readNullableInt(json['cursor']),
      limit: readNullableInt(json['limit']),
      maxBytes: readNullableInt(json['maxBytes']),
    );
  }

  final int? cursor;
  final int? limit;
  final int? maxBytes;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'cursor': cursor,
      'limit': limit,
      'maxBytes': maxBytes,
    });
  }
}

class GatewaySchemaLogsTailResult {
  const GatewaySchemaLogsTailResult({
    required this.file,
    required this.cursor,
    required this.size,
    required this.lines,
    this.truncated,
    this.reset,
  });

  factory GatewaySchemaLogsTailResult.fromJson(JsonMap json) {
    return GatewaySchemaLogsTailResult(
      file: _generatedReadRequiredString(json, 'file',
          context: 'LogsTailResult.file', allowEmpty: false),
      cursor: readRequiredInt(json, 'cursor', context: 'LogsTailResult.cursor'),
      size: readRequiredInt(json, 'size', context: 'LogsTailResult.size'),
      lines: asJsonList(json['lines'], context: 'LogsTailResult.lines')
          .map((entry) => _generatedReadItemString(entry,
              context: 'LogsTailResult.lines[]'))
          .toList(growable: false),
      truncated: readNullableBool(json['truncated']),
      reset: readNullableBool(json['reset']),
    );
  }

  final String file;
  final int cursor;
  final int size;
  final List<String> lines;
  final bool? truncated;
  final bool? reset;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'file': file,
      'cursor': cursor,
      'size': size,
      'lines': lines.map((entry) => entry).toList(growable: false),
      'truncated': truncated,
      'reset': reset,
    });
  }
}

class GatewaySchemaModelChoice {
  const GatewaySchemaModelChoice({
    required this.id,
    required this.name,
    required this.provider,
    this.contextWindow,
    this.reasoning,
  });

  factory GatewaySchemaModelChoice.fromJson(JsonMap json) {
    return GatewaySchemaModelChoice(
      id: _generatedReadRequiredString(json, 'id',
          context: 'ModelChoice.id', allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'ModelChoice.name', allowEmpty: false),
      provider: _generatedReadRequiredString(json, 'provider',
          context: 'ModelChoice.provider', allowEmpty: false),
      contextWindow: readNullableInt(json['contextWindow']),
      reasoning: readNullableBool(json['reasoning']),
    );
  }

  final String id;
  final String name;
  final String provider;
  final int? contextWindow;
  final bool? reasoning;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'name': name,
      'provider': provider,
      'contextWindow': contextWindow,
      'reasoning': reasoning,
    });
  }
}

class GatewaySchemaModelsListParams {
  const GatewaySchemaModelsListParams(this.value);

  factory GatewaySchemaModelsListParams.fromJson(JsonMap json) {
    return GatewaySchemaModelsListParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaModelsListResultModelsItem {
  const GatewaySchemaModelsListResultModelsItem({
    required this.id,
    required this.name,
    required this.provider,
    this.contextWindow,
    this.reasoning,
  });

  factory GatewaySchemaModelsListResultModelsItem.fromJson(JsonMap json) {
    return GatewaySchemaModelsListResultModelsItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaModelsListResult.modelsItem.id',
          allowEmpty: false),
      name: _generatedReadRequiredString(json, 'name',
          context: 'GatewaySchemaModelsListResult.modelsItem.name',
          allowEmpty: false),
      provider: _generatedReadRequiredString(json, 'provider',
          context: 'GatewaySchemaModelsListResult.modelsItem.provider',
          allowEmpty: false),
      contextWindow: readNullableInt(json['contextWindow']),
      reasoning: readNullableBool(json['reasoning']),
    );
  }

  final String id;
  final String name;
  final String provider;
  final int? contextWindow;
  final bool? reasoning;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'name': name,
      'provider': provider,
      'contextWindow': contextWindow,
      'reasoning': reasoning,
    });
  }
}

class GatewaySchemaModelsListResult {
  const GatewaySchemaModelsListResult({
    required this.models,
  });

  factory GatewaySchemaModelsListResult.fromJson(JsonMap json) {
    return GatewaySchemaModelsListResult(
      models: asJsonList(json['models'], context: 'ModelsListResult.models')
          .map((entry) => GatewaySchemaModelsListResultModelsItem.fromJson(
              asJsonMap(entry, context: 'ModelsListResult.models[]')))
          .toList(growable: false),
    );
  }

  final List<GatewaySchemaModelsListResultModelsItem> models;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'models': models.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaNodeDescribeParams {
  const GatewaySchemaNodeDescribeParams({
    required this.nodeId,
  });

  factory GatewaySchemaNodeDescribeParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeDescribeParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodeDescribeParams.nodeId', allowEmpty: false),
    );
  }

  final String nodeId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
    });
  }
}

class GatewaySchemaNodeEventParams {
  const GatewaySchemaNodeEventParams({
    required this.event,
    this.payload,
    this.payloadJSON,
  });

  factory GatewaySchemaNodeEventParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeEventParams(
      event: _generatedReadRequiredString(json, 'event',
          context: 'NodeEventParams.event', allowEmpty: false),
      payload: json['payload'],
      payloadJSON:
          _generatedReadNullableString(json['payloadJSON'], allowEmpty: true),
    );
  }

  final String event;
  final Object? payload;
  final String? payloadJSON;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'event': event,
      'payload': payload,
      'payloadJSON': payloadJSON,
    });
  }
}

class GatewaySchemaNodeInvokeParams {
  const GatewaySchemaNodeInvokeParams({
    required this.nodeId,
    required this.command,
    this.params,
    this.timeoutMs,
    required this.idempotencyKey,
  });

  factory GatewaySchemaNodeInvokeParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeInvokeParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodeInvokeParams.nodeId', allowEmpty: false),
      command: _generatedReadRequiredString(json, 'command',
          context: 'NodeInvokeParams.command', allowEmpty: false),
      params: json['params'],
      timeoutMs: readNullableInt(json['timeoutMs']),
      idempotencyKey: _generatedReadRequiredString(json, 'idempotencyKey',
          context: 'NodeInvokeParams.idempotencyKey', allowEmpty: false),
    );
  }

  final String nodeId;
  final String command;
  final Object? params;
  final int? timeoutMs;
  final String idempotencyKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'command': command,
      'params': params,
      'timeoutMs': timeoutMs,
      'idempotencyKey': idempotencyKey,
    });
  }
}

class GatewaySchemaNodeInvokeRequestEvent {
  const GatewaySchemaNodeInvokeRequestEvent({
    required this.id,
    required this.nodeId,
    required this.command,
    this.paramsJSON,
    this.timeoutMs,
    this.idempotencyKey,
  });

  factory GatewaySchemaNodeInvokeRequestEvent.fromJson(JsonMap json) {
    return GatewaySchemaNodeInvokeRequestEvent(
      id: _generatedReadRequiredString(json, 'id',
          context: 'NodeInvokeRequestEvent.id', allowEmpty: false),
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodeInvokeRequestEvent.nodeId', allowEmpty: false),
      command: _generatedReadRequiredString(json, 'command',
          context: 'NodeInvokeRequestEvent.command', allowEmpty: false),
      paramsJSON:
          _generatedReadNullableString(json['paramsJSON'], allowEmpty: true),
      timeoutMs: readNullableInt(json['timeoutMs']),
      idempotencyKey: _generatedReadNullableString(json['idempotencyKey'],
          allowEmpty: false),
    );
  }

  final String id;
  final String nodeId;
  final String command;
  final String? paramsJSON;
  final int? timeoutMs;
  final String? idempotencyKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'nodeId': nodeId,
      'command': command,
      'paramsJSON': paramsJSON,
      'timeoutMs': timeoutMs,
      'idempotencyKey': idempotencyKey,
    });
  }
}

class GatewaySchemaNodeInvokeResultParamsError {
  const GatewaySchemaNodeInvokeResultParamsError({
    this.code,
    this.message,
  });

  factory GatewaySchemaNodeInvokeResultParamsError.fromJson(JsonMap json) {
    return GatewaySchemaNodeInvokeResultParamsError(
      code: _generatedReadNullableString(json['code'], allowEmpty: false),
      message: _generatedReadNullableString(json['message'], allowEmpty: false),
    );
  }

  final String? code;
  final String? message;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'code': code,
      'message': message,
    });
  }
}

class GatewaySchemaNodeInvokeResultParams {
  const GatewaySchemaNodeInvokeResultParams({
    required this.id,
    required this.nodeId,
    required this.ok,
    this.payload,
    this.payloadJSON,
    this.error,
  });

  factory GatewaySchemaNodeInvokeResultParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeInvokeResultParams(
      id: _generatedReadRequiredString(json, 'id',
          context: 'NodeInvokeResultParams.id', allowEmpty: false),
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodeInvokeResultParams.nodeId', allowEmpty: false),
      ok: readRequiredBool(json, 'ok', context: 'NodeInvokeResultParams.ok'),
      payload: json['payload'],
      payloadJSON:
          _generatedReadNullableString(json['payloadJSON'], allowEmpty: true),
      error: json['error'] == null
          ? null
          : GatewaySchemaNodeInvokeResultParamsError.fromJson(asJsonMap(
              json['error'],
              context: 'NodeInvokeResultParams.error')),
    );
  }

  final String id;
  final String nodeId;
  final bool ok;
  final Object? payload;
  final String? payloadJSON;
  final GatewaySchemaNodeInvokeResultParamsError? error;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'nodeId': nodeId,
      'ok': ok,
      'payload': payload,
      'payloadJSON': payloadJSON,
      'error': error?.toJson(),
    });
  }
}

class GatewaySchemaNodeListParams {
  const GatewaySchemaNodeListParams(this.value);

  factory GatewaySchemaNodeListParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeListParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaNodePairApproveParams {
  const GatewaySchemaNodePairApproveParams({
    required this.requestId,
  });

  factory GatewaySchemaNodePairApproveParams.fromJson(JsonMap json) {
    return GatewaySchemaNodePairApproveParams(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'NodePairApproveParams.requestId', allowEmpty: false),
    );
  }

  final String requestId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
    });
  }
}

class GatewaySchemaNodePairListParams {
  const GatewaySchemaNodePairListParams(this.value);

  factory GatewaySchemaNodePairListParams.fromJson(JsonMap json) {
    return GatewaySchemaNodePairListParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaNodePairRejectParams {
  const GatewaySchemaNodePairRejectParams({
    required this.requestId,
  });

  factory GatewaySchemaNodePairRejectParams.fromJson(JsonMap json) {
    return GatewaySchemaNodePairRejectParams(
      requestId: _generatedReadRequiredString(json, 'requestId',
          context: 'NodePairRejectParams.requestId', allowEmpty: false),
    );
  }

  final String requestId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'requestId': requestId,
    });
  }
}

class GatewaySchemaNodePairRequestParams {
  const GatewaySchemaNodePairRequestParams({
    required this.nodeId,
    this.displayName,
    this.platform,
    this.version,
    this.coreVersion,
    this.uiVersion,
    this.deviceFamily,
    this.modelIdentifier,
    this.caps,
    this.commands,
    this.remoteIp,
    this.silent,
  });

  factory GatewaySchemaNodePairRequestParams.fromJson(JsonMap json) {
    return GatewaySchemaNodePairRequestParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodePairRequestParams.nodeId', allowEmpty: false),
      displayName:
          _generatedReadNullableString(json['displayName'], allowEmpty: false),
      platform:
          _generatedReadNullableString(json['platform'], allowEmpty: false),
      version: _generatedReadNullableString(json['version'], allowEmpty: false),
      coreVersion:
          _generatedReadNullableString(json['coreVersion'], allowEmpty: false),
      uiVersion:
          _generatedReadNullableString(json['uiVersion'], allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      modelIdentifier: _generatedReadNullableString(json['modelIdentifier'],
          allowEmpty: false),
      caps: json['caps'] == null
          ? null
          : asJsonList(json['caps'], context: 'NodePairRequestParams.caps')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'NodePairRequestParams.caps[]'))
              .toList(growable: false),
      commands: json['commands'] == null
          ? null
          : asJsonList(json['commands'],
                  context: 'NodePairRequestParams.commands')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'NodePairRequestParams.commands[]'))
              .toList(growable: false),
      remoteIp:
          _generatedReadNullableString(json['remoteIp'], allowEmpty: false),
      silent: readNullableBool(json['silent']),
    );
  }

  final String nodeId;
  final String? displayName;
  final String? platform;
  final String? version;
  final String? coreVersion;
  final String? uiVersion;
  final String? deviceFamily;
  final String? modelIdentifier;
  final List<String>? caps;
  final List<String>? commands;
  final String? remoteIp;
  final bool? silent;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'displayName': displayName,
      'platform': platform,
      'version': version,
      'coreVersion': coreVersion,
      'uiVersion': uiVersion,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'caps': caps?.map((entry) => entry).toList(growable: false),
      'commands': commands?.map((entry) => entry).toList(growable: false),
      'remoteIp': remoteIp,
      'silent': silent,
    });
  }
}

class GatewaySchemaNodePairVerifyParams {
  const GatewaySchemaNodePairVerifyParams({
    required this.nodeId,
    required this.token,
  });

  factory GatewaySchemaNodePairVerifyParams.fromJson(JsonMap json) {
    return GatewaySchemaNodePairVerifyParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodePairVerifyParams.nodeId', allowEmpty: false),
      token: _generatedReadRequiredString(json, 'token',
          context: 'NodePairVerifyParams.token', allowEmpty: false),
    );
  }

  final String nodeId;
  final String token;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'token': token,
    });
  }
}

class GatewaySchemaNodeRenameParams {
  const GatewaySchemaNodeRenameParams({
    required this.nodeId,
    required this.displayName,
  });

  factory GatewaySchemaNodeRenameParams.fromJson(JsonMap json) {
    return GatewaySchemaNodeRenameParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'NodeRenameParams.nodeId', allowEmpty: false),
      displayName: _generatedReadRequiredString(json, 'displayName',
          context: 'NodeRenameParams.displayName', allowEmpty: false),
    );
  }

  final String nodeId;
  final String displayName;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'displayName': displayName,
    });
  }
}

class GatewaySchemaPollParams {
  const GatewaySchemaPollParams({
    required this.to,
    required this.question,
    required this.options,
    this.maxSelections,
    this.durationSeconds,
    this.durationHours,
    this.silent,
    this.isAnonymous,
    this.threadId,
    this.channel,
    this.accountId,
    required this.idempotencyKey,
  });

  factory GatewaySchemaPollParams.fromJson(JsonMap json) {
    return GatewaySchemaPollParams(
      to: _generatedReadRequiredString(json, 'to',
          context: 'PollParams.to', allowEmpty: false),
      question: _generatedReadRequiredString(json, 'question',
          context: 'PollParams.question', allowEmpty: false),
      options: asJsonList(json['options'], context: 'PollParams.options')
          .map((entry) =>
              _generatedReadItemString(entry, context: 'PollParams.options[]'))
          .toList(growable: false),
      maxSelections: readNullableInt(json['maxSelections']),
      durationSeconds: readNullableInt(json['durationSeconds']),
      durationHours: readNullableInt(json['durationHours']),
      silent: readNullableBool(json['silent']),
      isAnonymous: readNullableBool(json['isAnonymous']),
      threadId:
          _generatedReadNullableString(json['threadId'], allowEmpty: true),
      channel: _generatedReadNullableString(json['channel'], allowEmpty: true),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
      idempotencyKey: _generatedReadRequiredString(json, 'idempotencyKey',
          context: 'PollParams.idempotencyKey', allowEmpty: false),
    );
  }

  final String to;
  final String question;
  final List<String> options;
  final int? maxSelections;
  final int? durationSeconds;
  final int? durationHours;
  final bool? silent;
  final bool? isAnonymous;
  final String? threadId;
  final String? channel;
  final String? accountId;
  final String idempotencyKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'to': to,
      'question': question,
      'options': options.map((entry) => entry).toList(growable: false),
      'maxSelections': maxSelections,
      'durationSeconds': durationSeconds,
      'durationHours': durationHours,
      'silent': silent,
      'isAnonymous': isAnonymous,
      'threadId': threadId,
      'channel': channel,
      'accountId': accountId,
      'idempotencyKey': idempotencyKey,
    });
  }
}

class GatewaySchemaPresenceEntry {
  const GatewaySchemaPresenceEntry({
    this.host,
    this.ip,
    this.version,
    this.platform,
    this.deviceFamily,
    this.modelIdentifier,
    this.mode,
    this.lastInputSeconds,
    this.reason,
    this.tags,
    this.text,
    required this.ts,
    this.deviceId,
    this.roles,
    this.scopes,
    this.instanceId,
  });

  factory GatewaySchemaPresenceEntry.fromJson(JsonMap json) {
    return GatewaySchemaPresenceEntry(
      host: _generatedReadNullableString(json['host'], allowEmpty: false),
      ip: _generatedReadNullableString(json['ip'], allowEmpty: false),
      version: _generatedReadNullableString(json['version'], allowEmpty: false),
      platform:
          _generatedReadNullableString(json['platform'], allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      modelIdentifier: _generatedReadNullableString(json['modelIdentifier'],
          allowEmpty: false),
      mode: _generatedReadNullableString(json['mode'], allowEmpty: false),
      lastInputSeconds: readNullableInt(json['lastInputSeconds']),
      reason: _generatedReadNullableString(json['reason'], allowEmpty: false),
      tags: json['tags'] == null
          ? null
          : asJsonList(json['tags'], context: 'PresenceEntry.tags')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'PresenceEntry.tags[]'))
              .toList(growable: false),
      text: _generatedReadNullableString(json['text'], allowEmpty: true),
      ts: readRequiredInt(json, 'ts', context: 'PresenceEntry.ts'),
      deviceId:
          _generatedReadNullableString(json['deviceId'], allowEmpty: false),
      roles: json['roles'] == null
          ? null
          : asJsonList(json['roles'], context: 'PresenceEntry.roles')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'PresenceEntry.roles[]'))
              .toList(growable: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'], context: 'PresenceEntry.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'PresenceEntry.scopes[]'))
              .toList(growable: false),
      instanceId:
          _generatedReadNullableString(json['instanceId'], allowEmpty: false),
    );
  }

  final String? host;
  final String? ip;
  final String? version;
  final String? platform;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? mode;
  final int? lastInputSeconds;
  final String? reason;
  final List<String>? tags;
  final String? text;
  final int ts;
  final String? deviceId;
  final List<String>? roles;
  final List<String>? scopes;
  final String? instanceId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'host': host,
      'ip': ip,
      'version': version,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'mode': mode,
      'lastInputSeconds': lastInputSeconds,
      'reason': reason,
      'tags': tags?.map((entry) => entry).toList(growable: false),
      'text': text,
      'ts': ts,
      'deviceId': deviceId,
      'roles': roles?.map((entry) => entry).toList(growable: false),
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
      'instanceId': instanceId,
    });
  }
}

class GatewaySchemaPushTestParams {
  const GatewaySchemaPushTestParams({
    required this.nodeId,
    this.title,
    this.body,
    this.environment,
  });

  factory GatewaySchemaPushTestParams.fromJson(JsonMap json) {
    return GatewaySchemaPushTestParams(
      nodeId: _generatedReadRequiredString(json, 'nodeId',
          context: 'PushTestParams.nodeId', allowEmpty: false),
      title: _generatedReadNullableString(json['title'], allowEmpty: true),
      body: _generatedReadNullableString(json['body'], allowEmpty: true),
      environment:
          _generatedReadNullableString(json['environment'], allowEmpty: true),
    );
  }

  final String nodeId;
  final String? title;
  final String? body;
  final String? environment;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'nodeId': nodeId,
      'title': title,
      'body': body,
      'environment': environment,
    });
  }
}

class GatewaySchemaPushTestResult {
  const GatewaySchemaPushTestResult({
    required this.ok,
    required this.status,
    this.apnsId,
    this.reason,
    required this.tokenSuffix,
    required this.topic,
    required this.environment,
  });

  factory GatewaySchemaPushTestResult.fromJson(JsonMap json) {
    return GatewaySchemaPushTestResult(
      ok: readRequiredBool(json, 'ok', context: 'PushTestResult.ok'),
      status: readRequiredInt(json, 'status', context: 'PushTestResult.status'),
      apnsId: _generatedReadNullableString(json['apnsId'], allowEmpty: true),
      reason: _generatedReadNullableString(json['reason'], allowEmpty: true),
      tokenSuffix: _generatedReadRequiredString(json, 'tokenSuffix',
          context: 'PushTestResult.tokenSuffix', allowEmpty: true),
      topic: _generatedReadRequiredString(json, 'topic',
          context: 'PushTestResult.topic', allowEmpty: true),
      environment: _generatedReadRequiredString(json, 'environment',
          context: 'PushTestResult.environment', allowEmpty: true),
    );
  }

  final bool ok;
  final int status;
  final String? apnsId;
  final String? reason;
  final String tokenSuffix;
  final String topic;
  final String environment;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'status': status,
      'apnsId': apnsId,
      'reason': reason,
      'tokenSuffix': tokenSuffix,
      'topic': topic,
      'environment': environment,
    });
  }
}

class GatewaySchemaRequestFrame {
  const GatewaySchemaRequestFrame({
    required this.type,
    required this.id,
    required this.method,
    this.params,
  });

  factory GatewaySchemaRequestFrame.fromJson(JsonMap json) {
    return GatewaySchemaRequestFrame(
      type: _generatedReadRequiredString(json, 'type',
          context: 'RequestFrame.type', allowEmpty: true),
      id: _generatedReadRequiredString(json, 'id',
          context: 'RequestFrame.id', allowEmpty: false),
      method: _generatedReadRequiredString(json, 'method',
          context: 'RequestFrame.method', allowEmpty: false),
      params: json['params'],
    );
  }

  final String type;
  final String id;
  final String method;
  final Object? params;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'type': type,
      'id': id,
      'method': method,
      'params': params,
    });
  }
}

class GatewaySchemaResponseFrameError {
  const GatewaySchemaResponseFrameError({
    required this.code,
    required this.message,
    this.details,
    this.retryable,
    this.retryAfterMs,
  });

  factory GatewaySchemaResponseFrameError.fromJson(JsonMap json) {
    return GatewaySchemaResponseFrameError(
      code: _generatedReadRequiredString(json, 'code',
          context: 'GatewaySchemaResponseFrame.error.code', allowEmpty: false),
      message: _generatedReadRequiredString(json, 'message',
          context: 'GatewaySchemaResponseFrame.error.message',
          allowEmpty: false),
      details: json['details'],
      retryable: readNullableBool(json['retryable']),
      retryAfterMs: readNullableInt(json['retryAfterMs']),
    );
  }

  final String code;
  final String message;
  final Object? details;
  final bool? retryable;
  final int? retryAfterMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'code': code,
      'message': message,
      'details': details,
      'retryable': retryable,
      'retryAfterMs': retryAfterMs,
    });
  }
}

class GatewaySchemaResponseFrame {
  const GatewaySchemaResponseFrame({
    required this.type,
    required this.id,
    required this.ok,
    this.payload,
    this.error,
  });

  factory GatewaySchemaResponseFrame.fromJson(JsonMap json) {
    return GatewaySchemaResponseFrame(
      type: _generatedReadRequiredString(json, 'type',
          context: 'ResponseFrame.type', allowEmpty: true),
      id: _generatedReadRequiredString(json, 'id',
          context: 'ResponseFrame.id', allowEmpty: false),
      ok: readRequiredBool(json, 'ok', context: 'ResponseFrame.ok'),
      payload: json['payload'],
      error: json['error'] == null
          ? null
          : GatewaySchemaResponseFrameError.fromJson(
              asJsonMap(json['error'], context: 'ResponseFrame.error')),
    );
  }

  final String type;
  final String id;
  final bool ok;
  final Object? payload;
  final GatewaySchemaResponseFrameError? error;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'type': type,
      'id': id,
      'ok': ok,
      'payload': payload,
      'error': error?.toJson(),
    });
  }
}

class GatewaySchemaSecretsReloadParams {
  const GatewaySchemaSecretsReloadParams(this.value);

  factory GatewaySchemaSecretsReloadParams.fromJson(JsonMap json) {
    return GatewaySchemaSecretsReloadParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaSecretsResolveAssignment {
  const GatewaySchemaSecretsResolveAssignment({
    this.path,
    required this.pathSegments,
    this.value,
  });

  factory GatewaySchemaSecretsResolveAssignment.fromJson(JsonMap json) {
    return GatewaySchemaSecretsResolveAssignment(
      path: _generatedReadNullableString(json['path'], allowEmpty: false),
      pathSegments: asJsonList(json['pathSegments'],
              context: 'SecretsResolveAssignment.pathSegments')
          .map((entry) => _generatedReadItemString(entry,
              context: 'SecretsResolveAssignment.pathSegments[]'))
          .toList(growable: false),
      value: json['value'],
    );
  }

  final String? path;
  final List<String> pathSegments;
  final Object? value;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'pathSegments':
          pathSegments.map((entry) => entry).toList(growable: false),
      'value': value,
    });
  }
}

class GatewaySchemaSecretsResolveParams {
  const GatewaySchemaSecretsResolveParams({
    required this.commandName,
    required this.targetIds,
  });

  factory GatewaySchemaSecretsResolveParams.fromJson(JsonMap json) {
    return GatewaySchemaSecretsResolveParams(
      commandName: _generatedReadRequiredString(json, 'commandName',
          context: 'SecretsResolveParams.commandName', allowEmpty: false),
      targetIds: asJsonList(json['targetIds'],
              context: 'SecretsResolveParams.targetIds')
          .map((entry) => _generatedReadItemString(entry,
              context: 'SecretsResolveParams.targetIds[]'))
          .toList(growable: false),
    );
  }

  final String commandName;
  final List<String> targetIds;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'commandName': commandName,
      'targetIds': targetIds.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaSecretsResolveResultAssignmentsItem {
  const GatewaySchemaSecretsResolveResultAssignmentsItem({
    this.path,
    required this.pathSegments,
    this.value,
  });

  factory GatewaySchemaSecretsResolveResultAssignmentsItem.fromJson(
      JsonMap json) {
    return GatewaySchemaSecretsResolveResultAssignmentsItem(
      path: _generatedReadNullableString(json['path'], allowEmpty: false),
      pathSegments: asJsonList(json['pathSegments'],
              context:
                  'GatewaySchemaSecretsResolveResult.assignmentsItem.pathSegments')
          .map((entry) => _generatedReadItemString(entry,
              context:
                  'GatewaySchemaSecretsResolveResult.assignmentsItem.pathSegments[]'))
          .toList(growable: false),
      value: json['value'],
    );
  }

  final String? path;
  final List<String> pathSegments;
  final Object? value;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'path': path,
      'pathSegments':
          pathSegments.map((entry) => entry).toList(growable: false),
      'value': value,
    });
  }
}

class GatewaySchemaSecretsResolveResult {
  const GatewaySchemaSecretsResolveResult({
    this.ok,
    this.assignments,
    this.diagnostics,
    this.inactiveRefPaths,
  });

  factory GatewaySchemaSecretsResolveResult.fromJson(JsonMap json) {
    return GatewaySchemaSecretsResolveResult(
      ok: readNullableBool(json['ok']),
      assignments: json['assignments'] == null
          ? null
          : asJsonList(json['assignments'],
                  context: 'SecretsResolveResult.assignments')
              .map((entry) =>
                  GatewaySchemaSecretsResolveResultAssignmentsItem.fromJson(
                      asJsonMap(entry,
                          context: 'SecretsResolveResult.assignments[]')))
              .toList(growable: false),
      diagnostics: json['diagnostics'] == null
          ? null
          : asJsonList(json['diagnostics'],
                  context: 'SecretsResolveResult.diagnostics')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'SecretsResolveResult.diagnostics[]'))
              .toList(growable: false),
      inactiveRefPaths: json['inactiveRefPaths'] == null
          ? null
          : asJsonList(json['inactiveRefPaths'],
                  context: 'SecretsResolveResult.inactiveRefPaths')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'SecretsResolveResult.inactiveRefPaths[]'))
              .toList(growable: false),
    );
  }

  final bool? ok;
  final List<GatewaySchemaSecretsResolveResultAssignmentsItem>? assignments;
  final List<String>? diagnostics;
  final List<String>? inactiveRefPaths;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ok': ok,
      'assignments':
          assignments?.map((entry) => entry.toJson()).toList(growable: false),
      'diagnostics': diagnostics?.map((entry) => entry).toList(growable: false),
      'inactiveRefPaths':
          inactiveRefPaths?.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaSendParams {
  const GatewaySchemaSendParams({
    required this.to,
    this.message,
    this.mediaUrl,
    this.mediaUrls,
    this.gifPlayback,
    this.channel,
    this.accountId,
    this.agentId,
    this.threadId,
    this.sessionKey,
    required this.idempotencyKey,
  });

  factory GatewaySchemaSendParams.fromJson(JsonMap json) {
    return GatewaySchemaSendParams(
      to: _generatedReadRequiredString(json, 'to',
          context: 'SendParams.to', allowEmpty: false),
      message: _generatedReadNullableString(json['message'], allowEmpty: true),
      mediaUrl:
          _generatedReadNullableString(json['mediaUrl'], allowEmpty: true),
      mediaUrls: json['mediaUrls'] == null
          ? null
          : asJsonList(json['mediaUrls'], context: 'SendParams.mediaUrls')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'SendParams.mediaUrls[]'))
              .toList(growable: false),
      gifPlayback: readNullableBool(json['gifPlayback']),
      channel: _generatedReadNullableString(json['channel'], allowEmpty: true),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: true),
      threadId:
          _generatedReadNullableString(json['threadId'], allowEmpty: true),
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      idempotencyKey: _generatedReadRequiredString(json, 'idempotencyKey',
          context: 'SendParams.idempotencyKey', allowEmpty: false),
    );
  }

  final String to;
  final String? message;
  final String? mediaUrl;
  final List<String>? mediaUrls;
  final bool? gifPlayback;
  final String? channel;
  final String? accountId;
  final String? agentId;
  final String? threadId;
  final String? sessionKey;
  final String idempotencyKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'to': to,
      'message': message,
      'mediaUrl': mediaUrl,
      'mediaUrls': mediaUrls?.map((entry) => entry).toList(growable: false),
      'gifPlayback': gifPlayback,
      'channel': channel,
      'accountId': accountId,
      'agentId': agentId,
      'threadId': threadId,
      'sessionKey': sessionKey,
      'idempotencyKey': idempotencyKey,
    });
  }
}

class GatewaySchemaSessionsCompactParams {
  const GatewaySchemaSessionsCompactParams({
    required this.key,
    this.maxLines,
  });

  factory GatewaySchemaSessionsCompactParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsCompactParams(
      key: _generatedReadRequiredString(json, 'key',
          context: 'SessionsCompactParams.key', allowEmpty: false),
      maxLines: readNullableInt(json['maxLines']),
    );
  }

  final String key;
  final int? maxLines;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'maxLines': maxLines,
    });
  }
}

class GatewaySchemaSessionsDeleteParams {
  const GatewaySchemaSessionsDeleteParams({
    required this.key,
    this.deleteTranscript,
    this.emitLifecycleHooks,
  });

  factory GatewaySchemaSessionsDeleteParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsDeleteParams(
      key: _generatedReadRequiredString(json, 'key',
          context: 'SessionsDeleteParams.key', allowEmpty: false),
      deleteTranscript: readNullableBool(json['deleteTranscript']),
      emitLifecycleHooks: readNullableBool(json['emitLifecycleHooks']),
    );
  }

  final String key;
  final bool? deleteTranscript;
  final bool? emitLifecycleHooks;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'deleteTranscript': deleteTranscript,
      'emitLifecycleHooks': emitLifecycleHooks,
    });
  }
}

class GatewaySchemaSessionsListParams {
  const GatewaySchemaSessionsListParams({
    this.limit,
    this.activeMinutes,
    this.includeGlobal,
    this.includeUnknown,
    this.includeDerivedTitles,
    this.includeLastMessage,
    this.label,
    this.spawnedBy,
    this.agentId,
    this.search,
  });

  factory GatewaySchemaSessionsListParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsListParams(
      limit: readNullableInt(json['limit']),
      activeMinutes: readNullableInt(json['activeMinutes']),
      includeGlobal: readNullableBool(json['includeGlobal']),
      includeUnknown: readNullableBool(json['includeUnknown']),
      includeDerivedTitles: readNullableBool(json['includeDerivedTitles']),
      includeLastMessage: readNullableBool(json['includeLastMessage']),
      label: _generatedReadNullableString(json['label'], allowEmpty: false),
      spawnedBy:
          _generatedReadNullableString(json['spawnedBy'], allowEmpty: false),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      search: _generatedReadNullableString(json['search'], allowEmpty: true),
    );
  }

  final int? limit;
  final int? activeMinutes;
  final bool? includeGlobal;
  final bool? includeUnknown;
  final bool? includeDerivedTitles;
  final bool? includeLastMessage;
  final String? label;
  final String? spawnedBy;
  final String? agentId;
  final String? search;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
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
    });
  }
}

class GatewaySchemaSessionsPatchParams {
  const GatewaySchemaSessionsPatchParams({
    required this.key,
    this.label,
    this.thinkingLevel,
    this.verboseLevel,
    this.reasoningLevel,
    this.responseUsage,
    this.elevatedLevel,
    this.execHost,
    this.execSecurity,
    this.execAsk,
    this.execNode,
    this.model,
    this.spawnedBy,
    this.spawnDepth,
    this.sendPolicy,
    this.groupActivation,
  });

  factory GatewaySchemaSessionsPatchParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsPatchParams(
      key: _generatedReadRequiredString(json, 'key',
          context: 'SessionsPatchParams.key', allowEmpty: false),
      label: _generatedReadNullableString(json['label'], allowEmpty: false),
      thinkingLevel: _generatedReadNullableString(json['thinkingLevel'],
          allowEmpty: false),
      verboseLevel:
          _generatedReadNullableString(json['verboseLevel'], allowEmpty: false),
      reasoningLevel: _generatedReadNullableString(json['reasoningLevel'],
          allowEmpty: false),
      responseUsage:
          _generatedReadNullableString(json['responseUsage'], allowEmpty: true),
      elevatedLevel: _generatedReadNullableString(json['elevatedLevel'],
          allowEmpty: false),
      execHost:
          _generatedReadNullableString(json['execHost'], allowEmpty: false),
      execSecurity:
          _generatedReadNullableString(json['execSecurity'], allowEmpty: false),
      execAsk: _generatedReadNullableString(json['execAsk'], allowEmpty: false),
      execNode:
          _generatedReadNullableString(json['execNode'], allowEmpty: false),
      model: _generatedReadNullableString(json['model'], allowEmpty: false),
      spawnedBy:
          _generatedReadNullableString(json['spawnedBy'], allowEmpty: false),
      spawnDepth: readNullableInt(json['spawnDepth']),
      sendPolicy:
          _generatedReadNullableString(json['sendPolicy'], allowEmpty: true),
      groupActivation: _generatedReadNullableString(json['groupActivation'],
          allowEmpty: true),
    );
  }

  final String key;
  final String? label;
  final String? thinkingLevel;
  final String? verboseLevel;
  final String? reasoningLevel;
  final String? responseUsage;
  final String? elevatedLevel;
  final String? execHost;
  final String? execSecurity;
  final String? execAsk;
  final String? execNode;
  final String? model;
  final String? spawnedBy;
  final int? spawnDepth;
  final String? sendPolicy;
  final String? groupActivation;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'label': label,
      'thinkingLevel': thinkingLevel,
      'verboseLevel': verboseLevel,
      'reasoningLevel': reasoningLevel,
      'responseUsage': responseUsage,
      'elevatedLevel': elevatedLevel,
      'execHost': execHost,
      'execSecurity': execSecurity,
      'execAsk': execAsk,
      'execNode': execNode,
      'model': model,
      'spawnedBy': spawnedBy,
      'spawnDepth': spawnDepth,
      'sendPolicy': sendPolicy,
      'groupActivation': groupActivation,
    });
  }
}

class GatewaySchemaSessionsPreviewParams {
  const GatewaySchemaSessionsPreviewParams({
    required this.keys,
    this.limit,
    this.maxChars,
  });

  factory GatewaySchemaSessionsPreviewParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsPreviewParams(
      keys: asJsonList(json['keys'], context: 'SessionsPreviewParams.keys')
          .map((entry) => _generatedReadItemString(entry,
              context: 'SessionsPreviewParams.keys[]'))
          .toList(growable: false),
      limit: readNullableInt(json['limit']),
      maxChars: readNullableInt(json['maxChars']),
    );
  }

  final List<String> keys;
  final int? limit;
  final int? maxChars;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'keys': keys.map((entry) => entry).toList(growable: false),
      'limit': limit,
      'maxChars': maxChars,
    });
  }
}

class GatewaySchemaSessionsResetParams {
  const GatewaySchemaSessionsResetParams({
    required this.key,
    this.reason,
  });

  factory GatewaySchemaSessionsResetParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsResetParams(
      key: _generatedReadRequiredString(json, 'key',
          context: 'SessionsResetParams.key', allowEmpty: false),
      reason: _generatedReadNullableString(json['reason'], allowEmpty: true),
    );
  }

  final String key;
  final String? reason;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'reason': reason,
    });
  }
}

class GatewaySchemaSessionsResolveParams {
  const GatewaySchemaSessionsResolveParams({
    this.key,
    this.sessionId,
    this.label,
    this.agentId,
    this.spawnedBy,
    this.includeGlobal,
    this.includeUnknown,
  });

  factory GatewaySchemaSessionsResolveParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsResolveParams(
      key: _generatedReadNullableString(json['key'], allowEmpty: false),
      sessionId:
          _generatedReadNullableString(json['sessionId'], allowEmpty: false),
      label: _generatedReadNullableString(json['label'], allowEmpty: false),
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      spawnedBy:
          _generatedReadNullableString(json['spawnedBy'], allowEmpty: false),
      includeGlobal: readNullableBool(json['includeGlobal']),
      includeUnknown: readNullableBool(json['includeUnknown']),
    );
  }

  final String? key;
  final String? sessionId;
  final String? label;
  final String? agentId;
  final String? spawnedBy;
  final bool? includeGlobal;
  final bool? includeUnknown;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'sessionId': sessionId,
      'label': label,
      'agentId': agentId,
      'spawnedBy': spawnedBy,
      'includeGlobal': includeGlobal,
      'includeUnknown': includeUnknown,
    });
  }
}

class GatewaySchemaSessionsUsageParams {
  const GatewaySchemaSessionsUsageParams({
    this.key,
    this.startDate,
    this.endDate,
    this.mode,
    this.utcOffset,
    this.limit,
    this.includeContextWeight,
  });

  factory GatewaySchemaSessionsUsageParams.fromJson(JsonMap json) {
    return GatewaySchemaSessionsUsageParams(
      key: _generatedReadNullableString(json['key'], allowEmpty: false),
      startDate:
          _generatedReadNullableString(json['startDate'], allowEmpty: true),
      endDate: _generatedReadNullableString(json['endDate'], allowEmpty: true),
      mode: _generatedReadNullableString(json['mode'], allowEmpty: true),
      utcOffset:
          _generatedReadNullableString(json['utcOffset'], allowEmpty: true),
      limit: readNullableInt(json['limit']),
      includeContextWeight: readNullableBool(json['includeContextWeight']),
    );
  }

  final String? key;
  final String? startDate;
  final String? endDate;
  final String? mode;
  final String? utcOffset;
  final int? limit;
  final bool? includeContextWeight;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'key': key,
      'startDate': startDate,
      'endDate': endDate,
      'mode': mode,
      'utcOffset': utcOffset,
      'limit': limit,
      'includeContextWeight': includeContextWeight,
    });
  }
}

class GatewaySchemaShutdownEvent {
  const GatewaySchemaShutdownEvent({
    required this.reason,
    this.restartExpectedMs,
  });

  factory GatewaySchemaShutdownEvent.fromJson(JsonMap json) {
    return GatewaySchemaShutdownEvent(
      reason: _generatedReadRequiredString(json, 'reason',
          context: 'ShutdownEvent.reason', allowEmpty: false),
      restartExpectedMs: readNullableInt(json['restartExpectedMs']),
    );
  }

  final String reason;
  final int? restartExpectedMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'reason': reason,
      'restartExpectedMs': restartExpectedMs,
    });
  }
}

class GatewaySchemaSkillsBinsParams {
  const GatewaySchemaSkillsBinsParams(this.value);

  factory GatewaySchemaSkillsBinsParams.fromJson(JsonMap json) {
    return GatewaySchemaSkillsBinsParams(json);
  }

  final JsonMap value;

  JsonMap toJson() => value;
}

class GatewaySchemaSkillsBinsResult {
  const GatewaySchemaSkillsBinsResult({
    required this.bins,
  });

  factory GatewaySchemaSkillsBinsResult.fromJson(JsonMap json) {
    return GatewaySchemaSkillsBinsResult(
      bins: asJsonList(json['bins'], context: 'SkillsBinsResult.bins')
          .map((entry) => _generatedReadItemString(entry,
              context: 'SkillsBinsResult.bins[]'))
          .toList(growable: false),
    );
  }

  final List<String> bins;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'bins': bins.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaSkillsInstallParams {
  const GatewaySchemaSkillsInstallParams({
    required this.name,
    required this.installId,
    this.timeoutMs,
  });

  factory GatewaySchemaSkillsInstallParams.fromJson(JsonMap json) {
    return GatewaySchemaSkillsInstallParams(
      name: _generatedReadRequiredString(json, 'name',
          context: 'SkillsInstallParams.name', allowEmpty: false),
      installId: _generatedReadRequiredString(json, 'installId',
          context: 'SkillsInstallParams.installId', allowEmpty: false),
      timeoutMs: readNullableInt(json['timeoutMs']),
    );
  }

  final String name;
  final String installId;
  final int? timeoutMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'name': name,
      'installId': installId,
      'timeoutMs': timeoutMs,
    });
  }
}

class GatewaySchemaSkillsStatusParams {
  const GatewaySchemaSkillsStatusParams({
    this.agentId,
  });

  factory GatewaySchemaSkillsStatusParams.fromJson(JsonMap json) {
    return GatewaySchemaSkillsStatusParams(
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
    );
  }

  final String? agentId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
    });
  }
}

class GatewaySchemaSkillsUpdateParams {
  const GatewaySchemaSkillsUpdateParams({
    required this.skillKey,
    this.enabled,
    this.apiKey,
    this.env,
  });

  factory GatewaySchemaSkillsUpdateParams.fromJson(JsonMap json) {
    return GatewaySchemaSkillsUpdateParams(
      skillKey: _generatedReadRequiredString(json, 'skillKey',
          context: 'SkillsUpdateParams.skillKey', allowEmpty: false),
      enabled: readNullableBool(json['enabled']),
      apiKey: _generatedReadNullableString(json['apiKey'], allowEmpty: true),
      env: json['env'] == null
          ? null
          : Map<String, String>.unmodifiable({
              for (final entry
                  in asJsonMap(json['env'], context: 'SkillsUpdateParams.env')
                      .entries)
                entry.key: _generatedReadItemString(entry.value,
                    context: 'SkillsUpdateParams.env.${entry.key}')
            }),
    );
  }

  final String skillKey;
  final bool? enabled;
  final String? apiKey;
  final Map<String, String>? env;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'skillKey': skillKey,
      'enabled': enabled,
      'apiKey': apiKey,
      'env': env,
    });
  }
}

class GatewaySchemaSnapshotPresenceItem {
  const GatewaySchemaSnapshotPresenceItem({
    this.host,
    this.ip,
    this.version,
    this.platform,
    this.deviceFamily,
    this.modelIdentifier,
    this.mode,
    this.lastInputSeconds,
    this.reason,
    this.tags,
    this.text,
    required this.ts,
    this.deviceId,
    this.roles,
    this.scopes,
    this.instanceId,
  });

  factory GatewaySchemaSnapshotPresenceItem.fromJson(JsonMap json) {
    return GatewaySchemaSnapshotPresenceItem(
      host: _generatedReadNullableString(json['host'], allowEmpty: false),
      ip: _generatedReadNullableString(json['ip'], allowEmpty: false),
      version: _generatedReadNullableString(json['version'], allowEmpty: false),
      platform:
          _generatedReadNullableString(json['platform'], allowEmpty: false),
      deviceFamily:
          _generatedReadNullableString(json['deviceFamily'], allowEmpty: false),
      modelIdentifier: _generatedReadNullableString(json['modelIdentifier'],
          allowEmpty: false),
      mode: _generatedReadNullableString(json['mode'], allowEmpty: false),
      lastInputSeconds: readNullableInt(json['lastInputSeconds']),
      reason: _generatedReadNullableString(json['reason'], allowEmpty: false),
      tags: json['tags'] == null
          ? null
          : asJsonList(json['tags'],
                  context: 'GatewaySchemaSnapshot.presenceItem.tags')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaSnapshot.presenceItem.tags[]'))
              .toList(growable: false),
      text: _generatedReadNullableString(json['text'], allowEmpty: true),
      ts: readRequiredInt(json, 'ts',
          context: 'GatewaySchemaSnapshot.presenceItem.ts'),
      deviceId:
          _generatedReadNullableString(json['deviceId'], allowEmpty: false),
      roles: json['roles'] == null
          ? null
          : asJsonList(json['roles'],
                  context: 'GatewaySchemaSnapshot.presenceItem.roles')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaSnapshot.presenceItem.roles[]'))
              .toList(growable: false),
      scopes: json['scopes'] == null
          ? null
          : asJsonList(json['scopes'],
                  context: 'GatewaySchemaSnapshot.presenceItem.scopes')
              .map((entry) => _generatedReadItemString(entry,
                  context: 'GatewaySchemaSnapshot.presenceItem.scopes[]'))
              .toList(growable: false),
      instanceId:
          _generatedReadNullableString(json['instanceId'], allowEmpty: false),
    );
  }

  final String? host;
  final String? ip;
  final String? version;
  final String? platform;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? mode;
  final int? lastInputSeconds;
  final String? reason;
  final List<String>? tags;
  final String? text;
  final int ts;
  final String? deviceId;
  final List<String>? roles;
  final List<String>? scopes;
  final String? instanceId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'host': host,
      'ip': ip,
      'version': version,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'mode': mode,
      'lastInputSeconds': lastInputSeconds,
      'reason': reason,
      'tags': tags?.map((entry) => entry).toList(growable: false),
      'text': text,
      'ts': ts,
      'deviceId': deviceId,
      'roles': roles?.map((entry) => entry).toList(growable: false),
      'scopes': scopes?.map((entry) => entry).toList(growable: false),
      'instanceId': instanceId,
    });
  }
}

class GatewaySchemaSnapshotStateVersion {
  const GatewaySchemaSnapshotStateVersion({
    required this.presence,
    required this.health,
  });

  factory GatewaySchemaSnapshotStateVersion.fromJson(JsonMap json) {
    return GatewaySchemaSnapshotStateVersion(
      presence: readRequiredInt(json, 'presence',
          context: 'GatewaySchemaSnapshot.stateVersion.presence'),
      health: readRequiredInt(json, 'health',
          context: 'GatewaySchemaSnapshot.stateVersion.health'),
    );
  }

  final int presence;
  final int health;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence': presence,
      'health': health,
    });
  }
}

class GatewaySchemaSnapshotSessionDefaults {
  const GatewaySchemaSnapshotSessionDefaults({
    required this.defaultAgentId,
    required this.mainKey,
    required this.mainSessionKey,
    this.scope,
  });

  factory GatewaySchemaSnapshotSessionDefaults.fromJson(JsonMap json) {
    return GatewaySchemaSnapshotSessionDefaults(
      defaultAgentId: _generatedReadRequiredString(json, 'defaultAgentId',
          context: 'GatewaySchemaSnapshot.sessionDefaults.defaultAgentId',
          allowEmpty: false),
      mainKey: _generatedReadRequiredString(json, 'mainKey',
          context: 'GatewaySchemaSnapshot.sessionDefaults.mainKey',
          allowEmpty: false),
      mainSessionKey: _generatedReadRequiredString(json, 'mainSessionKey',
          context: 'GatewaySchemaSnapshot.sessionDefaults.mainSessionKey',
          allowEmpty: false),
      scope: _generatedReadNullableString(json['scope'], allowEmpty: false),
    );
  }

  final String defaultAgentId;
  final String mainKey;
  final String mainSessionKey;
  final String? scope;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'defaultAgentId': defaultAgentId,
      'mainKey': mainKey,
      'mainSessionKey': mainSessionKey,
      'scope': scope,
    });
  }
}

class GatewaySchemaSnapshotUpdateAvailable {
  const GatewaySchemaSnapshotUpdateAvailable({
    required this.currentVersion,
    required this.latestVersion,
    required this.channel,
  });

  factory GatewaySchemaSnapshotUpdateAvailable.fromJson(JsonMap json) {
    return GatewaySchemaSnapshotUpdateAvailable(
      currentVersion: _generatedReadRequiredString(json, 'currentVersion',
          context: 'GatewaySchemaSnapshot.updateAvailable.currentVersion',
          allowEmpty: false),
      latestVersion: _generatedReadRequiredString(json, 'latestVersion',
          context: 'GatewaySchemaSnapshot.updateAvailable.latestVersion',
          allowEmpty: false),
      channel: _generatedReadRequiredString(json, 'channel',
          context: 'GatewaySchemaSnapshot.updateAvailable.channel',
          allowEmpty: false),
    );
  }

  final String currentVersion;
  final String latestVersion;
  final String channel;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'currentVersion': currentVersion,
      'latestVersion': latestVersion,
      'channel': channel,
    });
  }
}

class GatewaySchemaSnapshot {
  const GatewaySchemaSnapshot({
    required this.presence,
    this.health,
    required this.stateVersion,
    required this.uptimeMs,
    this.configPath,
    this.stateDir,
    this.sessionDefaults,
    this.authMode,
    this.updateAvailable,
  });

  factory GatewaySchemaSnapshot.fromJson(JsonMap json) {
    return GatewaySchemaSnapshot(
      presence: asJsonList(json['presence'], context: 'Snapshot.presence')
          .map((entry) => GatewaySchemaSnapshotPresenceItem.fromJson(
              asJsonMap(entry, context: 'Snapshot.presence[]')))
          .toList(growable: false),
      health: json['health'],
      stateVersion: GatewaySchemaSnapshotStateVersion.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'stateVersion',
              context: 'Snapshot'),
          context: 'Snapshot.stateVersion')),
      uptimeMs: readRequiredInt(json, 'uptimeMs', context: 'Snapshot.uptimeMs'),
      configPath:
          _generatedReadNullableString(json['configPath'], allowEmpty: false),
      stateDir:
          _generatedReadNullableString(json['stateDir'], allowEmpty: false),
      sessionDefaults: json['sessionDefaults'] == null
          ? null
          : GatewaySchemaSnapshotSessionDefaults.fromJson(asJsonMap(
              json['sessionDefaults'],
              context: 'Snapshot.sessionDefaults')),
      authMode:
          _generatedReadNullableString(json['authMode'], allowEmpty: true),
      updateAvailable: json['updateAvailable'] == null
          ? null
          : GatewaySchemaSnapshotUpdateAvailable.fromJson(asJsonMap(
              json['updateAvailable'],
              context: 'Snapshot.updateAvailable')),
    );
  }

  final List<GatewaySchemaSnapshotPresenceItem> presence;
  final Object? health;
  final GatewaySchemaSnapshotStateVersion stateVersion;
  final int uptimeMs;
  final String? configPath;
  final String? stateDir;
  final GatewaySchemaSnapshotSessionDefaults? sessionDefaults;
  final String? authMode;
  final GatewaySchemaSnapshotUpdateAvailable? updateAvailable;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence':
          presence.map((entry) => entry.toJson()).toList(growable: false),
      'health': health,
      'stateVersion': stateVersion.toJson(),
      'uptimeMs': uptimeMs,
      'configPath': configPath,
      'stateDir': stateDir,
      'sessionDefaults': sessionDefaults?.toJson(),
      'authMode': authMode,
      'updateAvailable': updateAvailable?.toJson(),
    });
  }
}

class GatewaySchemaStateVersion {
  const GatewaySchemaStateVersion({
    required this.presence,
    required this.health,
  });

  factory GatewaySchemaStateVersion.fromJson(JsonMap json) {
    return GatewaySchemaStateVersion(
      presence:
          readRequiredInt(json, 'presence', context: 'StateVersion.presence'),
      health: readRequiredInt(json, 'health', context: 'StateVersion.health'),
    );
  }

  final int presence;
  final int health;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'presence': presence,
      'health': health,
    });
  }
}

class GatewaySchemaTalkConfigParams {
  const GatewaySchemaTalkConfigParams({
    this.includeSecrets,
  });

  factory GatewaySchemaTalkConfigParams.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigParams(
      includeSecrets: readNullableBool(json['includeSecrets']),
    );
  }

  final bool? includeSecrets;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'includeSecrets': includeSecrets,
    });
  }
}

class GatewaySchemaTalkConfigResultConfigTalk {
  const GatewaySchemaTalkConfigResultConfigTalk({
    this.provider,
    this.providers,
    this.voiceId,
    this.voiceAliases,
    this.modelId,
    this.outputFormat,
    this.apiKey,
    this.interruptOnSpeech,
  });

  factory GatewaySchemaTalkConfigResultConfigTalk.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigResultConfigTalk(
      provider:
          _generatedReadNullableString(json['provider'], allowEmpty: true),
      providers: json['providers'] == null
          ? null
          : Map<String, JsonMap>.unmodifiable({
              for (final entry in asJsonMap(json['providers'],
                      context:
                          'GatewaySchemaTalkConfigResultConfig.talk.providers')
                  .entries)
                entry.key: asJsonMap(entry.value,
                    context:
                        'GatewaySchemaTalkConfigResultConfig.talk.providers.${entry.key}')
            }),
      voiceId: _generatedReadNullableString(json['voiceId'], allowEmpty: true),
      voiceAliases: json['voiceAliases'] == null
          ? null
          : Map<String, String>.unmodifiable({
              for (final entry in asJsonMap(json['voiceAliases'],
                      context:
                          'GatewaySchemaTalkConfigResultConfig.talk.voiceAliases')
                  .entries)
                entry.key: _generatedReadItemString(entry.value,
                    context:
                        'GatewaySchemaTalkConfigResultConfig.talk.voiceAliases.${entry.key}')
            }),
      modelId: _generatedReadNullableString(json['modelId'], allowEmpty: true),
      outputFormat:
          _generatedReadNullableString(json['outputFormat'], allowEmpty: true),
      apiKey: _generatedReadNullableString(json['apiKey'], allowEmpty: true),
      interruptOnSpeech: readNullableBool(json['interruptOnSpeech']),
    );
  }

  final String? provider;
  final Map<String, JsonMap>? providers;
  final String? voiceId;
  final Map<String, String>? voiceAliases;
  final String? modelId;
  final String? outputFormat;
  final String? apiKey;
  final bool? interruptOnSpeech;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'provider': provider,
      'providers': providers,
      'voiceId': voiceId,
      'voiceAliases': voiceAliases,
      'modelId': modelId,
      'outputFormat': outputFormat,
      'apiKey': apiKey,
      'interruptOnSpeech': interruptOnSpeech,
    });
  }
}

class GatewaySchemaTalkConfigResultConfigSession {
  const GatewaySchemaTalkConfigResultConfigSession({
    this.mainKey,
  });

  factory GatewaySchemaTalkConfigResultConfigSession.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigResultConfigSession(
      mainKey: _generatedReadNullableString(json['mainKey'], allowEmpty: true),
    );
  }

  final String? mainKey;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'mainKey': mainKey,
    });
  }
}

class GatewaySchemaTalkConfigResultConfigUi {
  const GatewaySchemaTalkConfigResultConfigUi({
    this.seamColor,
  });

  factory GatewaySchemaTalkConfigResultConfigUi.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigResultConfigUi(
      seamColor:
          _generatedReadNullableString(json['seamColor'], allowEmpty: true),
    );
  }

  final String? seamColor;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'seamColor': seamColor,
    });
  }
}

class GatewaySchemaTalkConfigResultConfig {
  const GatewaySchemaTalkConfigResultConfig({
    this.talk,
    this.session,
    this.ui,
  });

  factory GatewaySchemaTalkConfigResultConfig.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigResultConfig(
      talk: json['talk'] == null
          ? null
          : GatewaySchemaTalkConfigResultConfigTalk.fromJson(asJsonMap(
              json['talk'],
              context: 'GatewaySchemaTalkConfigResult.config.talk')),
      session: json['session'] == null
          ? null
          : GatewaySchemaTalkConfigResultConfigSession.fromJson(asJsonMap(
              json['session'],
              context: 'GatewaySchemaTalkConfigResult.config.session')),
      ui: json['ui'] == null
          ? null
          : GatewaySchemaTalkConfigResultConfigUi.fromJson(asJsonMap(json['ui'],
              context: 'GatewaySchemaTalkConfigResult.config.ui')),
    );
  }

  final GatewaySchemaTalkConfigResultConfigTalk? talk;
  final GatewaySchemaTalkConfigResultConfigSession? session;
  final GatewaySchemaTalkConfigResultConfigUi? ui;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'talk': talk?.toJson(),
      'session': session?.toJson(),
      'ui': ui?.toJson(),
    });
  }
}

class GatewaySchemaTalkConfigResult {
  const GatewaySchemaTalkConfigResult({
    required this.config,
  });

  factory GatewaySchemaTalkConfigResult.fromJson(JsonMap json) {
    return GatewaySchemaTalkConfigResult(
      config: GatewaySchemaTalkConfigResultConfig.fromJson(asJsonMap(
          _generatedReadRequiredValue(json, 'config',
              context: 'TalkConfigResult'),
          context: 'TalkConfigResult.config')),
    );
  }

  final GatewaySchemaTalkConfigResultConfig config;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'config': config.toJson(),
    });
  }
}

class GatewaySchemaTalkModeParams {
  const GatewaySchemaTalkModeParams({
    required this.enabled,
    this.phase,
  });

  factory GatewaySchemaTalkModeParams.fromJson(JsonMap json) {
    return GatewaySchemaTalkModeParams(
      enabled:
          readRequiredBool(json, 'enabled', context: 'TalkModeParams.enabled'),
      phase: _generatedReadNullableString(json['phase'], allowEmpty: true),
    );
  }

  final bool enabled;
  final String? phase;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'enabled': enabled,
      'phase': phase,
    });
  }
}

class GatewaySchemaTickEvent {
  const GatewaySchemaTickEvent({
    required this.ts,
  });

  factory GatewaySchemaTickEvent.fromJson(JsonMap json) {
    return GatewaySchemaTickEvent(
      ts: readRequiredInt(json, 'ts', context: 'TickEvent.ts'),
    );
  }

  final int ts;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'ts': ts,
    });
  }
}

class GatewaySchemaToolCatalogEntry {
  const GatewaySchemaToolCatalogEntry({
    required this.id,
    required this.label,
    required this.description,
    required this.source,
    this.pluginId,
    this.optional,
    required this.defaultProfiles,
  });

  factory GatewaySchemaToolCatalogEntry.fromJson(JsonMap json) {
    return GatewaySchemaToolCatalogEntry(
      id: _generatedReadRequiredString(json, 'id',
          context: 'ToolCatalogEntry.id', allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'ToolCatalogEntry.label', allowEmpty: false),
      description: _generatedReadRequiredString(json, 'description',
          context: 'ToolCatalogEntry.description', allowEmpty: true),
      source: _generatedReadRequiredString(json, 'source',
          context: 'ToolCatalogEntry.source', allowEmpty: true),
      pluginId:
          _generatedReadNullableString(json['pluginId'], allowEmpty: false),
      optional: readNullableBool(json['optional']),
      defaultProfiles: asJsonList(json['defaultProfiles'],
              context: 'ToolCatalogEntry.defaultProfiles')
          .map((entry) => _generatedReadItemString(entry,
              context: 'ToolCatalogEntry.defaultProfiles[]'))
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String description;
  final String source;
  final String? pluginId;
  final bool? optional;
  final List<String> defaultProfiles;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'description': description,
      'source': source,
      'pluginId': pluginId,
      'optional': optional,
      'defaultProfiles':
          defaultProfiles.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaToolCatalogGroupToolsItem {
  const GatewaySchemaToolCatalogGroupToolsItem({
    required this.id,
    required this.label,
    required this.description,
    required this.source,
    this.pluginId,
    this.optional,
    required this.defaultProfiles,
  });

  factory GatewaySchemaToolCatalogGroupToolsItem.fromJson(JsonMap json) {
    return GatewaySchemaToolCatalogGroupToolsItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaToolCatalogGroup.toolsItem.id',
          allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaToolCatalogGroup.toolsItem.label',
          allowEmpty: false),
      description: _generatedReadRequiredString(json, 'description',
          context: 'GatewaySchemaToolCatalogGroup.toolsItem.description',
          allowEmpty: true),
      source: _generatedReadRequiredString(json, 'source',
          context: 'GatewaySchemaToolCatalogGroup.toolsItem.source',
          allowEmpty: true),
      pluginId:
          _generatedReadNullableString(json['pluginId'], allowEmpty: false),
      optional: readNullableBool(json['optional']),
      defaultProfiles: asJsonList(json['defaultProfiles'],
              context:
                  'GatewaySchemaToolCatalogGroup.toolsItem.defaultProfiles')
          .map((entry) => _generatedReadItemString(entry,
              context:
                  'GatewaySchemaToolCatalogGroup.toolsItem.defaultProfiles[]'))
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String description;
  final String source;
  final String? pluginId;
  final bool? optional;
  final List<String> defaultProfiles;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'description': description,
      'source': source,
      'pluginId': pluginId,
      'optional': optional,
      'defaultProfiles':
          defaultProfiles.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaToolCatalogGroup {
  const GatewaySchemaToolCatalogGroup({
    required this.id,
    required this.label,
    required this.source,
    this.pluginId,
    required this.tools,
  });

  factory GatewaySchemaToolCatalogGroup.fromJson(JsonMap json) {
    return GatewaySchemaToolCatalogGroup(
      id: _generatedReadRequiredString(json, 'id',
          context: 'ToolCatalogGroup.id', allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'ToolCatalogGroup.label', allowEmpty: false),
      source: _generatedReadRequiredString(json, 'source',
          context: 'ToolCatalogGroup.source', allowEmpty: true),
      pluginId:
          _generatedReadNullableString(json['pluginId'], allowEmpty: false),
      tools: asJsonList(json['tools'], context: 'ToolCatalogGroup.tools')
          .map((entry) => GatewaySchemaToolCatalogGroupToolsItem.fromJson(
              asJsonMap(entry, context: 'ToolCatalogGroup.tools[]')))
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String source;
  final String? pluginId;
  final List<GatewaySchemaToolCatalogGroupToolsItem> tools;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'source': source,
      'pluginId': pluginId,
      'tools': tools.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaToolCatalogProfile {
  const GatewaySchemaToolCatalogProfile({
    required this.id,
    required this.label,
  });

  factory GatewaySchemaToolCatalogProfile.fromJson(JsonMap json) {
    return GatewaySchemaToolCatalogProfile(
      id: _generatedReadRequiredString(json, 'id',
          context: 'ToolCatalogProfile.id', allowEmpty: true),
      label: _generatedReadRequiredString(json, 'label',
          context: 'ToolCatalogProfile.label', allowEmpty: false),
    );
  }

  final String id;
  final String label;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
    });
  }
}

class GatewaySchemaToolsCatalogParams {
  const GatewaySchemaToolsCatalogParams({
    this.agentId,
    this.includePlugins,
  });

  factory GatewaySchemaToolsCatalogParams.fromJson(JsonMap json) {
    return GatewaySchemaToolsCatalogParams(
      agentId: _generatedReadNullableString(json['agentId'], allowEmpty: false),
      includePlugins: readNullableBool(json['includePlugins']),
    );
  }

  final String? agentId;
  final bool? includePlugins;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'includePlugins': includePlugins,
    });
  }
}

class GatewaySchemaToolsCatalogResultProfilesItem {
  const GatewaySchemaToolsCatalogResultProfilesItem({
    required this.id,
    required this.label,
  });

  factory GatewaySchemaToolsCatalogResultProfilesItem.fromJson(JsonMap json) {
    return GatewaySchemaToolsCatalogResultProfilesItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaToolsCatalogResult.profilesItem.id',
          allowEmpty: true),
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaToolsCatalogResult.profilesItem.label',
          allowEmpty: false),
    );
  }

  final String id;
  final String label;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
    });
  }
}

class GatewaySchemaToolsCatalogResultGroupsItemToolsItem {
  const GatewaySchemaToolsCatalogResultGroupsItemToolsItem({
    required this.id,
    required this.label,
    required this.description,
    required this.source,
    this.pluginId,
    this.optional,
    required this.defaultProfiles,
  });

  factory GatewaySchemaToolsCatalogResultGroupsItemToolsItem.fromJson(
      JsonMap json) {
    return GatewaySchemaToolsCatalogResultGroupsItemToolsItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.id',
          allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.label',
          allowEmpty: false),
      description: _generatedReadRequiredString(json, 'description',
          context:
              'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.description',
          allowEmpty: true),
      source: _generatedReadRequiredString(json, 'source',
          context: 'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.source',
          allowEmpty: true),
      pluginId:
          _generatedReadNullableString(json['pluginId'], allowEmpty: false),
      optional: readNullableBool(json['optional']),
      defaultProfiles: asJsonList(json['defaultProfiles'],
              context:
                  'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.defaultProfiles')
          .map((entry) => _generatedReadItemString(entry,
              context:
                  'GatewaySchemaToolsCatalogResultGroupsItem.toolsItem.defaultProfiles[]'))
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String description;
  final String source;
  final String? pluginId;
  final bool? optional;
  final List<String> defaultProfiles;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'description': description,
      'source': source,
      'pluginId': pluginId,
      'optional': optional,
      'defaultProfiles':
          defaultProfiles.map((entry) => entry).toList(growable: false),
    });
  }
}

class GatewaySchemaToolsCatalogResultGroupsItem {
  const GatewaySchemaToolsCatalogResultGroupsItem({
    required this.id,
    required this.label,
    required this.source,
    this.pluginId,
    required this.tools,
  });

  factory GatewaySchemaToolsCatalogResultGroupsItem.fromJson(JsonMap json) {
    return GatewaySchemaToolsCatalogResultGroupsItem(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaToolsCatalogResult.groupsItem.id',
          allowEmpty: false),
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaToolsCatalogResult.groupsItem.label',
          allowEmpty: false),
      source: _generatedReadRequiredString(json, 'source',
          context: 'GatewaySchemaToolsCatalogResult.groupsItem.source',
          allowEmpty: true),
      pluginId:
          _generatedReadNullableString(json['pluginId'], allowEmpty: false),
      tools: asJsonList(json['tools'],
              context: 'GatewaySchemaToolsCatalogResult.groupsItem.tools')
          .map((entry) => GatewaySchemaToolsCatalogResultGroupsItemToolsItem
              .fromJson(asJsonMap(entry,
                  context:
                      'GatewaySchemaToolsCatalogResult.groupsItem.tools[]')))
          .toList(growable: false),
    );
  }

  final String id;
  final String label;
  final String source;
  final String? pluginId;
  final List<GatewaySchemaToolsCatalogResultGroupsItemToolsItem> tools;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'label': label,
      'source': source,
      'pluginId': pluginId,
      'tools': tools.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaToolsCatalogResult {
  const GatewaySchemaToolsCatalogResult({
    required this.agentId,
    required this.profiles,
    required this.groups,
  });

  factory GatewaySchemaToolsCatalogResult.fromJson(JsonMap json) {
    return GatewaySchemaToolsCatalogResult(
      agentId: _generatedReadRequiredString(json, 'agentId',
          context: 'ToolsCatalogResult.agentId', allowEmpty: false),
      profiles: asJsonList(json['profiles'],
              context: 'ToolsCatalogResult.profiles')
          .map((entry) => GatewaySchemaToolsCatalogResultProfilesItem.fromJson(
              asJsonMap(entry, context: 'ToolsCatalogResult.profiles[]')))
          .toList(growable: false),
      groups: asJsonList(json['groups'], context: 'ToolsCatalogResult.groups')
          .map((entry) => GatewaySchemaToolsCatalogResultGroupsItem.fromJson(
              asJsonMap(entry, context: 'ToolsCatalogResult.groups[]')))
          .toList(growable: false),
    );
  }

  final String agentId;
  final List<GatewaySchemaToolsCatalogResultProfilesItem> profiles;
  final List<GatewaySchemaToolsCatalogResultGroupsItem> groups;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'agentId': agentId,
      'profiles':
          profiles.map((entry) => entry.toJson()).toList(growable: false),
      'groups': groups.map((entry) => entry.toJson()).toList(growable: false),
    });
  }
}

class GatewaySchemaUpdateRunParams {
  const GatewaySchemaUpdateRunParams({
    this.sessionKey,
    this.note,
    this.restartDelayMs,
    this.timeoutMs,
  });

  factory GatewaySchemaUpdateRunParams.fromJson(JsonMap json) {
    return GatewaySchemaUpdateRunParams(
      sessionKey:
          _generatedReadNullableString(json['sessionKey'], allowEmpty: true),
      note: _generatedReadNullableString(json['note'], allowEmpty: true),
      restartDelayMs: readNullableInt(json['restartDelayMs']),
      timeoutMs: readNullableInt(json['timeoutMs']),
    );
  }

  final String? sessionKey;
  final String? note;
  final int? restartDelayMs;
  final int? timeoutMs;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionKey': sessionKey,
      'note': note,
      'restartDelayMs': restartDelayMs,
      'timeoutMs': timeoutMs,
    });
  }
}

class GatewaySchemaWakeParams {
  const GatewaySchemaWakeParams({
    required this.mode,
    required this.text,
  });

  factory GatewaySchemaWakeParams.fromJson(JsonMap json) {
    return GatewaySchemaWakeParams(
      mode: _generatedReadRequiredString(json, 'mode',
          context: 'WakeParams.mode', allowEmpty: true),
      text: _generatedReadRequiredString(json, 'text',
          context: 'WakeParams.text', allowEmpty: false),
    );
  }

  final String mode;
  final String text;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'mode': mode,
      'text': text,
    });
  }
}

class GatewaySchemaWebLoginStartParams {
  const GatewaySchemaWebLoginStartParams({
    this.force,
    this.timeoutMs,
    this.verbose,
    this.accountId,
  });

  factory GatewaySchemaWebLoginStartParams.fromJson(JsonMap json) {
    return GatewaySchemaWebLoginStartParams(
      force: readNullableBool(json['force']),
      timeoutMs: readNullableInt(json['timeoutMs']),
      verbose: readNullableBool(json['verbose']),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
    );
  }

  final bool? force;
  final int? timeoutMs;
  final bool? verbose;
  final String? accountId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'force': force,
      'timeoutMs': timeoutMs,
      'verbose': verbose,
      'accountId': accountId,
    });
  }
}

class GatewaySchemaWebLoginWaitParams {
  const GatewaySchemaWebLoginWaitParams({
    this.timeoutMs,
    this.accountId,
  });

  factory GatewaySchemaWebLoginWaitParams.fromJson(JsonMap json) {
    return GatewaySchemaWebLoginWaitParams(
      timeoutMs: readNullableInt(json['timeoutMs']),
      accountId:
          _generatedReadNullableString(json['accountId'], allowEmpty: true),
    );
  }

  final int? timeoutMs;
  final String? accountId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'timeoutMs': timeoutMs,
      'accountId': accountId,
    });
  }
}

class GatewaySchemaWizardCancelParams {
  const GatewaySchemaWizardCancelParams({
    required this.sessionId,
  });

  factory GatewaySchemaWizardCancelParams.fromJson(JsonMap json) {
    return GatewaySchemaWizardCancelParams(
      sessionId: _generatedReadRequiredString(json, 'sessionId',
          context: 'WizardCancelParams.sessionId', allowEmpty: false),
    );
  }

  final String sessionId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionId': sessionId,
    });
  }
}

class GatewaySchemaWizardNextParamsAnswer {
  const GatewaySchemaWizardNextParamsAnswer({
    required this.stepId,
    this.value,
  });

  factory GatewaySchemaWizardNextParamsAnswer.fromJson(JsonMap json) {
    return GatewaySchemaWizardNextParamsAnswer(
      stepId: _generatedReadRequiredString(json, 'stepId',
          context: 'GatewaySchemaWizardNextParams.answer.stepId',
          allowEmpty: false),
      value: json['value'],
    );
  }

  final String stepId;
  final Object? value;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'stepId': stepId,
      'value': value,
    });
  }
}

class GatewaySchemaWizardNextParams {
  const GatewaySchemaWizardNextParams({
    required this.sessionId,
    this.answer,
  });

  factory GatewaySchemaWizardNextParams.fromJson(JsonMap json) {
    return GatewaySchemaWizardNextParams(
      sessionId: _generatedReadRequiredString(json, 'sessionId',
          context: 'WizardNextParams.sessionId', allowEmpty: false),
      answer: json['answer'] == null
          ? null
          : GatewaySchemaWizardNextParamsAnswer.fromJson(
              asJsonMap(json['answer'], context: 'WizardNextParams.answer')),
    );
  }

  final String sessionId;
  final GatewaySchemaWizardNextParamsAnswer? answer;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionId': sessionId,
      'answer': answer?.toJson(),
    });
  }
}

class GatewaySchemaWizardNextResultStepOptionsItem {
  const GatewaySchemaWizardNextResultStepOptionsItem({
    this.value,
    required this.label,
    this.hint,
  });

  factory GatewaySchemaWizardNextResultStepOptionsItem.fromJson(JsonMap json) {
    return GatewaySchemaWizardNextResultStepOptionsItem(
      value: json['value'],
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaWizardNextResultStep.optionsItem.label',
          allowEmpty: false),
      hint: _generatedReadNullableString(json['hint'], allowEmpty: true),
    );
  }

  final Object? value;
  final String label;
  final String? hint;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'value': value,
      'label': label,
      'hint': hint,
    });
  }
}

class GatewaySchemaWizardNextResultStep {
  const GatewaySchemaWizardNextResultStep({
    required this.id,
    required this.type,
    this.title,
    this.message,
    this.options,
    this.initialValue,
    this.placeholder,
    this.sensitive,
    this.executor,
  });

  factory GatewaySchemaWizardNextResultStep.fromJson(JsonMap json) {
    return GatewaySchemaWizardNextResultStep(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaWizardNextResult.step.id', allowEmpty: false),
      type: _generatedReadRequiredString(json, 'type',
          context: 'GatewaySchemaWizardNextResult.step.type', allowEmpty: true),
      title: _generatedReadNullableString(json['title'], allowEmpty: true),
      message: _generatedReadNullableString(json['message'], allowEmpty: true),
      options: json['options'] == null
          ? null
          : asJsonList(json['options'],
                  context: 'GatewaySchemaWizardNextResult.step.options')
              .map((entry) => GatewaySchemaWizardNextResultStepOptionsItem
                  .fromJson(asJsonMap(entry,
                      context: 'GatewaySchemaWizardNextResult.step.options[]')))
              .toList(growable: false),
      initialValue: json['initialValue'],
      placeholder:
          _generatedReadNullableString(json['placeholder'], allowEmpty: true),
      sensitive: readNullableBool(json['sensitive']),
      executor:
          _generatedReadNullableString(json['executor'], allowEmpty: true),
    );
  }

  final String id;
  final String type;
  final String? title;
  final String? message;
  final List<GatewaySchemaWizardNextResultStepOptionsItem>? options;
  final Object? initialValue;
  final String? placeholder;
  final bool? sensitive;
  final String? executor;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'options':
          options?.map((entry) => entry.toJson()).toList(growable: false),
      'initialValue': initialValue,
      'placeholder': placeholder,
      'sensitive': sensitive,
      'executor': executor,
    });
  }
}

class GatewaySchemaWizardNextResult {
  const GatewaySchemaWizardNextResult({
    required this.done,
    this.step,
    this.status,
    this.error,
  });

  factory GatewaySchemaWizardNextResult.fromJson(JsonMap json) {
    return GatewaySchemaWizardNextResult(
      done: readRequiredBool(json, 'done', context: 'WizardNextResult.done'),
      step: json['step'] == null
          ? null
          : GatewaySchemaWizardNextResultStep.fromJson(
              asJsonMap(json['step'], context: 'WizardNextResult.step')),
      status: _generatedReadNullableString(json['status'], allowEmpty: true),
      error: _generatedReadNullableString(json['error'], allowEmpty: true),
    );
  }

  final bool done;
  final GatewaySchemaWizardNextResultStep? step;
  final String? status;
  final String? error;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'done': done,
      'step': step?.toJson(),
      'status': status,
      'error': error,
    });
  }
}

class GatewaySchemaWizardStartParams {
  const GatewaySchemaWizardStartParams({
    this.mode,
    this.workspace,
  });

  factory GatewaySchemaWizardStartParams.fromJson(JsonMap json) {
    return GatewaySchemaWizardStartParams(
      mode: _generatedReadNullableString(json['mode'], allowEmpty: true),
      workspace:
          _generatedReadNullableString(json['workspace'], allowEmpty: true),
    );
  }

  final String? mode;
  final String? workspace;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'mode': mode,
      'workspace': workspace,
    });
  }
}

class GatewaySchemaWizardStartResultStepOptionsItem {
  const GatewaySchemaWizardStartResultStepOptionsItem({
    this.value,
    required this.label,
    this.hint,
  });

  factory GatewaySchemaWizardStartResultStepOptionsItem.fromJson(JsonMap json) {
    return GatewaySchemaWizardStartResultStepOptionsItem(
      value: json['value'],
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaWizardStartResultStep.optionsItem.label',
          allowEmpty: false),
      hint: _generatedReadNullableString(json['hint'], allowEmpty: true),
    );
  }

  final Object? value;
  final String label;
  final String? hint;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'value': value,
      'label': label,
      'hint': hint,
    });
  }
}

class GatewaySchemaWizardStartResultStep {
  const GatewaySchemaWizardStartResultStep({
    required this.id,
    required this.type,
    this.title,
    this.message,
    this.options,
    this.initialValue,
    this.placeholder,
    this.sensitive,
    this.executor,
  });

  factory GatewaySchemaWizardStartResultStep.fromJson(JsonMap json) {
    return GatewaySchemaWizardStartResultStep(
      id: _generatedReadRequiredString(json, 'id',
          context: 'GatewaySchemaWizardStartResult.step.id', allowEmpty: false),
      type: _generatedReadRequiredString(json, 'type',
          context: 'GatewaySchemaWizardStartResult.step.type',
          allowEmpty: true),
      title: _generatedReadNullableString(json['title'], allowEmpty: true),
      message: _generatedReadNullableString(json['message'], allowEmpty: true),
      options: json['options'] == null
          ? null
          : asJsonList(json['options'],
                  context: 'GatewaySchemaWizardStartResult.step.options')
              .map((entry) =>
                  GatewaySchemaWizardStartResultStepOptionsItem.fromJson(
                      asJsonMap(entry,
                          context:
                              'GatewaySchemaWizardStartResult.step.options[]')))
              .toList(growable: false),
      initialValue: json['initialValue'],
      placeholder:
          _generatedReadNullableString(json['placeholder'], allowEmpty: true),
      sensitive: readNullableBool(json['sensitive']),
      executor:
          _generatedReadNullableString(json['executor'], allowEmpty: true),
    );
  }

  final String id;
  final String type;
  final String? title;
  final String? message;
  final List<GatewaySchemaWizardStartResultStepOptionsItem>? options;
  final Object? initialValue;
  final String? placeholder;
  final bool? sensitive;
  final String? executor;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'options':
          options?.map((entry) => entry.toJson()).toList(growable: false),
      'initialValue': initialValue,
      'placeholder': placeholder,
      'sensitive': sensitive,
      'executor': executor,
    });
  }
}

class GatewaySchemaWizardStartResult {
  const GatewaySchemaWizardStartResult({
    required this.sessionId,
    required this.done,
    this.step,
    this.status,
    this.error,
  });

  factory GatewaySchemaWizardStartResult.fromJson(JsonMap json) {
    return GatewaySchemaWizardStartResult(
      sessionId: _generatedReadRequiredString(json, 'sessionId',
          context: 'WizardStartResult.sessionId', allowEmpty: false),
      done: readRequiredBool(json, 'done', context: 'WizardStartResult.done'),
      step: json['step'] == null
          ? null
          : GatewaySchemaWizardStartResultStep.fromJson(
              asJsonMap(json['step'], context: 'WizardStartResult.step')),
      status: _generatedReadNullableString(json['status'], allowEmpty: true),
      error: _generatedReadNullableString(json['error'], allowEmpty: true),
    );
  }

  final String sessionId;
  final bool done;
  final GatewaySchemaWizardStartResultStep? step;
  final String? status;
  final String? error;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionId': sessionId,
      'done': done,
      'step': step?.toJson(),
      'status': status,
      'error': error,
    });
  }
}

class GatewaySchemaWizardStatusParams {
  const GatewaySchemaWizardStatusParams({
    required this.sessionId,
  });

  factory GatewaySchemaWizardStatusParams.fromJson(JsonMap json) {
    return GatewaySchemaWizardStatusParams(
      sessionId: _generatedReadRequiredString(json, 'sessionId',
          context: 'WizardStatusParams.sessionId', allowEmpty: false),
    );
  }

  final String sessionId;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'sessionId': sessionId,
    });
  }
}

class GatewaySchemaWizardStatusResult {
  const GatewaySchemaWizardStatusResult({
    required this.status,
    this.error,
  });

  factory GatewaySchemaWizardStatusResult.fromJson(JsonMap json) {
    return GatewaySchemaWizardStatusResult(
      status: _generatedReadRequiredString(json, 'status',
          context: 'WizardStatusResult.status', allowEmpty: true),
      error: _generatedReadNullableString(json['error'], allowEmpty: true),
    );
  }

  final String status;
  final String? error;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'status': status,
      'error': error,
    });
  }
}

class GatewaySchemaWizardStepOptionsItem {
  const GatewaySchemaWizardStepOptionsItem({
    this.value,
    required this.label,
    this.hint,
  });

  factory GatewaySchemaWizardStepOptionsItem.fromJson(JsonMap json) {
    return GatewaySchemaWizardStepOptionsItem(
      value: json['value'],
      label: _generatedReadRequiredString(json, 'label',
          context: 'GatewaySchemaWizardStep.optionsItem.label',
          allowEmpty: false),
      hint: _generatedReadNullableString(json['hint'], allowEmpty: true),
    );
  }

  final Object? value;
  final String label;
  final String? hint;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'value': value,
      'label': label,
      'hint': hint,
    });
  }
}

class GatewaySchemaWizardStep {
  const GatewaySchemaWizardStep({
    required this.id,
    required this.type,
    this.title,
    this.message,
    this.options,
    this.initialValue,
    this.placeholder,
    this.sensitive,
    this.executor,
  });

  factory GatewaySchemaWizardStep.fromJson(JsonMap json) {
    return GatewaySchemaWizardStep(
      id: _generatedReadRequiredString(json, 'id',
          context: 'WizardStep.id', allowEmpty: false),
      type: _generatedReadRequiredString(json, 'type',
          context: 'WizardStep.type', allowEmpty: true),
      title: _generatedReadNullableString(json['title'], allowEmpty: true),
      message: _generatedReadNullableString(json['message'], allowEmpty: true),
      options: json['options'] == null
          ? null
          : asJsonList(json['options'], context: 'WizardStep.options')
              .map((entry) => GatewaySchemaWizardStepOptionsItem.fromJson(
                  asJsonMap(entry, context: 'WizardStep.options[]')))
              .toList(growable: false),
      initialValue: json['initialValue'],
      placeholder:
          _generatedReadNullableString(json['placeholder'], allowEmpty: true),
      sensitive: readNullableBool(json['sensitive']),
      executor:
          _generatedReadNullableString(json['executor'], allowEmpty: true),
    );
  }

  final String id;
  final String type;
  final String? title;
  final String? message;
  final List<GatewaySchemaWizardStepOptionsItem>? options;
  final Object? initialValue;
  final String? placeholder;
  final bool? sensitive;
  final String? executor;

  JsonMap toJson() {
    return withoutNulls(<String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'options':
          options?.map((entry) => entry.toJson()).toList(growable: false),
      'initialValue': initialValue,
      'placeholder': placeholder,
      'sensitive': sensitive,
      'executor': executor,
    });
  }
}

String _generatedReadRequiredString(
  JsonMap json,
  String key, {
  required String context,
  required bool allowEmpty,
}) {
  final value = json[key];
  if (value is String && (allowEmpty || value.isNotEmpty)) {
    return value;
  }
  throw GatewayProtocolException('Missing or invalid "$key" in $context.');
}

String? _generatedReadNullableString(
  Object? value, {
  required bool allowEmpty,
}) {
  if (value is String && (allowEmpty || value.isNotEmpty)) {
    return value;
  }
  return null;
}

Object? _generatedReadRequiredValue(
  JsonMap json,
  String key, {
  required String context,
}) {
  if (!json.containsKey(key)) {
    throw GatewayProtocolException('Missing or invalid "$key" in $context.');
  }
  return json[key];
}

num? _generatedReadNullableNum(Object? value) {
  if (value is num) {
    return value;
  }
  return null;
}

num _generatedReadRequiredNum(
  JsonMap json,
  String key, {
  required String context,
}) {
  final value = _generatedReadNullableNum(json[key]);
  if (value != null) {
    return value;
  }
  throw GatewayProtocolException('Missing or invalid "$key" in $context.');
}

String _generatedReadItemString(
  Object? value, {
  required String context,
}) {
  if (value is String) {
    return value;
  }
  throw GatewayProtocolException('Expected string in $context.');
}

int _generatedReadItemInt(
  Object? value, {
  required String context,
}) {
  final intValue = readNullableInt(value);
  if (intValue != null) {
    return intValue;
  }
  throw GatewayProtocolException('Expected int in $context.');
}

num _generatedReadItemNum(
  Object? value, {
  required String context,
}) {
  final numValue = _generatedReadNullableNum(value);
  if (numValue != null) {
    return numValue;
  }
  throw GatewayProtocolException('Expected num in $context.');
}

bool _generatedReadItemBool(
  Object? value, {
  required String context,
}) {
  final boolValue = readNullableBool(value);
  if (boolValue != null) {
    return boolValue;
  }
  throw GatewayProtocolException('Expected bool in $context.');
}
