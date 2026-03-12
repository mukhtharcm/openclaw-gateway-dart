import 'dart:async';

import 'package:openclaw_gateway/src/auth.dart';
import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/node_models.dart';
import 'package:openclaw_gateway/src/tls.dart';

typedef GatewayNodeAvailabilityResolver = FutureOr<bool> Function();
typedef GatewayNodePermissionResolver = FutureOr<Map<String, bool>> Function();
typedef GatewayNodeCommandHandler = FutureOr<GatewayNodeCommandResult> Function(
  GatewayNodeCommandContext context,
);

/// Static or dynamic capability metadata for node-host sessions.
class GatewayNodeCapability {
  const GatewayNodeCapability({
    required this.name,
    this.isEnabled,
  });

  final String name;
  final GatewayNodeAvailabilityResolver? isEnabled;

  Future<bool> enabled() async {
    final resolver = isEnabled;
    if (resolver == null) {
      return true;
    }
    return await resolver();
  }
}

/// Declared node command metadata plus the invoke handler.
class GatewayNodeCommand {
  const GatewayNodeCommand({
    required this.name,
    required this.handler,
    this.capabilities = const <String>[],
    this.isAvailable,
  });

  final String name;
  final List<String> capabilities;
  final GatewayNodeAvailabilityResolver? isAvailable;
  final GatewayNodeCommandHandler handler;

  Future<bool> available() async {
    final resolver = isAvailable;
    if (resolver == null) {
      return true;
    }
    return await resolver();
  }
}

/// Resolved node connect metadata derived from a [GatewayNodeCapabilityRegistry].
class GatewayNodeConnectSnapshot {
  const GatewayNodeConnectSnapshot({
    required this.capabilities,
    required this.commands,
    required this.permissions,
  });

  final List<String> capabilities;
  final List<String> commands;
  final Map<String, bool> permissions;
}

/// Invoke context passed into node command handlers.
class GatewayNodeCommandContext {
  const GatewayNodeCommandContext({
    required this.client,
    required this.request,
  });

  final GatewayClient client;
  final GatewayNodeInvokeRequest request;

  String get id => request.id;
  String get nodeId => request.nodeId;
  String get command => request.command;
  Object? get params => request.params;
  int? get timeoutMs => request.timeoutMs;
  String? get idempotencyKey => request.idempotencyKey;
}

/// Structured node command handler result.
class GatewayNodeCommandResult {
  const GatewayNodeCommandResult({
    required this.ok,
    this.payload,
    this.payloadJson,
    this.error,
  });

  const GatewayNodeCommandResult.ok({
    Object? payload,
    String? payloadJson,
  }) : this(
          ok: true,
          payload: payload,
          payloadJson: payloadJson,
        );

  GatewayNodeCommandResult.error({
    String? code,
    String? message,
    Object? payload,
    String? payloadJson,
  }) : this(
          ok: false,
          payload: payload,
          payloadJson: payloadJson,
          error: GatewayNodeInvokeError(
            code: code,
            message: message,
          ),
        );

  final bool ok;
  final Object? payload;
  final String? payloadJson;
  final GatewayNodeInvokeError? error;
}

/// High-level registry for declared node capabilities, commands, and permissions.
class GatewayNodeCapabilityRegistry {
  GatewayNodeCapabilityRegistry({
    List<GatewayNodeCapability> capabilities = const <GatewayNodeCapability>[],
    List<GatewayNodeCommand> commands = const <GatewayNodeCommand>[],
    GatewayNodePermissionResolver? permissionsResolver,
  })  : capabilities = List.unmodifiable(capabilities),
        commands = List.unmodifiable(commands),
        _permissionsResolver = permissionsResolver;

  final List<GatewayNodeCapability> capabilities;
  final List<GatewayNodeCommand> commands;
  final GatewayNodePermissionResolver? _permissionsResolver;

  Future<GatewayNodeConnectSnapshot> snapshot() async {
    final resolvedCapabilities = <String>{};
    for (final capability in capabilities) {
      if (await capability.enabled()) {
        resolvedCapabilities.add(capability.name);
      }
    }

    final resolvedCommands = <String>[];
    for (final command in commands) {
      if (!await command.available()) {
        continue;
      }
      resolvedCommands.add(command.name);
      resolvedCapabilities.addAll(command.capabilities);
    }

    final permissions = await (_permissionsResolver?.call() ??
        Future<Map<String, bool>>.value(const <String, bool>{}));

    return GatewayNodeConnectSnapshot(
      capabilities: _sortedUniqueStrings(resolvedCapabilities),
      commands: _sortedUniqueStrings(resolvedCommands),
      permissions: _sortedBoolMap(permissions),
    );
  }

