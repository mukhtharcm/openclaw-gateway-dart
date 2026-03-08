import 'dart:convert';
import 'dart:io';

import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/identity_store.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// JSON file-backed persistence for a gateway device identity plus device tokens.
class GatewayJsonFileAuthStateStore extends GatewayEd25519IdentityStore
    implements GatewayDeviceTokenStore {
  GatewayJsonFileAuthStateStore({
    required String path,
  }) : _file = File(path);

  final File _file;

  @override
  Future<void> delete({
    required String deviceId,
    required String role,
  }) async {
    final state = await _load();
    state.tokens.removeWhere(
      (token) => token.deviceId == deviceId && token.role == role,
    );
    await _persist(state);
  }

  @override
  Future<void> deleteIdentity() async {
    final state = await _load();
    state.identity = null;
    await _persist(state);
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
  Future<GatewayEd25519Identity?> readIdentity() async {
    final state = await _load();
    final identity = state.identity;
    if (identity == null) {
      return null;
    }
    return GatewayEd25519Identity.fromData(identity);
  }

  @override
  Future<void> write(GatewayStoredDeviceToken token) async {
    final state = await _load();
    state.tokens.removeWhere(
      (existing) =>
          existing.deviceId == token.deviceId && existing.role == token.role,
    );
    state.tokens.add(token);
    await _persist(state);
  }

  @override
  Future<void> writeIdentity(GatewayEd25519IdentityData data) async {
    final state = await _load();
    state.identity = data;
    await _persist(state);
  }

  Future<_GatewayJsonFileAuthState> _load() async {
    if (!await _file.exists()) {
      return _GatewayJsonFileAuthState();
    }
    final decoded = jsonDecode(await _file.readAsString());
    final json = asJsonMap(decoded, context: 'GatewayJsonFileAuthStateStore');
    return _GatewayJsonFileAuthState.fromJson(json);
  }

  Future<void> _persist(_GatewayJsonFileAuthState state) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(state.toJson()),
    );
  }
}

class _GatewayJsonFileAuthState {
  _GatewayJsonFileAuthState({
    this.identity,
    this.tokens = const <GatewayStoredDeviceToken>[],
  });

  factory _GatewayJsonFileAuthState.fromJson(JsonMap json) {
    final identityValue = json['identity'];
    final tokensValue = json['tokens'];
    return _GatewayJsonFileAuthState(
      identity: identityValue == null
          ? null
          : GatewayEd25519IdentityData.fromJson(
              asJsonMap(
                identityValue,
                context: 'GatewayJsonFileAuthStateStore.identity',
              ),
            ),
      tokens: tokensValue == null
          ? const <GatewayStoredDeviceToken>[]
          : asJsonList(
              tokensValue,
              context: 'GatewayJsonFileAuthStateStore.tokens',
            )
              .map((entry) => _storedDeviceTokenFromJson(
                    asJsonMap(
                      entry,
                      context: 'GatewayJsonFileAuthStateStore.tokens[]',
                    ),
                  ))
              .toList(growable: true),
    );
  }

  GatewayEd25519IdentityData? identity;
  final List<GatewayStoredDeviceToken> tokens;

  JsonMap toJson() {
    return <String, Object?>{
      'identity': identity?.toJson(),
      'tokens': tokens.map(_storedDeviceTokenToJson).toList(growable: false),
    };
  }
}

GatewayStoredDeviceToken _storedDeviceTokenFromJson(JsonMap json) {
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

JsonMap _storedDeviceTokenToJson(GatewayStoredDeviceToken token) {
  return <String, Object?>{
    'deviceId': token.deviceId,
    'role': token.role,
    'token': token.token,
    'scopes': token.scopes,
    'issuedAtMs': token.issuedAtMs,
  };
}
