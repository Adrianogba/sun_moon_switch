import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_moon_switch/sun_moon_switch.dart';

/// Pumps a fixed number of frames.
///
/// The idle-motion loop never ends, so `pumpAndSettle` would time out. The
/// same caveat applies to `LinearProgressIndicator` and friends.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Wraps [child] in a realistic app shell.
///
/// A real [WidgetsApp] is used so that the default keyboard shortcuts (space,
/// enter) reach the switch the same way they would in an app.
Widget _host(
  Widget child, {
  bool reduceMotion = false,
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Directionality(
      textDirection: direction,
      child: Builder(
        builder: (BuildContext context) {
          final Widget body = Material(child: Center(child: child));
          if (!reduceMotion) return body;
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: body,
          );
        },
      ),
    ),
  );
}

void main() {
  group('SunMoonSwitch layout', () {
    testWidgets('takes the requested size', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          SunMoonSwitch(
            value: false,
            onChanged: (_) {},
            width: 160,
            height: 70,
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(SunMoonSwitch)),
        const Size(160, 70),
      );
    });

    testWidgets('defaults to 110x48', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: (_) {})),
      );

      expect(
        tester.getSize(find.byType(SunMoonSwitch)),
        const Size(110, 48),
      );
    });

    testWidgets('renders in RTL without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          SunMoonSwitch(value: true, onChanged: (_) {}),
          direction: TextDirection.rtl,
        ),
      );
      await _settle(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('SunMoonSwitch interaction', () {
    testWidgets('tapping reports the opposite value', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: log.add)),
      );

      await tester.tap(find.byType(SunMoonSwitch));
      await _settle(tester);

      expect(log, <bool>[true]);
    });

    testWidgets('tapping a dark switch reports false', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: true, onChanged: log.add)),
      );

      await tester.tap(find.byType(SunMoonSwitch));
      await _settle(tester);

      expect(log, <bool>[false]);
    });

    testWidgets('does nothing when onChanged is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const SunMoonSwitch(value: false, onChanged: null)),
      );

      await tester.tap(find.byType(SunMoonSwitch));
      await _settle(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('dragging past the midpoint toggles', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: log.add)),
      );

      await tester.drag(find.byType(SunMoonSwitch), const Offset(70, 0));
      await _settle(tester);

      expect(log, <bool>[true]);
    });

    testWidgets('a small drag back does not toggle', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: log.add)),
      );

      // Past the touch slop (so it is a drag, not a tap) but short of the
      // midpoint.
      await tester.drag(find.byType(SunMoonSwitch), const Offset(24, 0));
      await _settle(tester);

      expect(log, isEmpty);
    });

    testWidgets('a fling toggles even before the midpoint', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: log.add)),
      );

      await tester.fling(
        find.byType(SunMoonSwitch),
        const Offset(12, 0),
        1200,
      );
      await _settle(tester);

      expect(log, <bool>[true]);
    });

    testWidgets('the space key activates a focused switch', (
      WidgetTester tester,
    ) async {
      final List<bool> log = <bool>[];
      await tester.pumpWidget(
        _host(
          SunMoonSwitch(value: false, onChanged: log.add, autofocus: true),
        ),
      );
      await _settle(tester);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await _settle(tester);

      expect(log, <bool>[true]);
    });
  });

  group('SunMoonSwitch animation', () {
    testWidgets('animates when the value changes', (
      WidgetTester tester,
    ) async {
      Widget build(bool value) =>
          _host(SunMoonSwitch(value: value, onChanged: (_) {}));

      await tester.pumpWidget(build(false));
      await tester.pumpWidget(build(true));

      // Mid-flight: still rebuilding every frame.
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue);

      await _settle(tester);
      expect(
        tester.hasRunningAnimations,
        isTrue,
        reason: 'idle motion keeps looping after the toggle settles',
      );
    });

    testWidgets('idle motion can be switched off', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SunMoonSwitch(
            value: false,
            onChanged: (_) {},
            animateAmbient: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion skips the transition and idle loop', (
      WidgetTester tester,
    ) async {
      Widget build(bool value) => _host(
            SunMoonSwitch(value: value, onChanged: (_) {}),
            reduceMotion: true,
          );

      await tester.pumpWidget(build(false));
      await tester.pumpWidget(build(true));
      await tester.pump();

      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('disposes cleanly mid-animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: false, onChanged: (_) {})),
      );
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: true, onChanged: (_) {})),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpWidget(_host(const SizedBox()));

      expect(tester.takeException(), isNull);
    });
  });

  group('SunMoonSwitch semantics', () {
    testWidgets('exposes a toggled state and a tap action', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(SunMoonSwitch(value: true, onChanged: (_) {})),
      );

      expect(
        tester.getSemantics(find.byType(SunMoonSwitch)),
        matchesSemantics(
          label: 'Dark mode',
          isToggled: true,
          hasToggledState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('honors a custom semantic label', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          SunMoonSwitch(
            value: false,
            onChanged: (_) {},
            semanticLabel: 'Night theme',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(SunMoonSwitch)).label,
        'Night theme',
      );

      handle.dispose();
    });
  });

  group('SunMoonSwitchColors', () {
    test('copyWith replaces only the given fields', () {
      const SunMoonSwitchColors base = SunMoonSwitchColors();
      final SunMoonSwitchColors updated = base.copyWith(
        star: const Color(0xFFFF0000),
      );

      expect(updated.star, const Color(0xFFFF0000));
      expect(updated.daySkyTop, base.daySkyTop);
      expect(updated, isNot(base));
    });

    test('value equality and hashCode agree', () {
      expect(const SunMoonSwitchColors(), SunMoonSwitchColors.defaults);
      expect(
        const SunMoonSwitchColors().hashCode,
        SunMoonSwitchColors.defaults.hashCode,
      );
      expect(SunMoonSwitchColors.midnight, isNot(SunMoonSwitchColors.defaults));
    });

    test('lerp follows the Flutter contract', () {
      const SunMoonSwitchColors a = SunMoonSwitchColors();
      const SunMoonSwitchColors b = SunMoonSwitchColors.midnight;

      expect(SunMoonSwitchColors.lerp(null, null, 0.5), isNull);
      expect(SunMoonSwitchColors.lerp(a, null, 0.5), a);
      expect(SunMoonSwitchColors.lerp(null, b, 0.5), b);
      expect(SunMoonSwitchColors.lerp(a, b, 0), a);
      expect(SunMoonSwitchColors.lerp(a, b, 1), b);
      expect(
        SunMoonSwitchColors.lerp(a, b, 0.5)!.nightSkyTop,
        Color.lerp(a.nightSkyTop, b.nightSkyTop, 0.5),
      );
    });
  });

  group('SunMoonSwitchPainter', () {
    SunMoonSwitchPainter painter({double progress = 0, double ambient = 0}) {
      return SunMoonSwitchPainter(
        progress: progress,
        thumbProgress: progress,
        ambient: ambient,
        press: 0,
        thumbRatio: SunMoonSwitchSize.medium.ratio,
        colors: SunMoonSwitchColors.defaults,
        animateAmbient: true,
        textDirection: TextDirection.ltr,
      );
    }

    test('repaints only when something changed', () {
      expect(painter().shouldRepaint(painter()), isFalse);
      expect(painter().shouldRepaint(painter(progress: 0.5)), isTrue);
      expect(painter().shouldRepaint(painter(ambient: 0.5)), isTrue);
    });
  });

  group('SunMoonSwitchSize', () {
    test('ratios are ordered and within the track', () {
      expect(SunMoonSwitchSize.small.ratio, lessThan(1));
      expect(
        SunMoonSwitchSize.small.ratio,
        lessThan(SunMoonSwitchSize.medium.ratio),
      );
      expect(
        SunMoonSwitchSize.medium.ratio,
        lessThan(SunMoonSwitchSize.large.ratio),
      );
      expect(SunMoonSwitchSize.large.ratio, lessThan(1));
    });
  });
}
