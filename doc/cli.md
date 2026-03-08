# CLI

`openclaw_gateway` ships with a small optional CLI executable for manual
testing, local debugging, and smoke tests.

## Run

```sh
dart run openclaw_gateway:openclaw_gateway_cli --help
```

Sample node host:

```sh
dart run openclaw_gateway:openclaw_gateway_node_host --help
```

## Connection Settings

Global flags:

- `--url`
- `--token`
- `--password`
- `--client-id`
- `--client-version`
- `--display-name`
- `--platform`
- `--mode`
- `--scope`
- `--pretty`

Environment variables:

- `OPENCLAW_GATEWAY_URL`
- `OPENCLAW_GATEWAY_TOKEN`
- `OPENCLAW_GATEWAY_PASSWORD`

Example:

```sh
export OPENCLAW_GATEWAY_URL='ws://127.0.0.1:18789'
export OPENCLAW_GATEWAY_TOKEN='gateway-shared-token'
```

## Commands

- `health`
- `status`
- `config-get`
- `sessions-list`
- `sessions-preview`
- `chat-history`
- `chat-send`
- `chat-watch`
- `chat-abort`
- `nodes-list`
- `node-describe`
- `node-invoke`
- `events`
- `raw`

## Examples

```sh
dart run openclaw_gateway:openclaw_gateway_cli health
dart run openclaw_gateway:openclaw_gateway_cli sessions-list --limit 10
dart run openclaw_gateway:openclaw_gateway_cli chat-history main --limit 20
dart run openclaw_gateway:openclaw_gateway_cli chat-send main "hello from dart"
dart run openclaw_gateway:openclaw_gateway_cli chat-watch main "Reply with exactly: ok"
dart run openclaw_gateway:openclaw_gateway_cli nodes-list
dart run openclaw_gateway:openclaw_gateway_cli node-describe <node-id>
dart run openclaw_gateway:openclaw_gateway_cli node-invoke <node-id> system.notify --params '{"title":"Hello","body":"From Dart"}'
dart run openclaw_gateway:openclaw_gateway_cli events --name chat
echo '{"probe":true}' | dart run openclaw_gateway:openclaw_gateway_cli raw health
```

## Notes

- `chat-send` returns the gateway acknowledgement payload.
- `chat-watch` sends the request, listens for matching `chat` events, and stops
  when the final event arrives.
- `node-invoke` uses the typed node client and auto-generates the idempotency
  key when you do not pass `--idempotency-key`.
- `raw` is the escape hatch for gateway methods that do not have a typed helper
  yet.

## Node Host Workflow

The node-host executable is the easiest way to test end-to-end `node.invoke`
without depending on a first-party mobile or macOS app:

```sh
export OPENCLAW_GATEWAY_URL='ws://127.0.0.1:18789'
export OPENCLAW_GATEWAY_TOKEN='gateway-shared-token'

dart run openclaw_gateway:openclaw_gateway_node_host --approve-pairing
```

That executable:

- creates or reuses a persisted Ed25519 device identity
- stores role-scoped device tokens in its state file
- advertises `system.notify` by default, which is allowlisted by the gateway for
  unknown/dart node platforms
- can auto-approve the first pairing request when shared auth is available

Then invoke it from another shell:

```sh
dart run openclaw_gateway:openclaw_gateway_cli nodes-list
dart run openclaw_gateway:openclaw_gateway_cli node-invoke <node-id> system.notify --params '{"title":"Hello","body":"From Dart"}'
```
