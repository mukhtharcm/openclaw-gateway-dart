# OpenClaw Gateway Flutter Example

This example is a small Flutter app that connects to an OpenClaw gateway and
acts like a compact gateway workbench. It lets you:

- connect with a gateway URL and shared token
- inspect gateway metadata, health, usage, cron, and voice wake status
- browse recent sessions and session previews
- load chat history and send prompts
- inspect channels, models, tools, and paired nodes
- watch a live event feed alongside the local activity log

## Run On macOS

From the package root:

```sh
cd example/flutter_basic
flutter pub get
flutter run -d macos
```

## Run On Linux

```sh
cd example/flutter_basic
flutter pub get
flutter run -d linux
```

## Local Gateway Defaults

The example defaults the gateway URL field to:

```text
ws://127.0.0.1:18789
```

Paste your gateway token into the app UI at runtime. Do not hardcode it into
the example.

## Notes

- The app depends on the local package source via `path: ../..`.
- The macOS runner now includes outbound network sandbox access plus local
  networking ATS allowance for the default `ws://127.0.0.1:18789` gateway
  workflow.
- It is meant as a starting point and inspection tool, not a production app
  shell.
- For real apps, back auth state and device tokens with secure storage.
- If you already built the macOS app before pulling this fix, run
  `flutter clean` once before `flutter run -d macos`.
