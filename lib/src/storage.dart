import 'dart:convert';

import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/identity_store.dart';
import 'package:openclaw_gateway/src/protocol.dart';
import 'package:openclaw_gateway/src/tls.dart';

/// Serializable snapshot for a gateway device identity plus cached device tokens.
class GatewayAuthStateSnapshot {
  const GatewayAuthStateSnapshot({
    this.identity,
    this.tokens = const <GatewayStoredDeviceToken>[],
    this.tlsFingerprints = const <GatewayStoredTlsFingerprint>[],
  });

  factory GatewayAuthStateSnapshot.fromJson(JsonMap json) {
    final identityValue = json['identity'];
    final tokensValue = json['tokens'];
    final tlsValue = json['tlsFingerprints'];
    return GatewayAuthStateSnapshot(
      identity: identityValue == null
          ? null
          : GatewayEd25519IdentityData.fromJson(
              asJsonMap(
                identityValue,
                context: 'GatewayAuthStateSnapshot.identity',
              ),
            ),
      tokens: tokensValue == null
          ? const <GatewayStoredDeviceToken>[]
          : asJsonList(tokensValue, context: 'GatewayAuthStateSnapshot.tokens')
              .map(
                (entry) => _gatewayStoredDeviceTokenFromJson(
                  asJsonMap(
                    entry,
                    context: 'GatewayAuthStateSnapshot.tokens[]',
                  ),
                ),
              )
              .toList(growable: false),
      tlsFingerprints: tlsValue == null
          ? const <GatewayStoredTlsFingerprint>[]
          : asJsonList(
              tlsValue,
              context: 'GatewayAuthStateSnapshot.tlsFingerprints',
            )
              .map(
                (entry) => gatewayStoredTlsFingerprintFromJson(
                  asJsonMap(
                    entry,
                    context: 'GatewayAuthStateSnapshot.tlsFingerprints[]',
                  ),
                ),
              )
              .toList(growable: false),
    );
  }

  final GatewayEd25519IdentityData? identity;
  final List<GatewayStoredDeviceToken> tokens;
  final List<GatewayStoredTlsFingerprint> tlsFingerprints;

  JsonMap toJson() {
    return <String, Object?>{
      'identity': identity?.toJson(),
      'tokens':
          tokens.map(_gatewayStoredDeviceTokenToJson).toList(growable: false),
      'tlsFingerprints': tlsFingerprints
          .map(gatewayStoredTlsFingerprintToJson)
          .toList(growable: false),
    };
  }
}

/// Minimal string storage abstraction for portable auth-state persistence.
abstract interface class GatewayStringStore {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);

  Future<void> deleteString(String key);
}

/// In-memory string store suitable for tests and temporary runtimes.
class GatewayMemoryStringStore implements GatewayStringStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> deleteString(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> readString(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    _values[key] = value;
  }
}