  Future<GatewayConnectOptions> buildConnectOptions({
    required Uri uri,
    required GatewayAuth auth,
    required GatewayClientInfo clientInfo,
    String? pathEnv,
    String? locale,
    String? userAgent,
    GatewayDeviceIdentity? deviceIdentity,
    GatewayDeviceTokenStore? deviceTokenStore,
    GatewayTlsPolicy? tlsPolicy,
    Duration connectChallengeTimeout = const Duration(seconds: 6),
    Duration connectResponseTimeout = const Duration(seconds: 12),
    Duration requestTimeout = const Duration(seconds: 15),
    bool autoReconnect = false,
    Duration reconnectInitialDelay = const Duration(milliseconds: 500),
    Duration reconnectMaxDelay = const Duration(seconds: 30),
    bool tickWatchEnabled = true,
    Duration tickWatchMinimumCheckInterval = const Duration(seconds: 1),
    int tickWatchMissedIntervals = 2,
  }) async {
    final snapshot = await this.snapshot();
    return GatewayConnectOptions.forNode(
      uri: uri,
      auth: auth,
      clientInfo: clientInfo,
      caps: snapshot.capabilities,
      commands: snapshot.commands,
      permissions: snapshot.permissions,
      pathEnv: pathEnv,
      locale: locale,
      userAgent: userAgent,
      deviceIdentity: deviceIdentity,
      deviceTokenStore: deviceTokenStore,
      tlsPolicy: tlsPolicy,
      connectChallengeTimeout: connectChallengeTimeout,
      connectResponseTimeout: connectResponseTimeout,
      requestTimeout: requestTimeout,
      autoReconnect: autoReconnect,
      reconnectInitialDelay: reconnectInitialDelay,
      reconnectMaxDelay: reconnectMaxDelay,
      tickWatchEnabled: tickWatchEnabled,
      tickWatchMinimumCheckInterval: tickWatchMinimumCheckInterval,
      tickWatchMissedIntervals: tickWatchMissedIntervals,
    );
  }

  Future<GatewayNodeCommand?> resolve(String commandName) async {
    for (final command in commands) {
      if (command.name != commandName) {
        continue;
      }
      if (!await command.available()) {
        return null;
      }
      return command;
    }
    return null;
  }

  Future<GatewayNodeCommandResult> dispatch(
    GatewayClient client,
    GatewayNodeInvokeRequest request,
  ) async {
    final command = await resolve(request.command);
    if (command == null) {
      return GatewayNodeCommandResult.error(
        code: 'unsupported_command',
        message: 'Unsupported command "${request.command}".',
      );
    }
    try {
      return await command.handler(
        GatewayNodeCommandContext(
          client: client,
          request: request,
        ),
      );
    } catch (error) {
      return GatewayNodeCommandResult.error(
        code: 'handler_error',
        message: error.toString(),
      );
    }
  }

  StreamSubscription<GatewayNodeInvokeRequest> attach(
    GatewayClient client, {
    bool cancelOnError = false,
  }) {
    return client.node.invokeRequests.listen(
      (request) {
        unawaited(_dispatchAndRespond(client, request));
      },
      cancelOnError: cancelOnError,
    );
  }

  Future<void> _dispatchAndRespond(
    GatewayClient client,
    GatewayNodeInvokeRequest request,
  ) async {
    final result = await dispatch(client, request);
    await client.node.sendInvokeResult(
      id: request.id,
      nodeId: request.nodeId,
      ok: result.ok,
      payload: result.payload,
      payloadJson: result.payloadJson,
      error: result.error,
    );
  }
}

List<String> _sortedUniqueStrings(Iterable<String> values) {
  return values
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

Map<String, bool> _sortedBoolMap(Map<String, bool> values) {
  final entries = values.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  return Map<String, bool>.unmodifiable(Map<String, bool>.fromEntries(entries));
}
