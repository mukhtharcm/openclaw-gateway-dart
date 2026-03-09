import 'dart:convert';

import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Typed `chat.history` response payload.
class GatewayChatHistoryResult {
  const GatewayChatHistoryResult({
    required this.sessionKey,
    required this.messages,
    required this.raw,
    this.sessionId,
    this.thinkingLevel,
    this.verboseLevel,
  });

  factory GatewayChatHistoryResult.fromJson(JsonMap json) {
    return GatewayChatHistoryResult(
      sessionKey:
          readRequiredString(json, 'sessionKey', context: 'chat.history'),
      sessionId: readNullableString(json['sessionId']),
      messages: json['messages'] == null
          ? const <GatewayChatMessage>[]
          : asJsonList(json['messages'], context: 'chat.history.messages')
              .map(
                (entry) => GatewayChatMessage.fromJsonValue(
                  entry,
                  context: 'chat.history.messages[]',
                ),
              )
              .toList(growable: false),
      thinkingLevel: readNullableString(json['thinkingLevel']),
      verboseLevel: readNullableString(json['verboseLevel']),
      raw: json,
    );
  }

  final String sessionKey;
  final String? sessionId;
  final List<GatewayChatMessage> messages;
  final String? thinkingLevel;
  final String? verboseLevel;
  final JsonMap raw;
}

/// Typed `chat.send` acknowledgement payload.
class GatewayChatSendResult {
  const GatewayChatSendResult({
    required this.runId,
    required this.status,
    required this.raw,
  });

  factory GatewayChatSendResult.fromJson(JsonMap json) {
    return GatewayChatSendResult(
      runId: readRequiredString(json, 'runId', context: 'chat.send'),
      status: readRequiredString(json, 'status', context: 'chat.send'),
      raw: json,
    );
  }

  final String runId;
  final String status;
  final JsonMap raw;

  bool get isInFlight => status == 'in_flight';
}

/// Typed `chat.abort` response payload.
class GatewayChatAbortResult {
  const GatewayChatAbortResult({
    required this.ok,
    required this.aborted,
    required this.runIds,
    required this.raw,
  });

  factory GatewayChatAbortResult.fromJson(JsonMap json) {
    return GatewayChatAbortResult(
      ok: readRequiredBool(json, 'ok', context: 'chat.abort'),
      aborted: readRequiredBool(json, 'aborted', context: 'chat.abort'),
      runIds: json['runIds'] == null
          ? const <String>[]
          : readStringList(json['runIds'], context: 'chat.abort.runIds'),
      raw: json,
    );
  }

  final bool ok;
  final bool aborted;
  final List<String> runIds;
  final JsonMap raw;
}

/// Typed chat transcript entry used by `chat.history`.
class GatewayChatMessage {
  const GatewayChatMessage({
    required this.role,
    required this.content,
    required this.raw,
    this.timestamp,
    this.toolCallId,
    this.toolName,
    this.usage,
    this.stopReason,
  });

  factory GatewayChatMessage.fromJson(JsonMap json) {
    final content = json['content'];
    return GatewayChatMessage(
      role: readRequiredString(json, 'role', context: 'chat message'),
      content: _readChatMessageContent(content),
      timestamp: _readNullableDouble(json['timestamp']),
      toolCallId: readNullableString(json['toolCallId']) ??
          readNullableString(json['tool_call_id']),
      toolName: readNullableString(json['toolName']) ??
          readNullableString(json['tool_name']),
      usage: json['usage'] == null
          ? null
          : GatewayChatUsage.fromJson(
              asJsonMap(json['usage'], context: 'chat message.usage'),
            ),
      stopReason: readNullableString(json['stopReason']),
      raw: json,
    );
  }

  factory GatewayChatMessage.fromJsonValue(
    Object? value, {
    required String context,
  }) {
    if (value is String) {
      return GatewayChatMessage(
        role: 'assistant',
        content: <GatewayChatMessageContent>[
          GatewayChatMessageContent.text(value),
        ],
        raw: <String, Object?>{
          'role': 'assistant',
          'content': value,
        },
      );
    }
    return GatewayChatMessage.fromJson(asJsonMap(value, context: context));
  }

