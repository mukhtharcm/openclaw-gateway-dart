// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Regenerate with:
// dart run tool/sync_openclaw_contract.dart

const int gatewayContractProtocolVersion = 3;

/// Allowlisted gateway client ids mirrored from OpenClaw.
abstract final class GatewayContractClientIds {
  static const String webchatUi = 'webchat-ui';
  static const String controlUi = 'openclaw-control-ui';
  static const String webchat = 'webchat';
  static const String cli = 'cli';
  static const String gatewayClient = 'gateway-client';
  static const String macosApp = 'openclaw-macos';
  static const String iosApp = 'openclaw-ios';
  static const String androidApp = 'openclaw-android';
  static const String nodeHost = 'node-host';
  static const String test = 'test';
  static const String fingerprint = 'fingerprint';
  static const String probe = 'openclaw-probe';

  static const List<String> values = <String>[
    webchatUi,
    controlUi,
    webchat,
    cli,
    gatewayClient,
    macosApp,
    iosApp,
    androidApp,
    nodeHost,
    test,
    fingerprint,
    probe,
  ];
}

/// Allowlisted gateway client modes mirrored from OpenClaw.
abstract final class GatewayContractClientModes {
  static const String webchat = 'webchat';
  static const String cli = 'cli';
  static const String ui = 'ui';
  static const String backend = 'backend';
  static const String node = 'node';
  static const String probe = 'probe';
  static const String test = 'test';

  static const List<String> values = <String>[
    webchat,
    cli,
    ui,
    backend,
    node,
    probe,
    test,
  ];
}

/// Allowlisted gateway client capability strings.
abstract final class GatewayContractClientCaps {
  static const String toolEvents = 'tool-events';

  static const List<String> values = <String>[
    toolEvents,
  ];
}

/// Known base gateway RPC method names mirrored from OpenClaw.
abstract final class GatewayMethodNames {
  static const String health = 'health';
  static const String doctorMemoryStatus = 'doctor.memory.status';
  static const String logsTail = 'logs.tail';
  static const String channelsStatus = 'channels.status';
  static const String channelsLogout = 'channels.logout';
  static const String status = 'status';
  static const String usageStatus = 'usage.status';
  static const String usageCost = 'usage.cost';
  static const String ttsStatus = 'tts.status';
  static const String ttsProviders = 'tts.providers';
  static const String ttsEnable = 'tts.enable';
  static const String ttsDisable = 'tts.disable';
  static const String ttsConvert = 'tts.convert';
  static const String ttsSetProvider = 'tts.setProvider';
  static const String configGet = 'config.get';
  static const String configSet = 'config.set';
  static const String configApply = 'config.apply';
  static const String configPatch = 'config.patch';
  static const String configSchema = 'config.schema';
  static const String configSchemaLookup = 'config.schema.lookup';
  static const String execApprovalsGet = 'exec.approvals.get';
  static const String execApprovalsSet = 'exec.approvals.set';
  static const String execApprovalsNodeGet = 'exec.approvals.node.get';
  static const String execApprovalsNodeSet = 'exec.approvals.node.set';
  static const String execApprovalRequest = 'exec.approval.request';
  static const String execApprovalWaitDecision = 'exec.approval.waitDecision';
  static const String execApprovalResolve = 'exec.approval.resolve';
  static const String wizardStart = 'wizard.start';
  static const String wizardNext = 'wizard.next';
  static const String wizardCancel = 'wizard.cancel';
  static const String wizardStatus = 'wizard.status';
  static const String talkConfig = 'talk.config';
  static const String talkMode = 'talk.mode';
  static const String modelsList = 'models.list';
  static const String toolsCatalog = 'tools.catalog';
  static const String agentsList = 'agents.list';
  static const String agentsCreate = 'agents.create';
  static const String agentsUpdate = 'agents.update';
  static const String agentsDelete = 'agents.delete';
  static const String agentsFilesList = 'agents.files.list';
  static const String agentsFilesGet = 'agents.files.get';
  static const String agentsFilesSet = 'agents.files.set';
  static const String skillsStatus = 'skills.status';
  static const String skillsBins = 'skills.bins';
  static const String skillsInstall = 'skills.install';
  static const String skillsUpdate = 'skills.update';
  static const String updateRun = 'update.run';
  static const String voicewakeGet = 'voicewake.get';
  static const String voicewakeSet = 'voicewake.set';
  static const String secretsReload = 'secrets.reload';
  static const String secretsResolve = 'secrets.resolve';
  static const String sessionsList = 'sessions.list';
  static const String sessionsPreview = 'sessions.preview';
  static const String sessionsPatch = 'sessions.patch';
  static const String sessionsReset = 'sessions.reset';
  static const String sessionsDelete = 'sessions.delete';
  static const String sessionsCompact = 'sessions.compact';
  static const String lastHeartbeat = 'last-heartbeat';
  static const String setHeartbeats = 'set-heartbeats';
  static const String wake = 'wake';
  static const String nodePairRequest = 'node.pair.request';
  static const String nodePairList = 'node.pair.list';
  static const String nodePairApprove = 'node.pair.approve';
  static const String nodePairReject = 'node.pair.reject';
  static const String nodePairVerify = 'node.pair.verify';
  static const String devicePairList = 'device.pair.list';
  static const String devicePairApprove = 'device.pair.approve';
  static const String devicePairReject = 'device.pair.reject';
  static const String devicePairRemove = 'device.pair.remove';
  static const String deviceTokenRotate = 'device.token.rotate';
  static const String deviceTokenRevoke = 'device.token.revoke';
  static const String nodeRename = 'node.rename';
  static const String nodeList = 'node.list';
  static const String nodeDescribe = 'node.describe';
  static const String nodeInvoke = 'node.invoke';
  static const String nodeInvokeResult = 'node.invoke.result';
  static const String nodeEvent = 'node.event';
  static const String nodeCanvasCapabilityRefresh =
      'node.canvas.capability.refresh';
  static const String cronList = 'cron.list';
  static const String cronStatus = 'cron.status';
  static const String cronAdd = 'cron.add';
  static const String cronUpdate = 'cron.update';
  static const String cronRemove = 'cron.remove';
  static const String cronRun = 'cron.run';
  static const String cronRuns = 'cron.runs';
  static const String systemPresence = 'system-presence';
  static const String systemEvent = 'system-event';
  static const String send = 'send';
  static const String agent = 'agent';
  static const String agentIdentityGet = 'agent.identity.get';
  static const String agentWait = 'agent.wait';
  static const String browserRequest = 'browser.request';
  static const String chatHistory = 'chat.history';
  static const String chatAbort = 'chat.abort';
  static const String chatSend = 'chat.send';

