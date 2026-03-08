import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Operator-side device pairing and device-token helpers.
class GatewayDevicesClient {
  const GatewayDevicesClient(this._client);

  final GatewayClient _client;

  Future<JsonMap> pairList() {
    return _client.requestJsonMap('device.pair.list');
  }

  Future<JsonMap> pairApprove({
    required String requestId,
  }) {
    return _client.requestJsonMap(
      'device.pair.approve',
      params: <String, Object?>{
        'requestId': requestId,
      },
    );
  }

  Future<JsonMap> pairReject({
    required String requestId,
  }) {
    return _client.requestJsonMap(
      'device.pair.reject',
      params: <String, Object?>{
        'requestId': requestId,
      },
    );
  }

  Future<JsonMap> pairRemove({
    required String deviceId,
  }) {
    return _client.requestJsonMap(
      'device.pair.remove',
      params: <String, Object?>{
        'deviceId': deviceId,
      },
    );
  }

  Future<JsonMap> tokenRotate({
    required String deviceId,
    required String role,
    List<String>? scopes,
  }) {
    return _client.requestJsonMap(
      'device.token.rotate',
      params: withoutNulls({
        'deviceId': deviceId,
        'role': role,
        'scopes': scopes,
      }),
    );
  }

  Future<JsonMap> tokenRevoke({
    required String deviceId,
    required String role,
  }) {
    return _client.requestJsonMap(
      'device.token.revoke',
      params: <String, Object?>{
        'deviceId': deviceId,
        'role': role,
      },
    );
  }
}
