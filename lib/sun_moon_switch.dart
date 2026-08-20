/// A beautifully animated day/night toggle switch for Flutter.
///
/// The package exposes a single widget, [SunMoonSwitch], that animates between
/// a glowing sun with drifting clouds and a cratered moon under twinkling
/// stars. Everything is drawn with a [CustomPainter], so it stays razor sharp
/// at any size and adds a single layer to the scene.
///
/// ## Quick start
///
/// ```dart
/// import 'package:sun_moon_switch/sun_moon_switch.dart';
///
/// SunMoonSwitch(
///   value: _isDark,
///   onChanged: (isDark) => setState(() => _isDark = isDark),
/// )
/// ```
///
/// Restyle it with [SunMoonSwitchColors] and size the orb with
/// [SunMoonSwitchSize].
library;

export 'src/sun_moon_switch.dart' show SunMoonSwitch, SunMoonSwitchSize;
export 'src/sun_moon_switch_colors.dart' show SunMoonSwitchColors;
export 'src/sun_moon_switch_painter.dart' show SunMoonSwitchPainter;
