# Changelog

## Unreleased

- Added auto reconnect, connection lifecycle state streaming, and tick timeout
  detection to `GatewayClient`.
- Added allowlisted gateway client id and mode constants.
- Added Ed25519 device identities and pluggable device-token persistence for
  authenticated reconnects and paired-device flows.
- Added typed operator wrappers for channels, config schema/apply, sessions
  patch/reset/delete/compact, models, tools, agents, voice wake, and cron.
- Added dedicated operator-side node and device clients plus node-role helpers
  for `node.invoke.request`, `node.invoke.result`, `node.event`, and canvas
  capability refresh.
- Added typed CLI helpers for `nodes-list`, `node-describe`, and `node-invoke`,
  plus a dedicated sample node-host executable with persisted identity/token
  state and optional pairing approval.
- Expanded tests, examples, and docs for app, Flutter, device-auth, and
  node-mode usage, including a live end-to-end `node.invoke` smoke test.

## 0.1.0

- Initial public release.
- Added a pure Dart OpenClaw gateway client with handshake, RPC, and event
  stream support.
- Added typed operator helpers for health, status, config, sessions, and chat
  methods.
- Added a sample CLI executable for local gateway testing and debugging.
- Added docs, examples, tests, and CI.
