// Pure Dart client APIs for the OpenClaw gateway protocol.
//
// The package is suitable for Dart CLI tools, backend processes, and Flutter
// apps that need to connect to an OpenClaw gateway over WebSocket.

export 'src/admin_client.dart';
export 'src/admin_models.dart';
export 'src/auth.dart';
export 'src/automation_models.dart';
export 'src/chat_models.dart';
export 'src/client.dart';
export 'src/client_identity.dart';
export 'src/contract.dart';
export 'src/connect_error_details.dart';
export 'src/discovery_models.dart';
export 'src/discovery_stub.dart'
    if (dart.library.io) 'src/io/discovery_io.dart';
export 'src/devices_client.dart';
export 'src/device_identity.dart';
export 'src/device_token_store.dart';
export 'src/event_models.dart';
export 'src/errors.dart';
export 'src/generated_protocol_dtos.dart';
export 'src/identity_store.dart';
export 'src/models.dart';
export 'src/mutation_models.dart';
export 'src/node_client.dart';
export 'src/node_models.dart';
export 'src/node_router.dart';
export 'src/nodes_client.dart';
export 'src/operator_client.dart';
export 'src/query_client.dart';
export 'src/query_models.dart';
export 'src/tls.dart';
export 'src/tls_probe_stub.dart'
    if (dart.library.io) 'src/io/tls_probe_io.dart';
export 'src/protocol.dart'
    show
        JsonList,
        JsonMap,
        defaultOperatorScopes,
        gatewayDefaultRole,
        gatewayNodeRole,
        gatewayOperatorRole,
        gatewayProtocolVersion;
export 'src/storage.dart';
