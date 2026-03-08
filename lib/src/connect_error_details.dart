import 'package:openclaw_gateway/src/protocol.dart';

/// Detail codes returned by gateway connect failures.
abstract final class GatewayConnectErrorDetailCodes {
  static const String authRequired = 'AUTH_REQUIRED';
  static const String authUnauthorized = 'AUTH_UNAUTHORIZED';
  static const String authTokenMissing = 'AUTH_TOKEN_MISSING';
  static const String authTokenMismatch = 'AUTH_TOKEN_MISMATCH';
  static const String authTokenNotConfigured = 'AUTH_TOKEN_NOT_CONFIGURED';
  static const String authPasswordMissing = 'AUTH_PASSWORD_MISSING';
  static const String authPasswordMismatch = 'AUTH_PASSWORD_MISMATCH';
  static const String authPasswordNotConfigured =
      'AUTH_PASSWORD_NOT_CONFIGURED';
  static const String authDeviceTokenMismatch = 'AUTH_DEVICE_TOKEN_MISMATCH';
  static const String authRateLimited = 'AUTH_RATE_LIMITED';
  static const String authTailscaleIdentityMissing =
      'AUTH_TAILSCALE_IDENTITY_MISSING';
  static const String authTailscaleProxyMissing =
      'AUTH_TAILSCALE_PROXY_MISSING';
  static const String authTailscaleWhoisFailed = 'AUTH_TAILSCALE_WHOIS_FAILED';
  static const String authTailscaleIdentityMismatch =
      'AUTH_TAILSCALE_IDENTITY_MISMATCH';
  static const String controlUiDeviceIdentityRequired =
      'CONTROL_UI_DEVICE_IDENTITY_REQUIRED';
  static const String deviceIdentityRequired = 'DEVICE_IDENTITY_REQUIRED';
  static const String deviceAuthInvalid = 'DEVICE_AUTH_INVALID';
  static const String deviceAuthDeviceIdMismatch =
      'DEVICE_AUTH_DEVICE_ID_MISMATCH';
  static const String deviceAuthSignatureExpired =
      'DEVICE_AUTH_SIGNATURE_EXPIRED';
  static const String deviceAuthNonceRequired = 'DEVICE_AUTH_NONCE_REQUIRED';
  static const String deviceAuthNonceMismatch = 'DEVICE_AUTH_NONCE_MISMATCH';
  static const String deviceAuthSignatureInvalid =
      'DEVICE_AUTH_SIGNATURE_INVALID';
  static const String deviceAuthPublicKeyInvalid =
      'DEVICE_AUTH_PUBLIC_KEY_INVALID';
  static const String pairingRequired = 'PAIRING_REQUIRED';
}

/// Reads the gateway connect detail code from a response error details payload.
String? readGatewayConnectErrorDetailCode(Object? details) {
  if (details is! Map) {
    return null;
  }
  final json = asJsonMap(details, context: 'response.error.details');
  return readNullableString(json['code']);
}
