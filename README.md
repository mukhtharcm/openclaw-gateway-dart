# openclaw_gateway

`openclaw_gateway` is a pure Dart client for the OpenClaw gateway protocol.

It is meant to be the reusable SDK layer for:

- Dart CLI tools
- Dart automation and backend processes
- Flutter apps on mobile, desktop, and web

The package handles the gateway WebSocket handshake, request/response RPC, and
event streams. A small sample CLI is included for manual testing and debugging,
but the main product is the library.

## Current Scope

`openclaw_gateway` is intentionally small in `0.1.0`.

Included today:

- pure Dart gateway client
- `connect.challenge` plus `connect` handshake
- reconnect/backoff plus lifecycle state tracking
- request/response RPC helpers
- event streams and incoming server request streams
- Ed25519 device identities
- device-token persistence and reuse
- operator-oriented helpers for channels, config, sessions, chat, models, tools, agents, voice wake, and cron
- operator-side node and device helpers
- node-role helpers for invoke requests, invoke results, node events, and canvas capability refresh
- sample CLI executable for local testing

Not included yet:

- gateway discovery
- TLS pinning / TOFU helpers
- secure storage adapters
- generated protocol models from the upstream TypeScript schema

## Install

The package is not on pub.dev yet.

Use a Git dependency for now:

```yaml
dependencies:
  openclaw_gateway:
    git:
      url: https://github.com/mukhtharcm/openclaw-gateway-dart.git
```

After the package is published, the install command will be:

```sh
dart pub add openclaw_gateway
```

## Quick Start

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<void> main() async {
  final client = await GatewayClient.connect(
    uri: Uri.parse('ws://127.0.0.1:18789'),
    auth: const GatewayAuth.token('gateway-shared-token'),
    autoReconnect: true,
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'dart',
      mode: GatewayClientModes.backend,
      displayName: 'My OpenClaw App',
    ),
  );

  try {
    final health = await client.operator.health();
    final sessions = await client.operator.sessionsList(limit: 10);

    print(health);
    print(sessions);
  } finally {
    await client.close();
  }
}
```

## Flutter Usage

The package itself is pure Dart, so it can be used directly from Flutter.

```dart
import 'package:flutter/material.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<GatewayClient> openGateway() {
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

class GatewayEventsView extends StatelessWidget {
  const GatewayEventsView({super.key, required this.client});

  final GatewayClient client;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GatewayChatEvent>(
      stream: client.operator.chatEvents,
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event == null) {
          return const Text('Waiting for chat events...');
        }
        return Text(event.message.toString());
      },
    );
  }
}
```

`autoReconnect` re-establishes the socket after disconnects and tick timeouts.
Use `client.connectionStates` to drive UI or logging for transitions such as
`connecting`, `connected`, `reconnecting`, and `closed`.

More docs:

- [doc/flutter.md](doc/flutter.md)
- [doc/cli.md](doc/cli.md)
- [doc/device-auth.md](doc/device-auth.md)
- [doc/node.md](doc/node.md)

## Device Auth

The package can sign gateway `connect` requests with an Ed25519 device
identity and reuse/persist role-scoped device tokens.

For a brand new identity, the gateway will typically require pairing first.
After that pairing is approved, later `hello-ok` responses include a
role-scoped device token, and subsequent reconnects can reuse it through
`GatewayDeviceTokenStore`.

```dart
final identity = await GatewayEd25519Identity.generate();
final tokens = GatewayMemoryDeviceTokenStore();

final client = await GatewayClient.connect(
  uri: Uri.parse('ws://127.0.0.1:18789'),
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
```

`GatewayMemoryDeviceTokenStore` is only a starter implementation. Real apps
should back `GatewayDeviceTokenStore` with secure or persistent storage.
Use `client.devices.pairList()`, `client.devices.pairApprove(...)`, and
`client.devices.pairReject(...)` to build the operator-side pairing flow.

## Node APIs

Operator-side node management:

```dart
final nodes = await client.nodes.list();
final result = await client.nodes.invoke(
  nodeId: nodes.first.nodeId,
  command: 'ping',
);
```

Node-role runtime handling:

```dart
await for (final request in client.node.invokeRequests) {
  await client.node.sendInvokeResult(
    id: request.id,
    nodeId: request.nodeId,
    ok: true,
    payload: {'handled': true},
  );
}
```

## Sample CLI

The package includes an optional sample executable:

```sh
dart run openclaw_gateway:openclaw_gateway_cli --help
```

Configure it with flags or environment variables:

```sh
export OPENCLAW_GATEWAY_URL='ws://127.0.0.1:18789'
export OPENCLAW_GATEWAY_TOKEN='gateway-shared-token'
```

Examples:

```sh
dart run openclaw_gateway:openclaw_gateway_cli health
dart run openclaw_gateway:openclaw_gateway_cli status
dart run openclaw_gateway:openclaw_gateway_cli sessions-list --limit 10
dart run openclaw_gateway:openclaw_gateway_cli chat-history main --limit 20
dart run openclaw_gateway:openclaw_gateway_cli chat-send main "hello from dart"
dart run openclaw_gateway:openclaw_gateway_cli chat-watch main "hello from dart"
dart run openclaw_gateway:openclaw_gateway_cli events --name chat
echo '{"probe":true}' | dart run openclaw_gateway:openclaw_gateway_cli raw health
```

`chat.send` returns an acknowledgement payload such as
`{"runId":"...","status":"started"}`. The streamed assistant output arrives on
the `chat` event stream. The `chat-watch` command wraps that pattern and waits
for the final chat event.

The CLI is intentionally narrower than the library. For gateway methods that do
not have a dedicated CLI command yet, use `raw` or integrate through the Dart
API directly.

The gateway validates `client.id` and `client.mode` against a fixed allowlist.
For generic Dart and Flutter apps, `gateway-client` is the safest library
default and `cli` is the safest CLI default.

## API Overview

- `GatewayClient`
  - owns the WebSocket connection
  - exposes raw request helpers and event streams
  - exposes `connectionStates` for lifecycle tracking
- `GatewayOperatorClient`
  - typed helpers for channels, config, sessions, chat, models, tools, agents, voice wake, and cron
- `GatewayNodesClient`
  - operator-side node inventory, pairing, rename, and invoke helpers
- `GatewayDevicesClient`
  - operator-side device pairing and token rotation helpers
- `GatewayNodeClient`
  - node-role helpers for `node.invoke.request`, `node.invoke.result`, `node.event`, and canvas capability refresh
- `GatewayAuth`
  - token, password, and device-token auth shapes
- `GatewayEd25519Identity`
  - device identity generation, serialization, and signing helpers
- `GatewayDeviceTokenStore`
  - pluggable persistence for role-scoped device tokens returned by `hello-ok`
- `GatewayConnectOptions`
  - lower-level connect options when the defaults are not enough

## Local Development

```sh
dart pub get
dart format .
dart analyze
dart test
dart pub publish --dry-run
```

## Live Gateway Smoke Test

The repo includes an opt-in live integration test that exercises the typed
client against a running gateway, including device-token reuse.

```sh
OPENCLAW_GATEWAY_LIVE_TEST=1 \
OPENCLAW_GATEWAY_URL='ws://127.0.0.1:18789' \
OPENCLAW_GATEWAY_TOKEN='gateway-shared-token' \
dart test test/live_gateway_test.dart
```

This is skipped by default and is safe to leave in the normal test suite.

## Security

Do not hardcode or commit real gateway tokens, passwords, or device tokens.
Use environment variables, secure storage, or another secret-management system.
