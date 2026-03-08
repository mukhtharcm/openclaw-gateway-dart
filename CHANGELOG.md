# Changelog

## Unreleased

- Added auto reconnect, connection lifecycle state streaming, and tick timeout
  detection to `GatewayClient`.
- Added reconnect-focused client tests and updated docs for app and Flutter
  usage.

## 0.1.0

- Initial public release.
- Added a pure Dart OpenClaw gateway client with handshake, RPC, and event
  stream support.
- Added typed operator helpers for health, status, config, sessions, and chat
  methods.
- Added a sample CLI executable for local gateway testing and debugging.
- Added docs, examples, tests, and CI.
