import 'package:openclaw_gateway/src/auth.dart';
import 'package:openclaw_gateway/src/device_identity.dart';
import 'package:openclaw_gateway/src/device_token_store.dart';
import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Describes the client identity sent to the gateway during `connect`.
class GatewayClientInfo {
  const GatewayClientInfo({
    required this.id,
    required this.version,
    required this.platform,
    required this.mode,
    this.displayName,
    this.deviceFamily,
    this.modelIdentifier,
    this.instanceId,
  });

  final String id;
  final String version;
  final String platform;
  final String mode;
  final String? displayName;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? instanceId;

  /// Serializes the client info payload for the `connect` request.
  JsonMap toJson() {
    return withoutNulls({
      'id': id,
      'displayName': displayName,
      'version': version,
      'platform': platform,
      'deviceFamily': deviceFamily,
      'modelIdentifier': modelIdentifier,
      'mode': mode,
      'instanceId': instanceId,
    });
  }
}

/// Options used to establish a gateway client connection.
class GatewayConnectOptions {
  GatewayConnectOptions({
    required this.uri,
    required this.auth,
    required this.clientInfo,
    this.role = gatewayDefaultRole,
    List<String>? scopes,
    List<String>? caps,
    List<String>? commands,
    Map<String, bool>? permissions,
    this.pathEnv,
    this.locale,
    this.userAgent,
    this.deviceIdentity,
    this.deviceTokenStore,
    this.connectChallengeTimeout = const Duration(seconds: 6),
    this.connectResponseTimeout = const Duration(seconds: 12),
    this.requestTimeout = const Duration(seconds: 15),
    this.autoReconnect = false,
    this.reconnectInitialDelay = const Duration(milliseconds: 500),
    this.reconnectMaxDelay = const Duration(seconds: 30),
    this.tickWatchEnabled = true,
    this.tickWatchMinimumCheckInterval = const Duration(seconds: 1),
    this.tickWatchMissedIntervals = 2,
  })  : scopes = List.unmodifiable(scopes ?? defaultOperatorScopes),
        caps = List.unmodifiable(caps ?? const <String>[]),
        commands = List.unmodifiable(commands ?? const <String>[]),
        permissions = Map.unmodifiable(permissions ?? const <String, bool>{});