  final String role;
  final List<GatewayChatMessageContent> content;
  final double? timestamp;
  final String? toolCallId;
  final String? toolName;
  final GatewayChatUsage? usage;
  final String? stopReason;
  final JsonMap raw;

  String get normalizedRole => role.trim().toLowerCase();

  String get primaryText => content
      .where((part) => part.isTextLike)
      .map((part) => part.text?.trim())
      .whereType<String>()
      .where((text) => text.isNotEmpty)
      .join('\n\n');

  bool get hasVisibleText => primaryText.isNotEmpty;

  bool get hasAttachments => content.any((part) => part.isAttachment);

  String get identityKey {
    final timestampKey = timestamp == null ? '' : timestamp!.toStringAsFixed(3);
    final contentKey = content.map((part) => part.identityKey).join('\u001E');
    return [
      normalizedRole,
      timestampKey,
      toolCallId ?? '',
      toolName ?? '',
      contentKey,
    ].join('|');
  }
}

/// Structured content block inside a chat transcript entry.
class GatewayChatMessageContent {
  const GatewayChatMessageContent({
    required this.raw,
    this.type,
    this.text,
    this.thinking,
    this.thinkingSignature,
    this.mimeType,
    this.fileName,
    this.content,
    this.id,
    this.name,
    this.arguments,
  });

  const GatewayChatMessageContent.text(this.text)
      : raw = const <String, Object?>{'type': 'text'},
        type = 'text',
        thinking = null,
        thinkingSignature = null,
        mimeType = null,
        fileName = null,
        content = null,
        id = null,
        name = null,
        arguments = null;

  factory GatewayChatMessageContent.fromJson(JsonMap json) {
    return GatewayChatMessageContent(
      raw: json,
      type: readNullableString(json['type']),
      text: readNullableString(json['text']),
      thinking: readNullableString(json['thinking']),
      thinkingSignature: readNullableString(json['thinkingSignature']),
      mimeType: readNullableString(json['mimeType']),
      fileName: readNullableString(json['fileName']),
      content: json['content'],
      id: readNullableString(json['id']),
      name: readNullableString(json['name']),
      arguments: json['arguments'],
    );
  }

  final JsonMap raw;
  final String? type;
  final String? text;
  final String? thinking;
  final String? thinkingSignature;
  final String? mimeType;
  final String? fileName;
  final Object? content;
  final String? id;
  final String? name;
  final Object? arguments;

  String get normalizedType => (type ?? 'text').trim().toLowerCase();

  bool get isTextLike => normalizedType == 'text' || normalizedType.isEmpty;

  bool get isAttachment =>
      normalizedType == 'attachment' ||
      normalizedType == 'file' ||
      normalizedType == 'image';

  bool get isToolCall =>
      const <String>{'toolcall', 'tool_call', 'tooluse', 'tool_use'}.contains(
        normalizedType,
      ) ||
      (name != null && arguments != null);

  bool get isToolResult =>
      normalizedType == 'toolresult' || normalizedType == 'tool_result';

  String get identityKey => [
        normalizedType,
        text?.trim() ?? '',
        thinking?.trim() ?? '',
        thinkingSignature?.trim() ?? '',
        mimeType?.trim() ?? '',
        fileName?.trim() ?? '',
        id?.trim() ?? '',
        name?.trim() ?? '',
      ].join('\u001F');
}

class GatewayChatUsageCost {
  const GatewayChatUsageCost({
    this.input,
    this.output,
    this.cacheRead,
    this.cacheWrite,
    this.total,
  });

  factory GatewayChatUsageCost.fromJson(JsonMap json) {
    return GatewayChatUsageCost(
      input: _readNullableDouble(json['input']),
      output: _readNullableDouble(json['output']),
      cacheRead: _readNullableDouble(json['cacheRead']),
      cacheWrite: _readNullableDouble(json['cacheWrite']),
      total: _readNullableDouble(json['total']),
    );
  }

