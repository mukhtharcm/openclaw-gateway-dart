import 'package:openclaw_gateway/src/protocol.dart';

/// Authentication payload sent during the gateway `connect` request.
class GatewayAuth {
  const GatewayAuth._({
    this.token,
    this.password,
    this.deviceToken,
  });

  /// No authentication fields.
  const GatewayAuth.none() : this._();

  /// Shared gateway token authentication.
  const GatewayAuth.token(String token) : this._(token: token);

  /// Password authentication.
  const GatewayAuth.password(String password) : this._(password: password);

  /// Previously issued device token authentication.
  const GatewayAuth.deviceToken(String deviceToken)
      : this._(deviceToken: deviceToken);

  /// Shared token plus previously issued device token authentication.
  const GatewayAuth.tokenAndDeviceToken({
    required String token,
    required String deviceToken,
  }) : this._(
          token: token,
          deviceToken: deviceToken,
        );

  final String? token;
  final String? password;
  final String? deviceToken;

  /// Serializes the auth payload for the `connect` request.
  JsonMap? toJson() {
    final json = withoutNulls({
      'token': token?.trim().isNotEmpty == true ? token : null,
      'password': password?.trim().isNotEmpty == true ? password : null,
      'deviceToken':
          deviceToken?.trim().isNotEmpty == true ? deviceToken : null,
    });
    return json.isEmpty ? null : json;
  }
}
