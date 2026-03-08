import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openclaw_gateway/openclaw_gateway.dart';

void main() {
  runApp(const GatewayExampleApp());
}

class GatewayExampleApp extends StatelessWidget {
  const GatewayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenClaw Gateway Flutter Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
      ),
      home: const GatewayExampleHomePage(),
    );
  }
}

class GatewayExampleHomePage extends StatefulWidget {
  const GatewayExampleHomePage({super.key});

  @override
  State<GatewayExampleHomePage> createState() => _GatewayExampleHomePageState();
}

class _GatewayExampleHomePageState extends State<GatewayExampleHomePage> {
  final TextEditingController _urlController = TextEditingController(
    text: 'ws://127.0.0.1:18789',
  );
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _sessionController = TextEditingController(
    text: 'main',
  );
  final TextEditingController _promptController = TextEditingController(
    text: 'Reply with exactly: ok',
  );

  GatewayClient? _client;
  StreamSubscription<GatewayConnectionState>? _connectionSubscription;
  StreamSubscription<GatewayChatEvent>? _chatSubscription;

  GatewayConnectionState _connectionState = const GatewayConnectionState(
    phase: GatewayConnectionPhase.disconnected,
  );
  GatewayHealthSummary? _health;
  List<GatewaySessionRow> _sessions = const <GatewaySessionRow>[];
  List<JsonMap> _history = const <JsonMap>[];
  final List<String> _logLines = <String>[];

  String? _serverVersion;
  String? _errorText;
  bool _busy = false;

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _chatSubscription?.cancel();
    unawaited(_client?.close());
    _urlController.dispose();
    _tokenController.dispose();
    _sessionController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final token = _tokenController.text.trim();
    final url = _urlController.text.trim();
    if (token.isEmpty) {
      _setError('Enter a gateway token first.');
      return;
    }
    if (url.isEmpty) {
      _setError('Enter a gateway WebSocket URL first.');
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    await _disconnect(quiet: true);

    try {
      final client = await GatewayClient.connect(
        uri: Uri.parse(url),
        auth: GatewayAuth.token(token),
        autoReconnect: true,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.gatewayClient,
          version: '0.1.0',
          platform: 'flutter',
          mode: GatewayClientModes.ui,
          displayName: 'OpenClaw Flutter Example',
        ),
      );

      _connectionSubscription = client.connectionStates.listen((state) {
        if (!mounted) {
          return;
        }
        setState(() {
          _connectionState = state;
        });
        if (state.error != null) {
          _appendLog('connection error: ${state.error}');
        }
      });

      _chatSubscription = client.operator.chatEvents.listen((event) {
        if (event.sessionKey != _sessionController.text.trim()) {
          return;
        }
        final summary =
            event.errorMessage ??
            (event.message == null
                ? '(no message payload)'
                : _pretty(event.message));
        _appendLog('chat ${event.state}: $summary');
        if (event.isTerminal) {
          unawaited(_loadHistory());
        }
      });

      if (!mounted) {
        await client.close();
        return;
      }

      setState(() {
        _client = client;
        _connectionState = client.connectionState;
        _serverVersion = client.hello.server.version;
      });
      _appendLog('connected to gateway ${client.hello.server.version}');
      await _refresh();
    } catch (error) {
      _setError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _disconnect({bool quiet = false}) async {
    final client = _client;
    _client = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await _chatSubscription?.cancel();
    _chatSubscription = null;
    if (client != null) {
      await client.close();
      if (!quiet) {
        _appendLog('disconnected');
      }
    }
    if (mounted) {
      setState(() {
        _connectionState = const GatewayConnectionState(
          phase: GatewayConnectionPhase.disconnected,
        );
        _health = null;
        _sessions = const <GatewaySessionRow>[];
        _history = const <JsonMap>[];
      });
    }
  }

  Future<void> _refresh() async {
    final client = _client;
    if (client == null) {
      _setError('Connect first.');
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final health = await client.query.health();
      final sessions = await client.query.sessionsList(
        limit: 12,
        includeDerivedTitles: true,
        includeLastMessage: true,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _health = health;
        _sessions = sessions.sessions;
      });
      await _loadHistory();
    } catch (error) {
      _setError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _loadHistory() async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      final payload = await client.operator.chatHistory(
        sessionKey: _sessionController.text.trim(),
        limit: 12,
      );
      final messages = payload['messages'];
      final history = messages is List
          ? messages
                .whereType<Object?>()
                .map(_toJsonMap)
                .toList(growable: false)
          : const <JsonMap>[];
      if (!mounted) {
        return;
      }
      setState(() {
        _history = history;
      });
    } catch (error) {
      _appendLog('history load failed: $error');
    }
  }

