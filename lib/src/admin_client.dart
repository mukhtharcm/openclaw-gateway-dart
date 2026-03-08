import 'package:openclaw_gateway/src/admin_models.dart';
import 'package:openclaw_gateway/src/automation_models.dart';
import 'package:openclaw_gateway/src/client.dart';
import 'package:openclaw_gateway/src/mutation_models.dart';
import 'package:openclaw_gateway/src/protocol.dart';
import 'package:openclaw_gateway/src/query_models.dart';

/// Typed admin and mutation wrappers for the gateway control plane.
class GatewayAdminClient {
  const GatewayAdminClient(this._client);

  static const Object _omitted = Object();

  final GatewayClient _client;

  Future<GatewayChannelLogoutResult> channelsLogout({
    required String channel,
    String? accountId,
  }) async {
    final payload = await _client.requestJsonMap(
      'channels.logout',
      params: withoutNulls({
        'channel': channel,
        'accountId': accountId,
      }),
    );
    return GatewayChannelLogoutResult.fromJson(payload);
  }

  Future<GatewayConfigWriteResult> configSet({
    required String raw,
    String? baseHash,
  }) async {
    final payload = await _client.requestJsonMap(
      'config.set',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
      }),
    );
    return GatewayConfigWriteResult.fromJson(payload);
  }

  Future<GatewayConfigWriteResult> configApply({
    required String raw,
    String? baseHash,
    String? sessionKey,
    String? note,
    int? restartDelayMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'config.apply',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
        'sessionKey': sessionKey,
        'note': note,
        'restartDelayMs': restartDelayMs,
      }),
    );
    return GatewayConfigWriteResult.fromJson(payload);
  }

  Future<GatewayConfigWriteResult> configPatch({
    required String raw,
    String? baseHash,
    String? sessionKey,
    String? note,
    int? restartDelayMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'config.patch',
      params: withoutNulls({
        'raw': raw,
        'baseHash': baseHash,
        'sessionKey': sessionKey,
        'note': note,
        'restartDelayMs': restartDelayMs,
      }),
    );
    return GatewayConfigWriteResult.fromJson(payload);
  }

  Future<GatewayVoiceWakeConfig> voiceWakeSet({
    required List<String> triggers,
  }) async {
    final payload = await _client.requestJsonMap(
      'voicewake.set',
      params: <String, Object?>{
        'triggers': triggers,
      },
    );
    return GatewayVoiceWakeConfig.fromJson(payload);
  }

  Future<GatewayOkResult> systemEvent({
    required String text,
    String? deviceId,
    String? instanceId,
    String? host,
    String? ip,
    String? mode,
    String? version,
    String? platform,
    String? deviceFamily,
    String? modelIdentifier,
    int? lastInputSeconds,
    String? reason,
    List<String>? roles,
    List<String>? scopes,
    List<String>? tags,
  }) async {
    final payload = await _client.requestJsonMap(
      'system-event',
      params: withoutNulls({
        'text': text,
        'deviceId': deviceId,
        'instanceId': instanceId,
        'host': host,
        'ip': ip,
        'mode': mode,
        'version': version,
        'platform': platform,
        'deviceFamily': deviceFamily,
        'modelIdentifier': modelIdentifier,
        'lastInputSeconds': lastInputSeconds,
        'reason': reason,
        'roles': roles,
        'scopes': scopes,
        'tags': tags,
      }),
    );
    return GatewayOkResult.fromJson(payload);
  }

  Future<GatewaySessionMutationResult> sessionsPatch({
    required String key,
    Object? label = _omitted,
    Object? thinkingLevel = _omitted,
    Object? verboseLevel = _omitted,
    Object? reasoningLevel = _omitted,
    Object? responseUsage = _omitted,
    Object? elevatedLevel = _omitted,
    Object? execHost = _omitted,
    Object? execSecurity = _omitted,
    Object? execAsk = _omitted,
    Object? execNode = _omitted,
    Object? model = _omitted,
    Object? spawnedBy = _omitted,
    Object? spawnDepth = _omitted,
    Object? sendPolicy = _omitted,
    Object? groupActivation = _omitted,
    Object? allowRuntimeDelegation = _omitted,
    Object? skillBins = _omitted,
    Object? contextTokens = _omitted,
    Object? lastChannel = _omitted,
    Object? lastAccountId = _omitted,
    Object? lastTo = _omitted,
  }) async {
    final params = <String, Object?>{
      'key': key,
    };
    void maybeSet(String name, Object? value) {
      if (!identical(value, _omitted)) {
        params[name] = value;
      }
    }

    maybeSet('label', label);
    maybeSet('thinkingLevel', thinkingLevel);
    maybeSet('verboseLevel', verboseLevel);
    maybeSet('reasoningLevel', reasoningLevel);
    maybeSet('responseUsage', responseUsage);
    maybeSet('elevatedLevel', elevatedLevel);
    maybeSet('execHost', execHost);
    maybeSet('execSecurity', execSecurity);
    maybeSet('execAsk', execAsk);
    maybeSet('execNode', execNode);
    maybeSet('model', model);
    maybeSet('spawnedBy', spawnedBy);
    maybeSet('spawnDepth', spawnDepth);
    maybeSet('sendPolicy', sendPolicy);
    maybeSet('groupActivation', groupActivation);
    maybeSet('allowRuntimeDelegation', allowRuntimeDelegation);
    maybeSet('skillBins', skillBins);
    maybeSet('contextTokens', contextTokens);
    maybeSet('lastChannel', lastChannel);
    maybeSet('lastAccountId', lastAccountId);
    maybeSet('lastTo', lastTo);

    final payload = await _client.requestJsonMap(
      'sessions.patch',
      params: params,
    );
    return GatewaySessionMutationResult.fromJson(payload);
  }

  Future<GatewaySessionMutationResult> sessionsReset({
    required String key,
    String? reason,
  }) async {
    final payload = await _client.requestJsonMap(
      'sessions.reset',
      params: withoutNulls({
        'key': key,
        'reason': reason,
      }),
    );
    return GatewaySessionMutationResult.fromJson(payload);
  }

  Future<GatewaySessionDeleteResult> sessionsDelete({
    required String key,
    bool? deleteTranscript,
    bool? emitLifecycleHooks,
  }) async {
    final payload = await _client.requestJsonMap(
      'sessions.delete',
      params: withoutNulls({
        'key': key,
        'deleteTranscript': deleteTranscript,
        'emitLifecycleHooks': emitLifecycleHooks,
      }),
    );
    return GatewaySessionDeleteResult.fromJson(payload);
  }

  Future<GatewaySessionCompactResult> sessionsCompact({
    required String key,
    int? maxLines,
  }) async {
    final payload = await _client.requestJsonMap(
      'sessions.compact',
      params: withoutNulls({
        'key': key,
        'maxLines': maxLines,
      }),
    );
    return GatewaySessionCompactResult.fromJson(payload);
  }

  Future<GatewayCronJob> cronAdd({
    required String name,
    required Object schedule,
    required String sessionTarget,
    required String wakeMode,
    required Object payload,
    bool? enabled,
    String? timezone,
    String? agentId,
    String? model,
    String? provider,
    int? maxTurns,
    int? timeoutMs,
    Object? delivery,
    Object? failureAlert,
  }) async {
    final response = await _client.requestJsonMap(
      'cron.add',
      params: withoutNulls({
        'name': name,
        'schedule': schedule,
        'sessionTarget': sessionTarget,
        'wakeMode': wakeMode,
        'payload': payload,
        'enabled': enabled,
        'timezone': timezone,
        'agentId': agentId,
        'model': model,
        'provider': provider,
        'maxTurns': maxTurns,
        'timeoutMs': timeoutMs,
        'delivery': delivery,
        'failureAlert': failureAlert,
      }),
    );
    return GatewayCronJob.fromJson(response);
  }

  Future<GatewayCronJob> cronUpdate({
    String? id,
    String? jobId,
    required Object patch,
  }) async {
    final response = await _client.requestJsonMap(
      'cron.update',
      params: withoutNulls({
        'id': id,
        'jobId': jobId,
        'patch': patch,
      }),
    );
    return GatewayCronJob.fromJson(response);
  }

  Future<GatewayCronRemoveResult> cronRemove({
    String? id,
    String? jobId,
  }) async {
    final response = await _client.requestJsonMap(
      'cron.remove',
      params: withoutNulls({
        'id': id,
        'jobId': jobId,
      }),
    );
    return GatewayCronRemoveResult.fromJson(response);
  }

  Future<GatewayCronRunResult> cronRun({
    String? id,
    String? jobId,
    String? mode,
  }) async {
    final response = await _client.requestJsonMap(
      'cron.run',
      params: withoutNulls({
        'id': id,
        'jobId': jobId,
        'mode': mode,
      }),
    );
    return GatewayCronRunResult.fromJson(response);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsGet() async {
    final payload = await _client.requestJsonMap(
      'exec.approvals.get',
      params: const <String, Object?>{},
    );
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsSet({
    required Object file,
    String? baseHash,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approvals.set',
      params: withoutNulls({
        'file': file,
        'baseHash': baseHash,
      }),
    );
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsNodeGet({
    required String nodeId,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approvals.node.get',
      params: <String, Object?>{
        'nodeId': nodeId,
      },
    );
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayExecApprovalsSnapshot> execApprovalsNodeSet({
    required String nodeId,
    required Object file,
    String? baseHash,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approvals.node.set',
      params: withoutNulls({
        'nodeId': nodeId,
        'file': file,
        'baseHash': baseHash,
      }),
    );
    return GatewayExecApprovalsSnapshot.fromJson(payload);
  }

  Future<GatewayExecApprovalRequestStatus> execApprovalRequest({
    String? id,
    required String command,
    List<String>? commandArgv,
    Object? systemRunPlan,
    Map<String, String>? env,
    String? cwd,
    String? nodeId,
    String? host,
    String? security,
    String? ask,
    String? agentId,
    String? resolvedPath,
    String? sessionKey,
    String? turnSourceChannel,
    String? turnSourceTo,
    String? turnSourceAccountId,
    String? turnSourceThreadId,
    int? timeoutMs,
    bool? twoPhase,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approval.request',
      params: withoutNulls({
        'id': id,
        'command': command,
        'commandArgv': commandArgv,
        'systemRunPlan': systemRunPlan,
        'env': env,
        'cwd': cwd,
        'nodeId': nodeId,
        'host': host,
        'security': security,
        'ask': ask,
        'agentId': agentId,
        'resolvedPath': resolvedPath,
        'sessionKey': sessionKey,
        'turnSourceChannel': turnSourceChannel,
        'turnSourceTo': turnSourceTo,
        'turnSourceAccountId': turnSourceAccountId,
        'turnSourceThreadId': turnSourceThreadId,
        'timeoutMs': timeoutMs,
        'twoPhase': twoPhase,
      }),
    );
    return GatewayExecApprovalRequestStatus.fromJson(payload);
  }

  Future<GatewayExecApprovalRequestStatus> execApprovalWaitDecision({
    required String id,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approval.waitDecision',
      params: <String, Object?>{
        'id': id,
      },
    );
    return GatewayExecApprovalRequestStatus.fromJson(payload);
  }

  Future<GatewayOkResult> execApprovalResolve({
    required String id,
    required String decision,
  }) async {
    final payload = await _client.requestJsonMap(
      'exec.approval.resolve',
      params: <String, Object?>{
        'id': id,
        'decision': decision,
      },
    );
    return GatewayOkResult.fromJson(payload);
  }

  Future<GatewayWizardStepResult> wizardStart({
    String? mode,
    String? workspace,
  }) async {
    final payload = await _client.requestJsonMap(
      'wizard.start',
      params: withoutNulls({
        'mode': mode,
        'workspace': workspace,
      }),
    );
    return GatewayWizardStepResult.fromJson(payload);
  }

  Future<GatewayWizardStepResult> wizardNext({
    required String sessionId,
    String? stepId,
    Object? value,
  }) async {
    final payload = await _client.requestJsonMap(
      'wizard.next',
      params: withoutNulls({
        'sessionId': sessionId,
        'answer': stepId == null && value == null
            ? null
            : withoutNulls({
                'stepId': stepId,
                'value': value,
              }),
      }),
    );
    return GatewayWizardStepResult.fromJson(payload);
  }

  Future<GatewayWizardStatus> wizardCancel({
    required String sessionId,
  }) async {
    final payload = await _client.requestJsonMap(
      'wizard.cancel',
      params: <String, Object?>{
        'sessionId': sessionId,
      },
    );
    return GatewayWizardStatus.fromJson(payload);
  }

  Future<GatewayWizardStatus> wizardStatus({
    required String sessionId,
  }) async {
    final payload = await _client.requestJsonMap(
      'wizard.status',
      params: <String, Object?>{
        'sessionId': sessionId,
      },
    );
    return GatewayWizardStatus.fromJson(payload);
  }

  Future<GatewayTalkConfig> talkConfig({
    bool? includeSecrets,
  }) async {
    final payload = await _client.requestJsonMap(
      'talk.config',
      params: withoutNulls({
        'includeSecrets': includeSecrets,
      }),
    );
    return GatewayTalkConfig.fromJson(payload);
  }

  Future<GatewayTalkModeState> talkMode({
    required bool enabled,
    String? phase,
  }) async {
    final payload = await _client.requestJsonMap(
      'talk.mode',
      params: withoutNulls({
        'enabled': enabled,
        'phase': phase,
      }),
    );
    return GatewayTalkModeState.fromJson(payload);
  }

  Future<GatewayWebLoginStartResult> webLoginStart({
    bool? force,
    int? timeoutMs,
    bool? verbose,
    String? accountId,
  }) async {
    final payload = await _client.requestJsonMap(
      'web.login.start',
      params: withoutNulls({
        'force': force,
        'timeoutMs': timeoutMs,
        'verbose': verbose,
        'accountId': accountId,
      }),
    );
    return GatewayWebLoginStartResult.fromJson(payload);
  }

  Future<GatewayWebLoginWaitResult> webLoginWait({
    int? timeoutMs,
    String? accountId,
  }) async {
    final payload = await _client.requestJsonMap(
      'web.login.wait',
      params: withoutNulls({
        'timeoutMs': timeoutMs,
        'accountId': accountId,
      }),
    );
    return GatewayWebLoginWaitResult.fromJson(payload);
  }

  Future<GatewayUsageStatusResult> usageStatus() async {
    final payload = await _client.requestJsonMap(
      'usage.status',
      params: const <String, Object?>{},
    );
    return GatewayUsageStatusResult.fromJson(payload);
  }

  Future<GatewayUsageCostResult> usageCost({
    String? startDate,
    String? endDate,
    int? days,
    String? mode,
    String? utcOffset,
  }) async {
    final payload = await _client.requestJsonMap(
      'usage.cost',
      params: withoutNulls({
        'startDate': startDate,
        'endDate': endDate,
        'days': days,
        'mode': mode,
        'utcOffset': utcOffset,
      }),
    );
    return GatewayUsageCostResult.fromJson(payload);
  }

  Future<GatewayTtsStatus> ttsStatus() async {
    final payload = await _client.requestJsonMap(
      'tts.status',
      params: const <String, Object?>{},
    );
    return GatewayTtsStatus.fromJson(payload);
  }

  Future<GatewayTtsProvidersResult> ttsProviders() async {
    final payload = await _client.requestJsonMap(
      'tts.providers',
      params: const <String, Object?>{},
    );
    return GatewayTtsProvidersResult.fromJson(payload);
  }

  Future<GatewayTtsEnabledResult> ttsEnable() async {
    final payload = await _client.requestJsonMap(
      'tts.enable',
      params: const <String, Object?>{},
    );
    return GatewayTtsEnabledResult.fromJson(payload);
  }

  Future<GatewayTtsEnabledResult> ttsDisable() async {
    final payload = await _client.requestJsonMap(
      'tts.disable',
      params: const <String, Object?>{},
    );
    return GatewayTtsEnabledResult.fromJson(payload);
  }

  Future<GatewayTtsConvertResult> ttsConvert({
    required String text,
    String? channel,
  }) async {
    final payload = await _client.requestJsonMap(
      'tts.convert',
      params: withoutNulls({
        'text': text,
        'channel': channel,
      }),
    );
    return GatewayTtsConvertResult.fromJson(payload);
  }

  Future<String> ttsSetProvider({
    required String provider,
  }) async {
    final payload = await _client.requestJsonMap(
      'tts.setProvider',
      params: <String, Object?>{
        'provider': provider,
      },
    );
    return readRequiredString(payload, 'provider', context: 'tts.setProvider');
  }

  Future<GatewayAgentsListResult> agentsList() async {
    final payload = await _client.requestJsonMap('agents.list');
    return GatewayAgentsListResult.fromJson(payload);
  }

  Future<GatewayAgentsCreateResult> agentsCreate({
    required String name,
    required String workspace,
    String? emoji,
    String? avatar,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.create',
      params: withoutNulls({
        'name': name,
        'workspace': workspace,
        'emoji': emoji,
        'avatar': avatar,
      }),
    );
    return GatewayAgentsCreateResult.fromJson(payload);
  }

  Future<GatewayAgentsUpdateResult> agentsUpdate({
    required String agentId,
    String? name,
    String? workspace,
    String? model,
    String? avatar,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.update',
      params: withoutNulls({
        'agentId': agentId,
        'name': name,
        'workspace': workspace,
        'model': model,
        'avatar': avatar,
      }),
    );
    return GatewayAgentsUpdateResult.fromJson(payload);
  }

  Future<GatewayAgentsDeleteResult> agentsDelete({
    required String agentId,
    bool? deleteFiles,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.delete',
      params: withoutNulls({
        'agentId': agentId,
        'deleteFiles': deleteFiles,
      }),
    );
    return GatewayAgentsDeleteResult.fromJson(payload);
  }

  Future<GatewayAgentFilesListResult> agentsFilesList({
    required String agentId,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.files.list',
      params: <String, Object?>{
        'agentId': agentId,
      },
    );
    return GatewayAgentFilesListResult.fromJson(payload);
  }

  Future<GatewayAgentFileResult> agentsFilesGet({
    required String agentId,
    required String name,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.files.get',
      params: <String, Object?>{
        'agentId': agentId,
        'name': name,
      },
    );
    return GatewayAgentFileResult.fromJson(payload);
  }

  Future<GatewayAgentFileResult> agentsFilesSet({
    required String agentId,
    required String name,
    required String content,
  }) async {
    final payload = await _client.requestJsonMap(
      'agents.files.set',
      params: <String, Object?>{
        'agentId': agentId,
        'name': name,
        'content': content,
      },
    );
    return GatewayAgentFileResult.fromJson(payload);
  }

  Future<GatewaySkillsStatusResult> skillsStatus({
    String? agentId,
  }) async {
    final payload = await _client.requestJsonMap(
      'skills.status',
      params: withoutNulls({
        'agentId': agentId,
      }),
    );
    return GatewaySkillsStatusResult.fromJson(payload);
  }

  Future<GatewaySkillInstallResult> skillsInstall({
    required String name,
    required String installId,
    int? timeoutMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'skills.install',
      params: withoutNulls({
        'name': name,
        'installId': installId,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewaySkillInstallResult.fromJson(payload);
  }

  Future<GatewaySkillUpdateResult> skillsUpdate({
    required String skillKey,
    bool? enabled,
    String? apiKey,
    Map<String, String>? env,
  }) async {
    final payload = await _client.requestJsonMap(
      'skills.update',
      params: withoutNulls({
        'skillKey': skillKey,
        'enabled': enabled,
        'apiKey': apiKey,
        'env': env,
      }),
    );
    return GatewaySkillUpdateResult.fromJson(payload);
  }

  Future<GatewayLastHeartbeatResult?> lastHeartbeat() async {
    final payload = await _client.request(
      'last-heartbeat',
      params: const <String, Object?>{},
    );
    if (payload == null) {
      return null;
    }
    return GatewayLastHeartbeatResult.fromJson(
      asJsonMap(payload, context: 'last-heartbeat'),
    );
  }

  Future<GatewaySetHeartbeatsResult> setHeartbeats({
    required bool enabled,
  }) async {
    final payload = await _client.requestJsonMap(
      'set-heartbeats',
      params: <String, Object?>{
        'enabled': enabled,
      },
    );
    return GatewaySetHeartbeatsResult.fromJson(payload);
  }

  Future<GatewayWakeResult> wake({
    required String mode,
    required String text,
  }) async {
    final payload = await _client.requestJsonMap(
      'wake',
      params: <String, Object?>{
        'mode': mode,
        'text': text,
      },
    );
    return GatewayWakeResult.fromJson(payload);
  }

  Future<GatewayLogsTailResult> logsTail({
    int? cursor,
    int? limit,
    int? maxBytes,
  }) async {
    final payload = await _client.requestJsonMap(
      'logs.tail',
      params: withoutNulls({
        'cursor': cursor,
        'limit': limit,
        'maxBytes': maxBytes,
      }),
    );
    return GatewayLogsTailResult.fromJson(payload);
  }

  Future<GatewayDoctorMemoryStatus> doctorMemoryStatus() async {
    final payload = await _client.requestJsonMap(
      'doctor.memory.status',
      params: const <String, Object?>{},
    );
    return GatewayDoctorMemoryStatus.fromJson(payload);
  }

  Future<GatewayUpdateRunResponse> updateRun({
    String? sessionKey,
    String? note,
    int? restartDelayMs,
    int? timeoutMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'update.run',
      params: withoutNulls({
        'sessionKey': sessionKey,
        'note': note,
        'restartDelayMs': restartDelayMs,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewayUpdateRunResponse.fromJson(payload);
  }

  Future<GatewaySecretsReloadResult> secretsReload() async {
    final payload = await _client.requestJsonMap(
      'secrets.reload',
      params: const <String, Object?>{},
    );
    return GatewaySecretsReloadResult.fromJson(payload);
  }

  Future<GatewaySecretsResolveResult> secretsResolve({
    required String commandName,
    required List<String> targetIds,
  }) async {
    final payload = await _client.requestJsonMap(
      'secrets.resolve',
      params: <String, Object?>{
        'commandName': commandName,
        'targetIds': targetIds,
      },
    );
    return GatewaySecretsResolveResult.fromJson(payload);
  }

  Future<GatewaySendResult> send({
    required String to,
    String? message,
    String? mediaUrl,
    List<String>? mediaUrls,
    bool? gifPlayback,
    String? channel,
    String? accountId,
    String? agentId,
    String? threadId,
    String? sessionKey,
    String? idempotencyKey,
  }) async {
    final payload = await _client.requestJsonMap(
      'send',
      params: withoutNulls({
        'to': to,
        'message': message,
        'mediaUrl': mediaUrl,
        'mediaUrls': mediaUrls,
        'gifPlayback': gifPlayback,
        'channel': channel,
        'accountId': accountId,
        'agentId': agentId,
        'threadId': threadId,
        'sessionKey': sessionKey,
        'idempotencyKey':
            idempotencyKey ?? _client.createIdempotencyKey(prefix: 'send'),
      }),
    );
    return GatewaySendResult.fromJson(payload);
  }

  Future<GatewayAgentRequestResult> agent({
    required String message,
    String? agentId,
    String? to,
    String? replyTo,
    String? sessionId,
    String? sessionKey,
    String? thinking,
    bool? deliver,
    List<Object?>? attachments,
    String? channel,
    String? replyChannel,
    String? accountId,
    String? replyAccountId,
    String? threadId,
    String? groupId,
    String? groupChannel,
    String? groupSpace,
    int? timeout,
    bool? bestEffortDeliver,
    String? lane,
    String? extraSystemPrompt,
    bool? internalEvents,
    Object? inputProvenance,
    String? idempotencyKey,
    String? label,
    String? spawnedBy,
  }) async {
    final payload = await _client.requestJsonMap(
      'agent',
      params: withoutNulls({
        'message': message,
        'agentId': agentId,
        'to': to,
        'replyTo': replyTo,
        'sessionId': sessionId,
        'sessionKey': sessionKey,
        'thinking': thinking,
        'deliver': deliver,
        'attachments': attachments,
        'channel': channel,
        'replyChannel': replyChannel,
        'accountId': accountId,
        'replyAccountId': replyAccountId,
        'threadId': threadId,
        'groupId': groupId,
        'groupChannel': groupChannel,
        'groupSpace': groupSpace,
        'timeout': timeout,
        'bestEffortDeliver': bestEffortDeliver,
        'lane': lane,
        'extraSystemPrompt': extraSystemPrompt,
        'internalEvents': internalEvents,
        'inputProvenance': inputProvenance,
        'idempotencyKey':
            idempotencyKey ?? _client.createIdempotencyKey(prefix: 'agent'),
        'label': label,
        'spawnedBy': spawnedBy,
      }),
    );
    return GatewayAgentRequestResult.fromJson(payload);
  }

  Future<GatewayAgentIdentity> agentIdentityGet({
    String? agentId,
    String? sessionKey,
  }) async {
    final payload = await _client.requestJsonMap(
      'agent.identity.get',
      params: withoutNulls({
        'agentId': agentId,
        'sessionKey': sessionKey,
      }),
    );
    return GatewayAgentIdentity.fromJson(payload);
  }

  Future<GatewayAgentWaitResult> agentWait({
    required String runId,
    int? timeoutMs,
  }) async {
    final payload = await _client.requestJsonMap(
      'agent.wait',
      params: withoutNulls({
        'runId': runId,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewayAgentWaitResult.fromJson(payload);
  }

  Future<GatewayBrowserResponse> browserRequest({
    required String method,
    required String path,
    Map<String, Object?>? query,
    Object? body,
    int? timeoutMs,
  }) async {
    final payload = await _client.request(
      'browser.request',
      params: withoutNulls({
        'method': method,
        'path': path,
        'query': query,
        'body': body,
        'timeoutMs': timeoutMs,
      }),
    );
    return GatewayBrowserResponse.fromPayload(payload);
  }
}
