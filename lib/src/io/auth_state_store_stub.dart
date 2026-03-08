import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/identity_store.dart';

class GatewayJsonFileAuthStateStore extends GatewayEd25519IdentityStore
    implements GatewayDeviceTokenStore {
  GatewayJsonFileAuthStateStore({
    required String path,
  }) : _path = path;

  final String _path;

  Never _unsupported() {
    throw UnsupportedError(
      'GatewayJsonFileAuthStateStore is only available on platforms with dart:io support ($_path).',
    );
  }

  @override
  Future<void> delete({
    required String deviceId,
    required String role,
  }) async {
    _unsupported();
  }

  @override
  Future<void> deleteIdentity() async {
    _unsupported();
  }

  @override
  Future<GatewayStoredDeviceToken?> read({
    required String deviceId,
    required String role,
  }) async {
    _unsupported();
  }

  @override
  Future<GatewayEd25519Identity?> readIdentity() async {
    _unsupported();
  }

  @override
  Future<void> write(GatewayStoredDeviceToken token) async {
    _unsupported();
  }

  @override
  Future<void> writeIdentity(GatewayEd25519IdentityData data) async {
    _unsupported();
  }
}
