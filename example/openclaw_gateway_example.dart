import 'dart:convert';
import 'dart:io';

import 'package:openclaw_gateway/openclaw_gateway.dart';

Future<void> main() async {
  final rawUrl = Platform.environment['OPENCLAW_GATEWAY_URL'];
  final token = Platform.environment['OPENCLAW_GATEWAY_TOKEN'];
  final password = Platform.environment['OPENCLAW_GATEWAY_PASSWORD'];

  if (rawUrl == null || rawUrl.trim().isEmpty) {
    stderr.writeln('OPENCLAW_GATEWAY_URL is required.');
    exitCode = 64;
    return;
  }

  final auth = token != null && token.isNotEmpty
      ? GatewayAuth.token(token)
      : password != null && password.isNotEmpty
          ? GatewayAuth.password(password)
          : const GatewayAuth.none();

  final client = await GatewayClient.connect(
    uri: Uri.parse(rawUrl),
    auth: auth,
    clientInfo: const GatewayClientInfo(
      id: GatewayClientIds.gatewayClient,
      version: '0.1.0',
      platform: 'dart',
      mode: GatewayClientModes.backend,
      displayName: 'OpenClaw Gateway Example',
    ),
    autoReconnect: true,
  );

  try {
    final health = await client.operator.health();
    final sessions = await client.operator.sessionsList(limit: 5);

    stdout.writeln('Health:');
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(health));
    stdout.writeln('');
    stdout.writeln('Sessions:');
    stdout.writeln(const JsonEncoder.withIndent('  ').convert(sessions));
  } finally {
    await client.close();
  }
}
