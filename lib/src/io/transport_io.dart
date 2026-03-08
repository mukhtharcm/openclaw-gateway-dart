import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:openclaw_gateway/src/tls.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> openGatewayWebSocketChannel({
  required Uri uri,
  required Duration connectTimeout,
  GatewayTlsPolicy? tlsPolicy,
}) async {
  final resolvedTls = await resolveGatewayTlsPolicy(tlsPolicy);
  if (resolvedTls == null || uri.scheme.toLowerCase() != 'wss') {
    return IOWebSocketChannel.connect(
      uri,
      connectTimeout: connectTimeout,
    );
  }

  final customClient = HttpClient();
  customClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) {
    final fingerprint =
        normalizeGatewayTlsFingerprint(sha256.convert(cert.der).toString());
    final expected = resolvedTls.expectedFingerprint;
    if (expected != null) {
      return fingerprint == expected;
    }
    if (resolvedTls.allowTofu &&
        resolvedTls.stableId != null &&
        resolvedTls.fingerprintStore != null) {
      unawaited(
        resolvedTls.fingerprintStore!.writeFingerprint(
          GatewayStoredTlsFingerprint(
            stableId: resolvedTls.stableId!,
            fingerprint: fingerprint,
            observedAtMs: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
      );
      return true;
    }
    return false;
  };

  return IOWebSocketChannel.connect(
    uri,
    connectTimeout: connectTimeout,
    customClient: customClient,
  );
}
