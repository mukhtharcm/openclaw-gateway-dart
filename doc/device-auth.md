# Device Auth

`openclaw_gateway` can participate in the gateway's device-auth flow:

- sign `connect` with a device identity
- reuse a stored device token when no shared token is provided
- persist the `hello-ok.auth.deviceToken` returned by the gateway
- clear stale stored tokens when the gateway rejects device-token auth

## Basic Setup

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<GatewayClient> connectWithDeviceAuth(Uri uri) async {
  final identity = await GatewayEd25519Identity.generate();
  final tokens = GatewayMemoryDeviceTokenStore();

  return GatewayClient.connect(
    uri: uri,
    auth: const GatewayAuth.none(),
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

## Persisting Identity And Tokens

The package ships an in-memory token store and a serializable Ed25519 identity
record. Real apps should persist both somewhere appropriate for their platform.

```dart
final identity = await GatewayEd25519Identity.generate();
final exported = await identity.exportData();

// Persist `exported.toJson()` with your app's storage layer.
final restored = GatewayEd25519Identity.fromData(exported);
```

For token persistence, implement `GatewayDeviceTokenStore` with your own
storage backend, for example secure storage on Flutter mobile or a file/database
in a Dart backend.

## Auth Precedence

The client follows the same precedence as first-party OpenClaw clients:

- explicit shared token or password wins
- explicit `deviceToken` is used next
- stored device token is only used when a device identity exists and no shared
  token was supplied

That keeps shared gateway credentials authoritative while still allowing paired
device reconnects without re-entering a shared token.
