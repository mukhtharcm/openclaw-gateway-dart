// Pure Dart client APIs for the OpenClaw gateway protocol.
//
// The package is suitable for Dart CLI tools, backend processes, and Flutter
// apps that need to connect to an OpenClaw gateway over WebSocket.

export 'src/auth.dart';
export 'src/chat_models.dart';
export 'src/client.dart';
export 'src/client_identity.dart';
export 'src/connect_error_details.dart';
export 'src/devices_client.dart';
export 'src/device_identity.dart';
export 'src/device_token_store.dart';
export 'src/errors.dart';
export 'src/identity_store.dart';
export 'src/models.dart';
export 'src/node_client.dart';
export 'src/node_models.dart';
export 'src/node_router.dart';
export 'src/nodes_client.dart';
export 'src/operator_client.dart';
export 'src/protocol.dart'
    show
        JsonList,
        JsonMap,
        defaultOperatorScopes,
        gatewayDefaultRole,
        gatewayNodeRole,
        gatewayOperatorRole,
        gatewayProtocolVersion;
