import 'dart:convert';

import 'package:openclaw_gateway/src/chat_models.dart';
import 'package:openclaw_gateway/src/models.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Base class for typed gateway push events.
abstract class GatewayTypedEvent {
  const GatewayTypedEvent({
    required this.eventName,
    this.seq,
    this.stateVersion,
  });

  final String eventName;
  final int? seq;
  final GatewayStateVersion? stateVersion;
}

/// Presence entry carried by the `presence` event.
class GatewayPresenceEntry {
  const GatewayPresenceEntry({
    required this.ts,
    this.host,
    this.ip,
    this.version,
    this.platform,
    this.deviceFamily,
    this.modelIdentifier,
    this.mode,
    this.lastInputSeconds,
    this.reason,
    this.tags = const <String>[],
    this.text,
    this.deviceId,
    this.roles = const <String>[],
    this.scopes = const <String>[],
    this.instanceId,
  });

  factory GatewayPresenceEntry.fromJson(JsonMap json) {
    return GatewayPresenceEntry(
      ts: readRequiredInt(json, 'ts', context: 'presence entry'),
      host: readNullableString(json['host']),
      ip: readNullableString(json['ip']),
      version: readNullableString(json['version']),
      platform: readNullableString(json['platform']),
      deviceFamily: readNullableString(json['deviceFamily']),
      modelIdentifier: readNullableString(json['modelIdentifier']),
      mode: readNullableString(json['mode']),
      lastInputSeconds: readNullableInt(json['lastInputSeconds']),
      reason: readNullableString(json['reason']),
      tags: json['tags'] == null
          ? const <String>[]
          : readStringList(json['tags'], context: 'presence entry.tags'),
      text: readNullableString(json['text']),
      deviceId: readNullableString(json['deviceId']),
      roles: json['roles'] == null
          ? const <String>[]
          : readStringList(json['roles'], context: 'presence entry.roles'),
      scopes: json['scopes'] == null
          ? const <String>[]
          : readStringList(json['scopes'], context: 'presence entry.scopes'),
      instanceId: readNullableString(json['instanceId']),
    );
  }

  final String? host;
  final String? ip;
  final String? version;
  final String? platform;
  final String? deviceFamily;
  final String? modelIdentifier;
  final String? mode;
  final int? lastInputSeconds;
  final String? reason;
  final List<String> tags;
  final String? text;
  final int ts;
  final String? deviceId;
  final List<String> roles;
  final List<String> scopes;
  final String? instanceId;
}