  /// Builds operator-style connect options using the default operator scopes.
  factory GatewayConnectOptions.forOperator({
    required Uri uri,
    required GatewayAuth auth,
    required GatewayClientInfo clientInfo,
    List<String>? scopes,
    List<String>? caps,
    String? pathEnv,
    String? locale,
    String? userAgent,
    GatewayDeviceIdentity? deviceIdentity,
    GatewayDeviceTokenStore? deviceTokenStore,
    Duration connectChallengeTimeout = const Duration(seconds: 6),
    Duration connectResponseTimeout = const Duration(seconds: 12),
    Duration requestTimeout = const Duration(seconds: 15),
    bool autoReconnect = false,
    Duration reconnectInitialDelay = const Duration(milliseconds: 500),
    Duration reconnectMaxDelay = const Duration(seconds: 30),
    bool tickWatchEnabled = true,
    Duration tickWatchMinimumCheckInterval = const Duration(seconds: 1),
    int tickWatchMissedIntervals = 2,
  }) {
    return GatewayConnectOptions(
      uri: uri,
      auth: auth,
      clientInfo: clientInfo,
      role: gatewayDefaultRole,
      scopes: scopes ?? defaultOperatorScopes,
      caps: caps,
      pathEnv: pathEnv,
      locale: locale,
      userAgent: userAgent,
      deviceIdentity: deviceIdentity,
      deviceTokenStore: deviceTokenStore,
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

  /// Builds node-style connect options using the default node role and no scopes.
  factory GatewayConnectOptions.forNode({
    required Uri uri,
    required GatewayAuth auth,
    required GatewayClientInfo clientInfo,
    List<String>? caps,
    List<String>? commands,
    Map<String, bool>? permissions,
    String? pathEnv,
    String? locale,
    String? userAgent,
    GatewayDeviceIdentity? deviceIdentity,
    GatewayDeviceTokenStore? deviceTokenStore,
    Duration connectChallengeTimeout = const Duration(seconds: 6),
    Duration connectResponseTimeout = const Duration(seconds: 12),
    Duration requestTimeout = const Duration(seconds: 15),
    bool autoReconnect = false,
    Duration reconnectInitialDelay = const Duration(milliseconds: 500),
    Duration reconnectMaxDelay = const Duration(seconds: 30),
    bool tickWatchEnabled = true,
    Duration tickWatchMinimumCheckInterval = const Duration(seconds: 1),
    int tickWatchMissedIntervals = 2,
  }) {
    return GatewayConnectOptions(
      uri: uri,
      auth: auth,
      clientInfo: clientInfo,
      role: gatewayNodeRole,
      scopes: const <String>[],
      caps: caps,
      commands: commands,
      permissions: permissions,
      pathEnv: pathEnv,
      locale: locale,
      userAgent: userAgent,
      deviceIdentity: deviceIdentity,
      deviceTokenStore: deviceTokenStore,
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

  final Uri uri;
  final GatewayAuth auth;
  final GatewayClientInfo clientInfo;
  final String role;
  final List<String> scopes;
  final List<String> caps;
  final List<String> commands;
  final Map<String, bool> permissions;
  final String? pathEnv;
  final String? locale;
  final String? userAgent;
  final GatewayDeviceIdentity? deviceIdentity;
  final GatewayDeviceTokenStore? deviceTokenStore;
  final Duration connectChallengeTimeout;
  final Duration connectResponseTimeout;
  final Duration requestTimeout;
  final bool autoReconnect;
  final Duration reconnectInitialDelay;
  final Duration reconnectMaxDelay;
  final bool tickWatchEnabled;
  final Duration tickWatchMinimumCheckInterval;
  final int tickWatchMissedIntervals;

  /// Serializes the `connect` request parameters.
  JsonMap toConnectParams() {
    return withoutNulls({
      'minProtocol': gatewayProtocolVersion,
      'maxProtocol': gatewayProtocolVersion,
      'client': clientInfo.toJson(),
      'caps': caps.isEmpty ? null : caps,
      'commands': commands.isEmpty ? null : commands,
      'permissions': permissions.isEmpty ? null : permissions,
      'pathEnv': pathEnv,
      'role': role,
      'scopes': scopes.isEmpty ? null : scopes,
      'auth': auth.toJson(),
      'locale': locale,
      'userAgent': userAgent,
    });
  }
}

/// High-level lifecycle phases for the gateway socket.
enum GatewayConnectionPhase {
  disconnected,
  connecting,
  connected,
  reconnecting,
  closed,
}

/// Current lifecycle state for a [GatewayClient] connection.
class GatewayConnectionState {
  const GatewayConnectionState({
    required this.phase,
    this.attempt = 0,
    this.error,
    this.hello,
  });

  final GatewayConnectionPhase phase;
  final int attempt;
  final GatewayException? error;
  final GatewayHelloOk? hello;

  /// Whether the gateway handshake is currently complete.
  bool get isConnected => phase == GatewayConnectionPhase.connected;
}

/// Gateway server metadata returned in the `hello-ok` payload.
class GatewayServerInfo {
  const GatewayServerInfo({
    required this.version,
    required this.connId,
  });

  factory GatewayServerInfo.fromJson(JsonMap json) {
    return GatewayServerInfo(
      version: readRequiredString(json, 'version', context: 'hello-ok.server'),
      connId: readRequiredString(json, 'connId', context: 'hello-ok.server'),
    );
  }

  final String version;
  final String connId;
}

/// Advertised gateway methods and events returned in `hello-ok`.
class GatewayFeatures {
  const GatewayFeatures({
    required this.methods,
    required this.events,
  });

  factory GatewayFeatures.fromJson(JsonMap json) {
    return GatewayFeatures(
      methods:
          readStringList(json['methods'], context: 'hello-ok.features.methods'),
      events:
          readStringList(json['events'], context: 'hello-ok.features.events'),
    );
  }

  final List<String> methods;
  final List<String> events;
}

/// Authentication state returned in the `hello-ok` payload.
class GatewayHelloAuth {
  const GatewayHelloAuth({
    required this.deviceToken,
    required this.role,
    required this.scopes,
    this.issuedAtMs,
  });

  factory GatewayHelloAuth.fromJson(JsonMap json) {
    return GatewayHelloAuth(
      deviceToken:
          readRequiredString(json, 'deviceToken', context: 'hello-ok.auth'),
      role: readRequiredString(json, 'role', context: 'hello-ok.auth'),
      scopes: readStringList(json['scopes'], context: 'hello-ok.auth.scopes'),
      issuedAtMs: readNullableInt(json['issuedAtMs']),
    );
  }

  final String deviceToken;
  final String role;
  final List<String> scopes;
  final int? issuedAtMs;
}

/// Gateway policy limits returned in the `hello-ok` payload.
class GatewayPolicy {
  const GatewayPolicy({
    required this.maxPayload,
    required this.maxBufferedBytes,
    required this.tickIntervalMs,
  });

  factory GatewayPolicy.fromJson(JsonMap json) {
    return GatewayPolicy(
      maxPayload:
          readRequiredInt(json, 'maxPayload', context: 'hello-ok.policy'),
      maxBufferedBytes: readRequiredInt(
        json,
        'maxBufferedBytes',
        context: 'hello-ok.policy',
      ),
      tickIntervalMs: readRequiredInt(
        json,
        'tickIntervalMs',
        context: 'hello-ok.policy',
      ),
    );
  }

  final int maxPayload;
  final int maxBufferedBytes;
  final int tickIntervalMs;
}

/// Parsed `hello-ok` payload returned after a successful `connect`.
class GatewayHelloOk {
  const GatewayHelloOk({
    required this.protocol,
    required this.server,
    required this.features,
    required this.snapshot,
    required this.policy,
    this.canvasHostUrl,
    this.auth,
  });

  factory GatewayHelloOk.fromJson(JsonMap json) {
    final type = readRequiredString(json, 'type', context: 'hello-ok');
    if (type != 'hello-ok') {
      throw GatewayProtocolException('Expected hello-ok payload, got "$type".');
    }

    final authValue = json['auth'];
    return GatewayHelloOk(
      protocol: readRequiredInt(json, 'protocol', context: 'hello-ok'),
      server: GatewayServerInfo.fromJson(
        asJsonMap(json['server'], context: 'hello-ok.server'),
      ),
      features: GatewayFeatures.fromJson(
        asJsonMap(json['features'], context: 'hello-ok.features'),
      ),
      snapshot: asJsonMap(json['snapshot'], context: 'hello-ok.snapshot'),
      canvasHostUrl: readNullableString(json['canvasHostUrl']),
      auth: authValue == null
          ? null
          : GatewayHelloAuth.fromJson(
              asJsonMap(authValue, context: 'hello-ok.auth'),
            ),
      policy: GatewayPolicy.fromJson(
        asJsonMap(json['policy'], context: 'hello-ok.policy'),
      ),
    );
  }

  final int protocol;
  final GatewayServerInfo server;
  final GatewayFeatures features;
  final JsonMap snapshot;
  final String? canvasHostUrl;
  final GatewayHelloAuth? auth;
  final GatewayPolicy policy;
}

/// Error payload returned in a gateway response frame.
class GatewayErrorShape {
  const GatewayErrorShape({
    required this.code,
    required this.message,
    this.details,
    this.retryable,
    this.retryAfterMs,
  });

  factory GatewayErrorShape.fromJson(JsonMap json) {
    return GatewayErrorShape(
      code: readRequiredString(json, 'code', context: 'response.error'),
      message: readRequiredString(json, 'message', context: 'response.error'),
      details: json['details'],
      retryable: json['retryable'] as bool?,
      retryAfterMs: readNullableInt(json['retryAfterMs']),
    );
  }

  final String code;
  final String message;
  final Object? details;
  final bool? retryable;
  final int? retryAfterMs;
}

/// Parsed gateway response frame.
class GatewayResponseFrame {
  const GatewayResponseFrame({
    required this.id,
    required this.ok,
    this.payload,
    this.error,
  });

  factory GatewayResponseFrame.fromJson(JsonMap json) {
    return GatewayResponseFrame(
      id: readRequiredString(json, 'id', context: 'response frame'),
      ok: readRequiredBool(json, 'ok', context: 'response frame'),
      payload: json['payload'],
      error: json['error'] == null
          ? null
          : GatewayErrorShape.fromJson(
              asJsonMap(json['error'], context: 'response.error'),
            ),
    );
  }

  final String id;
  final bool ok;
  final Object? payload;
  final GatewayErrorShape? error;
}

/// Parsed gateway event frame.
class GatewayEventFrame {
  const GatewayEventFrame({
    required this.event,
    this.payload,
    this.seq,
    this.stateVersion,
  });

  factory GatewayEventFrame.fromJson(JsonMap json) {
    return GatewayEventFrame(
      event: readRequiredString(json, 'event', context: 'event frame'),
      payload: json['payload'],
      seq: readNullableInt(json['seq']),
      stateVersion: json['stateVersion'],
    );
  }

  final String event;
  final Object? payload;
  final int? seq;
  final Object? stateVersion;
}

/// Parsed gateway-initiated request frame.
class GatewayIncomingRequestFrame {
  const GatewayIncomingRequestFrame({
    required this.id,
    required this.method,
    this.params,
  });

  factory GatewayIncomingRequestFrame.fromJson(JsonMap json) {
    return GatewayIncomingRequestFrame(
      id: readRequiredString(json, 'id', context: 'request frame'),
      method: readRequiredString(json, 'method', context: 'request frame'),
      params: json['params'],
    );
  }

  final String id;
  final String method;
  final Object? params;
}
