import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:openclaw_gateway_flutter_basic/main.dart';

void main() {
  testWidgets('renders gateway example shell', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GatewayExampleApp());

    expect(find.text('Gateway Desk'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Gateway Overview'), findsOneWidget);
  });
}
