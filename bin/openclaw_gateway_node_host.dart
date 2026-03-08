import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:openclaw_gateway/openclaw_gateway_io.dart';

const String _defaultClientVersion = '0.1.0';
const String _defaultDisplayName = 'OpenClaw Dart Node Host';
const String _defaultPlatform = 'dart';
const String _defaultStateFile = '.openclaw_gateway_node_state.json';

Future<void> main(List<String> arguments) async {
  final parser = _buildParser();
  late final ArgResults args;

  try {
    args = parser.parse(arguments);
  } on FormatException catch (error) {
    _printUsage(parser, stderr, error: error.message);
    exitCode = 64;
    return;
  }

  if (args.flag('help')) {
    _printUsage(parser, stdout);
    return;
  }

  try {
    final env = Platform.environment;
    final uri = _readRequiredUri(args, env);
    final auth = _resolveAuth(args, env);
    final statePath = _resolveStatePath(args);
    final store = GatewayJsonFileAuthStateStore(path: statePath);
    final identity = await store.readOrCreateIdentity();
    final registry = _buildRegistry(
      commands: args.multiOption('command'),
      caps: args.multiOption('cap'),
    );
    final snapshot = await registry.snapshot();

    final client = await _connectNodeHost(
      uri: uri,
      auth: auth,
      displayName: args.option('display-name') ?? _defaultDisplayName,
      platform: args.option('platform') ?? _defaultPlatform,
      version: args.option('client-version') ?? _defaultClientVersion,
      identity: identity,
      store: store,
      snapshot: snapshot,
      approvePairing: args.flag('approve-pairing'),
    );

    stdout.writeln(
      'Connected nodeId=${identity.deviceId} commands=${snapshot.commands.join(",")} stateFile=$statePath',
    );

    final done = Completer<void>();
    var handledRequests = 0;

    final stateSubscription = client.connectionStates.listen((state) {
      stderr.writeln(
        'connection phase=${state.phase.name} attempt=${state.attempt}',
      );
    });

    final requestSubscription = registry.attach(client);
    final handledRequestSubscription =
        client.node.invokeRequests.listen((request) {
      stderr.writeln(
        'invoke id=${request.id} command=${request.command} nodeId=${request.nodeId}',
      );
      handledRequests += 1;
      if (args.flag('once') && handledRequests >= 1 && !done.isCompleted) {
        done.complete();
      }
    });

    final sigintSubscription = ProcessSignal.sigint.watch().listen((_) {
      if (!done.isCompleted) {
        done.complete();
      }
    });

    final sigtermSubscription = ProcessSignal.sigterm.watch().listen((_) {
      if (!done.isCompleted) {
        done.complete();
      }
    });

    try {
      await done.future;
    } finally {
      await sigtermSubscription.cancel();
      await sigintSubscription.cancel();
      await handledRequestSubscription.cancel();
      await requestSubscription.cancel();
      await stateSubscription.cancel();
      await client.close();
    }
  } on _CliUsageException catch (error) {
    _printUsage(parser, stderr, error: error.message);
    exitCode = 64;
  } on GatewayException catch (error) {
    stderr.writeln(error.toString());
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  }
}

ArgParser _buildParser() {
  return ArgParser()
    ..addOption(
      'url',
      abbr: 'u',
      help: 'Gateway WebSocket URL. Falls back to OPENCLAW_GATEWAY_URL.',
      valueHelp: 'wss://gateway.example',
    )
    ..addOption(
      'token',
      help: 'Shared gateway token. Falls back to OPENCLAW_GATEWAY_TOKEN.',
      valueHelp: 'token',
    )
    ..addOption(
      'password',
      help: 'Gateway password. Falls back to OPENCLAW_GATEWAY_PASSWORD.',
      valueHelp: 'password',
    )
    ..addOption(
      'display-name',
      defaultsTo: _defaultDisplayName,
      help: 'Display name sent by the node client.',
    )
    ..addOption(
      'client-version',
      defaultsTo: _defaultClientVersion,
      help: 'Gateway client version sent during connect.',
    )
    ..addOption(
      'platform',
      defaultsTo: _defaultPlatform,
      help: 'Gateway client platform string sent during connect.',
    )
    ..addMultiOption(
      'command',
      defaultsTo: const <String>['system.notify'],
      help: 'Declared node command. Repeat to advertise multiple commands.',
      valueHelp: 'command',
    )
    ..addMultiOption(
      'cap',
      help: 'Declared node capability. Repeat to advertise multiple caps.',
      valueHelp: 'cap',
    )
    ..addOption(
      'state-file',
      defaultsTo: _defaultStateFile,
      help: 'Path to the persisted identity/device-token JSON state file.',
      valueHelp: 'path',
    )
    ..addFlag(
      'approve-pairing',
      help:
          'If the gateway requests pairing, approve it automatically with the shared auth from --token or --password.',
    )
    ..addFlag(
      'once',
      help: 'Exit after the first handled invoke request.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage.',
    );
}

