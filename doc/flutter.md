# Flutter

`openclaw_gateway` is a pure Dart package, so you can use it directly from
Flutter without any plugin wrapper.

That makes it a good fit for Flutter apps that already know how to reach a
gateway URL and want a reusable protocol client instead of hand-rolling
WebSocket code.

## What Works Well Today

- connecting to a known gateway URL
- token or password authentication
- device identity and cached device-token auth
- request/response gateway methods
- listening to gateway events
- reconnect/backoff and lifecycle state
- operator-side app flows such as:
  - health/status views
  - session lists
  - chat history
  - streaming chat output

## What Is Not Included Yet

- gateway discovery
- secure storage helpers
- TLS pinning or TOFU helpers
- opinionated storage adapters for device identities and device tokens

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
- gateway discovery and trust UX
