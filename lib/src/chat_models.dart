import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

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
}
