import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'package:openclaw_gateway/src/tls.dart';

/// TLS certificate probing utilities for `dart:io` platforms.
abstract final class GatewayTlsProbe {
  static Future<String?> probeFingerprint(
    Uri uri, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'wss' && scheme != 'https') {
      return null;
    }
    final host = uri.host.trim();
    if (host.isEmpty) {
      return null;
    }
    final port = uri.hasPort ? uri.port : (scheme == 'wss' ? 443 : 443);

    SecureSocket? socket;
    try {
      socket = await SecureSocket.connect(
        host,
        port,
        timeout: timeout,
        onBadCertificate: (_) => true,
      );
      final certificate = socket.peerCertificate;
      if (certificate == null) {
        return null;
      }
      return normalizeGatewayTlsFingerprint(
        sha256.convert(certificate.der).toString(),
      );
    } catch (_) {
      return null;
    } finally {
      socket?.destroy();
    }
  }
}
