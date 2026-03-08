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
      title: 'OpenClaw Gateway Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFDCE4DE),
        dividerColor: const Color(0xFFD6DDD8),
        textTheme: Typography.blackMountainView.apply(
          bodyColor: const Color(0xFF16312C),
          displayColor: const Color(0xFF16312C),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.78),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD6DDD8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF155E57),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF16312C),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            side: const BorderSide(color: Color(0xFFD0D8D2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
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
  StreamSubscription<GatewayEventFrame>? _eventSubscription;

  GatewayConnectionState _connectionState = const GatewayConnectionState(
    phase: GatewayConnectionPhase.disconnected,
  );
  GatewayHealthSummary? _health;
  GatewayStatusSnapshot? _status;
  GatewayChannelsStatusResult? _channelsStatus;
  GatewaySessionsListResult? _sessionsList;
  GatewaySessionsPreviewResult? _sessionsPreview;
  GatewayModelsListResult? _models;
  GatewayToolsCatalogResult? _tools;
  GatewayUsageStatusResult? _usage;
  GatewayVoiceWakeConfig? _voiceWake;
  GatewayCronStatusSummary? _cronStatus;
  List<GatewayNodeSummary> _nodes = const <GatewayNodeSummary>[];
  List<JsonMap> _history = const <JsonMap>[];
  final List<_EventLine> _eventLines = <_EventLine>[];
  final List<String> _logLines = <String>[];

  int _selectedSection = 0;
  String? _serverVersion;
  String? _errorText;
  bool _busy = false;

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _eventSubscription?.cancel();
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
          _appendLog('connection error: ${_describeError(state.error!)}');
        }
      });

      _eventSubscription = client.events.listen(_handleEventFrame);

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
      _setError(_describeUnknownError(error));
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
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    if (client != null) {
      await client.close();
      if (!quiet) {
        _appendLog('disconnected');
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _connectionState = const GatewayConnectionState(
        phase: GatewayConnectionPhase.disconnected,
      );
      _health = null;
      _status = null;
      _channelsStatus = null;
      _sessionsList = null;
      _sessionsPreview = null;
      _models = null;
      _tools = null;
      _usage = null;
      _voiceWake = null;
      _cronStatus = null;
      _nodes = const <GatewayNodeSummary>[];
      _history = const <JsonMap>[];
      _serverVersion = null;
    });
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
      final healthFuture = client.query.health();
      final statusFuture = client.query.status();
      final sessionsFuture = client.query.sessionsList(
        limit: 12,
        includeDerivedTitles: true,
        includeLastMessage: true,
      );
      final channelsFuture = _loadOptional(
        'channels.status',
        () => client.query.channelsStatus(),
      );
      final modelsFuture = _loadOptional(
        'models.list',
        () => client.query.modelsList(),
      );
      final toolsFuture = _loadOptional(
        'tools.catalog',
        () => client.query.toolsCatalog(includePlugins: true),
      );
      final usageFuture = _loadOptional(
        'usage.status',
        () => client.query.usageStatus(),
      );
      final voiceWakeFuture = _loadOptional(
        'voicewake.get',
        () => client.query.voiceWakeGet(),
      );
      final cronStatusFuture = _loadOptional(
        'cron.status',
        () => client.query.cronStatus(),
      );
      final nodesFuture = _loadOptional('node.list', () => client.nodes.list());

      final health = await healthFuture;
      final status = await statusFuture;
      final sessions = await sessionsFuture;
      final previewKeys = sessions.sessions
          .take(4)
          .map((session) => session.key)
          .toList(growable: false);
      final previewsFuture = previewKeys.isEmpty
          ? Future<GatewaySessionsPreviewResult?>.value(null)
          : _loadOptional(
              'sessions.preview',
              () => client.query.sessionsPreview(
                keys: previewKeys,
                limit: 3,
                maxChars: 160,
              ),
            );
      final historyFuture = _fetchHistory(_sessionController.text.trim());

      final channels = await channelsFuture;
      final models = await modelsFuture;
      final tools = await toolsFuture;
      final usage = await usageFuture;
      final voiceWake = await voiceWakeFuture;
      final cronStatus = await cronStatusFuture;
      final nodes = await nodesFuture;
      final previews = await previewsFuture;
      final history = await historyFuture;

      if (!mounted) {
        return;
      }
      setState(() {
        _health = health;
        _status = status;
        _sessionsList = sessions;
        _sessionsPreview = previews;
        _channelsStatus = channels;
        _models = models;
        _tools = tools;
        _usage = usage;
        _voiceWake = voiceWake;
        _cronStatus = cronStatus;
        _nodes = nodes ?? const <GatewayNodeSummary>[];
        _history = history;
      });
      _appendLog('refreshed gateway data');
    } catch (error) {
      _setError(_describeUnknownError(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<List<JsonMap>> _fetchHistory(String sessionKey) async {
    final client = _client;
    if (client == null || sessionKey.isEmpty) {
      return const <JsonMap>[];
    }

    final payload = await client.operator.chatHistory(
      sessionKey: sessionKey,
      limit: 12,
    );
    final messages = payload['messages'];
    return messages is List
        ? messages.whereType<Object?>().map(_toJsonMap).toList(growable: false)
        : const <JsonMap>[];
  }

  Future<void> _loadHistory() async {
    final client = _client;
    if (client == null) {
      return;
    }

    try {
      final history = await _fetchHistory(_sessionController.text.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        _history = history;
      });
    } catch (error) {
      _appendLog('history load failed: ${_describeUnknownError(error)}');
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
      _appendLog('chat.send accepted: ${_truncate(_pretty(payload), 220)}');
      if (mounted) {
        _promptController.clear();
      }
    } catch (error) {
      _setError(_describeUnknownError(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _handleEventFrame(GatewayEventFrame frame) {
    _appendEvent(frame.event, _summarizeEvent(frame));

    if (frame.event == 'chat') {
      final event = GatewayChatEvent.fromEventFrame(frame);
      if (event.sessionKey != _sessionController.text.trim()) {
        return;
      }
      final summary =
          event.errorMessage ??
          (event.message == null
              ? '(no message payload)'
              : _pretty(event.message));
      _appendLog('chat ${event.state}: ${_truncate(summary, 220)}');
      if (event.isTerminal) {
        unawaited(_loadHistory());
      }
      return;
    }

    if (frame.event == 'health') {
      try {
        final event = GatewayHealthEvent.fromEventFrame(frame);
        if (mounted) {
          setState(() {
            _health = GatewayHealthSummary.fromJson(event.raw);
          });
        }
      } catch (_) {
        // Keep the event feed resilient if the payload shape changes.
      }
    }
  }

  Future<T?> _loadOptional<T>(String label, Future<T> Function() loader) async {
    try {
      return await loader();
    } catch (error) {
      _appendLog('$label unavailable: ${_describeUnknownError(error)}');
      return null;
    }
  }

  void _selectSession(String key) {
    _sessionController.text = key;
    _appendLog('session selected: $key');
    unawaited(_loadHistory());
  }

  void _appendLog(String line) {
    if (!mounted) {
      return;
    }
    setState(() {
      _logLines.insert(0, '[${_clockNow()}] $line');
      if (_logLines.length > 50) {
        _logLines.removeRange(50, _logLines.length);
      }
    });
  }

  void _appendEvent(String name, String summary) {
    if (!mounted) {
      return;
    }
    setState(() {
      _eventLines.insert(
        0,
        _EventLine(timeLabel: _clockNow(), name: name, summary: summary),
      );
      if (_eventLines.length > 80) {
        _eventLines.removeRange(80, _eventLines.length);
      }
    });
  }

  void _setError(String message) {
    if (!mounted) {
      return;
    }
    setState(() {
      _errorText = message;
    });
    _appendLog('error: $message');
  }

  void _clearEvents() {
    setState(() {
      _eventLines.clear();
    });
  }

  String _describeUnknownError(Object error) {
    if (error is GatewayException) {
      return _describeError(error);
    }
    return error.toString();
  }

  String _describeError(GatewayException error) {
    final parts = <String>[error.toString()];
    Object? cause = error.cause;
    while (cause != null) {
      parts.add('caused by: $cause');
      if (cause is GatewayException) {
        cause = cause.cause;
      } else {
        break;
      }
    }
    return parts.join('\n');
  }

  String _summarizeEvent(GatewayEventFrame frame) {
    try {
      switch (frame.event) {
        case 'chat':
          final event = GatewayChatEvent.fromEventFrame(frame);
          final message =
              event.errorMessage ??
              (event.message == null
                  ? null
                  : _truncate(_pretty(event.message), 120));
          return [
            event.sessionKey,
            event.state,
            if (message != null && message.isNotEmpty) message,
          ].join(' • ');
        case 'presence':
          final event = GatewayPresenceEvent.fromEventFrame(frame);
          return '${event.presence.length} presence entries';
        case 'health':
          final event = GatewayHealthEvent.fromEventFrame(frame);
          return 'ok=${event.ok} • channels=${event.channelOrder.length}';
        case 'tick':
          final event = GatewayTickEvent.fromEventFrame(frame);
          return 'ts=${event.ts}';
        case 'shutdown':
          final event = GatewayShutdownEvent.fromEventFrame(frame);
          return event.reason;
        default:
          return _truncate(_pretty(frame.payload), 160);
      }
    } catch (_) {
      return _truncate(_pretty(frame.payload), 160);
    }
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

  String _clockNow() {
    final now = DateTime.now();
    return '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';
  }

  String _formatUnixMs(int? value) {
    if (value == null) {
      return '-';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} '
        '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) {
      return value;
    }
    return '${value.substring(0, maxChars - 1)}…';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final connected = _connectionState.isConnected;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isDesktopLayout(constraints.maxWidth)) {
          return _buildDesktopShell(connected);
        }
        return _buildCompactShell(connected);
      },
    );
  }

  bool _isDesktopLayout(double width) => width >= 1120;

  Widget _buildCompactShell(bool connected) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Sessions'),
              Tab(text: 'Explore'),
              Tab(text: 'Events'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildOverviewTab(connected),
              _buildSessionsTab(connected),
              _buildExploreTab(connected),
              _buildEventsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopShell(bool connected) {
    final section = _desktopSections[_selectedSection];
    return Scaffold(
      backgroundColor: const Color(0xFFDCE4DE),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8FAF7), Color(0xFFF2F5F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              _buildDesktopSidebar(connected),
              Expanded(
                child: Column(
                  children: [
                    _buildDesktopToolbar(section, connected),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey<int>(_selectedSection),
                            child: switch (_selectedSection) {
                              0 => _buildDesktopOverviewPage(),
                              1 => _buildDesktopSessionsPage(connected),
                              2 => _buildDesktopExplorePage(connected),
                              _ => _buildDesktopEventsPage(),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(bool connected) {
    final scheme = Theme.of(context).colorScheme;
    final hello = _client?.hello;
    return Container(
      width: 276,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF163C39), Color(0xFF1B2E2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OpenClaw',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gateway Desk',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              primary: false,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusChip(phase: _connectionState.phase, busy: _busy),
                      const SizedBox(height: 10),
                      Text(
                        connected ? 'Live gateway session' : 'Ready to connect',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.76),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SidebarMetaLine(
                        label: 'Server',
                        value: _serverVersion ?? '-',
                      ),
                      _SidebarMetaLine(
                        label: 'Protocol',
                        value: hello == null ? '-' : '${hello.protocol}',
                      ),
                      _SidebarMetaLine(
                        label: 'Events',
                        value: hello == null
                            ? '-'
                            : '${hello.features.events.length}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                for (final entry in _desktopSections.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _DesktopNavItem(
                      item: entry.$2,
                      selected: _selectedSection == entry.$1,
                      onTap: () {
                        setState(() {
                          _selectedSection = entry.$1;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected session',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _sessionController.text.trim().isEmpty
                            ? 'main'
                            : _sessionController.text.trim(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Use the workspace panes to inspect the gateway, browse sessions, and watch live traffic.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopToolbar(_DesktopSectionItem section, bool connected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  section.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_errorText != null)
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE6E2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _truncate(_errorText!, 140),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8C2F20),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          FilledButton.icon(
            onPressed: _busy ? null : _connect,
            icon: const Icon(Icons.link),
            label: const Text('Connect'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _busy || _client == null ? null : _disconnect,
            icon: const Icon(Icons.link_off),
            label: const Text('Disconnect'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _busy || !connected ? null : _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopOverviewPage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DesktopScrollPane(
            children: [_buildConnectionCard(), _buildHealthCard()],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DesktopScrollPane(
            children: [_buildSnapshotCard(), _buildRuntimeCard()],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSessionsPage(bool connected) {
    final sessions = _sessionsList?.sessions ?? const <GatewaySessionRow>[];
    final previews =
        _sessionsPreview?.previews ?? const <GatewaySessionsPreviewEntry>[];
    final selectedKey = _sessionController.text.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _DesktopScrollPane(
            children: [
              _SectionCard(
                title: 'Sessions',
                child: sessions.isEmpty
                    ? const _EmptyHint('No sessions loaded yet.')
                    : Column(
                        children: sessions
                            .map(
                              (session) => ListTile(
                                dense: true,
                                selected: session.key == selectedKey,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  session.displayName ??
                                      session.derivedTitle ??
                                      session.label ??
                                      session.key,
                                ),
                                subtitle: Text(
                                  [
                                    session.key,
                                    if (session.channel != null)
                                      session.channel!,
                                    if (session.lastMessagePreview != null)
                                      _truncate(
                                        session.lastMessagePreview!,
                                        100,
                                      ),
                                  ].join(' • '),
                                ),
                                trailing: Text(
                                  _formatUnixMs(session.updatedAt),
                                ),
                                onTap: () => _selectSession(session.key),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _DesktopScrollPane(
            children: [
              _SectionCard(
                title: 'Session Previews',
                child: previews.isEmpty
                    ? const _EmptyHint('Refresh to load session previews.')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: previews
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MiniPanel(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${entry.key} • ${entry.status}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      for (final item in entry.items)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Text(
                                            '${item.role}: ${item.text}',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
              ),
              _SectionCard(
                title: 'Composer',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selected session: ${selectedKey.isEmpty ? '-' : selectedKey}',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promptController,
                      minLines: 4,
                      maxLines: 8,
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
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: _DesktopScrollPane(
            children: [
              _SectionCard(
                title: 'Chat History',
                child: _history.isEmpty
                    ? const _EmptyHint('No history loaded yet.')
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopExplorePage(bool connected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DesktopScrollPane(
            children: [_buildChannelsCard(), _buildModelsCard()],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _DesktopScrollPane(
            children: [_buildToolsCard(), _buildNodesCard(connected)],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopEventsPage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _DesktopScrollPane(children: [_buildEventFeedCard()])),
        const SizedBox(width: 16),
        Expanded(
          child: _DesktopScrollPane(children: [_buildActivityLogCard()]),
        ),
      ],
    );
  }

  Widget _buildConnectionCard() {
    final connected = _connectionState.isConnected;
    return _SectionCard(
      title: 'Connection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Gateway URL',
              hintText: 'ws://127.0.0.1:18789 or wss://gateway-host:8443',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            decoration: const InputDecoration(labelText: 'Gateway Token'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sessionController,
            decoration: const InputDecoration(labelText: 'Session Key'),
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
                onPressed: _busy || _client == null ? null : _disconnect,
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
            SelectableText(
              _errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSnapshotCard() {
    final hello = _client?.hello;
    return _SectionCard(
      title: 'Gateway Snapshot',
      child: hello == null
          ? const _EmptyHint('Connect to inspect gateway metadata.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricChip('Protocol ${hello.protocol}'),
                    _MetricChip('Methods ${hello.features.methods.length}'),
                    _MetricChip('Events ${hello.features.events.length}'),
                    _MetricChip('Tick ${hello.policy.tickIntervalMs}ms'),
                    _MetricChip('Role ${hello.auth?.role ?? 'shared-token'}'),
                  ],
                ),
                const SizedBox(height: 12),
                _FactLine('Connection id', hello.server.connId),
                _FactLine('Canvas host', hello.canvasHostUrl ?? '-'),
                _FactLine('Buffered bytes', '${hello.policy.maxBufferedBytes}'),
                _FactLine('Max payload', '${hello.policy.maxPayload}'),
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Status snapshot',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _truncate(_pretty(_status!.raw), 900),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildHealthCard() {
    return _SectionCard(
      title: 'Health',
      child: _health == null
          ? const _EmptyHint('Connect and refresh to load gateway health.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricChip(_health!.ok ? 'Gateway OK' : 'Gateway not OK'),
                    _MetricChip('Channels ${_health!.channelOrder.length}'),
                    _MetricChip(
                      'Heartbeat ${_health!.heartbeatSeconds ?? '-'}s',
                    ),
                    _MetricChip(
                      'Default agent ${_health!.defaultAgentId ?? '-'}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final channelId in _health!.channelOrder)
                  _FactLine(
                    _health!.channelLabels[channelId] ?? channelId,
                    _truncate(_pretty(_health!.channels[channelId]), 160),
                  ),
              ],
            ),
    );
  }

  Widget _buildRuntimeCard() {
    return _SectionCard(
      title: 'Usage And Runtime',
      child: _usage == null && _voiceWake == null && _cronStatus == null
          ? const _EmptyHint(
              'No optional runtime details were loaded from this gateway.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_usage != null) ...[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _usage!.providers
                        .map(
                          (provider) => _MetricChip(
                            '${provider.displayName} ${provider.windows.isEmpty ? '' : provider.windows.first.usedPercent.toString()}%',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_voiceWake != null)
                  _FactLine(
                    'Voice wake triggers',
                    _voiceWake!.triggers.isEmpty
                        ? '-'
                        : _voiceWake!.triggers.join(', '),
                  ),
                if (_cronStatus != null)
                  _FactLine(
                    'Cron',
                    '${_cronStatus!.jobs} jobs • enabled=${_cronStatus!.enabled}',
                  ),
                if (_cronStatus?.nextWakeAtMs != null)
                  _FactLine(
                    'Next cron wake',
                    _formatUnixMs(_cronStatus!.nextWakeAtMs),
                  ),
                if (_usage != null)
                  for (final provider in _usage!.providers)
                    _FactLine(
                      provider.displayName,
                      provider.windows.isEmpty
                          ? (provider.error ?? provider.plan ?? 'No windows')
                          : provider.windows
                                .map(
                                  (window) =>
                                      '${window.label}: ${window.usedPercent}%',
                                )
                                .join(' • '),
                    ),
              ],
            ),
    );
  }

  Widget _buildChannelsCard() {
    return _SectionCard(
      title: 'Channels',
      child: _channelsStatus == null
          ? const _EmptyHint('Connect and refresh to load channel status.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _channelsStatus!.channelOrder
                  .map((channelId) {
                    final accounts =
                        _channelsStatus!.channelAccounts[channelId] ??
                        const <GatewayChannelAccountSnapshot>[];
                    final connectedCount = accounts
                        .where((account) => account.connected == true)
                        .length;
                    return _FactLine(
                      _channelsStatus!.channelLabels[channelId] ?? channelId,
                      '${accounts.length} accounts • $connectedCount connected',
                    );
                  })
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildModelsCard() {
    return _SectionCard(
      title: 'Models',
      child: _models == null
          ? const _EmptyHint('No model data loaded.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [_MetricChip('Total ${_models!.models.length}')],
                ),
                const SizedBox(height: 12),
                for (final model in _models!.models.take(8))
                  _FactLine(
                    model.name,
                    '${model.provider} • ${model.id}'
                    '${model.contextWindow == null ? '' : ' • ${model.contextWindow} ctx'}',
                  ),
              ],
            ),
    );
  }

  Widget _buildToolsCard() {
    return _SectionCard(
      title: 'Tools',
      child: _tools == null
          ? const _EmptyHint('No tool catalog loaded.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricChip('Agent ${_tools!.agentId}'),
                    _MetricChip('Groups ${_tools!.groups.length}'),
                    _MetricChip('Profiles ${_tools!.profiles.length}'),
                  ],
                ),
                const SizedBox(height: 12),
                for (final group in _tools!.groups.take(8))
                  _FactLine(group.label, '${group.tools.length} tools'),
              ],
            ),
    );
  }

  Widget _buildNodesCard(bool connected) {
    return _SectionCard(
      title: 'Nodes',
      child: _nodes.isEmpty
          ? _EmptyHint(
              connected
                  ? 'No nodes are paired or connected.'
                  : 'Connect first to inspect nodes.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _nodes
                  .map(
                    (node) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MiniPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              node.displayName ?? node.nodeId,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              [
                                node.nodeId,
                                node.platform ?? '-',
                                node.connected ? 'connected' : 'offline',
                              ].join(' • '),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'caps: ${node.caps.isEmpty ? '-' : node.caps.join(', ')}',
                            ),
                            Text(
                              'commands: ${node.commands.isEmpty ? '-' : _truncate(node.commands.join(', '), 140)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildEventFeedCard() {
    return _SectionCard(
      title: 'Live Event Feed',
      trailing: TextButton.icon(
        onPressed: _eventLines.isEmpty ? null : _clearEvents,
        icon: const Icon(Icons.clear_all),
        label: const Text('Clear'),
      ),
      child: _eventLines.isEmpty
          ? const _EmptyHint('No gateway events received yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _eventLines
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SelectableText(
                        '[${event.timeLabel}] ${event.name}: ${event.summary}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildActivityLogCard() {
    return _SectionCard(
      title: 'Activity Log',
      child: _logLines.isEmpty
          ? const _EmptyHint('No activity yet.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _logLines
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SelectableText(
                        line,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  Widget _buildOverviewTab(bool connected) {
    final hello = _client?.hello;
    return ListView(
      padding: const EdgeInsets.all(16),
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
                  hintText: 'ws://127.0.0.1:18789 or wss://gateway-host:8443',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: 'Gateway Token'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sessionController,
                decoration: const InputDecoration(labelText: 'Session Key'),
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
                    onPressed: _busy || _client == null ? null : _disconnect,
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
                SelectableText(
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
          title: 'Gateway Snapshot',
          child: hello == null
              ? const _EmptyHint('Connect to inspect gateway metadata.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricChip('Protocol ${hello.protocol}'),
                        _MetricChip('Methods ${hello.features.methods.length}'),
                        _MetricChip('Events ${hello.features.events.length}'),
                        _MetricChip('Tick ${hello.policy.tickIntervalMs}ms'),
                        _MetricChip(
                          'Role ${hello.auth?.role ?? 'shared-token'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FactLine('Connection id', hello.server.connId),
                    _FactLine('Canvas host', hello.canvasHostUrl ?? '-'),
                    _FactLine(
                      'Buffered bytes',
                      '${hello.policy.maxBufferedBytes}',
                    ),
                    _FactLine('Max payload', '${hello.policy.maxPayload}'),
                    if (_status != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Status snapshot',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _truncate(_pretty(_status!.raw), 900),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ],
                ),
        ),
        _SectionCard(
          title: 'Health',
          child: _health == null
              ? const _EmptyHint('Connect and refresh to load gateway health.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricChip(
                          _health!.ok ? 'Gateway OK' : 'Gateway not OK',
                        ),
                        _MetricChip('Channels ${_health!.channelOrder.length}'),
                        _MetricChip(
                          'Heartbeat ${_health!.heartbeatSeconds ?? '-'}s',
                        ),
                        _MetricChip(
                          'Default agent ${_health!.defaultAgentId ?? '-'}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final channelId in _health!.channelOrder)
                      _FactLine(
                        _health!.channelLabels[channelId] ?? channelId,
                        _truncate(_pretty(_health!.channels[channelId]), 160),
                      ),
                  ],
                ),
        ),
        _SectionCard(
          title: 'Usage And Runtime',
          child: _usage == null && _voiceWake == null && _cronStatus == null
              ? const _EmptyHint(
                  'No optional runtime details were loaded from this gateway.',
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_usage != null) ...[
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _usage!.providers
                            .map(
                              (provider) => _MetricChip(
                                '${provider.displayName} ${provider.windows.isEmpty ? '' : provider.windows.first.usedPercent.toString()}%',
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_voiceWake != null)
                      _FactLine(
                        'Voice wake triggers',
                        _voiceWake!.triggers.isEmpty
                            ? '-'
                            : _voiceWake!.triggers.join(', '),
                      ),
                    if (_cronStatus != null)
                      _FactLine(
                        'Cron',
                        '${_cronStatus!.jobs} jobs • enabled=${_cronStatus!.enabled}',
                      ),
                    if (_cronStatus?.nextWakeAtMs != null)
                      _FactLine(
                        'Next cron wake',
                        _formatUnixMs(_cronStatus!.nextWakeAtMs),
                      ),
                    if (_usage != null)
                      for (final provider in _usage!.providers)
                        _FactLine(
                          provider.displayName,
                          provider.windows.isEmpty
                              ? (provider.error ??
                                    provider.plan ??
                                    'No windows')
                              : provider.windows
                                    .map(
                                      (window) =>
                                          '${window.label}: ${window.usedPercent}%',
                                    )
                                    .join(' • '),
                        ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSessionsTab(bool connected) {
    final sessions = _sessionsList?.sessions ?? const <GatewaySessionRow>[];
    final previews =
        _sessionsPreview?.previews ?? const <GatewaySessionsPreviewEntry>[];
    final selectedKey = _sessionController.text.trim();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Chat Composer',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selected session: ${selectedKey.isEmpty ? '-' : selectedKey}',
              ),
              const SizedBox(height: 12),
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
          title: 'Sessions',
          child: sessions.isEmpty
              ? const _EmptyHint('No sessions loaded yet.')
              : Column(
                  children: sessions
                      .map(
                        (session) => ListTile(
                          dense: true,
                          selected: session.key == selectedKey,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            session.displayName ??
                                session.derivedTitle ??
                                session.label ??
                                session.key,
                          ),
                          subtitle: Text(
                            [
                              session.key,
                              if (session.channel != null) session.channel!,
                              if (session.lastMessagePreview != null)
                                _truncate(session.lastMessagePreview!, 90),
                            ].join(' • '),
                          ),
                          trailing: Text(_formatUnixMs(session.updatedAt)),
                          onTap: () => _selectSession(session.key),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        _SectionCard(
          title: 'Session Previews',
          child: previews.isEmpty
              ? const _EmptyHint('Refresh to load session previews.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: previews
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key} • ${entry.status}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  for (final item in entry.items)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text('${item.role}: ${item.text}'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        _SectionCard(
          title: 'Chat History',
          child: _history.isEmpty
              ? const _EmptyHint('No history loaded yet.')
              : Column(
                  children: _history
                      .map(
                        (entry) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${entry['role'] ?? 'unknown'}'),
                          subtitle: Text(_pretty(entry['content'] ?? entry)),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }

  Widget _buildExploreTab(bool connected) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Channels',
          child: _channelsStatus == null
              ? const _EmptyHint('Connect and refresh to load channel status.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _channelsStatus!.channelOrder
                      .map((channelId) {
                        final accounts =
                            _channelsStatus!.channelAccounts[channelId] ??
                            const <GatewayChannelAccountSnapshot>[];
                        final connectedCount = accounts
                            .where((account) => account.connected == true)
                            .length;
                        return _FactLine(
                          _channelsStatus!.channelLabels[channelId] ??
                              channelId,
                          '${accounts.length} accounts • $connectedCount connected',
                        );
                      })
                      .toList(growable: false),
                ),
        ),
        _SectionCard(
          title: 'Models',
          child: _models == null
              ? const _EmptyHint('No model data loaded.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricChip('Total ${_models!.models.length}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final model in _models!.models.take(8))
                      _FactLine(
                        model.name,
                        '${model.provider} • ${model.id}'
                        '${model.contextWindow == null ? '' : ' • ${model.contextWindow} ctx'}',
                      ),
                  ],
                ),
        ),
        _SectionCard(
          title: 'Tools',
          child: _tools == null
              ? const _EmptyHint('No tool catalog loaded.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricChip('Agent ${_tools!.agentId}'),
                        _MetricChip('Groups ${_tools!.groups.length}'),
                        _MetricChip('Profiles ${_tools!.profiles.length}'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final group in _tools!.groups.take(6))
                      _FactLine(group.label, '${group.tools.length} tools'),
                  ],
                ),
        ),
        _SectionCard(
          title: 'Nodes',
          child: _nodes.isEmpty
              ? const _EmptyHint('No nodes are paired or connected.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _nodes
                      .map(
                        (node) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    node.displayName ?? node.nodeId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                      node.nodeId,
                                      node.platform ?? '-',
                                      node.connected ? 'connected' : 'offline',
                                    ].join(' • '),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'caps: ${node.caps.isEmpty ? '-' : node.caps.join(', ')}',
                                  ),
                                  Text(
                                    'commands: ${node.commands.isEmpty ? '-' : _truncate(node.commands.join(', '), 140)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        if (!connected)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: _EmptyHint('Connect first to explore gateway data.'),
          ),
      ],
    );
  }

  Widget _buildEventsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: 'Live Event Feed',
          trailing: TextButton.icon(
            onPressed: _eventLines.isEmpty ? null : _clearEvents,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear'),
          ),
          child: _eventLines.isEmpty
              ? const _EmptyHint('No gateway events received yet.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _eventLines
                      .map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: SelectableText(
                            '[${event.timeLabel}] ${event.name}: ${event.summary}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        _SectionCard(
          title: 'Activity Log',
          child: _logLines.isEmpty
              ? const _EmptyHint('No activity yet.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _logLines
                      .map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SelectableText(
                            line,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class _EventLine {
  const _EventLine({
    required this.timeLabel,
    required this.name,
    required this.summary,
  });

  final String timeLabel;
  final String name;
  final String summary;
}

class _DesktopSectionItem {
  const _DesktopSectionItem({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String title;
  final String subtitle;
  final IconData icon;
}

const List<_DesktopSectionItem> _desktopSections = <_DesktopSectionItem>[
  _DesktopSectionItem(
    label: 'Overview',
    title: 'Gateway Overview',
    subtitle:
        'Connection details, health, runtime state, and gateway metadata.',
    icon: Icons.dashboard_outlined,
  ),
  _DesktopSectionItem(
    label: 'Sessions',
    title: 'Session Workspace',
    subtitle:
        'Browse active sessions, inspect previews, and drive chat traffic.',
    icon: Icons.chat_bubble_outline,
  ),
  _DesktopSectionItem(
    label: 'Explore',
    title: 'Capability Explorer',
    subtitle: 'Inspect channels, models, tools, and paired node surfaces.',
    icon: Icons.travel_explore_outlined,
  ),
  _DesktopSectionItem(
    label: 'Events',
    title: 'Event Monitor',
    subtitle: 'Watch live gateway events and the local operator activity log.',
    icon: Icons.graphic_eq_outlined,
  ),
];

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7DED8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                ...switch (trailing) {
                  final Widget trailing => [trailing],
                  null => const <Widget>[],
                },
              ],
            ),
            const SizedBox(height: 14),
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

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD5DCD6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label),
      ),
    );
  }
}

class _FactLine extends StatelessWidget {
  const _FactLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _DesktopScrollPane extends StatelessWidget {
  const _DesktopScrollPane({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      primary: false,
      children: children,
    );
  }
}

class _DesktopNavItem extends StatelessWidget {
  const _DesktopNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _DesktopSectionItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.transparent;
    final foreground = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.78);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarMetaLine extends StatelessWidget {
  const _SidebarMetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.68),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DED8)),
      ),
      child: child,
    );
  }
}
