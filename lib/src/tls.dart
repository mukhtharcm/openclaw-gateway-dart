import 'package:openclaw_gateway/src/protocol.dart';

/// A stored TLS fingerprint for a stable gateway identifier.
class GatewayStoredTlsFingerprint {
  const GatewayStoredTlsFingerprint({
    required this.stableId,
    required this.fingerprint,
    this.observedAtMs,
  });

  final String stableId;
  final String fingerprint;
  final int? observedAtMs;
}

/// Persistence interface for gateway TLS fingerprints.
abstract interface class GatewayTlsFingerprintStore {
  Future<GatewayStoredTlsFingerprint?> readFingerprint({
    required String stableId,
  });

  Future<void> writeFingerprint(GatewayStoredTlsFingerprint fingerprint);

  Future<void> deleteFingerprint({
    required String stableId,
  });
}

/// In-memory TLS fingerprint storage for tests or short-lived clients.
class GatewayMemoryTlsFingerprintStore implements GatewayTlsFingerprintStore {
  final Map<String, GatewayStoredTlsFingerprint> _values =
      <String, GatewayStoredTlsFingerprint>{};

  @override
  Future<void> deleteFingerprint({
    required String stableId,
  }) async {
    _values.remove(stableId);
  }

  @override
  Future<GatewayStoredTlsFingerprint?> readFingerprint({
    required String stableId,
  }) async {
    return _values[stableId];
  }

  @override
  Future<void> writeFingerprint(GatewayStoredTlsFingerprint fingerprint) async {
    _values[fingerprint.stableId] = fingerprint;
  }
}

/// TLS pinning / TOFU configuration for `wss://` gateway connections.
class GatewayTlsPolicy {
  const GatewayTlsPolicy({
    this.expectedFingerprint,
    this.allowTofu = false,
    this.stableId,
    this.fingerprintStore,
  });

  factory GatewayTlsPolicy.pinned(
    String fingerprint, {
    String? stableId,
    GatewayTlsFingerprintStore? fingerprintStore,
  }) {
    return GatewayTlsPolicy(
      expectedFingerprint: fingerprint,
      stableId: stableId,
      fingerprintStore: fingerprintStore,
    );
  }

  factory GatewayTlsPolicy.trustOnFirstUse({
    required String stableId,
    required GatewayTlsFingerprintStore fingerprintStore,
  }) {
    return GatewayTlsPolicy(
      allowTofu: true,
      stableId: stableId,
      fingerprintStore: fingerprintStore,
    );
  }

  final String? expectedFingerprint;
  final bool allowTofu;
  final String? stableId;
  final GatewayTlsFingerprintStore? fingerprintStore;
}

/// Runtime TLS pinning resolution used by the IO transport layer.
class GatewayResolvedTlsPolicy {
  const GatewayResolvedTlsPolicy({
    required this.expectedFingerprint,
    required this.allowTofu,
    required this.stableId,
    required this.fingerprintStore,
  });

  final String? expectedFingerprint;
  final bool allowTofu;
  final String? stableId;
  final GatewayTlsFingerprintStore? fingerprintStore;
}

Future<GatewayResolvedTlsPolicy?> resolveGatewayTlsPolicy(
  GatewayTlsPolicy? policy,
) async {
  if (policy == null) {
    return null;
  }

  final explicitFingerprint = policy.expectedFingerprint == null
      ? null
      : normalizeGatewayTlsFingerprint(policy.expectedFingerprint!);
  final stableId = policy.stableId;
  final store = policy.fingerprintStore;
  final storedFingerprint = stableId == null || store == null
      ? null
      : await store.readFingerprint(stableId: stableId);
  final expectedFingerprint =
      explicitFingerprint ?? storedFingerprint?.fingerprint;
  final allowTofu =
      policy.allowTofu && expectedFingerprint == null && stableId != null;

  if (expectedFingerprint == null && !allowTofu) {
    return null;
  }

  return GatewayResolvedTlsPolicy(
    expectedFingerprint: expectedFingerprint,
    allowTofu: allowTofu,
    stableId: stableId,
    fingerprintStore: store,
  );
}

String normalizeGatewayTlsFingerprint(String raw) {
  final stripped = raw.trim().replaceFirst(
        RegExp(r'^sha-?256\s*:?\s*', caseSensitive: false),
        '',
      );
  return stripped.toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');
}

JsonMap gatewayStoredTlsFingerprintToJson(
  GatewayStoredTlsFingerprint fingerprint,
) {
  return <String, Object?>{
    'stableId': fingerprint.stableId,
    'fingerprint': fingerprint.fingerprint,
    'observedAtMs': fingerprint.observedAtMs,
  };
}

GatewayStoredTlsFingerprint gatewayStoredTlsFingerprintFromJson(JsonMap json) {
  return GatewayStoredTlsFingerprint(
    stableId: readRequiredString(
      json,
      'stableId',
      context: 'GatewayStoredTlsFingerprint',
    ),
    fingerprint: readRequiredString(
      json,
      'fingerprint',
      context: 'GatewayStoredTlsFingerprint',
    ),
    observedAtMs: readNullableInt(json['observedAtMs']),
  );
}
