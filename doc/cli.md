# CLI

`openclaw_gateway` ships with a small optional CLI executable for manual
testing, local debugging, and smoke tests.

## Run

```sh
dart run openclaw_gateway:openclaw_gateway_cli --help
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
- `events`
- `raw`

## Examples

```sh
dart run openclaw_gateway:openclaw_gateway_cli health
dart run openclaw_gateway:openclaw_gateway_cli sessions-list --limit 10
dart run openclaw_gateway:openclaw_gateway_cli chat-history main --limit 20
dart run openclaw_gateway:openclaw_gateway_cli chat-send main "hello from dart"
dart run openclaw_gateway:openclaw_gateway_cli chat-watch main "Reply with exactly: ok"
dart run openclaw_gateway:openclaw_gateway_cli events --name chat
echo '{"probe":true}' | dart run openclaw_gateway:openclaw_gateway_cli raw health
```

## Notes

- `chat-send` returns the gateway acknowledgement payload.
- `chat-watch` sends the request, listens for matching `chat` events, and stops
  when the final event arrives.
- `raw` is the escape hatch for gateway methods that do not have a typed helper
  yet.
