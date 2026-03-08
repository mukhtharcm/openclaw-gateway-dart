# Node Mode

`openclaw_gateway` supports both sides of the OpenClaw node flow:

- operator-side node management through `client.nodes`
- node-role runtime handling through `client.node`

## Operator Side

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<void> runNodeCommand(GatewayClient client) async {
  final nodes = await client.nodes.list();
  final first = nodes.first;

  final result = await client.nodes.invoke(
    nodeId: first.nodeId,
    command: 'system.notify',
    params: {'title': 'Hello', 'body': 'From Dart'},
  );

  print(result.payload);
}
```

Useful operator-side methods:

- `client.nodes.list()`
- `client.nodes.describe(nodeId: ...)`
- `client.nodes.invoke(...)`
- `client.nodes.pairList()`
- `client.nodes.pairApprove(...)`
- `client.devices.pairList()`
- `client.devices.tokenRotate(...)`

## Node Role

For a node-host style client, connect with `role: gatewayNodeRole`,
`client.id: GatewayClientIds.nodeHost`, and `client.mode: GatewayClientModes.node`.

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<void> runNodeSession(GatewayClient client) async {
  await for (final request in client.node.invokeRequests) {
    if (request.command == 'system.notify') {
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: {'notified': true},
      );
      continue;
    }

    await client.node.sendInvokeResult(
      id: request.id,
      nodeId: request.nodeId,
      ok: false,
      error: const GatewayNodeInvokeError(
        code: 'unsupported_command',
        message: 'Command not implemented.',
      ),
    );
  }
}
```

Node-role helpers:

- `client.node.invokeRequests`
- `client.node.sendInvokeResult(...)`
- `client.node.sendEvent(...)`
- `client.node.refreshCanvasCapability()`
- `client.node.skillsBins()`

For larger node hosts, use `GatewayNodeCapabilityRegistry` to compute connect
metadata and route invoke requests:

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
print(snapshot.capabilities);
print(snapshot.commands);

final subscription = registry.attach(client);
```

The registry helps you keep advertised `caps`, `commands`, and runtime invoke
handlers in one place, but the gateway still enforces its own command policy.
Node apps should only advertise commands they can actually serve.

## Sample Node Host

The package also ships with a runnable sample node host:

```sh
dart run openclaw_gateway:openclaw_gateway_node_host \
  --url 'ws://127.0.0.1:18789' \
  --token 'gateway-shared-token' \
  --approve-pairing
```

Use `client.nodes.invoke(...)` or the main CLI's `node-invoke` command to send
requests to that sample node.

## Device Auth

Node-role sessions generally need a device identity for pairing and cached
device-token reuse. See `doc/device-auth.md`.
