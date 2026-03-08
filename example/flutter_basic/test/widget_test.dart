import 'package:flutter_test/flutter_test.dart';

import 'package:openclaw_gateway_flutter_basic/main.dart';

void main() {
  testWidgets('renders gateway example shell', (WidgetTester tester) async {
    await tester.pumpWidget(const GatewayExampleApp());

    expect(find.text('OpenClaw Gateway Example'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
  });
}
