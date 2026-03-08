# Flutter

`openclaw_gateway` is a pure Dart package, so you can use it directly from
Flutter without any plugin wrapper.

That makes it a good fit for Flutter apps that already know how to reach a
gateway URL and want a reusable protocol client instead of hand-rolling
WebSocket code.

## What Works Well Today

- connecting to a known gateway URL
- local gateway discovery over Bonjour/mDNS
- token or password authentication
- device identity and cached device-token auth
- TLS fingerprint probing, pinning, and TOFU on `dart:io` platforms
- request/response gateway methods
- typed query/admin clients
- typed config/session mutation helpers
- listening to typed gateway events
- reconnect/backoff and lifecycle state
- operator-side app flows such as:
  - health/status views
  - session lists
  - chat history
  - streaming chat output

The repo also includes a small runnable sample at `example/flutter_basic` for
macOS and Linux. Use that first if you want to verify the SDK against a live
gateway before building your own app shell.

## What Is Not Included Yet

- built-in secure storage plugin adapters
- opinionated storage adapters for device identities and device tokens
- wide-area/Tailscale discovery helpers
- web-specific TLS pinning helpers

## Basic Client Setup

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<GatewayClient> connectGateway() {
  return GatewayClient.connect(
    uri: Uri.parse('ws://127.0.0.1:18789'),
    auth: const GatewayAuth.token('gateway-shared-token'),
    autoReconnect: true,
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'flutter',
      mode: GatewayClientModes.ui,
      displayName: 'OpenClaw Flutter',
    ),
  );
}
```

## Typed Clients

```dart
Future<void> loadDashboard(GatewayClient client) async {
  final health = await client.query.health();
  final sessions = await client.query.sessionsList(limit: 20);
  final usage = await client.admin.usageStatus();

  debugPrint('health ok=${health.ok}');
  debugPrint('sessions=${sessions.count}');
  debugPrint('providers=${usage.providers.length}');
}
```

## Listening To Events

```dart
Stream<GatewayChatEvent> chatEvents(GatewayClient client) {
  return client.operator.chatEvents;
}
```

## Tracking Connection State

```dart
Stream<GatewayConnectionState> connectionStates(GatewayClient client) {
  return client.connectionStates;
}
```

## Device Auth

```dart
Future<GatewayClient> connectWithDeviceAuth(Uri uri) async {
  final identity = await GatewayEd25519Identity.generate();
  final tokens = GatewayMemoryDeviceTokenStore();

  return GatewayClient.connect(
    uri: uri,
    auth: const GatewayAuth.none(),
    deviceIdentity: identity,
    deviceTokenStore: tokens,
    autoReconnect: true,
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'flutter',
      mode: GatewayClientModes.ui,
      displayName: 'OpenClaw Flutter',
    ),
  );
}
```

Use a real `GatewayDeviceTokenStore` implementation backed by secure storage in
production Flutter apps.

The package now includes a portable `GatewayJsonAuthStateStore` that can sit on
top of a custom `GatewayStringStore`. In Flutter, that means you can keep your
SDK state in `flutter_secure_storage` or another app-specific secure backend
without changing the gateway client itself.

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

final authState = GatewayJsonAuthStateStore(
  store: SecureStorageStringStore(const FlutterSecureStorage()),
);
```

That store can back device identities, cached device tokens, and TLS
fingerprints for the core package.

## Discovery

For desktop or local-network mobile flows, you can discover gateways first and
then connect to the chosen `primaryUri`:

```dart
final discovery = GatewayMdnsDiscoveryClient();
final gateways = await discovery.discoverOnce();
final gateway = gateways.first;
```

## TLS Pinning And TOFU

For `wss://` gateways on Flutter desktop or mobile `dart:io` runtimes:

```dart
final store = GatewayJsonAuthStateStore(
  store: SecureStorageStringStore(const FlutterSecureStorage()),
);

final client = await GatewayClient.connect(
  uri: Uri.parse('wss://gateway.example'),
  auth: const GatewayAuth.token('gateway-shared-token'),
  tlsPolicy: GatewayTlsPolicy.trustOnFirstUse(
    stableId: 'gateway.example',
    fingerprintStore: store,
  ),
  clientInfo: const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'flutter',
    mode: GatewayClientModes.ui,
  ),
);
```

## Node-Aware Apps

The package now supports both sides of node flows:

- `client.nodes` for operator-side node inventory, pairing, and `node.invoke`
- `client.node` for node-role sessions handling `node.invoke.request`

## Suggested App Architecture

- create one long-lived `GatewayClient`
- inject it into your app state layer
- expose typed operations through your own repository or service classes
- keep gateway secrets out of source code
- close the client cleanly when the app or session ends
- persist device identities and device tokens in app-managed storage

## Recommended Next Layer

For a production Flutter app, you will probably want a small app-local wrapper
on top of this package for:

- secret storage
- app lifecycle integration
- user-facing connection state
- mapping raw chat events into UI state
- discovery and trust UX

## Contract Metadata

The package also exports generated `GatewayMethodNames` and
`GatewayEventNames` constants. Those are synchronized from the OpenClaw source
tree with `tool/sync_openclaw_contract.dart`, which helps keep Flutter app code
aligned with new gateway methods and events as the server evolves.
