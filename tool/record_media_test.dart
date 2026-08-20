// Renders the README animations frame by frame.
//
// This is a development tool, not part of the published package. It is written
// as a widget test purely because that is the only headless environment where
// Flutter will rasterize a widget tree to PNG deterministically.
//
//   flutter test tool/record_media_test.dart
//   bash tool/build_media.sh            # stitches the frames into GIFs
//
// Frames land in `.media/<scene>/frame_XXX.png`.
@Timeout(Duration(minutes: 5))
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_moon_switch/sun_moon_switch.dart';

const double kPixelRatio = 2.0;
const Duration kFrame = Duration(milliseconds: 33); // ~30 fps

const SunMoonSwitchColors kSunset = SunMoonSwitchColors(
  daySkyTop: Color(0xFFFFC48C),
  daySkyBottom: Color(0xFFF2709C),
  nightSkyTop: Color(0xFF3A1C71),
  nightSkyBottom: Color(0xFF10061F),
  sunCore: Color(0xFFFFF6E5),
  sunEdge: Color(0xFFFF7B54),
  sunGlow: Color(0xFFFFB26B),
  moonGlow: Color(0xFFD3A4FF),
);

/// A still backdrop, used where only the switches should change between
/// frames. It keeps the resulting GIF small.
class _Still extends StatelessWidget {
  const _Still({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF20243A), Color(0xFF11131F)],
        ),
      ),
      child: Center(child: child),
    );
  }
}

/// A gradient backdrop that follows the switch state.
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const <Color>[Color(0xFF1B1B3F), Color(0xFF06060E)]
              : const <Color>[Color(0xFFEDF8FF), Color(0xFFBFE3F7)],
        ),
      ),
      child: Center(child: child),
    );
  }
}

void main() {
  final GlobalKey boundaryKey = GlobalKey();

  Future<void> shoot(WidgetTester tester, Directory dir, int index) async {
    await tester.runAsync(() async {
      final RenderRepaintBoundary boundary = boundaryKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: kPixelRatio);
      final ByteData? data =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('${dir.path}/frame_${index.toString().padLeft(3, '0')}.png')
          .writeAsBytesSync(data!.buffer.asUint8List());
    });
  }

  Future<Directory> prepare(
    WidgetTester tester,
    String name,
    Size size,
  ) async {
    tester.view
      ..devicePixelRatio = kPixelRatio
      ..physicalSize = size * kPixelRatio;
    addTearDown(tester.view.reset);

    final Directory dir = Directory('.media/$name');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    return dir;
  }

  /// Pumps [frames] frames, flipping [flag] at the frame indices in [toggles],
  /// capturing every frame to disk.
  Future<void> roll(
    WidgetTester tester,
    Directory dir,
    ValueNotifier<bool> flag, {
    required int frames,
    required Set<int> toggles,
  }) async {
    for (int i = 0; i < frames; i++) {
      if (toggles.contains(i)) flag.value = !flag.value;
      await tester.pump(kFrame);
      await shoot(tester, dir, i);
    }
  }

  Widget scene(ValueNotifier<bool> flag, Widget Function(bool) build) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(
        key: boundaryKey,
        child: ValueListenableBuilder<bool>(
          valueListenable: flag,
          builder: (BuildContext context, bool value, _) => build(value),
        ),
      ),
    );
  }

  testWidgets('hero', (WidgetTester tester) async {
    const Size size = Size(520, 200);
    final Directory dir = await prepare(tester, 'hero', size);
    final ValueNotifier<bool> flag = ValueNotifier<bool>(false);
    addTearDown(flag.dispose);

    await tester.pumpWidget(
      scene(
        flag,
        (bool value) => _Backdrop(
          isDark: value,
          child: SunMoonSwitch(
            value: value,
            onChanged: (bool v) => flag.value = v,
            width: 260,
            height: 108,
            thumbSize: SunMoonSwitchSize.large,
            ambientDuration: const Duration(milliseconds: 4000),
          ),
        ),
      ),
    );

    await roll(
      tester,
      dir,
      flag,
      frames: 120,
      toggles: <int>{12, 66},
    );
  });

  testWidgets('palettes', (WidgetTester tester) async {
    const Size size = Size(440, 320);
    final Directory dir = await prepare(tester, 'palettes', size);
    final ValueNotifier<bool> flag = ValueNotifier<bool>(false);
    addTearDown(flag.dispose);

    await tester.pumpWidget(
      scene(
        flag,
        (bool value) => _Still(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (final SunMoonSwitchColors palette in <SunMoonSwitchColors>[
                SunMoonSwitchColors.defaults,
                SunMoonSwitchColors.midnight,
                kSunset,
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SunMoonSwitch(
                    value: value,
                    onChanged: (bool v) => flag.value = v,
                    width: 170,
                    height: 72,
                    colors: palette,
                    ambientDuration: const Duration(milliseconds: 4000),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    await roll(
      tester,
      dir,
      flag,
      frames: 90,
      toggles: <int>{10, 50},
    );
  });

  testWidgets('sizes', (WidgetTester tester) async {
    const Size size = Size(440, 320);
    final Directory dir = await prepare(tester, 'sizes', size);
    final ValueNotifier<bool> flag = ValueNotifier<bool>(false);
    addTearDown(flag.dispose);

    await tester.pumpWidget(
      scene(
        flag,
        (bool value) => _Still(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (final SunMoonSwitchSize preset in SunMoonSwitchSize.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SunMoonSwitch(
                    value: value,
                    onChanged: (bool v) => flag.value = v,
                    width: 170,
                    height: 72,
                    thumbSize: preset,
                    ambientDuration: const Duration(milliseconds: 4000),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    await roll(
      tester,
      dir,
      flag,
      frames: 90,
      toggles: <int>{10, 50},
    );
  });

  testWidgets('drag', (WidgetTester tester) async {
    const Size size = Size(520, 200);
    final Directory dir = await prepare(tester, 'drag', size);
    final ValueNotifier<bool> flag = ValueNotifier<bool>(false);
    addTearDown(flag.dispose);

    await tester.pumpWidget(
      scene(
        flag,
        (bool value) => _Backdrop(
          isDark: value,
          child: SunMoonSwitch(
            value: value,
            onChanged: (bool v) => flag.value = v,
            width: 260,
            height: 108,
            thumbSize: SunMoonSwitchSize.large,
            ambientDuration: const Duration(milliseconds: 4000),
          ),
        ),
      ),
    );

    int frame = 0;
    Future<void> hold(int frames) async {
      for (int i = 0; i < frames; i++) {
        await tester.pump(kFrame);
        await shoot(tester, dir, frame++);
      }
    }

    await hold(8);

    // Press, then walk the orb across the track by hand.
    final Offset start =
        tester.getCenter(find.byType(SunMoonSwitch)) - const Offset(70, 0);
    final TestGesture gesture = await tester.startGesture(start);
    await hold(6);

    for (int i = 0; i < 22; i++) {
      await gesture.moveBy(const Offset(7, 0), timeStamp: kFrame * (i + 1));
      await tester.pump(kFrame);
      await shoot(tester, dir, frame++);
    }

    await gesture.up();
    await hold(30);
  });
}