  Future<void> _sendPrompt() async {
    final client = _client;
    if (client == null) {
      _setError('Connect first.');
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _setError('Enter a prompt first.');
      return;
    }

    setState(() {
      _busy = true;
      _errorText = null;
    });

    try {
      final payload = await client.operator.chatSend(
        sessionKey: _sessionController.text.trim(),
        message: prompt,
      );
      _appendLog('chat.send accepted: ${_pretty(payload)}');
      if (mounted) {
        _promptController.clear();
      }
    } catch (error) {
      _setError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _selectSession(String key) {
    _sessionController.text = key;
    _appendLog('session selected: $key');
    unawaited(_loadHistory());
  }

  void _appendLog(String line) {
    final timestamp = TimeOfDay.now().format(context);
    setState(() {
      _logLines.insert(0, '[$timestamp] $line');
      if (_logLines.length > 40) {
        _logLines.removeRange(40, _logLines.length);
      }
    });
  }

  void _setError(String message) {
    setState(() {
      _errorText = message;
    });
    _appendLog('error: $message');
  }

  String _pretty(Object? value) {
    if (value == null) {
      return 'null';
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  JsonMap _toJsonMap(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, entry) => MapEntry(key.toString(), entry));
    }
    throw FormatException('Expected chat history entry to be a map.');
  }

  @override
  Widget build(BuildContext context) {
    final connected = _connectionState.isConnected;
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenClaw Gateway Example'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: _StatusChip(phase: _connectionState.phase, busy: _busy),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                title: 'Connection',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Gateway URL',
                        hintText: 'ws://127.0.0.1:18789',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Gateway Token',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sessionController,
                      decoration: const InputDecoration(
                        labelText: 'Session Key',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: _busy ? null : _connect,
                          icon: const Icon(Icons.link),
                          label: const Text('Connect'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy || _client == null
                              ? null
                              : _disconnect,
                          icon: const Icon(Icons.link_off),
                          label: const Text('Disconnect'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy || !connected ? null : _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _busy || !connected ? null : _loadHistory,
                          icon: const Icon(Icons.history),
                          label: const Text('Load History'),
                        ),
                      ],
                    ),
                    if (_serverVersion != null) ...[
                      const SizedBox(height: 12),
                      Text('Server version: $_serverVersion'),
                    ],
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _SectionCard(
                title: 'Health',
                child: _health == null
                    ? const Text('Connect and refresh to load gateway health.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('OK: ${_health!.ok}'),
                          Text(
                            'Default agent: ${_health!.defaultAgentId ?? '-'}',
                          ),
                          Text('Channels: ${_health!.channelOrder.join(', ')}'),
                          Text(
                            'Heartbeat seconds: ${_health!.heartbeatSeconds ?? '-'}',
                          ),
                        ],
                      ),
              ),
              _SectionCard(
                title: 'Sessions',
                child: _sessions.isEmpty
                    ? const Text('No sessions loaded yet.')
                    : Column(
                        children: _sessions
                            .map(
                              (session) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  session.displayName ??
                                      session.derivedTitle ??
                                      session.key,
                                ),
                                subtitle: Text(session.key),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _selectSession(session.key),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
              _SectionCard(
                title: 'Chat',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _promptController,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Prompt'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _busy || !connected ? null : _sendPrompt,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Prompt'),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Chat History',
                child: _history.isEmpty
                    ? const Text('No history loaded yet.')
                    : Column(
                        children: _history
                            .map(
                              (entry) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text('${entry['role'] ?? 'unknown'}'),
                                subtitle: Text(
                                  _pretty(entry['content'] ?? entry),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
              _SectionCard(
                title: 'Activity Log',
                child: _logLines.isEmpty
                    ? const Text('No activity yet.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _logLines
                            .map(
                              (line) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SelectableText(
                                  line,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.phase, required this.busy});

  final GatewayConnectionPhase phase;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (phase) {
      GatewayConnectionPhase.connected => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      GatewayConnectionPhase.connecting => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      GatewayConnectionPhase.reconnecting => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      GatewayConnectionPhase.closed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      GatewayConnectionPhase.disconnected => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
    };

    final label = busy ? '${phase.name}...' : phase.name;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
