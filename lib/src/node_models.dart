import 'dart:convert';

import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Summary returned by `node.list` and `node.describe`.
class GatewayNodeSummary {
  const GatewayNodeSummary({
    required this.nodeId,
    required this.paired,
    required this.connected,
    this.displayName,
    this.platform,
    this.version,
    this.coreVersion,
    this.uiVersion,
    this.deviceFamily,
    this.modelIdentifier,
    this.remoteIp,
    this.caps = const <String>[],
    this.commands = const <String>[],
    this.pathEnv,
    this.permissions = const <String, bool>{},
    this.connectedAtMs,
  });

  factory GatewayNodeSummary.fromJson(JsonMap json) {
    return GatewayNodeSummary(
      nodeId: readRequiredString(json, 'nodeId', context: 'node summary'),
      displayName: readNullableString(json['displayName']),
      platform: readNullableString(json['platform']),
      version: readNullableString(json['version']),
      coreVersion: readNullableString(json['coreVersion']),
      uiVersion: readNullableString(json['uiVersion']),
      deviceFamily: readNullableString(json['deviceFamily']),
      modelIdentifier: readNullableString(json['modelIdentifier']),
      remoteIp: readNullableString(json['remoteIp']),
      caps: json['caps'] == null
          ? const <String>[]
          : readStringList(json['caps'], context: 'node summary.caps'),
      commands: json['commands'] == null
          ? const <String>[]
          : readStringList(json['commands'], context: 'node summary.commands'),
      pathEnv: readNullableString(json['pathEnv']),
      permissions: _readBoolMap(json['permissions']),
      connectedAtMs: readNullableInt(json['connectedAtMs']),
      paired: readRequiredBool(json, 'paired', context: 'node summary'),
      connected: readRequiredBool(json, 'connected', context: 'node summary'),
    );
  }

  final String nodeId;
  final String? displayName;
  final String? platform;
  final String? version;
  final String? coreVersion;
  final String? uiVersion;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? remoteIp;
  final List<String> caps;
  final List<String> commands;
  final String? pathEnv;
  final Map<String, bool> permissions;
  final int? connectedAtMs;
  final bool paired;
  final bool connected;
}

/// Incoming `node.invoke.request` event payload for node-role clients.
class GatewayNodeInvokeRequest {
  const GatewayNodeInvokeRequest({
    required this.id,
    required this.nodeId,
    required this.command,
    this.params,
    this.paramsJson,
    this.timeoutMs,
    this.idempotencyKey,
  });

  factory GatewayNodeInvokeRequest.fromJson(JsonMap json) {
    final paramsJson = readNullableString(json['paramsJSON']);
    final rawParams = json['params'];
    Object? params = rawParams;
    if (paramsJson != null) {
      params = jsonDecode(paramsJson);
    }
    return GatewayNodeInvokeRequest(
      id: readRequiredString(json, 'id', context: 'node.invoke.request'),
      nodeId: readRequiredString(
        json,
        'nodeId',
        context: 'node.invoke.request',
      ),
      command: readRequiredString(
        json,
        'command',
        context: 'node.invoke.request',
      ),
      params: params,
      paramsJson: paramsJson,
      timeoutMs: readNullableInt(json['timeoutMs']),
      idempotencyKey: readNullableString(json['idempotencyKey']),
    );
  }

  factory GatewayNodeInvokeRequest.fromEventFrame(GatewayEventFrame frame) {
    if (frame.event != 'node.invoke.request') {
      throw GatewayProtocolException(
        'Expected "node.invoke.request" event frame, got "${frame.event}".',
      );
    }
    return GatewayNodeInvokeRequest.fromJson(
      asJsonMap(frame.payload, context: 'node.invoke.request payload'),
    );
  }

  final String id;
  final String nodeId;
  final String command;
  final Object? params;
  final String? paramsJson;
  final int? timeoutMs;
  final String? idempotencyKey;
}

/// Error payload for `node.invoke.result`.
class GatewayNodeInvokeError {
  const GatewayNodeInvokeError({
    this.code,
    this.message,
  });

  factory GatewayNodeInvokeError.fromJson(JsonMap json) {
    return GatewayNodeInvokeError(
      code: readNullableString(json['code']),
      message: readNullableString(json['message']),
    );
  }

  final String? code;
  final String? message;

  JsonMap toJson() {
    return withoutNulls({
      'code': code,
      'message': message,
    });
  }
}

/// Typed success payload returned by `node.invoke`.
class GatewayNodeInvokeResult {
  const GatewayNodeInvokeResult({
    required this.ok,
    required this.nodeId,
    required this.command,
    this.payload,
    this.payloadJson,
  });

  factory GatewayNodeInvokeResult.fromJson(JsonMap json) {
    return GatewayNodeInvokeResult(
      ok: readRequiredBool(json, 'ok', context: 'node.invoke result'),
      nodeId: readRequiredString(json, 'nodeId', context: 'node.invoke result'),
      command: readRequiredString(
        json,
        'command',
        context: 'node.invoke result',
      ),
      payload: json['payload'],
      payloadJson: readNullableString(json['payloadJSON']),
    );
  }

  final bool ok;
  final String nodeId;
  final String command;
  final Object? payload;
  final String? payloadJson;
}

/// Typed result returned by `node.canvas.capability.refresh`.
class GatewayCanvasCapabilityRefreshResult {
  const GatewayCanvasCapabilityRefreshResult({
    required this.canvasCapability,
    required this.canvasCapabilityExpiresAtMs,
    required this.canvasHostUrl,
  });

  factory GatewayCanvasCapabilityRefreshResult.fromJson(JsonMap json) {
    return GatewayCanvasCapabilityRefreshResult(
      canvasCapability: readRequiredString(
        json,
        'canvasCapability',
        context: 'node.canvas.capability.refresh',
      ),
      canvasCapabilityExpiresAtMs: readRequiredInt(
        json,
        'canvasCapabilityExpiresAtMs',
        context: 'node.canvas.capability.refresh',
      ),
      canvasHostUrl: readRequiredString(
        json,
        'canvasHostUrl',
        context: 'node.canvas.capability.refresh',
      ),
    );
  }

  final String canvasCapability;
  final int canvasCapabilityExpiresAtMs;
  final String canvasHostUrl;
}

Map<String, bool> _readBoolMap(Object? value) {
  if (value == null) {
    return const <String, bool>{};
  }
  final json = asJsonMap(value, context: 'boolean map');
  final result = <String, bool>{};
  for (final entry in json.entries) {
    if (entry.value is bool) {
      result[entry.key] = entry.value! as bool;
    }
  }
  return Map.unmodifiable(result);
}
