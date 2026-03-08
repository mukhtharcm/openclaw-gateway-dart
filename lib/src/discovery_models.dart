import 'dart:io';

import 'package:openclaw_gateway/src/tls.dart';

const String gatewayDiscoveryServiceType = '_openclaw-gw._tcp';
const String gatewayDiscoveryLocalServiceName = '_openclaw-gw._tcp.local';

/// Options for Bonjour/mDNS gateway discovery.
class GatewayDiscoveryOptions {
  const GatewayDiscoveryOptions({
    this.serviceName = gatewayDiscoveryLocalServiceName,
    this.timeout = const Duration(seconds: 2),
    this.pollInterval = const Duration(seconds: 5),
  });

  final String serviceName;
  final Duration timeout;
  final Duration pollInterval;

  String get normalizedServiceName => _normalizeGatewayDiscoveryServiceName(
        serviceName,
      );
}

/// Parsed TXT-record hints published by an OpenClaw gateway.
class GatewayDiscoveryHints {
  const GatewayDiscoveryHints({
    this.displayName,
    this.lanHost,
    this.tailnetDns,
    this.gatewayPort,
    this.sshPort,
    this.gatewayTls = false,
    this.gatewayTlsFingerprintSha256,
    this.canvasPort,
    this.cliPath,
    this.role,
    this.transport,
    this.raw = const <String, String>{},
  });

  factory GatewayDiscoveryHints.fromTxt(Map<String, String> raw) {
    return GatewayDiscoveryHints(
      displayName: _trimToNull(raw['displayName']),
      lanHost: _trimToNull(raw['lanHost']),
      tailnetDns: _trimToNull(raw['tailnetDns']),
      gatewayPort: _parseIntOrNull(raw['gatewayPort']),
      sshPort: _parseIntOrNull(raw['sshPort']),
      gatewayTls: raw['gatewayTls'] == '1' || raw['gatewayTls'] == 'true',
      gatewayTlsFingerprintSha256: _trimToNull(raw['gatewayTlsSha256']),
      canvasPort: _parseIntOrNull(raw['canvasPort']),
      cliPath: _trimToNull(raw['cliPath']),
      role: _trimToNull(raw['role']),
      transport: _trimToNull(raw['transport']),
      raw: Map.unmodifiable(raw),
    );
  }

  final String? displayName;
  final String? lanHost;
  final String? tailnetDns;
  final int? gatewayPort;
  final int? sshPort;
  final bool gatewayTls;
  final String? gatewayTlsFingerprintSha256;
  final int? canvasPort;
  final String? cliPath;
  final String? role;
  final String? transport;
  final Map<String, String> raw;
}

/// A resolved gateway endpoint discovered over Bonjour/mDNS.
class GatewayDiscoveredGateway {
  GatewayDiscoveredGateway({
    required this.instanceName,
    required this.targetHost,
    required this.port,
    Map<String, String>? txt,
    GatewayDiscoveryHints? hints,
    List<InternetAddress>? ipv4,
    List<InternetAddress>? ipv6,
  })  : txt = Map.unmodifiable(txt ?? const <String, String>{}),
        hints = hints ?? GatewayDiscoveryHints.fromTxt(txt ?? const {}),
        ipv4 = List.unmodifiable(ipv4 ?? const <InternetAddress>[]),
        ipv6 = List.unmodifiable(ipv6 ?? const <InternetAddress>[]);

  final String instanceName;
  final String targetHost;
  final int port;
  final Map<String, String> txt;
  final GatewayDiscoveryHints hints;
  final List<InternetAddress> ipv4;
  final List<InternetAddress> ipv6;

  String get displayName => hints.displayName ?? instanceName;

  bool get tlsEnabled => hints.gatewayTls;

  String get stableId {
    final preferred =
        hints.tailnetDns ?? hints.lanHost ?? _trimToNull(instanceName);
    if (preferred != null) {
      return preferred;
    }
    return '$targetHost:$port';
  }

  Iterable<Uri> candidateUris({String path = '/'}) sync* {
    final scheme = tlsEnabled ? 'wss' : 'ws';
    final seen = <String>{};
    final hosts = <String>[
      targetHost,
      ...ipv4.map((entry) => entry.address),
      ...ipv6.map((entry) => entry.address),
    ];

    for (final host in hosts) {
      if (!seen.add(host)) {
        continue;
      }
      yield Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: path.startsWith('/') ? path : '/$path',
      );
    }
  }

  Uri get primaryUri => candidateUris().first;

  /// Builds a TOFU/pinned TLS policy using this gateway's stable id.
  ///
  /// Discovery TXT is treated as a hint only. It is never persisted by the SDK
  /// unless the caller explicitly opts into TOFU storage.
  GatewayTlsPolicy buildTlsPolicy({
    GatewayTlsFingerprintStore? fingerprintStore,
    bool allowTofu = false,
  }) {
    return GatewayTlsPolicy(
      expectedFingerprint: hints.gatewayTlsFingerprintSha256,
      allowTofu: allowTofu,
      stableId: stableId,
      fingerprintStore: fingerprintStore,
    );
  }
}

/// Public discovery surface for locating gateways on the local network.
abstract interface class GatewayDiscoveryClient {
  Future<List<GatewayDiscoveredGateway>> discoverOnce({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  });

  Stream<List<GatewayDiscoveredGateway>> watch({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  });
}

String _normalizeGatewayDiscoveryServiceName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return gatewayDiscoveryLocalServiceName;
  }
  if (trimmed.endsWith('.local')) {
    return trimmed;
  }
  if (trimmed == gatewayDiscoveryServiceType) {
    return gatewayDiscoveryLocalServiceName;
  }
  return '$trimmed.local';
}

int? _parseIntOrNull(String? raw) {
  if (raw == null) {
    return null;
  }
  return int.tryParse(raw.trim());
}

String? _trimToNull(String? raw) {
  if (raw == null) {
    return null;
  }
  final trimmed = raw.trim();
  return trimmed.isEmpty ? null : trimmed;
}
