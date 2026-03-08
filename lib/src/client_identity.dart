/// Allowlisted gateway client ids accepted by the OpenClaw gateway.
abstract final class GatewayClientIds {
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

/// Allowlisted gateway client modes accepted by the OpenClaw gateway.
abstract final class GatewayClientModes {
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
abstract final class GatewayClientCaps {
  static const String toolEvents = 'tool-events';

  static const List<String> values = <String>[
    toolEvents,
  ];
}