  final double? input;
  final double? output;
  final double? cacheRead;
  final double? cacheWrite;
  final double? total;
}

class GatewayChatUsage {
  const GatewayChatUsage({
    this.input,
    this.output,
    this.cacheRead,
    this.cacheWrite,
    this.cost,
    this.total,
  });

  factory GatewayChatUsage.fromJson(JsonMap json) {
    return GatewayChatUsage(
      input: readNullableInt(json['input']),
      output: readNullableInt(json['output']),
      cacheRead: readNullableInt(json['cacheRead']),
      cacheWrite: readNullableInt(json['cacheWrite']),
      cost: json['cost'] == null
          ? null
          : GatewayChatUsageCost.fromJson(
              asJsonMap(json['cost'], context: 'chat usage.cost'),
            ),
      total: readNullableInt(json['total']) ??
          readNullableInt(json['totalTokens']),
    );
  }

  final int? input;
  final int? output;
  final int? cacheRead;
  final int? cacheWrite;
  final GatewayChatUsageCost? cost;
  final int? total;
}

/// Typed payload for the gateway `chat` event stream.
class GatewayChatEvent {
  const GatewayChatEvent({
    required this.runId,
    required this.sessionKey,
    required this.seq,
    required this.state,
    this.message,
    this.errorMessage,
    this.usage,
    this.stopReason,
  });

  factory GatewayChatEvent.fromJson(JsonMap json) {
    return GatewayChatEvent(
      runId: readRequiredString(json, 'runId', context: 'chat event'),
      sessionKey: readRequiredString(json, 'sessionKey', context: 'chat event'),
      seq: readRequiredInt(json, 'seq', context: 'chat event'),
      state: readRequiredString(json, 'state', context: 'chat event'),
      message: json['message'],
      errorMessage: readNullableString(json['errorMessage']),
      usage: json['usage'],
      stopReason: readNullableString(json['stopReason']),
    );
  }

  factory GatewayChatEvent.fromEventFrame(GatewayEventFrame frame) {
    if (frame.event != 'chat') {
      throw GatewayProtocolException(
        'Expected "chat" event frame, got "${frame.event}".',
      );
    }
    return GatewayChatEvent.fromJson(
      asJsonMap(frame.payload, context: 'chat event payload'),
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

  bool get isTerminal => state != 'delta';

  bool matchesSessionKey(String currentSessionKey) =>
      gatewayChatSessionKeysMatch(
          incoming: sessionKey, current: currentSessionKey);
}

/// Returns true when two session keys refer to the same operator chat session.
///
/// The gateway sometimes emits canonical keys like `agent:main:main` while UI
/// clients still refer to the same session as `main`.
bool gatewayChatSessionKeysMatch({
  required String incoming,
  required String current,
}) {
  final incomingNormalized = incoming.trim().toLowerCase();
  final currentNormalized = current.trim().toLowerCase();
  if (incomingNormalized == currentNormalized) {
    return true;
  }
  return (incomingNormalized == 'agent:main:main' &&
          currentNormalized == 'main') ||
      (incomingNormalized == 'main' && currentNormalized == 'agent:main:main');
}

List<GatewayChatMessageContent> _readChatMessageContent(Object? rawContent) {
  if (rawContent == null) {
    return const <GatewayChatMessageContent>[];
  }
  if (rawContent is String) {
    return <GatewayChatMessageContent>[
      GatewayChatMessageContent.text(rawContent)
    ];
  }
  return asJsonList(rawContent, context: 'chat message.content').map((entry) {
    if (entry is String) {
      return GatewayChatMessageContent.text(entry);
    }
    return GatewayChatMessageContent.fromJson(
      asJsonMap(entry, context: 'chat message.content[]'),
    );
  }).toList(growable: false);
}

double? _readNullableDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

String debugChatMessage(Object? value) {
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}
