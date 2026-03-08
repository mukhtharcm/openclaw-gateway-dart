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
- typed event streams and incoming server request streams
- Ed25519 device identities
- device-token persistence and reuse
- portable auth-state storage abstractions plus JSON-backed stores
- operator-oriented helpers for channels, config, sessions, chat, models, tools, agents, voice wake, and cron
- typed query/admin clients for system presence, config, sessions, tools, cron, exec approvals, wizard, talk, usage, TTS, agents, skills, logs, secrets, updates, send, browser, and agent flows
- operator-side node and device helpers
- public node capability registry and invoke router helpers
- node-role helpers for invoke requests, invoke results, node events, and canvas capability refresh
- local Bonjour/mDNS gateway discovery helpers
- TLS fingerprint probing, pinning, and TOFU helpers on `dart:io` platforms
- generated protocol DTOs mirrored from the upstream OpenClaw schema bundle
- generated contract metadata for protocol version, method names, event names, client ids, modes, and caps
- sample CLI executable for local testing

Not included yet:

- built-in Flutter secure-storage adapters
- wide-area/Tailscale DNS-SD helpers
- web-specific TLS pinning helpers

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
    final health = await client.query.health();
    final sessions = await client.query.sessionsList(limit: 10);
    final usage = await client.admin.usageStatus();

    print(health);
    print(sessions);
    print(usage.providers.map((entry) => entry.provider).toList());
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

For Flutter credential storage, implement `GatewayStringStore` with your secure
backend and layer `GatewayJsonAuthStateStore` on top. A minimal
`flutter_secure_storage` adapter looks like this:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

