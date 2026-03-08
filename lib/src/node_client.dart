import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/node_models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Node-role helpers for handling node invokes and node-originated events.
class GatewayNodeClient {
  const GatewayNodeClient(this._client);

  final GatewayClient _client;

  Stream<GatewayNodeInvokeRequest> get invokeRequests => _client
      .eventsNamed('node.invoke.request')
      .map(GatewayNodeInvokeRequest.fromEventFrame);

  Future<JsonMap> sendEvent({
    required String event,
    Object? payload,
    String? payloadJson,
  }) {
    return _client.requestJsonMap(
      'node.event',
      params: withoutNulls({
        'event': event,
        'payload': payload,
        'payloadJSON': payloadJson,
      }),
    );
  }

  Future<JsonMap> sendInvokeResult({
    required String id,
    required String nodeId,
    required bool ok,
    Object? payload,
    String? payloadJson,
    GatewayNodeInvokeError? error,
  }) {
    return _client.requestJsonMap(
      'node.invoke.result',
      params: withoutNulls({
        'id': id,
        'nodeId': nodeId,
        'ok': ok,
        'payload': payload,
        'payloadJSON': payloadJson,
        'error': error?.toJson(),
      }),
    );
  }

  Future<GatewayCanvasCapabilityRefreshResult> refreshCanvasCapability() async {
    final payload = await _client.requestJsonMap(
      'node.canvas.capability.refresh',
      params: const <String, Object?>{},
    );
    return GatewayCanvasCapabilityRefreshResult.fromJson(payload);
  }
}
