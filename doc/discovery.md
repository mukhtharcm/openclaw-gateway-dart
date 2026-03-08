# Discovery

`openclaw_gateway` includes local Bonjour/mDNS discovery for OpenClaw gateways
on `dart:io` platforms.

The public entrypoint is `GatewayMdnsDiscoveryClient`.

## Basic Usage

```dart
import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<void> main() async {
  final discovery = GatewayMdnsDiscoveryClient();
  final gateways = await discovery.discoverOnce();

  for (final gateway in gateways) {
    print(gateway.displayName);
    print(gateway.primaryUri);
  }
}
```

## Discovery Result

Each `GatewayDiscoveredGateway` includes:

- display name
- target host and port resolved from SRV
- IPv4 and IPv6 addresses resolved from A/AAAA
- TXT hints parsed into `GatewayDiscoveryHints`
- candidate `ws://` or `wss://` URIs
- a stable id suitable for TLS TOFU storage

## Trust Model

The SDK follows OpenClaw's discovery trust boundary:

- routing comes from PTR/SRV/A/AAAA resolution
- TXT is treated as metadata only
- TXT fingerprints are hints and do not override stored TLS pins

## Polling Watcher

`watch()` is a polling wrapper around repeated discovery:

```dart
final discovery = GatewayMdnsDiscoveryClient();

await for (final gateways in discovery.watch()) {
  print('found ${gateways.length} gateway(s)');
}
```

## CLI

The sample CLI exposes one-shot discovery:

```sh
dart run openclaw_gateway:openclaw_gateway_cli discover
```