/// Portable JSON-backed auth-state store layered over a [GatewayStringStore].
class GatewayJsonAuthStateStore extends GatewayEd25519IdentityStore
    implements GatewayDeviceTokenStore, GatewayTlsFingerprintStore {
  GatewayJsonAuthStateStore({
    required GatewayStringStore store,
    this.key = 'openclaw_gateway.auth_state',
  }) : _store = store;

  final GatewayStringStore _store;
  final String key;

  @override
  Future<void> delete({
    required String deviceId,
    required String role,
  }) async {
    final state = await _load();
    final nextTokens = state.tokens
        .where((token) => token.deviceId != deviceId || token.role != role)
        .toList(growable: false);
    await _persist(
      GatewayAuthStateSnapshot(
        identity: state.identity,
        tokens: nextTokens,
        tlsFingerprints: state.tlsFingerprints,
      ),
    );
  }

  @override
  Future<void> deleteIdentity() async {
    final state = await _load();
    await _persist(
      GatewayAuthStateSnapshot(
        tokens: state.tokens,
        tlsFingerprints: state.tlsFingerprints,
      ),
    );
  }

  @override
  Future<GatewayStoredDeviceToken?> read({
    required String deviceId,
    required String role,
  }) async {
    final state = await _load();
    for (final token in state.tokens) {
      if (token.deviceId == deviceId && token.role == role) {
        return token;
      }
    }
    return null;
  }

  @override
  Future<void> deleteFingerprint({
    required String stableId,
  }) async {
    final state = await _load();
    final nextFingerprints = state.tlsFingerprints
        .where((fingerprint) => fingerprint.stableId != stableId)
        .toList(growable: false);
    await _persist(
      GatewayAuthStateSnapshot(
        identity: state.identity,
        tokens: state.tokens,
        tlsFingerprints: nextFingerprints,
      ),
    );
  }

  @override
  Future<GatewayEd25519Identity?> readIdentity() async {
    final state = await _load();
    final identity = state.identity;
    if (identity == null) {
      return null;
    }
    return GatewayEd25519Identity.fromData(identity);
  }

  @override
  Future<GatewayStoredTlsFingerprint?> readFingerprint({
    required String stableId,
  }) async {
    final state = await _load();
    for (final fingerprint in state.tlsFingerprints) {
      if (fingerprint.stableId == stableId) {
        return fingerprint;
      }
    }
    return null;
  }

  @override
  Future<void> write(GatewayStoredDeviceToken token) async {
    final state = await _load();
    final nextTokens = state.tokens
        .where(
          (existing) =>
              existing.deviceId != token.deviceId ||
              existing.role != token.role,
        )
        .toList(growable: true)
      ..add(token);
    await _persist(
      GatewayAuthStateSnapshot(
        identity: state.identity,
        tokens: nextTokens,
        tlsFingerprints: state.tlsFingerprints,
      ),
    );
  }

  @override
  Future<void> writeIdentity(GatewayEd25519IdentityData data) async {
    final state = await _load();
    await _persist(
      GatewayAuthStateSnapshot(
        identity: data,
        tokens: state.tokens,
        tlsFingerprints: state.tlsFingerprints,
      ),
    );
  }

  @override
  Future<void> writeFingerprint(GatewayStoredTlsFingerprint fingerprint) async {
    final state = await _load();
    final nextFingerprints = state.tlsFingerprints
        .where((entry) => entry.stableId != fingerprint.stableId)
        .toList(growable: true)
      ..add(fingerprint);
    await _persist(
      GatewayAuthStateSnapshot(
        identity: state.identity,
        tokens: state.tokens,
        tlsFingerprints: nextFingerprints,
      ),
    );
  }

  Future<GatewayAuthStateSnapshot> _load() async {
    final raw = await _store.readString(key);
    if (raw == null || raw.trim().isEmpty) {
      return const GatewayAuthStateSnapshot();
    }
    final decoded = jsonDecode(raw);
    return GatewayAuthStateSnapshot.fromJson(
      asJsonMap(decoded, context: 'GatewayJsonAuthStateStore'),
    );
  }

  Future<void> _persist(GatewayAuthStateSnapshot state) async {
    await _store.writeString(
      key,
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
    );
  }
}

GatewayStoredDeviceToken _gatewayStoredDeviceTokenFromJson(JsonMap json) {
  return GatewayStoredDeviceToken(
    deviceId: readRequiredString(
      json,
      'deviceId',
      context: 'GatewayStoredDeviceToken',
    ),
    role: readRequiredString(
      json,
      'role',
      context: 'GatewayStoredDeviceToken',
    ),
    token: readRequiredString(
      json,
      'token',
      context: 'GatewayStoredDeviceToken',
    ),
    scopes: json['scopes'] == null
        ? const <String>[]
        : readStringList(json['scopes'], context: 'GatewayStoredDeviceToken'),
    issuedAtMs: readNullableInt(json['issuedAtMs']),
  );
}

JsonMap _gatewayStoredDeviceTokenToJson(GatewayStoredDeviceToken token) {
  return <String, Object?>{
    'deviceId': token.deviceId,
    'role': token.role,
    'token': token.token,
    'scopes': token.scopes,
    'issuedAtMs': token.issuedAtMs,
  };
}
