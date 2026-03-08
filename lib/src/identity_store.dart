import 'package:openclaw_gateway/src/device_identity.dart';

/// Persistence interface for serialized Ed25519 gateway identities.
abstract class GatewayEd25519IdentityStore {
  Future<GatewayEd25519Identity?> readIdentity();

  Future<void> writeIdentity(GatewayEd25519IdentityData data);

  Future<void> deleteIdentity();

  Future<GatewayEd25519Identity> readOrCreateIdentity() async {
    final existing = await readIdentity();
    if (existing != null) {
      return existing;
    }
    final created = await GatewayEd25519Identity.generate();
    await writeIdentity(await created.exportData());
    return created;
  }
}
