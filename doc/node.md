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
    command: 'camera.capture',
    params: {'quality': 'high'},
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
    if (request.command == 'ping') {
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: {'pong': true},
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

## Device Auth

Node-role sessions generally need a device identity for pairing and cached
device-token reuse. See `doc/device-auth.md`.
