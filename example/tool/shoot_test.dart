// Renders the demo page to PNG for the README and the pub.dev gallery.
//
//   cd example && flutter test tool/shoot_test.dart
//
// It drives the real `DemoPage`, with Roboto loaded from the Flutter SDK so the
// text matches what a user sees in the running app.
@Timeout(Duration(minutes: 3))
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sun_moon_switch/sun_moon_switch.dart';
import 'package:sun_moon_switch_example/main.dart';

const double kPixelRatio = 2.0;
const Size kPage = Size(880, 1120);

/// Registers the real Roboto faces that ship with the Flutter SDK, so the
/// captured text is not the blank test font.
Future<void> _loadRoboto() async {
  final String? root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    fail('FLUTTER_ROOT is not set. Run this through `flutter test`.');
  }
  final String dir = '$root/bin/cache/artifacts/material_fonts';
  final FontLoader loader = FontLoader('Roboto');

  for (final String face in <String>[
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]) {
    final File file = File('$dir/$face');
    if (!file.existsSync()) continue;
    loader.addFont(
      Future<ByteData>.value(ByteData.sublistView(file.readAsBytesSync())),
    );
  }
  await loader.load();
}

void main() {
  final GlobalKey boundary = GlobalKey();

  testWidgets('demo screenshots', (WidgetTester tester) async {
    await _loadRoboto();

    tester.view
      ..devicePixelRatio = kPixelRatio
      ..physicalSize = kPage * kPixelRatio;
    addTearDown(tester.view.reset);

    final Directory out = Directory('../screenshots');
    out.createSync(recursive: true);

    Future<void> save(String name) async {
      await tester.runAsync(() async {
        final RenderRepaintBoundary object = boundary.currentContext!
            .findRenderObject()! as RenderRepaintBoundary;
        final ui.Image image = await object.toImage(pixelRatio: kPixelRatio);
        final ByteData? png =
            await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        File('${out.path}/$name.png')
            .writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // The demo app itself uses the platform default font; pin it here so
          // the capture uses the face we just registered.
          theme: ThemeData(fontFamily: 'Roboto'),
          home: const DemoPage(),
        ),
      ),
    );
    // Let the idle motion reach a flattering point in its cycle.
    await tester.pump(const Duration(milliseconds: 900));
    await save('demo_day');

    await tester.tap(find.byType(SunMoonSwitch).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 400));
    await save('demo_night');
  });
}
