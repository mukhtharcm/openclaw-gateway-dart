/// A stored per-device gateway auth token issued by `hello-ok.auth`.
class GatewayStoredDeviceToken {
  const GatewayStoredDeviceToken({
    required this.deviceId,
    required this.role,
    required this.token,
    this.scopes = const <String>[],
    this.issuedAtMs,
  });

  final String deviceId;
  final String role;
  final String token;
  final List<String> scopes;
  final int? issuedAtMs;
}

/// Persistence interface for device-scoped gateway auth tokens.
abstract interface class GatewayDeviceTokenStore {
  Future<GatewayStoredDeviceToken?> read({
    required String deviceId,
    required String role,
  });

  Future<void> write(GatewayStoredDeviceToken token);

  Future<void> delete({
    required String deviceId,
    required String role,
  });
}

/// In-memory device token store suitable for tests or short-lived clients.
class GatewayMemoryDeviceTokenStore implements GatewayDeviceTokenStore {
  final Map<String, GatewayStoredDeviceToken> _tokens =
      <String, GatewayStoredDeviceToken>{};

  @override
  Future<GatewayStoredDeviceToken?> read({
    required String deviceId,
    required String role,
  }) async {
    return _tokens[_key(deviceId, role)];
  }

  @override
  Future<void> write(GatewayStoredDeviceToken token) async {
    _tokens[_key(token.deviceId, token.role)] = token;
  }

  @override
  Future<void> delete({
    required String deviceId,
    required String role,
  }) async {
    _tokens.remove(_key(deviceId, role));
  }

  String _key(String deviceId, String role) => '$deviceId::$role';
}
