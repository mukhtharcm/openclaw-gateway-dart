# TLS

`openclaw_gateway` includes TLS fingerprint helpers for `wss://` connections on
`dart:io` platforms.

## What It Supports

- certificate fingerprint probing
- pinned fingerprint connections
- trust-on-first-use with persistent storage

## Probe

```dart
final uri = Uri.parse('wss://gateway.example');
final fingerprint = await GatewayTlsProbe.probeFingerprint(uri);
print(fingerprint);
```

CLI:

```sh
dart run openclaw_gateway:openclaw_gateway_cli tls-probe wss://gateway.example
```

## Pinned TLS

```dart
final client = await GatewayClient.connect(
  uri: Uri.parse('wss://gateway.example'),
  auth: const GatewayAuth.token('gateway-shared-token'),
  tlsPolicy: GatewayTlsPolicy.pinned('sha256 fingerprint here'),
  clientInfo: const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
  ),
);
```

## TOFU

```dart
final fingerprintStore = GatewayMemoryTlsFingerprintStore();

final client = await GatewayClient.connect(
  uri: Uri.parse('wss://gateway.example'),
  auth: const GatewayAuth.token('gateway-shared-token'),
  tlsPolicy: GatewayTlsPolicy.trustOnFirstUse(
    stableId: 'gateway.example',
    fingerprintStore: fingerprintStore,
  ),
  clientInfo: const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
  ),
);
```

On first successful connection, the fingerprint is stored. Later connections
reuse the stored pin automatically.

## Storage

`GatewayJsonAuthStateStore` and `GatewayJsonFileAuthStateStore` now persist:

- Ed25519 device identities
- device tokens
- TLS fingerprints