class GatewayPresenceEvent extends GatewayTypedEvent {
  const GatewayPresenceEvent({
    required this.presence,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'presence');

  factory GatewayPresenceEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'presence');
    return GatewayPresenceEvent(
      presence: readJsonMapList(payload['presence'], context: 'presence')
          .map(GatewayPresenceEntry.fromJson)
          .toList(growable: false),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final List<GatewayPresenceEntry> presence;
}

class GatewayTickEvent extends GatewayTypedEvent {
  const GatewayTickEvent({
    required this.ts,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'tick');

  factory GatewayTickEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'tick');
    return GatewayTickEvent(
      ts: readRequiredInt(payload, 'ts', context: 'tick'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final int ts;
}

class GatewayShutdownEvent extends GatewayTypedEvent {
  const GatewayShutdownEvent({
    required this.reason,
    this.restartExpectedMs,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'shutdown');

  factory GatewayShutdownEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'shutdown');
    return GatewayShutdownEvent(
      reason: readRequiredString(payload, 'reason', context: 'shutdown'),
      restartExpectedMs: readNullableInt(payload['restartExpectedMs']),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String reason;
  final int? restartExpectedMs;
}

class GatewayHealthEvent extends GatewayTypedEvent {
  const GatewayHealthEvent({
    required this.ok,
    required this.ts,
    required this.channels,
    required this.channelOrder,
    required this.channelLabels,
    required this.agents,
    required this.sessions,
    required this.raw,
    this.durationMs,
    this.heartbeatSeconds,
    this.defaultAgentId,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'health');

  factory GatewayHealthEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'health');
    return GatewayHealthEvent(
      ok: readRequiredBool(payload, 'ok', context: 'health'),
      ts: readRequiredInt(payload, 'ts', context: 'health'),
      durationMs: readNullableInt(payload['durationMs']),
      channels: payload['channels'] == null
          ? const <String, Object?>{}
          : asJsonMap(payload['channels'], context: 'health.channels'),
      channelOrder: payload['channelOrder'] == null
          ? const <String>[]
          : readStringList(
              payload['channelOrder'],
              context: 'health.channelOrder',
            ),
      channelLabels: payload['channelLabels'] == null
          ? const <String, String>{}
          : readStringMap(
              payload['channelLabels'],
              context: 'health.channelLabels',
            ),
      heartbeatSeconds: readNullableInt(payload['heartbeatSeconds']),
      defaultAgentId: readNullableString(payload['defaultAgentId']),
      agents: payload['agents'],
      sessions: payload['sessions'],
      raw: payload,
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final bool ok;
  final int ts;
  final int? durationMs;
  final JsonMap channels;
  final List<String> channelOrder;
  final Map<String, String> channelLabels;
  final int? heartbeatSeconds;
  final String? defaultAgentId;
  final Object? agents;
  final Object? sessions;
  final JsonMap raw;
}

class GatewayHeartbeatEvent extends GatewayTypedEvent {
  const GatewayHeartbeatEvent({
    required this.ts,
    required this.status,
    required this.raw,
    this.to,
    this.accountId,
    this.preview,
    this.durationMs,
    this.hasMedia,
    this.reason,
    this.channel,
    this.silent,
    this.indicatorType,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'heartbeat');

  factory GatewayHeartbeatEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'heartbeat');
    return GatewayHeartbeatEvent(
      ts: readRequiredInt(payload, 'ts', context: 'heartbeat'),
      status: readRequiredString(payload, 'status', context: 'heartbeat'),
      to: readNullableString(payload['to']),
      accountId: readNullableString(payload['accountId']),
      preview: readNullableString(payload['preview']),
      durationMs: readNullableInt(payload['durationMs']),
      hasMedia: readNullableBool(payload['hasMedia']),
      reason: readNullableString(payload['reason']),
      channel: readNullableString(payload['channel']),
      silent: readNullableBool(payload['silent']),
      indicatorType: readNullableString(payload['indicatorType']),
      raw: payload,
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final int ts;
  final String status;
  final String? to;
  final String? accountId;
  final String? preview;
  final int? durationMs;
  final bool? hasMedia;
  final String? reason;
  final String? channel;
  final bool? silent;
  final String? indicatorType;
  final JsonMap raw;
}

class GatewayCronEvent extends GatewayTypedEvent {
  const GatewayCronEvent({
    required this.jobId,
    required this.action,
    required this.raw,
    this.status,
    this.error,
    this.summary,
    this.sessionId,
    this.sessionKey,
    this.runAtMs,
    this.durationMs,
    this.nextRunAtMs,
    this.delivered,
    this.deliveryStatus,
    this.deliveryError,
    this.model,
    this.provider,
    this.jobName,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'cron');

  factory GatewayCronEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'cron');
    return GatewayCronEvent(
      jobId: readRequiredString(payload, 'jobId', context: 'cron'),
      action: readRequiredString(payload, 'action', context: 'cron'),
      status: readNullableString(payload['status']),
      error: readNullableString(payload['error']),
      summary: readNullableString(payload['summary']),
      sessionId: readNullableString(payload['sessionId']),
      sessionKey: readNullableString(payload['sessionKey']),
      runAtMs: readNullableInt(payload['runAtMs']),
      durationMs: readNullableInt(payload['durationMs']),
      nextRunAtMs: readNullableInt(payload['nextRunAtMs']),
      delivered: readNullableBool(payload['delivered']),
      deliveryStatus: readNullableString(payload['deliveryStatus']),
      deliveryError: readNullableString(payload['deliveryError']),
      model: readNullableString(payload['model']),
      provider: readNullableString(payload['provider']),
      jobName: readNullableString(payload['jobName']),
      raw: payload,
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String jobId;
  final String action;
  final String? status;
  final String? error;
  final String? summary;
  final String? sessionId;
  final String? sessionKey;
  final int? runAtMs;
  final int? durationMs;
  final int? nextRunAtMs;
  final bool? delivered;
  final String? deliveryStatus;
  final String? deliveryError;
  final String? model;
  final String? provider;
  final String? jobName;
  final JsonMap raw;
}

class GatewayTalkModeEvent extends GatewayTypedEvent {
  const GatewayTalkModeEvent({
    required this.enabled,
    required this.ts,
    this.phase,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'talk.mode');

  factory GatewayTalkModeEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'talk.mode');
    return GatewayTalkModeEvent(
      enabled: readRequiredBool(payload, 'enabled', context: 'talk.mode'),
      phase: readNullableString(payload['phase']),
      ts: readRequiredInt(payload, 'ts', context: 'talk.mode'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final bool enabled;
  final String? phase;
  final int ts;
}

class GatewayNodePairRequestedEvent extends GatewayTypedEvent {
  const GatewayNodePairRequestedEvent({
    required this.requestId,
    required this.nodeId,
    required this.ts,
    required this.permissions,
    this.displayName,
    this.platform,
    this.version,
    this.coreVersion,
    this.uiVersion,
    this.deviceFamily,
    this.modelIdentifier,
    this.caps = const <String>[],
    this.commands = const <String>[],
    this.remoteIp,
    this.silent,
    this.isRepair,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'node.pair.requested');

  factory GatewayNodePairRequestedEvent.fromEventFrame(
      GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'node.pair.requested');
    return GatewayNodePairRequestedEvent(
      requestId: readRequiredString(
        payload,
        'requestId',
        context: 'node.pair.requested',
      ),
      nodeId: readRequiredString(payload, 'nodeId', context: 'node pair'),
      displayName: readNullableString(payload['displayName']),
      platform: readNullableString(payload['platform']),
      version: readNullableString(payload['version']),
      coreVersion: readNullableString(payload['coreVersion']),
      uiVersion: readNullableString(payload['uiVersion']),
      deviceFamily: readNullableString(payload['deviceFamily']),
      modelIdentifier: readNullableString(payload['modelIdentifier']),
      caps: payload['caps'] == null
          ? const <String>[]
          : readStringList(payload['caps'], context: 'node pair caps'),
      commands: payload['commands'] == null
          ? const <String>[]
          : readStringList(payload['commands'], context: 'node pair commands'),
      permissions: readBoolMap(
        payload['permissions'],
        context: 'node pair permissions',
      ),
      remoteIp: readNullableString(payload['remoteIp']),
      silent: readNullableBool(payload['silent']),
      isRepair: readNullableBool(payload['isRepair']),
      ts: readRequiredInt(payload, 'ts', context: 'node pair'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String requestId;
  final String nodeId;
  final String? displayName;
  final String? platform;
  final String? version;
  final String? coreVersion;
  final String? uiVersion;
  final String? deviceFamily;
  final String? modelIdentifier;
  final List<String> caps;
  final List<String> commands;
  final Map<String, bool> permissions;
  final String? remoteIp;
  final bool? silent;
  final bool? isRepair;
  final int ts;
}

class GatewayNodePairResolvedEvent extends GatewayTypedEvent {
  const GatewayNodePairResolvedEvent({
    required this.requestId,
    required this.nodeId,
    required this.decision,
    required this.ts,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'node.pair.resolved');

  factory GatewayNodePairResolvedEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'node.pair.resolved');
    return GatewayNodePairResolvedEvent(
      requestId: readRequiredString(payload, 'requestId', context: 'node pair'),
      nodeId: readRequiredString(payload, 'nodeId', context: 'node pair'),
      decision: readRequiredString(payload, 'decision', context: 'node pair'),
      ts: readRequiredInt(payload, 'ts', context: 'node pair'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String requestId;
  final String nodeId;
  final String decision;
  final int ts;
}

class GatewayDevicePairRequestedEvent extends GatewayTypedEvent {
  const GatewayDevicePairRequestedEvent({
    required this.requestId,
    required this.deviceId,
    required this.publicKey,
    required this.ts,
    this.displayName,
    this.platform,
    this.deviceFamily,
    this.clientId,
    this.clientMode,
    this.role,
    this.roles = const <String>[],
    this.scopes = const <String>[],
    this.remoteIp,
    this.silent,
    this.isRepair,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'device.pair.requested');

  factory GatewayDevicePairRequestedEvent.fromEventFrame(
    GatewayEventFrame frame,
  ) {
    final payload = _readEventPayload(frame, 'device.pair.requested');
    return GatewayDevicePairRequestedEvent(
      requestId: readRequiredString(
        payload,
        'requestId',
        context: 'device pair',
      ),
      deviceId: readRequiredString(payload, 'deviceId', context: 'device pair'),
      publicKey: readRequiredString(
        payload,
        'publicKey',
        context: 'device pair',
      ),
      displayName: readNullableString(payload['displayName']),
      platform: readNullableString(payload['platform']),
      deviceFamily: readNullableString(payload['deviceFamily']),
      clientId: readNullableString(payload['clientId']),
      clientMode: readNullableString(payload['clientMode']),
      role: readNullableString(payload['role']),
      roles: payload['roles'] == null
          ? const <String>[]
          : readStringList(payload['roles'], context: 'device pair roles'),
      scopes: payload['scopes'] == null
          ? const <String>[]
          : readStringList(payload['scopes'], context: 'device pair scopes'),
      remoteIp: readNullableString(payload['remoteIp']),
      silent: readNullableBool(payload['silent']),
      isRepair: readNullableBool(payload['isRepair']),
      ts: readRequiredInt(payload, 'ts', context: 'device pair'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String requestId;
  final String deviceId;
  final String publicKey;
  final String? displayName;
  final String? platform;
  final String? deviceFamily;
  final String? clientId;
  final String? clientMode;
  final String? role;
  final List<String> roles;
  final List<String> scopes;
  final String? remoteIp;
  final bool? silent;
  final bool? isRepair;
  final int ts;
}

class GatewayDevicePairResolvedEvent extends GatewayTypedEvent {
  const GatewayDevicePairResolvedEvent({
    required this.requestId,
    required this.deviceId,
    required this.decision,
    required this.ts,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'device.pair.resolved');

  factory GatewayDevicePairResolvedEvent.fromEventFrame(
    GatewayEventFrame frame,
  ) {
    final payload = _readEventPayload(frame, 'device.pair.resolved');
    return GatewayDevicePairResolvedEvent(
      requestId: readRequiredString(
        payload,
        'requestId',
        context: 'device pair',
      ),
      deviceId: readRequiredString(payload, 'deviceId', context: 'device pair'),
      decision: readRequiredString(payload, 'decision', context: 'device pair'),
      ts: readRequiredInt(payload, 'ts', context: 'device pair'),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String requestId;
  final String deviceId;
  final String decision;
  final int ts;
}

class GatewayVoiceWakeChangedEvent extends GatewayTypedEvent {
  const GatewayVoiceWakeChangedEvent({
    required this.triggers,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'voicewake.changed');

  factory GatewayVoiceWakeChangedEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'voicewake.changed');
    return GatewayVoiceWakeChangedEvent(
      triggers: readStringList(
        payload['triggers'],
        context: 'voicewake.changed',
      ),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final List<String> triggers;
}

class GatewayExecApprovalRequestDetails {
  const GatewayExecApprovalRequestDetails({
    required this.command,
    required this.raw,
    this.commandArgv = const <String>[],
    this.envKeys = const <String>[],
    this.cwd,
    this.nodeId,
    this.host,
    this.security,
    this.ask,
    this.agentId,
    this.resolvedPath,
    this.sessionKey,
    this.turnSourceChannel,
    this.turnSourceTo,
    this.turnSourceAccountId,
    this.turnSourceThreadId,
    this.systemRunBinding,
    this.systemRunPlan,
  });

  factory GatewayExecApprovalRequestDetails.fromJson(JsonMap json) {
    return GatewayExecApprovalRequestDetails(
      command: readRequiredString(
        json,
        'command',
        context: 'exec approval request',
      ),
      commandArgv: json['commandArgv'] == null
          ? const <String>[]
          : readStringList(
              json['commandArgv'],
              context: 'exec approval request.commandArgv',
            ),
      envKeys: json['envKeys'] == null
          ? const <String>[]
          : readStringList(
              json['envKeys'],
              context: 'exec approval request.envKeys',
            ),
      cwd: readNullableString(json['cwd']),
      nodeId: readNullableString(json['nodeId']),
      host: readNullableString(json['host']),
      security: readNullableString(json['security']),
      ask: readNullableString(json['ask']),
      agentId: readNullableString(json['agentId']),
      resolvedPath: readNullableString(json['resolvedPath']),
      sessionKey: readNullableString(json['sessionKey']),
      turnSourceChannel: readNullableString(json['turnSourceChannel']),
      turnSourceTo: readNullableString(json['turnSourceTo']),
      turnSourceAccountId: readNullableString(json['turnSourceAccountId']),
      turnSourceThreadId: readNullableString(json['turnSourceThreadId']),
      systemRunBinding: json['systemRunBinding'] == null
          ? null
          : asJsonMap(
              json['systemRunBinding'],
              context: 'exec approval request.systemRunBinding',
            ),
      systemRunPlan: json['systemRunPlan'] == null
          ? null
          : asJsonMap(
              json['systemRunPlan'],
              context: 'exec approval request.systemRunPlan',
            ),
      raw: json,
    );
  }

  final String command;
  final List<String> commandArgv;
  final List<String> envKeys;
  final String? cwd;
  final String? nodeId;
  final String? host;
  final String? security;
  final String? ask;
  final String? agentId;
  final String? resolvedPath;
  final String? sessionKey;
  final String? turnSourceChannel;
  final String? turnSourceTo;
  final String? turnSourceAccountId;
  final String? turnSourceThreadId;
  final JsonMap? systemRunBinding;
  final JsonMap? systemRunPlan;
  final JsonMap raw;
}

class GatewayExecApprovalRequestedEvent extends GatewayTypedEvent {
  const GatewayExecApprovalRequestedEvent({
    required this.id,
    required this.request,
    required this.createdAtMs,
    required this.expiresAtMs,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'exec.approval.requested');

  factory GatewayExecApprovalRequestedEvent.fromEventFrame(
    GatewayEventFrame frame,
  ) {
    final payload = _readEventPayload(frame, 'exec.approval.requested');
    return GatewayExecApprovalRequestedEvent(
      id: readRequiredString(payload, 'id', context: 'exec approval event'),
      request: GatewayExecApprovalRequestDetails.fromJson(
        asJsonMap(
          payload['request'],
          context: 'exec approval event.request',
        ),
      ),
      createdAtMs: readRequiredInt(
        payload,
        'createdAtMs',
        context: 'exec approval event',
      ),
      expiresAtMs: readRequiredInt(
        payload,
        'expiresAtMs',
        context: 'exec approval event',
      ),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String id;
  final GatewayExecApprovalRequestDetails request;
  final int createdAtMs;
  final int expiresAtMs;
}

class GatewayExecApprovalResolvedEvent extends GatewayTypedEvent {
  const GatewayExecApprovalResolvedEvent({
    required this.id,
    required this.decision,
    required this.ts,
    this.resolvedBy,
    this.request,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'exec.approval.resolved');

  factory GatewayExecApprovalResolvedEvent.fromEventFrame(
    GatewayEventFrame frame,
  ) {
    final payload = _readEventPayload(frame, 'exec.approval.resolved');
    return GatewayExecApprovalResolvedEvent(
      id: readRequiredString(payload, 'id', context: 'exec approval resolved'),
      decision: readRequiredString(
        payload,
        'decision',
        context: 'exec approval resolved',
      ),
      resolvedBy: readNullableString(payload['resolvedBy']),
      ts: readRequiredInt(payload, 'ts', context: 'exec approval resolved'),
      request: payload['request'] == null
          ? null
          : GatewayExecApprovalRequestDetails.fromJson(
              asJsonMap(
                payload['request'],
                context: 'exec approval resolved.request',
              ),
            ),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String id;
  final String decision;
  final String? resolvedBy;
  final int ts;
  final GatewayExecApprovalRequestDetails? request;
}

class GatewayUpdateAvailableInfo {
  const GatewayUpdateAvailableInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.channel,
  });

  factory GatewayUpdateAvailableInfo.fromJson(JsonMap json) {
    return GatewayUpdateAvailableInfo(
      currentVersion: readRequiredString(
        json,
        'currentVersion',
        context: 'update.available',
      ),
      latestVersion: readRequiredString(
        json,
        'latestVersion',
        context: 'update.available',
      ),
      channel: readRequiredString(json, 'channel', context: 'update.available'),
    );
  }

  final String currentVersion;
  final String latestVersion;
  final String channel;
}

class GatewayUpdateAvailableEvent extends GatewayTypedEvent {
  const GatewayUpdateAvailableEvent({
    required this.updateAvailable,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'update.available');

  factory GatewayUpdateAvailableEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'update.available');
    return GatewayUpdateAvailableEvent(
      updateAvailable: payload['updateAvailable'] == null
          ? null
          : GatewayUpdateAvailableInfo.fromJson(
              asJsonMap(
                payload['updateAvailable'],
                context: 'update.available.updateAvailable',
              ),
            ),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final GatewayUpdateAvailableInfo? updateAvailable;
}

class GatewayAgentEvent extends GatewayTypedEvent {
  const GatewayAgentEvent({
    required this.runId,
    required this.stream,
    required this.ts,
    required this.data,
    this.payloadSeq,
    this.sessionKey,
    super.seq,
    super.stateVersion,
  }) : super(eventName: 'agent');

  factory GatewayAgentEvent.fromEventFrame(GatewayEventFrame frame) {
    final payload = _readEventPayload(frame, 'agent');
    return GatewayAgentEvent(
      runId: readRequiredString(payload, 'runId', context: 'agent'),
      payloadSeq: readNullableInt(payload['seq']),
      stream: readRequiredString(payload, 'stream', context: 'agent'),
      ts: readRequiredInt(payload, 'ts', context: 'agent'),
      data: payload['data'],
      sessionKey: readNullableString(payload['sessionKey']),
      seq: frame.seq,
      stateVersion: frame.stateVersion,
    );
  }

  final String runId;
  final int? payloadSeq;
  final String stream;
  final int ts;
  final Object? data;
  final String? sessionKey;

  String get streamName => stream;

  GatewayAgentLifecycleData? get lifecycleData {
    if (stream != 'lifecycle' || data == null) {
      return null;
    }
    return GatewayAgentLifecycleData.fromJson(
      asJsonMap(data, context: 'agent lifecycle data'),
    );
  }

  GatewayAgentAssistantData? get assistantData {
    if (stream != 'assistant' || data == null) {
      return null;
    }
    return GatewayAgentAssistantData.fromJson(
      asJsonMap(data, context: 'agent assistant data'),
    );
  }

  GatewayAgentToolData? get toolData {
    if (stream != 'tool' || data == null) {
      return null;
    }
    return GatewayAgentToolData.fromJson(
      asJsonMap(data, context: 'agent tool data'),
    );
  }
}

class GatewayAgentLifecycleData {
  const GatewayAgentLifecycleData({
    required this.phase,
    this.startedAt,
    this.endedAt,
    this.error,
    required this.raw,
  });

  factory GatewayAgentLifecycleData.fromJson(JsonMap json) {
    return GatewayAgentLifecycleData(
      phase: readRequiredString(json, 'phase', context: 'agent lifecycle data'),
      startedAt: readNullableString(json['startedAt']),
      endedAt: readNullableString(json['endedAt']),
      error: readNullableString(json['error']),
      raw: json,
    );
  }

  final String phase;
  final String? startedAt;
  final String? endedAt;
  final String? error;
  final JsonMap raw;
}

class GatewayAgentAssistantData {
  const GatewayAgentAssistantData({
    this.text,
    this.delta,
    this.mediaUrls = const <String>[],
    required this.raw,
  });

  factory GatewayAgentAssistantData.fromJson(JsonMap json) {
    return GatewayAgentAssistantData(
      text: readNullableString(json['text']),
      delta: readNullableString(json['delta']),
      mediaUrls: json['mediaUrls'] == null
          ? const <String>[]
          : readStringList(json['mediaUrls'], context: 'agent assistant media'),
      raw: json,
    );
  }

  final String? text;
  final String? delta;
  final List<String> mediaUrls;
  final JsonMap raw;
}

class GatewayAgentToolData {
  const GatewayAgentToolData({
    required this.phase,
    required this.raw,
    this.name,
    this.toolCallId,
    this.args,
    this.partialResult,
    this.meta,
    this.isError,
    this.result,
  });

  factory GatewayAgentToolData.fromJson(JsonMap json) {
    return GatewayAgentToolData(
      phase: readRequiredString(json, 'phase', context: 'agent tool data'),
      raw: json,
      name: readNullableString(json['name']),
      toolCallId: readNullableString(json['toolCallId']),
      args: json['args'],
      partialResult: json['partialResult'],
      meta: json['meta'],
      isError: readNullableBool(json['isError']),
      result: json['result'],
    );
  }

  final String phase;
  final JsonMap raw;
  final String? name;
  final String? toolCallId;
  final Object? args;
  final Object? partialResult;
  final Object? meta;
  final bool? isError;
  final Object? result;
}

/// Returns a compact human-readable summary for a gateway event frame.
String summarizeGatewayEventFrame(
  GatewayEventFrame frame, {
  int maxLength = 200,
}) {
  try {
    final summary = switch (frame.event) {
      'chat' => _summarizeChatEvent(
          GatewayChatEvent.fromEventFrame(frame),
          maxLength: maxLength,
        ),
      'presence' => _summarizePresenceEvent(
          GatewayPresenceEvent.fromEventFrame(frame),
        ),
      'tick' => _summarizeTickEvent(GatewayTickEvent.fromEventFrame(frame)),
      'shutdown' => _summarizeShutdownEvent(
          GatewayShutdownEvent.fromEventFrame(frame),
        ),
      'health' =>
        _summarizeHealthEvent(GatewayHealthEvent.fromEventFrame(frame)),
      'heartbeat' => _summarizeHeartbeatEvent(
          GatewayHeartbeatEvent.fromEventFrame(frame),
          maxLength: maxLength,
        ),
      'cron' => _summarizeCronEvent(GatewayCronEvent.fromEventFrame(frame)),
      'talk.mode' => _summarizeTalkModeEvent(
          GatewayTalkModeEvent.fromEventFrame(frame),
        ),
      'node.pair.requested' => _summarizeNodePairRequestedEvent(
          GatewayNodePairRequestedEvent.fromEventFrame(frame),
        ),
      'node.pair.resolved' => _summarizeNodePairResolvedEvent(
          GatewayNodePairResolvedEvent.fromEventFrame(frame),
        ),
      'device.pair.requested' => _summarizeDevicePairRequestedEvent(
          GatewayDevicePairRequestedEvent.fromEventFrame(frame),
        ),
      'device.pair.resolved' => _summarizeDevicePairResolvedEvent(
          GatewayDevicePairResolvedEvent.fromEventFrame(frame),
        ),
      'voicewake.changed' => _summarizeVoiceWakeChangedEvent(
          GatewayVoiceWakeChangedEvent.fromEventFrame(frame),
        ),
      'exec.approval.requested' => _summarizeExecApprovalRequestedEvent(
          GatewayExecApprovalRequestedEvent.fromEventFrame(frame),
        ),
      'exec.approval.resolved' => _summarizeExecApprovalResolvedEvent(
          GatewayExecApprovalResolvedEvent.fromEventFrame(frame),
        ),
      'update.available' => _summarizeUpdateAvailableEvent(
          GatewayUpdateAvailableEvent.fromEventFrame(frame),
        ),
      'agent' => _summarizeAgentEvent(
          GatewayAgentEvent.fromEventFrame(frame),
          maxLength: maxLength,
        ),
      _ => _fallbackEventSummary(frame, maxLength),
    };
    return _truncateEventSummary(summary, maxLength);
  } catch (_) {
    return _fallbackEventSummary(frame, maxLength);
  }
}

JsonMap _readEventPayload(GatewayEventFrame frame, String eventName) {
  if (frame.event != eventName) {
    throw StateError(
      'Expected "$eventName" event frame, got "${frame.event}".',
    );
  }
  return asJsonMap(frame.payload, context: '$eventName payload');
}

String _summarizeChatEvent(GatewayChatEvent event, {required int maxLength}) {
  final parts = <String>[event.sessionKey, event.state];
  final detail = event.errorMessage ??
      (event.message == null ? null : summarizeChatValue(event.message));
  if (detail?.trim().isNotEmpty == true) {
    parts.add(_truncateEventSummary(detail!, maxLength ~/ 2));
  }
  return parts.join(' · ');
}

String _summarizePresenceEvent(GatewayPresenceEvent event) {
  if (event.presence.isEmpty) {
    return 'no active clients';
  }
  final labels = event.presence
      .map(
        (entry) =>
            entry.host ??
            entry.deviceId ??
            entry.instanceId ??
            entry.platform ??
            entry.mode,
      )
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .take(3)
      .toList(growable: false);
  final head =
      '${event.presence.length} active client${event.presence.length == 1 ? '' : 's'}';
  return labels.isEmpty ? head : '$head · ${labels.join(', ')}';
}

String _summarizeTickEvent(GatewayTickEvent event) => 'tick ${event.ts}';

String _summarizeShutdownEvent(GatewayShutdownEvent event) {
  final parts = <String>[event.reason];
  if (event.restartExpectedMs != null) {
    parts.add('restart in ${event.restartExpectedMs} ms');
  }
  return parts.join(' · ');
}

String _summarizeHealthEvent(GatewayHealthEvent event) {
  final parts = <String>[event.ok ? 'healthy' : 'degraded'];
  final channelCount = event.channelOrder.isNotEmpty
      ? event.channelOrder.length
      : event.channels.length;
  if (channelCount > 0) {
    parts.add('$channelCount channel${channelCount == 1 ? '' : 's'}');
  }
  if (event.heartbeatSeconds != null) {
    parts.add('heartbeat ${event.heartbeatSeconds}s');
  }
  if (event.defaultAgentId?.trim().isNotEmpty == true) {
    parts.add('agent ${event.defaultAgentId}');
  }
  return parts.join(' · ');
}

String _summarizeHeartbeatEvent(
  GatewayHeartbeatEvent event, {
  required int maxLength,
}) {
  final parts = <String>[
    if (event.channel?.trim().isNotEmpty == true) event.channel!,
    event.status,
  ];
  if (event.preview?.trim().isNotEmpty == true) {
    parts.add(_truncateEventSummary(event.preview!, maxLength ~/ 2));
  } else if (event.reason?.trim().isNotEmpty == true) {
    parts.add(event.reason!);
  }
  return parts.join(' · ');
}

String _summarizeCronEvent(GatewayCronEvent event) {
  final parts = <String>[
    event.jobName?.trim().isNotEmpty == true ? event.jobName! : event.jobId,
    event.action,
  ];
  if (event.status?.trim().isNotEmpty == true) {
    parts.add(event.status!);
  } else if (event.error?.trim().isNotEmpty == true) {
    parts.add(event.error!);
  }
  return parts.join(' · ');
}

String _summarizeTalkModeEvent(GatewayTalkModeEvent event) {
  final parts = <String>[event.enabled ? 'enabled' : 'disabled'];
  if (event.phase?.trim().isNotEmpty == true) {
    parts.add(event.phase!);
  }
  return parts.join(' · ');
}

String _summarizeNodePairRequestedEvent(GatewayNodePairRequestedEvent event) {
  final parts = <String>[
    event.displayName?.trim().isNotEmpty == true
        ? event.displayName!
        : event.nodeId,
    'pair requested',
  ];
  if (event.commands.isNotEmpty) {
    parts.add(
        '${event.commands.length} command${event.commands.length == 1 ? '' : 's'}');
  } else if (event.caps.isNotEmpty) {
    parts.add('${event.caps.length} cap${event.caps.length == 1 ? '' : 's'}');
  }
  return parts.join(' · ');
}

String _summarizeNodePairResolvedEvent(GatewayNodePairResolvedEvent event) =>
    '${event.nodeId} · ${event.decision}';

String _summarizeDevicePairRequestedEvent(
  GatewayDevicePairRequestedEvent event,
) {
  final parts = <String>[
    event.displayName?.trim().isNotEmpty == true
        ? event.displayName!
        : event.deviceId,
    'pair requested',
  ];
  if (event.role?.trim().isNotEmpty == true) {
    parts.add(event.role!);
  } else if (event.roles.isNotEmpty) {
    parts.add(event.roles.join(', '));
  }
  return parts.join(' · ');
}

String _summarizeDevicePairResolvedEvent(
  GatewayDevicePairResolvedEvent event,
) =>
    '${event.deviceId} · ${event.decision}';

String _summarizeVoiceWakeChangedEvent(GatewayVoiceWakeChangedEvent event) {
  if (event.triggers.isEmpty) {
    return 'no wake triggers';
  }
  return '${event.triggers.length} wake trigger${event.triggers.length == 1 ? '' : 's'} · ${event.triggers.take(3).join(', ')}';
}

String _summarizeExecApprovalRequestedEvent(
  GatewayExecApprovalRequestedEvent event,
) {
  final parts = <String>[event.request.command];
  if (event.request.cwd?.trim().isNotEmpty == true) {
    parts.add(event.request.cwd!);
  }
  return parts.join(' · ');
}

String _summarizeExecApprovalResolvedEvent(
  GatewayExecApprovalResolvedEvent event,
) {
  final parts = <String>[
    event.request?.command ?? event.id,
    event.decision,
  ];
  if (event.resolvedBy?.trim().isNotEmpty == true) {
    parts.add(event.resolvedBy!);
  }
  return parts.join(' · ');
}

String _summarizeUpdateAvailableEvent(GatewayUpdateAvailableEvent event) {
  final update = event.updateAvailable;
  if (update == null) {
    return 'update available';
  }
  return '${update.currentVersion} → ${update.latestVersion} (${update.channel})';
}

String _summarizeAgentEvent(
  GatewayAgentEvent event, {
  required int maxLength,
}) {
  final lifecycle = event.lifecycleData;
  if (lifecycle != null) {
    final parts = <String>['lifecycle', lifecycle.phase];
    if (lifecycle.error?.trim().isNotEmpty == true) {
      parts.add(lifecycle.error!);
    }
    return parts.join(' · ');
  }

  final assistant = event.assistantData;
  if (assistant != null) {
    final text = assistant.delta ?? assistant.text;
    final parts = <String>['assistant'];
    if (text?.trim().isNotEmpty == true) {
      parts.add(_truncateEventSummary(text!, maxLength ~/ 2));
    } else if (assistant.mediaUrls.isNotEmpty) {
      parts.add(
          '${assistant.mediaUrls.length} media item${assistant.mediaUrls.length == 1 ? '' : 's'}');
    }
    return parts.join(' · ');
  }

  final tool = event.toolData;
  if (tool != null) {
    final parts = <String>[
      tool.name?.trim().isNotEmpty == true ? tool.name! : 'tool',
      tool.phase,
    ];
    final resultPreview = tool.partialResult ?? tool.result ?? tool.args;
    if (resultPreview != null) {
      parts.add(
        _truncateEventSummary(
            summarizeChatValue(resultPreview), maxLength ~/ 2),
      );
    } else if (tool.isError == true) {
      parts.add('error');
    }
    return parts.join(' · ');
  }

  return event.streamName;
}

String _fallbackEventSummary(GatewayEventFrame frame, int maxLength) {
  if (frame.payload == null) {
    return '(no payload)';
  }
  try {
    final pretty = const JsonEncoder.withIndent('  ').convert(frame.payload);
    return _truncateEventSummary(
      pretty.replaceAll(RegExp(r'\s+'), ' ').trim(),
      maxLength,
    );
  } catch (_) {
    return _truncateEventSummary(frame.payload.toString(), maxLength);
  }
}

String _truncateEventSummary(String value, int maxLength) {
  if (value.length <= maxLength) {
    return value;
  }
  return '${value.substring(0, maxLength - 1)}…';
}
