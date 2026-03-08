import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/tls.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<WebSocketChannel> openGatewayWebSocketChannel({
  required Uri uri,
  required Duration connectTimeout,
  GatewayTlsPolicy? tlsPolicy,
}) async {
  final resolvedTls = await resolveGatewayTlsPolicy(tlsPolicy);
  if (resolvedTls != null) {
    throw GatewayProtocolException(
      'Custom gateway TLS policies require dart:io platforms.',
    );
  }
  return WebSocketChannel.connect(uri);
}
