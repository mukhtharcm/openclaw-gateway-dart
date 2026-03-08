/// Stub TLS probe implementation for platforms without `dart:io`.
abstract final class GatewayTlsProbe {
  static Future<String?> probeFingerprint(
    Uri uri, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    throw UnsupportedError(
      'Gateway TLS probing requires dart:io platforms.',
    );
  }
}
