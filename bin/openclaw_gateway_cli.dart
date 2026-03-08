import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

const String _defaultClientId = GatewayClientIds.cli;
const String _defaultClientVersion = '0.1.0';
const String _defaultDisplayName = 'OpenClaw Dart CLI';
const String _defaultPlatform = 'dart';
const String _defaultMode = GatewayClientModes.cli;

Future<void> main(List<String> arguments) async {
  final parser = _buildParser();
  late final ArgResults args;

  try {
    args = parser.parse(arguments);
  } on FormatException catch (error) {
    _printUsage(
      parser,
      stderr,
      error: error.message,
    );
    exitCode = 64;
    return;
  }

  if (args.flag('help')) {
    _printUsage(parser, stdout);
    return;
  }

  final command = args.command;
  if (command == null) {
    _printUsage(parser, stderr, error: 'Missing command.');
    exitCode = 64;
    return;
  }

  if (command.flag('help')) {
    _printCommandUsage(parser, command.name!, stdout);
    return;
  }

  try {
    switch (command.name) {
      case 'help':
        _handleHelp(parser, command);
        return;
      case 'events':
        await _runEventsCommand(args, command);
        return;
      case 'chat-watch':
        await _runChatWatchCommand(args, command);
        return;
      default:
        await _runRpcCommand(args, command);
        return;
    }
  } on _CliUsageException catch (error) {
    stderr.writeln(error.message);
    stderr.writeln('');
    _printCommandUsage(parser, command.name!, stderr);
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
  final parser = ArgParser()
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
      'client-id',
      defaultsTo: _defaultClientId,
      help: 'Gateway client id sent during connect.',
    )
    ..addOption(
      'client-version',
      defaultsTo: _defaultClientVersion,
      help: 'Gateway client version sent during connect.',
    )
    ..addOption(
      'display-name',
      defaultsTo: _defaultDisplayName,
      help: 'Gateway client display name sent during connect.',
    )
    ..addOption(
      'platform',
      defaultsTo: _defaultPlatform,
      help: 'Gateway client platform string sent during connect.',
    )
    ..addOption(
      'mode',
      defaultsTo: _defaultMode,
      help: 'Gateway client mode sent during connect.',
    )
    ..addMultiOption(
      'scope',
      help: 'Requested gateway scope. Repeat to override the defaults.',
      valueHelp: 'scope',
    )
    ..addFlag(
      'pretty',
      defaultsTo: true,
      help: 'Pretty-print JSON output.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage.',
    );

  parser.addCommand(
    'health',
    ArgParser()
      ..addFlag('probe',
          help: 'Ask the gateway to probe instead of using cache.')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'status',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'config-get',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'sessions-list',
    ArgParser()
      ..addOption('limit', valueHelp: 'n', help: 'Maximum sessions to return.')
      ..addOption(
        'active-minutes',
        valueHelp: 'n',
        help: 'Only include sessions active in the last N minutes.',
      )
      ..addOption('label', valueHelp: 'label', help: 'Filter by label.')
      ..addOption('spawned-by',
          valueHelp: 'value', help: 'Filter by spawnedBy.')
      ..addOption('agent-id', valueHelp: 'id', help: 'Filter by agent id.')
      ..addOption('search', valueHelp: 'text', help: 'Search session metadata.')
      ..addFlag('include-global', help: 'Include the global session row.')
      ..addFlag('include-unknown', help: 'Include the unknown session row.')
      ..addFlag(
        'include-derived-titles',
        help: 'Ask the gateway to read transcript-derived titles.',
      )
      ..addFlag(
        'include-last-message',
        help: 'Ask the gateway to read transcript previews.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'sessions-preview',
    ArgParser()
      ..addOption('limit',
          valueHelp: 'n', help: 'Maximum preview items per key.')
      ..addOption('max-chars',
          valueHelp: 'n', help: 'Maximum chars per preview item.')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'chat-history',
    ArgParser()
      ..addOption('limit', valueHelp: 'n', help: 'Maximum messages to return.')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'chat-send',
    ArgParser()
      ..addOption('thinking',
          valueHelp: 'level', help: 'Optional thinking level override.')
      ..addFlag('deliver',
          help: 'Ask the gateway to deliver externally when possible.')
      ..addOption('timeout-ms',
          valueHelp: 'n', help: 'Optional run timeout in ms.')
      ..addOption(
        'idempotency-key',
        valueHelp: 'key',
        help: 'Override the generated idempotency key.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'chat-watch',
    ArgParser()
      ..addOption(
        'thinking',
        valueHelp: 'level',
        help: 'Optional thinking level override.',
      )
      ..addFlag(
        'deliver',
        help: 'Ask the gateway to deliver externally when possible.',
      )
      ..addOption(
        'timeout-ms',
        valueHelp: 'n',
        help: 'Optional run timeout in ms for the gateway request.',
      )
      ..addOption(
        'wait-timeout-ms',
        valueHelp: 'n',
        help: 'Maximum time to wait for a final chat event.',
      )
      ..addOption(
        'idempotency-key',
        valueHelp: 'key',
        help: 'Override the generated idempotency key.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'chat-abort',
    ArgParser()
      ..addOption('run-id', valueHelp: 'id', help: 'Abort a specific run only.')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'nodes-list',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'node-describe',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'node-invoke',
    ArgParser()
      ..addOption(
        'params',
        valueHelp: '\'{"key":"value"}\'',
        help: 'Inline JSON params for the node command.',
      )
      ..addOption(
        'timeout-ms',
        valueHelp: 'n',
        help: 'Optional invoke timeout in ms.',
      )
      ..addOption(
        'idempotency-key',
        valueHelp: 'key',
        help: 'Override the generated idempotency key.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'events',
    ArgParser()
      ..addOption('name',
          valueHelp: 'event', help: 'Only print matching event names.')
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'raw',
    ArgParser()
      ..addOption(
        'params',
        valueHelp: '\'{"key":"value"}\'',
        help: 'Inline JSON params. If omitted, stdin is used when piped.',
      )
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  parser.addCommand(
    'help',
    ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Show usage.'),
  );
  return parser;
}

void _handleHelp(ArgParser parser, ArgResults command) {
  final target = command.rest.isEmpty ? null : command.rest.first;
  if (target == null) {
    _printUsage(parser, stdout);
    return;
  }
  _printCommandUsage(parser, target, stdout);
}

Future<void> _runRpcCommand(ArgResults globalArgs, ArgResults command) async {
  final client = await _connect(globalArgs);
  final output = _JsonPrinter(globalArgs.flag('pretty'));

  try {
    switch (command.name) {
      case 'health':
        output.writeJson(
            await client.operator.health(probe: command.flag('probe')));
        return;
      case 'status':
        output.writeJson(await client.operator.status());
        return;
      case 'config-get':
        output.writeJson(await client.operator.configGet());
        return;
      case 'sessions-list':
        output.writeJson(
          await client.operator.sessionsList(
            limit: _readIntOption(command, 'limit'),
            activeMinutes: _readIntOption(command, 'active-minutes'),
            includeGlobal: command.wasParsed('include-global')
                ? command.flag('include-global')
                : null,
            includeUnknown: command.wasParsed('include-unknown')
                ? command.flag('include-unknown')
                : null,
            includeDerivedTitles: command.wasParsed('include-derived-titles')
                ? command.flag('include-derived-titles')
                : null,
            includeLastMessage: command.wasParsed('include-last-message')
                ? command.flag('include-last-message')
                : null,
            label: _readOptionalString(command, 'label'),
            spawnedBy: _readOptionalString(command, 'spawned-by'),
            agentId: _readOptionalString(command, 'agent-id'),
            search: _readOptionalString(command, 'search'),
          ),
        );
        return;
      case 'sessions-preview':
        if (command.rest.isEmpty) {
          throw const _CliUsageException(
              'sessions-preview requires at least one session key.');
        }
        output.writeJson(
          await client.operator.sessionsPreview(
            keys: command.rest,
            limit: _readIntOption(command, 'limit'),
            maxChars: _readIntOption(command, 'max-chars'),
          ),
        );
        return;
      case 'chat-history':
        if (command.rest.isEmpty) {
          throw const _CliUsageException(
              'chat-history requires a session key.');
        }
        output.writeJson(
          await client.operator.chatHistory(
            sessionKey: command.rest.first,
            limit: _readIntOption(command, 'limit'),
          ),
        );
        return;
      case 'chat-send':
        if (command.rest.isEmpty) {
          throw const _CliUsageException('chat-send requires a session key.');
        }
        output.writeJson(
          await client.operator.chatSend(
            sessionKey: command.rest.first,
            message: await _readChatMessage(
              command,
              commandName: 'chat-send',
            ),
            thinking: _readOptionalString(command, 'thinking'),
            deliver:
                command.wasParsed('deliver') ? command.flag('deliver') : null,
            timeoutMs: _readIntOption(command, 'timeout-ms'),
            idempotencyKey: _readOptionalString(command, 'idempotency-key'),
          ),
        );
        return;
      case 'chat-abort':
        if (command.rest.isEmpty) {
          throw const _CliUsageException('chat-abort requires a session key.');
        }
        output.writeJson(
          await client.operator.chatAbort(
            sessionKey: command.rest.first,
            runId: _readOptionalString(command, 'run-id'),
          ),
        );
        return;
      case 'nodes-list':
        output.writeJson({
          'nodes': (await client.nodes.list())
              .map(_nodeSummaryToJson)
              .toList(growable: false),
        });
        return;
      case 'node-describe':
        if (command.rest.isEmpty) {
          throw const _CliUsageException('node-describe requires a node id.');
        }
        output.writeJson(
          _nodeSummaryToJson(
            await client.nodes.describe(nodeId: command.rest.first),
          ),
        );
        return;
      case 'node-invoke':
        if (command.rest.length < 2) {
          throw const _CliUsageException(
            'node-invoke requires a node id and command.',
          );
        }
        output.writeJson(
          _nodeInvokeResultToJson(
            await client.nodes.invoke(
              nodeId: command.rest.first,
              command: command.rest[1],
              params: await _readOptionalJsonInput(command, 'params'),
              timeoutMs: _readIntOption(command, 'timeout-ms'),
              idempotencyKey: _readOptionalString(command, 'idempotency-key'),
            ),
          ),
        );
        return;
      case 'raw':
        if (command.rest.isEmpty) {
          throw const _CliUsageException('raw requires a method name.');
        }
        output.writeJson(
          await client.request(
            command.rest.first,
            params: await _readOptionalJsonInput(command, 'params'),
          ),
        );
        return;
      default:
        throw _CliUsageException('Unknown command "${command.name}".');
    }
  } finally {
    await client.close();
  }
}

Future<void> _runChatWatchCommand(
  ArgResults globalArgs,
  ArgResults command,
) async {
  if (command.rest.isEmpty) {
    throw const _CliUsageException('chat-watch requires a session key.');
  }

  final sessionKey = command.rest.first;
  final message = await _readChatMessage(command, commandName: 'chat-watch');
  final client = await _connect(globalArgs);
  final runId = _readOptionalString(command, 'idempotency-key') ??
      client.createIdempotencyKey(prefix: 'chat');
  final waitTimeout = _readIntOption(command, 'wait-timeout-ms');
  final printer = _StreamingTextPrinter();
  final completion = Completer<void>();
  StreamSubscription<GatewayEventFrame>? subscription;
  StreamSubscription<ProcessSignal>? sigintSubscription;

  try {
    subscription = client.eventsNamed('chat').listen(
      (event) {
        final payload = _coerceJsonMap(event.payload);
        if (payload == null) {
          return;
        }
        final eventRunId = payload['runId'];
        if (eventRunId != runId) {
          return;
        }

        final state = payload['state'] as String?;
        final text = _extractChatMessageText(payload['message']);
        if (text != null) {
          printer.write(text);
        }

        switch (state) {
          case 'final':
            printer.finish();
            if (!completion.isCompleted) {
              completion.complete();
            }
            return;
          case 'error':
            printer.finish();
            final errorMessage =
                payload['errorMessage'] as String? ?? 'chat run failed';
            if (!completion.isCompleted) {
              completion.completeError(GatewayException(errorMessage));
            }
            return;
          case 'aborted':
            printer.finish();
            if (!completion.isCompleted) {
              completion.completeError(
                GatewayException('chat run aborted'),
              );
            }
            return;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completion.isCompleted) {
          completion.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completion.isCompleted) {
          completion.completeError(
            GatewayClosedException('Gateway closed before chat completed.'),
          );
        }
      },
      cancelOnError: true,
    );

    sigintSubscription = ProcessSignal.sigint.watch().listen((_) async {
      if (!completion.isCompleted) {
        completion.completeError(GatewayException('Interrupted.'));
      }
      try {
        await client.operator.chatAbort(sessionKey: sessionKey, runId: runId);
      } catch (_) {
        // Best effort only.
      }
    });

    final ack = await client.operator.chatSend(
      sessionKey: sessionKey,
      message: message,
      thinking: _readOptionalString(command, 'thinking'),
      deliver: command.wasParsed('deliver') ? command.flag('deliver') : null,
      timeoutMs: _readIntOption(command, 'timeout-ms'),
      idempotencyKey: runId,
    );

    stderr.writeln(
      'runId=${ack['runId'] ?? runId} status=${ack['status'] ?? 'unknown'}',
    );

    final waitFuture = completion.future;
    if (waitTimeout != null) {
      await waitFuture.timeout(
        Duration(milliseconds: waitTimeout),
        onTimeout: () => throw GatewayTimeoutException(
          'Timed out waiting for chat completion.',
        ),
      );
      return;
    }
    await waitFuture;
  } finally {
    await sigintSubscription?.cancel();
    await subscription?.cancel();
    await client.close();
  }
}

Future<void> _runEventsCommand(
    ArgResults globalArgs, ArgResults command) async {
  final client = await _connect(globalArgs);
  final output = _JsonPrinter(globalArgs.flag('pretty'));
  final eventName = _readOptionalString(command, 'name');
  StreamSubscription<GatewayEventFrame>? subscription;
  StreamSubscription<ProcessSignal>? sigintSubscription;

  try {
    subscription = client.events.listen((event) {
      if (eventName != null && event.event != eventName) {
        return;
      }
      output.writeJson({
        'event': event.event,
        'seq': event.seq,
        'stateVersion': event.stateVersion,
        'payload': event.payload,
      });
    });

    stdout.writeln('Connected. Press Ctrl-C to stop.');
    sigintSubscription = ProcessSignal.sigint.watch().listen((_) async {
      await subscription?.cancel();
      await client.close();
      exit(0);
    });

    await Completer<void>().future;
  } finally {
    await sigintSubscription?.cancel();
    await subscription?.cancel();
    await client.close();
  }
}

Future<GatewayClient> _connect(ArgResults args) {
  final env = Platform.environment;
  final rawUrl = _readGlobalValue(args, env, 'url', 'OPENCLAW_GATEWAY_URL');
  if (rawUrl == null || rawUrl.trim().isEmpty) {
    throw const _CliUsageException(
      'Missing gateway URL. Pass --url or set OPENCLAW_GATEWAY_URL.',
    );
  }

  final token = _readGlobalValue(args, env, 'token', 'OPENCLAW_GATEWAY_TOKEN');
  final password = _readGlobalValue(
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
        'Pass either --token or --password, not both.');
  }

  final auth = token != null && token.isNotEmpty
      ? GatewayAuth.token(token)
      : password != null && password.isNotEmpty
          ? GatewayAuth.password(password)
          : const GatewayAuth.none();

  final scopes = args.multiOption('scope');
  return GatewayClient.connect(
    uri: Uri.parse(rawUrl),
    auth: auth,
    clientInfo: GatewayClientInfo(
      id: args.option('client-id') ?? _defaultClientId,
      version: args.option('client-version') ?? _defaultClientVersion,
      platform: args.option('platform') ?? _defaultPlatform,
      mode: args.option('mode') ?? _defaultMode,
      displayName: args.option('display-name') ?? _defaultDisplayName,
    ),
    scopes: scopes.isEmpty ? null : scopes,
  );
}

String? _readGlobalValue(
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

String? _readOptionalString(ArgResults args, String name) {
  final value = args.option(name);
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _readIntOption(ArgResults args, String name) {
  final raw = _readOptionalString(args, name);
  if (raw == null) {
    return null;
  }
  final parsed = int.tryParse(raw);
  if (parsed == null) {
    throw FormatException('Invalid integer for --$name: $raw');
  }
  return parsed;
}

Future<String> _readChatMessage(
  ArgResults command, {
  required String commandName,
}) async {
  if (command.rest.length > 1) {
    return command.rest.skip(1).join(' ');
  }
  final piped = await _readPipedStdin();
  if (piped != null && piped.trim().isNotEmpty) {
    return piped;
  }
  throw _CliUsageException(
    '$commandName requires a message argument or piped stdin content.',
  );
}

Future<Object?> _readOptionalJsonInput(
    ArgResults command, String optionName) async {
  final inline = _readOptionalString(command, optionName);
  if (inline != null) {
    return jsonDecode(inline);
  }
  final piped = await _readPipedStdin();
  if (piped == null || piped.trim().isEmpty) {
    return null;
  }
  return jsonDecode(piped);
}

Future<String?> _readPipedStdin() async {
  if (stdin.hasTerminal) {
    return null;
  }
  return await stdin.transform(utf8.decoder).join();
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

  sink.writeln('OpenClaw Gateway CLI');
  sink.writeln('');
  sink.writeln('Usage:');
  sink.writeln(
      '  dart run openclaw_gateway:openclaw_gateway_cli <command> [options]');
  sink.writeln('');
  sink.writeln('Global options:');
  sink.writeln(parser.usage);
  sink.writeln('');
  sink.writeln('Examples:');
  sink.writeln('  dart run openclaw_gateway:openclaw_gateway_cli health');
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli sessions-list --limit 10',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli chat-history main --limit 20',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli chat-send main "hello"',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli chat-watch main "hello"',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli nodes-list',
  );
  sink.writeln(
    '  dart run openclaw_gateway:openclaw_gateway_cli node-invoke <node-id> system.notify --params \'{"title":"Hello","body":"From Dart"}\'',
  );
  sink.writeln(
    '  echo \'{"probe":true}\' | dart run openclaw_gateway:openclaw_gateway_cli raw health',
  );
}

void _printCommandUsage(ArgParser parser, String commandName, IOSink sink) {
  final command = parser.commands[commandName];
  if (command == null) {
    sink.writeln('Unknown command "$commandName".');
    sink.writeln('');
    _printUsage(parser, sink);
    return;
  }

  sink.writeln('Command: $commandName');
  sink.writeln('');
  sink.writeln('Usage:');
  switch (commandName) {
    case 'health':
      sink.writeln('  ... health [--probe]');
      break;
    case 'status':
      sink.writeln('  ... status');
      break;
    case 'config-get':
      sink.writeln('  ... config-get');
      break;
    case 'sessions-list':
      sink.writeln('  ... sessions-list [options]');
      break;
    case 'sessions-preview':
      sink.writeln('  ... sessions-preview <key> [<key> ...] [options]');
      break;
    case 'chat-history':
      sink.writeln('  ... chat-history <session-key> [--limit n]');
      break;
    case 'chat-send':
      sink.writeln('  ... chat-send <session-key> <message...>');
      sink.writeln('  ... chat-send <session-key> < input.txt');
      break;
    case 'chat-watch':
      sink.writeln('  ... chat-watch <session-key> <message...>');
      sink.writeln('  ... chat-watch <session-key> < input.txt');
      break;
    case 'chat-abort':
      sink.writeln('  ... chat-abort <session-key> [--run-id id]');
      break;
    case 'nodes-list':
      sink.writeln('  ... nodes-list');
      break;
    case 'node-describe':
      sink.writeln('  ... node-describe <node-id>');
      break;
    case 'node-invoke':
      sink.writeln(
          '  ... node-invoke <node-id> <command> [--params \'{"key":"value"}\']');
      break;
    case 'events':
      sink.writeln('  ... events [--name chat]');
      break;
    case 'raw':
      sink.writeln('  ... raw <method> [--params \'{"key":"value"}\']');
      break;
    case 'help':
      sink.writeln('  ... help [command]');
      break;
  }
  sink.writeln('');
  sink.writeln(command.usage);
}

class _JsonPrinter {
  _JsonPrinter(bool pretty)
      : _encoder =
            pretty ? const JsonEncoder.withIndent('  ') : const JsonEncoder();

  final JsonEncoder _encoder;

  void writeJson(Object? value) {
    stdout.writeln(_encoder.convert(value));
  }
}

JsonMap? _coerceJsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  return null;
}

String? _extractChatMessageText(Object? value) {
  final message = _coerceJsonMap(value);
  if (message == null) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  final directText = message['text'];
  if (directText is String && directText.isNotEmpty) {
    return directText;
  }

  final content = message['content'];
  if (content is String && content.isNotEmpty) {
    return content;
  }
  if (content is! List) {
    return null;
  }

  final parts = <String>[];
  for (final block in content) {
    final typed = _coerceJsonMap(block);
    if (typed == null) {
      continue;
    }
    if (typed['type'] == 'text' && typed['text'] is String) {
      parts.add(typed['text'] as String);
    }
  }

  if (parts.isEmpty) {
    return null;
  }
  return parts.join('\n');
}

Map<String, Object?> _nodeSummaryToJson(GatewayNodeSummary node) {
  return <String, Object?>{
    'nodeId': node.nodeId,
    'displayName': node.displayName,
    'platform': node.platform,
    'version': node.version,
    'coreVersion': node.coreVersion,
    'uiVersion': node.uiVersion,
    'deviceFamily': node.deviceFamily,
    'modelIdentifier': node.modelIdentifier,
    'remoteIp': node.remoteIp,
    'caps': node.caps,
    'commands': node.commands,
    'pathEnv': node.pathEnv,
    'permissions': node.permissions,
    'connectedAtMs': node.connectedAtMs,
    'paired': node.paired,
    'connected': node.connected,
  };
}

Map<String, Object?> _nodeInvokeResultToJson(GatewayNodeInvokeResult result) {
  return <String, Object?>{
    'ok': result.ok,
    'nodeId': result.nodeId,
    'command': result.command,
    'payload': result.payload,
    'payloadJSON': result.payloadJson,
  };
}

class _StreamingTextPrinter {
  String _current = '';
  bool _finished = false;

  void write(String next) {
    if (_finished) {
      return;
    }
    if (next == _current) {
      return;
    }
    if (next.startsWith(_current)) {
      stdout.write(next.substring(_current.length));
      _current = next;
      return;
    }

    if (_current.isNotEmpty && !_current.endsWith('\n')) {
      stdout.writeln();
    }
    stdout.writeln('[stream update]');
    stdout.write(next);
    _current = next;
  }

  void finish() {
    if (_finished) {
      return;
    }
    _finished = true;
    if (_current.isNotEmpty && !_current.endsWith('\n')) {
      stdout.writeln();
    }
  }
}

class _CliUsageException implements Exception {
  const _CliUsageException(this.message);

  final String message;
}
