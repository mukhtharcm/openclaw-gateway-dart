import 'package:openclaw_gateway/src/protocol.dart';

class GatewayScheduledRestart {
  const GatewayScheduledRestart({
    required this.ok,
    required this.pid,
    required this.signal,
    required this.delayMs,
    required this.coalesced,
    required this.cooldownMsApplied,
    this.reason,
    this.mode,
    this.raw = const <String, Object?>{},
  });

  factory GatewayScheduledRestart.fromJson(JsonMap json) {
    return GatewayScheduledRestart(
      ok: readRequiredBool(json, 'ok', context: 'scheduled restart'),
      pid: readRequiredInt(json, 'pid', context: 'scheduled restart'),
      signal: readRequiredString(json, 'signal', context: 'scheduled restart'),
      delayMs: readRequiredInt(json, 'delayMs', context: 'scheduled restart'),
      coalesced: readRequiredBool(
        json,
        'coalesced',
        context: 'scheduled restart',
      ),
      cooldownMsApplied: readRequiredInt(
        json,
        'cooldownMsApplied',
        context: 'scheduled restart',
      ),
      reason: readNullableString(json['reason']),
      mode: readNullableString(json['mode']),
      raw: json,
    );
  }

  final bool ok;
  final int pid;
  final String signal;
  final int delayMs;
  final bool coalesced;
  final int cooldownMsApplied;
  final String? reason;
  final String? mode;
  final JsonMap raw;
}

class GatewayRestartSentinel {
  const GatewayRestartSentinel({
    required this.path,
    required this.payload,
    this.raw = const <String, Object?>{},
  });

  factory GatewayRestartSentinel.fromJson(JsonMap json) {
    return GatewayRestartSentinel(
      path: readRequiredString(json, 'path', context: 'restart sentinel'),
      payload: asJsonMap(json['payload'], context: 'restart sentinel.payload'),
      raw: json,
    );
  }

  final String path;
  final JsonMap payload;
  final JsonMap raw;
}

class GatewayConfigWriteResult {
  const GatewayConfigWriteResult({
    required this.ok,
    required this.path,
    required this.config,
    this.restart,
    this.sentinel,
    this.raw = const <String, Object?>{},
  });

  factory GatewayConfigWriteResult.fromJson(JsonMap json) {
    return GatewayConfigWriteResult(
      ok: readRequiredBool(json, 'ok', context: 'config write'),
      path: readRequiredString(json, 'path', context: 'config write'),
      config: asJsonMap(json['config'], context: 'config write.config'),
      restart: json['restart'] == null
          ? null
          : GatewayScheduledRestart.fromJson(
              asJsonMap(json['restart'], context: 'config write.restart'),
            ),
      sentinel: json['sentinel'] == null
          ? null
          : GatewayRestartSentinel.fromJson(
              asJsonMap(json['sentinel'], context: 'config write.sentinel'),
            ),
      raw: json,
    );
  }

  final bool ok;
  final String path;
  final JsonMap config;
  final GatewayScheduledRestart? restart;
  final GatewayRestartSentinel? sentinel;
  final JsonMap raw;
}

class GatewaySessionResolvedModel {
  const GatewaySessionResolvedModel({
    this.modelProvider,
    this.model,
  });

  factory GatewaySessionResolvedModel.fromJson(JsonMap json) {
    return GatewaySessionResolvedModel(
      modelProvider: readNullableString(json['modelProvider']),
      model: readNullableString(json['model']),
    );
  }

  final String? modelProvider;
  final String? model;
}

class GatewaySessionMutationResult {
  const GatewaySessionMutationResult({
    required this.ok,
    required this.key,
    this.path,
    this.entry,
    this.resolved,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySessionMutationResult.fromJson(JsonMap json) {
    return GatewaySessionMutationResult(
      ok: readRequiredBool(json, 'ok', context: 'session mutation'),
      key: readRequiredString(json, 'key', context: 'session mutation'),
      path: readNullableString(json['path']),
      entry: json['entry'] == null
          ? null
          : asJsonMap(json['entry'], context: 'session mutation.entry'),
      resolved: json['resolved'] == null
          ? null
          : GatewaySessionResolvedModel.fromJson(
              asJsonMap(json['resolved'], context: 'session mutation.resolved'),
            ),
      raw: json,
    );
  }

  final bool ok;
  final String key;
  final String? path;
  final JsonMap? entry;
  final GatewaySessionResolvedModel? resolved;
  final JsonMap raw;
}

class GatewaySessionDeleteResult {
  const GatewaySessionDeleteResult({
    required this.ok,
    required this.key,
    required this.deleted,
    required this.archived,
    this.raw = const <String, Object?>{},
  });

  factory GatewaySessionDeleteResult.fromJson(JsonMap json) {
    return GatewaySessionDeleteResult(
      ok: readRequiredBool(json, 'ok', context: 'sessions.delete'),
      key: readRequiredString(json, 'key', context: 'sessions.delete'),
      deleted: readRequiredBool(json, 'deleted', context: 'sessions.delete'),
      archived: json['archived'] == null
          ? const <String>[]
          : readStringList(json['archived'],
              context: 'sessions.delete.archived'),
      raw: json,
    );
  }

  final bool ok;
  final String key;
  final bool deleted;
  final List<String> archived;
  final JsonMap raw;
}

class GatewaySessionCompactResult {
  const GatewaySessionCompactResult({
    required this.ok,
    required this.key,
    required this.compacted,
    this.kept,
    this.reason,
    this.archived = const <String>[],
    this.raw = const <String, Object?>{},
  });

  factory GatewaySessionCompactResult.fromJson(JsonMap json) {
    return GatewaySessionCompactResult(
      ok: readRequiredBool(json, 'ok', context: 'sessions.compact'),
      key: readRequiredString(json, 'key', context: 'sessions.compact'),
      compacted:
          readRequiredBool(json, 'compacted', context: 'sessions.compact'),
      kept: readNullableInt(json['kept']),
      reason: readNullableString(json['reason']),
      archived: json['archived'] == null
          ? const <String>[]
          : readStringList(
              json['archived'],
              context: 'sessions.compact.archived',
            ),
      raw: json,
    );
  }

  final bool ok;
  final String key;
  final bool compacted;
  final int? kept;
  final String? reason;
  final List<String> archived;
  final JsonMap raw;
}

class GatewayChannelLogoutResult {
  const GatewayChannelLogoutResult({
    required this.channel,
    required this.accountId,
    required this.cleared,
    this.loggedOut,
    this.raw = const <String, Object?>{},
  });

  factory GatewayChannelLogoutResult.fromJson(JsonMap json) {
    return GatewayChannelLogoutResult(
      channel: readRequiredString(json, 'channel', context: 'channels.logout'),
      accountId: readRequiredString(
        json,
        'accountId',
        context: 'channels.logout',
      ),
      cleared: readRequiredBool(json, 'cleared', context: 'channels.logout'),
      loggedOut: readNullableBool(json['loggedOut']),
      raw: json,
    );
  }

  final String channel;
  final String accountId;
  final bool cleared;
  final bool? loggedOut;
  final JsonMap raw;
}
