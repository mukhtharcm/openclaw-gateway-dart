import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Typed wrappers for common operator-side gateway methods.
class GatewayOperatorClient {
  const GatewayOperatorClient(this._client);

  final GatewayClient _client;

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

  /// Calls `config.get`.
  Future<JsonMap> configGet() {
    return _client.requestJsonMap('config.get');
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
}
