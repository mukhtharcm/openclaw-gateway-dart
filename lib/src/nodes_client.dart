import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/node_models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Operator-side node management and invoke helpers.
class GatewayNodesClient {
  const GatewayNodesClient(this._client);

  final GatewayClient _client;

  Future<JsonMap> pairRequest({
    required String nodeId,
    String? displayName,
    String? platform,
    String? version,
    String? coreVersion,
    String? uiVersion,
    String? deviceFamily,
    String? modelIdentifier,
    List<String>? caps,
    List<String>? commands,
    String? remoteIp,
    bool? silent,
  }) {
    return _client.requestJsonMap(
      'node.pair.request',
      params: withoutNulls({
        'nodeId': nodeId,
        'displayName': displayName,
        'platform': platform,
        'version': version,
        'coreVersion': coreVersion,
        'uiVersion': uiVersion,
        'deviceFamily': deviceFamily,
        'modelIdentifier': modelIdentifier,
        'caps': caps,
        'commands': commands,
        'remoteIp': remoteIp,
        'silent': silent,
      }),
    );
  }

  Future<JsonMap> pairList() {
    return _client.requestJsonMap('node.pair.list');
  }

  Future<JsonMap> pairApprove({
    required String requestId,
  }) {
    return _client.requestJsonMap(
      'node.pair.approve',
      params: <String, Object?>{
        'requestId': requestId,
      },
    );
  }

  Future<JsonMap> pairReject({
    required String requestId,
  }) {
    return _client.requestJsonMap(
      'node.pair.reject',
      params: <String, Object?>{
        'requestId': requestId,
      },
    );
  }

  Future<JsonMap> pairVerify({
    required String nodeId,
    required String token,
  }) {
    return _client.requestJsonMap(
      'node.pair.verify',
      params: <String, Object?>{
        'nodeId': nodeId,
        'token': token,
      },
    );
  }

  Future<JsonMap> rename({
    required String nodeId,
    required String displayName,
  }) {
    return _client.requestJsonMap(
      'node.rename',
      params: <String, Object?>{
        'nodeId': nodeId,
        'displayName': displayName,
      },
    );
  }

  Future<List<GatewayNodeSummary>> list() async {
    final payload = await _client.requestJsonMap('node.list');
    final nodes = asJsonList(payload['nodes'], context: 'node.list.nodes');
    return nodes
        .map(
          (node) => GatewayNodeSummary.fromJson(
              asJsonMap(node, context: 'node.list')),
        )
        .toList(growable: false);
  }

  Future<GatewayNodeSummary> describe({
    required String nodeId,
  }) async {
    final payload = await _client.requestJsonMap(
      'node.describe',
      params: <String, Object?>{
        'nodeId': nodeId,
      },
    );
    return GatewayNodeSummary.fromJson(payload);
  }

  Future<GatewayNodeInvokeResult> invoke({
    required String nodeId,
    required String command,
    Object? params,
    int? timeoutMs,
    String? idempotencyKey,
  }) async {
    final payload = await _client.requestJsonMap(
      'node.invoke',
      params: withoutNulls({
        'nodeId': nodeId,
        'command': command,
        'params': params,
        'timeoutMs': timeoutMs,
        'idempotencyKey':
            idempotencyKey ?? _client.createIdempotencyKey(prefix: 'node'),
      }),
    );
    return GatewayNodeInvokeResult.fromJson(payload);
  }
}