class SecureStorageStringStore implements GatewayStringStore {
  SecureStorageStringStore(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> deleteString(String key) {
    return _storage.delete(key: key);
  }

  @override
  Future<String?> readString(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> writeString(String key, String value) {
    return _storage.write(key: key, value: value);
  }
}
```

For app code, prefer the typed client families:

- `client.query` for typed read/list/status methods
- `client.admin` for typed control-plane and mutation methods
- `client.operator` when you intentionally want the raw `JsonMap` wrappers

A runnable sample app is included in `example/flutter_basic`. It is a small
macOS/Linux Flutter client for health, sessions, chat history, and chat send
flows against a known gateway URL.

More docs:

- [doc/flutter.md](doc/flutter.md)
- [doc/cli.md](doc/cli.md)
- [doc/discovery.md](doc/discovery.md)
- [doc/tls.md](doc/tls.md)
- [doc/device-auth.md](doc/device-auth.md)
- [doc/node.md](doc/node.md)

## Discovery

Local Bonjour/mDNS discovery is available through `GatewayMdnsDiscoveryClient`.
The SDK resolves routing from PTR/SRV/A/AAAA records and treats TXT as hints
only, matching the OpenClaw discovery trust model.

```dart
final discovery = GatewayMdnsDiscoveryClient();
final gateways = await discovery.discoverOnce();

for (final gateway in gateways) {
  print(gateway.displayName);
  print(gateway.primaryUri);
}
```

## TLS Pinning And TOFU

For `wss://` connections on `dart:io` platforms, the SDK can:

- probe the presented certificate fingerprint
- pin to an expected fingerprint
- trust-on-first-use and persist the stored fingerprint

```dart
final uri = Uri.parse('wss://gateway.example');
final fingerprint = await GatewayTlsProbe.probeFingerprint(uri);

final client = await GatewayClient.connect(
  uri: uri,
  auth: const GatewayAuth.token('gateway-shared-token'),
  tlsPolicy: GatewayTlsPolicy.pinned(fingerprint!),
  clientInfo: const GatewayClientInfo(
    id: GatewayClientIds.gatewayClient,
    version: '0.1.0',
    platform: 'dart',
    mode: GatewayClientModes.backend,
  ),
);
```

If you want one persisted blob for device identities, device tokens, and TLS
fingerprints together, `GatewayJsonAuthStateStore` and
`GatewayJsonFileAuthStateStore` now implement all three store interfaces.

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
If you want one persisted blob for both identity and device tokens, use
`GatewayJsonAuthStateStore` with a custom `GatewayStringStore`, or
`GatewayJsonFileAuthStateStore` on `dart:io` platforms.
Use `client.devices.pairList()`, `client.devices.pairApprove(...)`, and
`client.devices.pairReject(...)` to build the operator-side pairing flow.

## Generated DTOs

The package now exports schema-mirrored DTOs like `GatewaySchemaHelloOk`,
`GatewaySchemaConnectParams`, and `GatewaySchemaChatSendParams`. These are
generated from OpenClaw's exported protocol schema with
`tool/sync_openclaw_protocol_dtos.dart`.

They live alongside the curated manual models already used by the high-level
query/admin/operator clients:

```dart
final dto = GatewaySchemaConnectParams.fromJson({
  'minProtocol': gatewayProtocolVersion,
  'maxProtocol': gatewayProtocolVersion,
  'client': {
    'id': GatewayClientIds.cli,
    'version': '0.1.0',
    'platform': 'dart',
    'mode': GatewayClientModes.cli,
  },
});

print(dto.client.id);
```

## Node APIs

Operator-side node management:

```dart
final nodes = await client.nodes.list();
final result = await client.nodes.invoke(
  nodeId: nodes.first.nodeId,
  command: 'system.notify',
  params: {'title': 'Hello', 'body': 'From Dart'},
);
```

Node-role runtime handling:

```dart
await for (final request in client.node.invokeRequests) {
  if (request.command == 'system.notify') {
    await client.node.sendInvokeResult(
      id: request.id,
      nodeId: request.nodeId,
      ok: true,
      payload: {'notified': true},
    );
  }
}
```

## Contract Sync

The package ships generated contract metadata in `GatewayMethodNames`,
`GatewayEventNames`, `GatewayClientIds`, `GatewayClientModes`, and
`GatewayClientCaps`.

Protocol DTOs are generated separately with:

```sh
dart run tool/sync_openclaw_protocol_dtos.dart
```

To refresh the generated metadata from an OpenClaw checkout:

```sh
dart run tool/sync_openclaw_contract.dart \
  --openclaw-root ../contrib/openclaw
```

This keeps the method/event catalog and allowlisted client identifiers aligned
with the upstream gateway without hard-coding those lists by hand.

For larger node-host apps, prefer the public capability registry instead of a
manual `switch`:

```dart
final registry = GatewayNodeCapabilityRegistry(
  capabilities: const [
    GatewayNodeCapability(name: 'camera'),
  ],
  commands: [
    GatewayNodeCommand(
      name: 'camera.list',
      capabilities: const ['camera'],
      handler: (context) async => const GatewayNodeCommandResult.ok(
        payload: {'cameras': []},
      ),
    ),
  ],
  permissionsResolver: () async => {
    'camera': true,
  },
);

final snapshot = await registry.snapshot();
print(snapshot.commands);

final sub = registry.attach(client);
```

For a runnable sample node host, use the dedicated executable:

```sh
dart run openclaw_gateway:openclaw_gateway_node_host \
  --url 'ws://127.0.0.1:18789' \
  --token 'gateway-shared-token' \
  --approve-pairing
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
dart run openclaw_gateway:openclaw_gateway_cli nodes-list
dart run openclaw_gateway:openclaw_gateway_cli node-describe <node-id>
dart run openclaw_gateway:openclaw_gateway_cli node-invoke <node-id> system.notify --params '{"title":"Hello","body":"From Dart"}'
dart run openclaw_gateway:openclaw_gateway_cli events --name chat
echo '{"probe":true}' | dart run openclaw_gateway:openclaw_gateway_cli raw health
```

There is also a dedicated sample node-host executable:

```sh
dart run openclaw_gateway:openclaw_gateway_node_host --help
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
client against a running gateway, including device-token reuse and an
end-to-end `node.invoke` round-trip with a temporary Dart node client.

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
