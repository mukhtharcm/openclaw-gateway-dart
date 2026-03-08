// Pure Dart client APIs for the OpenClaw gateway protocol.
//
// The package is suitable for Dart CLI tools, backend processes, and Flutter
// apps that need to connect to an OpenClaw gateway over WebSocket.

export 'src/auth.dart';
export 'src/client.dart';
export 'src/errors.dart';
export 'src/models.dart';
export 'src/operator_client.dart';
export 'src/protocol.dart'
    show JsonList, JsonMap, defaultOperatorScopes, gatewayProtocolVersion;
