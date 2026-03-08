import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

class GatewayPreparedConnectParams {
  const GatewayPreparedConnectParams({
    required this.params,
    required this.usesSharedCredential,
    required this.usesDeviceTokenOnly,
  });

  final JsonMap params;
  final bool usesSharedCredential;
  final bool usesDeviceTokenOnly;
}

Future<GatewayPreparedConnectParams> prepareGatewayConnectParams({
  required GatewayConnectOptions options,
  required String nonce,
}) async {
  if (nonce.isEmpty) {
    throw GatewayProtocolException('Gateway connect nonce was empty.');
  }

  final resolvedAuth = await _resolveGatewayConnectAuth(options);
  final params = withoutNulls({
    'minProtocol': gatewayProtocolVersion,
    'maxProtocol': gatewayProtocolVersion,
    'client': options.clientInfo.toJson(),
    'caps': options.caps.isEmpty ? null : options.caps,
    'commands': options.commands.isEmpty ? null : options.commands,
    'permissions': options.permissions.isEmpty ? null : options.permissions,
    'pathEnv': options.pathEnv,
    'role': options.role,
    'scopes': options.scopes.isEmpty ? null : options.scopes,
    'auth': resolvedAuth.authJson,
    'locale': options.locale,
    'userAgent': options.userAgent,
    'device': await _buildDevicePayload(
      options: options,
      nonce: nonce,
      signatureToken: resolvedAuth.signatureToken,
    ),
  });

  return GatewayPreparedConnectParams(
    params: params,
    usesSharedCredential: resolvedAuth.usesSharedCredential,
    usesDeviceTokenOnly: !resolvedAuth.usesSharedCredential &&
        resolvedAuth.resolvedDeviceToken != null,
  );
}

class _GatewayResolvedConnectAuth {
  const _GatewayResolvedConnectAuth({
    required this.authJson,
    required this.signatureToken,
    required this.usesSharedCredential,
    required this.resolvedDeviceToken,
  });

  final JsonMap? authJson;
  final String? signatureToken;
  final bool usesSharedCredential;
  final String? resolvedDeviceToken;
}

Future<_GatewayResolvedConnectAuth> _resolveGatewayConnectAuth(
  GatewayConnectOptions options,
) async {
  final explicitToken = _trimToUndefined(options.auth.token);
  final explicitPassword = _trimToUndefined(options.auth.password);
  final explicitDeviceToken = _trimToUndefined(options.auth.deviceToken);

  if (options.deviceIdentity == null) {
    return _GatewayResolvedConnectAuth(
      authJson: options.auth.toJson(),
      signatureToken: explicitToken,
      usesSharedCredential: explicitToken != null || explicitPassword != null,
      resolvedDeviceToken: explicitDeviceToken,
    );
  }

  final storedDeviceToken = await options.deviceTokenStore?.read(
    deviceId: options.deviceIdentity!.deviceId,
    role: options.role,
  );
  final resolvedDeviceToken = explicitDeviceToken ??
      (explicitToken == null ? storedDeviceToken?.token : null);
  final authToken = explicitToken ?? resolvedDeviceToken;
  final authJson = withoutNulls({
    'token': authToken,
    'deviceToken': resolvedDeviceToken,
    'password': explicitPassword,
  });

  return _GatewayResolvedConnectAuth(
    authJson: authJson.isEmpty ? null : authJson,
    signatureToken: authToken,
    usesSharedCredential: explicitToken != null || explicitPassword != null,
    resolvedDeviceToken: resolvedDeviceToken,
  );
}

Future<JsonMap?> _buildDevicePayload({
  required GatewayConnectOptions options,
  required String nonce,
  required String? signatureToken,
}) async {
  final deviceIdentity = options.deviceIdentity;
  if (deviceIdentity == null) {
    return null;
  }

  final signedAtMs = DateTime.now().millisecondsSinceEpoch;
  final payload = buildDeviceAuthPayloadV3(
    deviceId: deviceIdentity.deviceId,
    clientId: options.clientInfo.id,
    clientMode: options.clientInfo.mode,
    role: options.role,
    scopes: options.scopes,
    signedAtMs: signedAtMs,
    token: signatureToken,
    nonce: nonce,
    platform: options.clientInfo.platform,
    deviceFamily: options.clientInfo.deviceFamily,
  );
  final signature = await deviceIdentity.signPayload(payload);
  return <String, Object?>{
    'id': deviceIdentity.deviceId,
    'publicKey': deviceIdentity.publicKey,
    'signature': signature,
    'signedAt': signedAtMs,
    'nonce': nonce,
  };
}

String buildDeviceAuthPayloadV3({
  required String deviceId,
  required String clientId,
  required String clientMode,
  required String role,
  required List<String> scopes,
  required int signedAtMs,
  required String nonce,
  String? token,
  String? platform,
  String? deviceFamily,
}) {
  return <String>[
    'v3',
    deviceId,
    clientId,
    clientMode,
    role,
    scopes.join(','),
    '$signedAtMs',
    token ?? '',
    nonce,
    normalizeDeviceMetadataForAuth(platform),
    normalizeDeviceMetadataForAuth(deviceFamily),
  ].join('|');
}

String normalizeDeviceMetadataForAuth(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 32),
  );
}

String? _trimToUndefined(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}
