# Device Auth

`openclaw_gateway` can participate in the gateway's device-auth flow:

- sign `connect` with a device identity
- reuse a stored device token when no shared token is provided
- persist the `hello-ok.auth.deviceToken` returned by the gateway
- clear stale stored tokens when the gateway rejects device-token auth

For a new device identity, expect the gateway to require pairing first. Once
that pairing is approved, later reconnects can rely on the cached device token.

## Basic Setup

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<GatewayClient> connectWithDeviceAuth(Uri uri) async {
  final identity = await GatewayEd25519Identity.generate();
  final tokens = GatewayMemoryDeviceTokenStore();

  return GatewayClient.connect(
    uri: uri,
    auth: const GatewayAuth.token('gateway-shared-token'),
    deviceIdentity: identity,
    deviceTokenStore: tokens,
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'dart',
      mode: GatewayClientModes.backend,
      displayName: 'OpenClaw Device Client',
    ),
    autoReconnect: true,
  );
}
```

After the first pairing is approved and a device token has been cached, later
reconnects can switch to `GatewayAuth.none()` and let `GatewayDeviceTokenStore`
provide the role-scoped device token automatically.

## Pairing Flow

The SDK exposes the operator-side pairing methods you need for this:

- `client.devices.pairList()`
- `client.devices.pairApprove(requestId: ...)`
- `client.devices.pairReject(requestId: ...)`
- `client.devices.pairRemove(deviceId: ...)`

Typical flow:

1. connect with a shared token and a new device identity
2. receive a `NOT_PAIRED` / `PAIRING_REQUIRED` response from the gateway
3. approve that request from an operator session
4. reconnect with the same identity
5. persist the returned device token for future reconnects

## Persisting Identity And Tokens

The package ships an in-memory token store and a serializable Ed25519 identity
record. Real apps should persist both somewhere appropriate for their platform.

```dart
final identity = await GatewayEd25519Identity.generate();
final exported = await identity.exportData();

// Persist `exported.toJson()` with your app's storage layer.
final restored = GatewayEd25519Identity.fromData(exported);
```

If you want one persisted JSON blob for both the identity and device tokens,
use one of the built-in stores:

```dart
final memory = GatewayJsonAuthStateStore(
  store: GatewayMemoryStringStore(),
);
```

On `dart:io` platforms, you can use the file-backed variant:

```dart
import 'package:openclaw_gateway/openclaw_gateway_io.dart';

final fileStore = GatewayJsonFileAuthStateStore(
  path: '.openclaw_gateway_auth_state.json',
);
```

For Flutter or other app runtimes, implement `GatewayStringStore` with your
preferred secure storage backend and layer `GatewayJsonAuthStateStore` on top.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

class SecureStorageStringStore implements GatewayStringStore {
  SecureStorageStringStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> deleteString(String key) => _storage.delete(key: key);

  @override
  Future<String?> readString(String key) => _storage.read(key: key);

  @override
  Future<void> writeString(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}
```

## Auth Precedence

The client follows the same precedence as first-party OpenClaw clients:

- explicit shared token or password wins
- explicit `deviceToken` is used next
- stored device token is only used when a device identity exists and no shared
  token was supplied

That keeps shared gateway credentials authoritative while still allowing paired
device reconnects without re-entering a shared token.
