import 'package:openclaw_gateway/src/discovery_models.dart';

/// Stub discovery implementation for platforms without `dart:io`.
class GatewayMdnsDiscoveryClient implements GatewayDiscoveryClient {
  @override
  Future<List<GatewayDiscoveredGateway>> discoverOnce({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  }) {
    throw UnsupportedError(
      'Gateway Bonjour discovery requires dart:io platforms.',
    );
  }

  @override
  Stream<List<GatewayDiscoveredGateway>> watch({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  }) {
    throw UnsupportedError(
      'Gateway Bonjour discovery requires dart:io platforms.',
    );
  }
}
