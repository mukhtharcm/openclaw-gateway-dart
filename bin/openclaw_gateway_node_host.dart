import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

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
    final state = await _NodeHostState.open(statePath);
    final identity = await state.loadOrCreateIdentity();
    final store = _NodeHostDeviceTokenStore(state);
    final commands = args.multiOption('command');
    final caps = args.multiOption('cap');

    final client = await _connectNodeHost(
      uri: uri,
      auth: auth,
      displayName: args.option('display-name') ?? _defaultDisplayName,
      platform: args.option('platform') ?? _defaultPlatform,
      version: args.option('client-version') ?? _defaultClientVersion,
      identity: identity,
      store: store,
      commands: commands,
      caps: caps,
      approvePairing: args.flag('approve-pairing'),
    );

    stdout.writeln(
      'Connected nodeId=${identity.deviceId} commands=${commands.join(",")} stateFile=${state.file.path}',
    );

    final done = Completer<void>();
    var handledRequests = 0;

    final stateSubscription = client.connectionStates.listen((state) {
      stderr.writeln(
        'connection phase=${state.phase.name} attempt=${state.attempt}',
      );
    });

    final requestSubscription = client.node.invokeRequests.listen((request) {
      unawaited(() async {
        stderr.writeln(
          'invoke id=${request.id} command=${request.command} nodeId=${request.nodeId}',
        );
        await _handleInvoke(client, request);
        handledRequests += 1;
        if (args.flag('once') && handledRequests >= 1 && !done.isCompleted) {
          done.complete();
        }
      }());
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
  required List<String> commands,
  required List<String> caps,
  required bool approvePairing,
}) async {
  while (true) {
    try {
      return await GatewayClient.connect(
        uri: uri,
        auth: auth,
        role: gatewayNodeRole,
        scopes: const <String>[],
        caps: caps,
        commands: commands,
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

Future<void> _handleInvoke(
  GatewayClient client,
  GatewayNodeInvokeRequest request,
) async {
  switch (request.command) {
    case 'system.notify':
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: <String, Object?>{
          'notified': true,
          'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
          'params': request.params,
        },
      );
      return;
    case 'camera.list':
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: <String, Object?>{
          'cameras': const <Object?>[],
        },
      );
      return;
    case 'ping':
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: <String, Object?>{
          'pong': true,
          'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
          'params': request.params,
        },
      );
      return;
    case 'echo':
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: true,
        payload: <String, Object?>{
          'echo': request.params,
          'receivedAtMs': DateTime.now().millisecondsSinceEpoch,
        },
      );
      return;
    case 'fail':
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: false,
        error: const GatewayNodeInvokeError(
          code: 'forced_failure',
          message: 'Requested failure from sample node host.',
        ),
      );
      return;
    default:
      await client.node.sendInvokeResult(
        id: request.id,
        nodeId: request.nodeId,
        ok: false,
        error: GatewayNodeInvokeError(
          code: 'unsupported_command',
          message: 'Unsupported command "${request.command}".',
        ),
      );
      return;
  }
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

class _NodeHostState {
  _NodeHostState._(this.file, this._json);

  static final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  static Future<_NodeHostState> open(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return _NodeHostState._(file, <String, Object?>{});
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map) {
      throw GatewayProtocolException(
        'Invalid node host state file: expected a JSON object.',
      );
    }
    return _NodeHostState._(file, Map<String, Object?>.from(decoded));
  }

  final File file;
  final Map<String, Object?> _json;

  Future<GatewayEd25519Identity> loadOrCreateIdentity() async {
    final raw = _json['identity'];
    if (raw is Map) {
      return GatewayEd25519Identity.fromData(
        GatewayEd25519IdentityData.fromJson(Map<String, Object?>.from(raw)),
      );
    }

    final identity = await GatewayEd25519Identity.generate();
    _json['identity'] = (await identity.exportData()).toJson();
    await persist();
    return identity;
  }

  GatewayStoredDeviceToken? readToken({
    required String deviceId,
    required String role,
  }) {
    final entries = _json['tokens'];
    if (entries is! List) {
      return null;
    }
    for (final entry in entries) {
      if (entry is! Map) {
        continue;
      }
      final json = Map<String, Object?>.from(entry);
      if (json['deviceId'] != deviceId || json['role'] != role) {
        continue;
      }
      return GatewayStoredDeviceToken(
        deviceId: json['deviceId']! as String,
        role: json['role']! as String,
        token: json['token']! as String,
        scopes: json['scopes'] is List
            ? List<String>.from(json['scopes']! as List)
            : const <String>[],
        issuedAtMs: json['issuedAtMs'] as int?,
      );
    }
    return null;
  }

  Future<void> writeToken(GatewayStoredDeviceToken token) async {
    final entries = _mutableTokens()
      ..removeWhere(
        (entry) =>
            entry['deviceId'] == token.deviceId && entry['role'] == token.role,
      )
      ..add(<String, Object?>{
        'deviceId': token.deviceId,
        'role': token.role,
        'token': token.token,
        'scopes': token.scopes,
        'issuedAtMs': token.issuedAtMs,
      });
    _json['tokens'] = entries;
    await persist();
  }

  Future<void> deleteToken({
    required String deviceId,
    required String role,
  }) async {
    final entries = _mutableTokens()
      ..removeWhere(
        (entry) => entry['deviceId'] == deviceId && entry['role'] == role,
      );
    _json['tokens'] = entries;
    await persist();
  }

  Future<void> persist() async {
    await file.parent.create(recursive: true);
    await file.writeAsString(_encoder.convert(_json));
  }

  List<Map<String, Object?>> _mutableTokens() {
    final entries = _json['tokens'];
    if (entries is! List) {
      return <Map<String, Object?>>[];
    }
    return entries
        .whereType<Map>()
        .map((entry) => Map<String, Object?>.from(entry))
        .toList(growable: true);
  }
}

class _NodeHostDeviceTokenStore implements GatewayDeviceTokenStore {
  const _NodeHostDeviceTokenStore(this._state);

  final _NodeHostState _state;

  @override
  Future<void> delete({
    required String deviceId,
    required String role,
  }) {
    return _state.deleteToken(deviceId: deviceId, role: role);
  }

  @override
  Future<GatewayStoredDeviceToken?> read({
    required String deviceId,
    required String role,
  }) async {
    return _state.readToken(deviceId: deviceId, role: role);
  }

  @override
  Future<void> write(GatewayStoredDeviceToken token) {
    return _state.writeToken(token);
  }
}

class _CliUsageException implements Exception {
  const _CliUsageException(this.message);

  final String message;
}
