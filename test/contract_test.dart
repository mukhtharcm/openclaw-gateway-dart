import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

void main() {
  test('exports generated contract metadata', () {
    expect(gatewayProtocolVersion, gatewayContractProtocolVersion);
    expect(GatewayMethodNames.values, contains('browser.request'));
    expect(GatewayMethodNames.values, contains('system-event'));
    expect(GatewayEventNames.values, contains('node.invoke.request'));
    expect(GatewayClientIds.values, contains(GatewayClientIds.gatewayClient));
    expect(GatewayClientModes.values, contains(GatewayClientModes.backend));
    expect(GatewayClientCaps.values, contains(GatewayClientCaps.toolEvents));
  });
}
