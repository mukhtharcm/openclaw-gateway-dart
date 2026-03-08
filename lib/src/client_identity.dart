import 'package:openclaw_gateway/src/contract.dart';

/// Allowlisted gateway client ids accepted by the OpenClaw gateway.
abstract final class GatewayClientIds {
  static const String webchatUi = GatewayContractClientIds.webchatUi;
  static const String controlUi = GatewayContractClientIds.controlUi;
  static const String webchat = GatewayContractClientIds.webchat;
  static const String cli = GatewayContractClientIds.cli;
  static const String gatewayClient = GatewayContractClientIds.gatewayClient;
  static const String macosApp = GatewayContractClientIds.macosApp;
  static const String iosApp = GatewayContractClientIds.iosApp;
  static const String androidApp = GatewayContractClientIds.androidApp;
  static const String nodeHost = GatewayContractClientIds.nodeHost;
  static const String test = GatewayContractClientIds.test;
  static const String fingerprint = GatewayContractClientIds.fingerprint;
  static const String probe = GatewayContractClientIds.probe;

  static const List<String> values = GatewayContractClientIds.values;
}

/// Allowlisted gateway client modes accepted by the OpenClaw gateway.
abstract final class GatewayClientModes {
  static const String webchat = GatewayContractClientModes.webchat;
  static const String cli = GatewayContractClientModes.cli;
  static const String ui = GatewayContractClientModes.ui;
  static const String backend = GatewayContractClientModes.backend;
  static const String node = GatewayContractClientModes.node;
  static const String probe = GatewayContractClientModes.probe;
  static const String test = GatewayContractClientModes.test;

  static const List<String> values = GatewayContractClientModes.values;
}

/// Allowlisted gateway client capability strings.
abstract final class GatewayClientCaps {
  static const String toolEvents = GatewayContractClientCaps.toolEvents;

  static const List<String> values = GatewayContractClientCaps.values;
}