Future<GatewayClient> _connectNodeHost({
  required Uri uri,
  required GatewayAuth auth,
  required String displayName,
  required String platform,
  required String version,
  required GatewayEd25519Identity identity,
  required GatewayDeviceTokenStore store,
  required GatewayNodeConnectSnapshot snapshot,
  required bool approvePairing,
}) async {
  while (true) {
    try {
      return await GatewayClient.connect(
        uri: uri,
        auth: auth,
        role: gatewayNodeRole,
        scopes: const <String>[],
        caps: snapshot.capabilities,
        commands: snapshot.commands,
        permissions: snapshot.permissions,
        autoReconnect: true,
        deviceIdentity: identity,
        deviceTokenStore: store,
        clientInfo: GatewayClientInfo(
          id: GatewayClientIds.nodeHost,
          version: version,
          platform: platform,
          mode: GatewayClientModes.node,
          displayName: displayName,
          deviceFamily: 'Dart',
        ),
      );
    } on GatewayResponseException catch (error) {
      final requestId = _readPairingRequestId(error.details);
      final detailCode = readGatewayConnectErrorDetailCode(error.details);
      if (!approvePairing ||
          error.code != 'NOT_PAIRED' ||
          detailCode != GatewayConnectErrorDetailCodes.pairingRequired ||
          requestId == null) {
        if (requestId != null) {
          stderr.writeln(
            'Pairing required. Approve requestId=$requestId with an operator session and rerun.',
          );
        }
        rethrow;
      }
      if (!_hasSharedAuth(auth)) {
        throw const _CliUsageException(
          '--approve-pairing requires --token or --password on the first run.',
        );
      }

      final operator = await GatewayClient.connect(
        uri: uri,
        auth: auth,
        autoReconnect: true,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.gatewayClient,
          version: _defaultClientVersion,
          platform: 'dart',
          mode: GatewayClientModes.backend,
          displayName: 'OpenClaw Dart Node Pair Approver',
        ),
      );

      try {
        final approved = await operator.devices.pairApprove(
          requestId: requestId,
        );
        stderr.writeln(
          'Approved pairing requestId=$requestId deviceId=${approved['device'] is Map ? (approved['device'] as Map)['deviceId'] : 'unknown'}',
        );
      } finally {
        await operator.close();
      }
    }
  }
}

GatewayNodeCapabilityRegistry _buildRegistry({
  required List<String> commands,
  required List<String> caps,
}) {
  final declaredCapabilities = caps
      .map((capability) => capability.trim())
      .where((capability) => capability.isNotEmpty)
      .map((capability) => GatewayNodeCapability(name: capability))
      .toList(growable: false);

  final declaredCommands = commands
      .map((command) => command.trim())
      .where((command) => command.isNotEmpty)
      .map(_buildCommand)
      .toList(growable: false);

  return GatewayNodeCapabilityRegistry(
    capabilities: declaredCapabilities,
    commands: declaredCommands,
  );
}

