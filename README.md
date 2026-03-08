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
- request/response RPC helpers
- event streams and incoming server request streams
- operator-oriented helpers for:
  - `health`
  - `status`
  - `config.get`
  - `sessions.list`
  - `sessions.preview`
  - `chat.history`
  - `chat.send`
  - `chat.abort`
- sample CLI executable for local testing

Not included yet:

- reconnect/backoff
- gateway discovery
- TLS pinning / TOFU helpers
- secure storage adapters
- device identity signing or pairing helpers
- node-mode client helpers

## Install

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
      id: 'gateway-client',
      version: '0.1.0',
      platform: 'dart',
      mode: 'backend',
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
      id: 'gateway-client',
      version: '0.1.0',
      platform: 'flutter',
      mode: 'ui',
      displayName: 'OpenClaw Flutter',
    ),
  );
}

class GatewayEventsView extends StatelessWidget {
  const GatewayEventsView({super.key, required this.client});

  final GatewayClient client;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GatewayEventFrame>(
      stream: client.eventsNamed('chat'),
      builder: (context, snapshot) {
        final event = snapshot.data;
        if (event == null) {
          return const Text('Waiting for chat events...');
        }
        return Text(event.payload.toString());
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

The gateway validates `client.id` and `client.mode` against a fixed allowlist.
For generic Dart and Flutter apps, `gateway-client` is the safest library
default and `cli` is the safest CLI default.

## API Overview

- `GatewayClient`
  - owns the WebSocket connection
  - exposes raw request helpers and event streams
  - exposes `connectionStates` for lifecycle tracking
- `GatewayOperatorClient`
  - typed helpers for common operator methods
- `GatewayAuth`
  - token, password, and device-token auth shapes
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

## Security

Do not hardcode or commit real gateway tokens, passwords, or device tokens.
Use environment variables, secure storage, or another secret-management system.
