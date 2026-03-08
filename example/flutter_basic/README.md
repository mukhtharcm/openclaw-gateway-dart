# OpenClaw Gateway Flutter Example

This example is a small Flutter app that connects to an OpenClaw gateway and
lets you:

- connect with a gateway URL and shared token
- inspect gateway health
- list recent sessions
- load chat history
- send a prompt and watch chat events update the UI

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
- It is meant as a starting point, not a production app shell.
- For real apps, back auth state and device tokens with secure storage.