GatewayNodeCommand _buildCommand(String command) {
  switch (command) {
    case 'system.notify':
      return GatewayNodeCommand(
        name: command,
        handler: (context) async => GatewayNodeCommandResult.ok(
          payload: <String, Object?>{
            'notified': true,
            'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
            'params': context.params,
          },
        ),
      );
    case 'camera.list':
      return const GatewayNodeCommand(
        name: 'camera.list',
        capabilities: <String>['camera'],
        handler: _handleCameraList,
      );
    case 'ping':
      return GatewayNodeCommand(
        name: command,
        handler: (context) async => GatewayNodeCommandResult.ok(
          payload: <String, Object?>{
            'pong': true,
            'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
            'params': context.params,
          },
        ),
      );
    case 'echo':
      return GatewayNodeCommand(
        name: command,
        handler: (context) async => GatewayNodeCommandResult.ok(
          payload: <String, Object?>{
            'echo': context.params,
            'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ),
      );
    case 'fail':
      return const GatewayNodeCommand(
        name: 'fail',
        handler: _handleFail,
      );
  }
  throw _CliUsageException(
    'Unsupported sample node command "$command". Use one of: system.notify, camera.list, ping, echo, fail.',
  );
}

Uri _readRequiredUri(ArgResults args, Map<String, String> env) {
  final rawUrl = _readValue(args, env, 'url', 'OPENCLAW_GATEWAY_URL');
  if (rawUrl == null || rawUrl.trim().isEmpty) {
    throw const _CliUsageException(
      'Missing gateway URL. Pass --url or set OPENCLAW_GATEWAY_URL.',
    );
  }
  return Uri.parse(rawUrl);
}

GatewayAuth _resolveAuth(ArgResults args, Map<String, String> env) {
  final token = _readValue(args, env, 'token', 'OPENCLAW_GATEWAY_TOKEN');
  final password = _readValue(
    args,
    env,
    'password',
    'OPENCLAW_GATEWAY_PASSWORD',
  );
  if (token != null &&
      token.isNotEmpty &&
      password != null &&
      password.isNotEmpty) {
    throw const _CliUsageException(
      'Pass either --token or --password, not both.',
    );
  }
  if (token != null && token.isNotEmpty) {
    return GatewayAuth.token(token);
  }
  if (password != null && password.isNotEmpty) {
    return GatewayAuth.password(password);
  }
  return const GatewayAuth.none();
}

bool _hasSharedAuth(GatewayAuth auth) {
  final json = auth.toJson();
  if (json == null) {
    return false;
  }
  final token = json['token'];
  final password = json['password'];
  return (token is String && token.isNotEmpty) ||
      (password is String && password.isNotEmpty);
}

String? _readValue(
  ArgResults args,
  Map<String, String> env,
  String optionName,
  String envName,
) {
  final value = args.option(optionName);
  if (value != null && value.isNotEmpty) {
    return value;
  }
  return env[envName];
}

String _resolveStatePath(ArgResults args) {
  final raw = args.option('state-file') ?? _defaultStateFile;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    throw const _CliUsageException('--state-file must not be empty.');
  }
  return trimmed;
}

String? _readPairingRequestId(Object? details) {
  if (details is! Map) {
    return null;
  }
  final requestId = details['requestId'];
  if (requestId is String && requestId.isNotEmpty) {
    return requestId;
  }
  return null;
}

void _printUsage(
  ArgParser parser,
  IOSink sink, {
  String? error,
}) {
  if (error != null) {
    sink.writeln(error);
    sink.writeln('');
  }

  sink.writeln('OpenClaw Gateway Node Host');
  sink.writeln('');
  sink.writeln('Usage:');
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_node_host [options]',
  );
  sink.writeln('');
  sink.writeln('Options:');
  sink.writeln(parser.usage);
  sink.writeln('');
  sink.writeln('Examples:');
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_node_host --url ws://127.0.0.1:18789 --token gateway-shared-token --approve-pairing',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_node_host --url ws://127.0.0.1:18789 --state-file ~/.openclaw_gateway_node_state.json --once',
  );
}

Future<GatewayNodeCommandResult> _handleCameraList(
  GatewayNodeCommandContext context,
) async {
  return const GatewayNodeCommandResult.ok(
    payload: <String, Object?>{
      'cameras': <Object?>[],
    },
  );
}

Future<GatewayNodeCommandResult> _handleFail(
  GatewayNodeCommandContext context,
) async {
  return GatewayNodeCommandResult.error(
    code: 'forced_failure',
    message: 'Requested failure from sample node host.',
  );
}

class _CliUsageException implements Exception {
  const _CliUsageException(this.message);

  final String message;
}
