import 'package:flutter_test/flutter_test.dart';
import 'package:sun_moon_switch/sun_moon_switch.dart';
import 'package:sun_moon_switch_example/main.dart';

void main() {
  testWidgets('the demo renders and toggles', (WidgetTester tester) async {
    await tester.pumpWidget(const SunMoonSwitchDemo());
    await tester.pump();

    expect(find.text('Day mode'), findsOneWidget);

    await tester.tap(find.byType(SunMoonSwitch).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Night mode'), findsOneWidget);
  });
}