  static const List<String> values = <String>[
    health,
    doctorMemoryStatus,
    logsTail,
    channelsStatus,
    channelsLogout,
    status,
    usageStatus,
    usageCost,
    ttsStatus,
    ttsProviders,
    ttsEnable,
    ttsDisable,
    ttsConvert,
    ttsSetProvider,
    configGet,
    configSet,
    configApply,
    configPatch,
    configSchema,
    configSchemaLookup,
    execApprovalsGet,
    execApprovalsSet,
    execApprovalsNodeGet,
    execApprovalsNodeSet,
    execApprovalRequest,
    execApprovalWaitDecision,
    execApprovalResolve,
    wizardStart,
    wizardNext,
    wizardCancel,
    wizardStatus,
    talkConfig,
    talkMode,
    modelsList,
    toolsCatalog,
    agentsList,
    agentsCreate,
    agentsUpdate,
    agentsDelete,
    agentsFilesList,
    agentsFilesGet,
    agentsFilesSet,
    skillsStatus,
    skillsBins,
    skillsInstall,
    skillsUpdate,
    updateRun,
    voicewakeGet,
    voicewakeSet,
    secretsReload,
    secretsResolve,
    sessionsList,
    sessionsPreview,
    sessionsPatch,
    sessionsReset,
    sessionsDelete,
    sessionsCompact,
    lastHeartbeat,
    setHeartbeats,
    wake,
    nodePairRequest,
    nodePairList,
    nodePairApprove,
    nodePairReject,
    nodePairVerify,
    devicePairList,
    devicePairApprove,
    devicePairReject,
    devicePairRemove,
    deviceTokenRotate,
    deviceTokenRevoke,
    nodeRename,
    nodeList,
    nodeDescribe,
    nodeInvoke,
    nodeInvokeResult,
    nodeEvent,
    nodeCanvasCapabilityRefresh,
    cronList,
    cronStatus,
    cronAdd,
    cronUpdate,
    cronRemove,
    cronRun,
    cronRuns,
    systemPresence,
    systemEvent,
    send,
    agent,
    agentIdentityGet,
    agentWait,
    browserRequest,
    chatHistory,
    chatAbort,
    chatSend,
  ];
}

/// Known gateway event names mirrored from OpenClaw.
abstract final class GatewayEventNames {
  static const String connectChallenge = 'connect.challenge';
  static const String agent = 'agent';
  static const String chat = 'chat';
  static const String presence = 'presence';
  static const String tick = 'tick';
  static const String talkMode = 'talk.mode';
  static const String shutdown = 'shutdown';
  static const String health = 'health';
  static const String heartbeat = 'heartbeat';
  static const String cron = 'cron';
  static const String nodePairRequested = 'node.pair.requested';
  static const String nodePairResolved = 'node.pair.resolved';
  static const String nodeInvokeRequest = 'node.invoke.request';
  static const String devicePairRequested = 'device.pair.requested';
  static const String devicePairResolved = 'device.pair.resolved';
  static const String voicewakeChanged = 'voicewake.changed';
  static const String execApprovalRequested = 'exec.approval.requested';
  static const String execApprovalResolved = 'exec.approval.resolved';

  static const List<String> values = <String>[
    connectChallenge,
    agent,
    chat,
    presence,
    tick,
    talkMode,
    shutdown,
    health,
    heartbeat,
    cron,
    nodePairRequested,
    nodePairResolved,
    nodeInvokeRequest,
    devicePairRequested,
    devicePairResolved,
    voicewakeChanged,
    execApprovalRequested,
    execApprovalResolved,
  ];
}
