import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// The palette used to paint a `SunMoonSwitch`.
///
/// Every color the widget draws is exposed here, so the switch can be matched
/// to any brand or theme: sky, orb, glow, craters, stars and clouds. Every
/// parameter has a default, so overriding one color is as cheap as:
///
/// ```dart
/// const SunMoonSwitchColors(
///   nightSkyTop: Color(0xFF2B1055),
///   nightSkyBottom: Color(0xFF120524),
/// )
/// ```
///
/// Use [copyWith] to derive a palette from another one, and [lerp] to animate
/// between two palettes.
@immutable
class SunMoonSwitchColors {
  /// Creates a palette for a `SunMoonSwitch`.
  const SunMoonSwitchColors({
    this.daySkyTop = const Color(0xFF7FD8F2),
    this.daySkyBottom = const Color(0xFF3AA6D6),
    this.nightSkyTop = const Color(0xFF2A2A5C),
    this.nightSkyBottom = const Color(0xFF0E0E23),
    this.sunCore = const Color(0xFFFFF3B0),
    this.sunEdge = const Color(0xFFFFB300),
    this.sunGlow = const Color(0xFFFFD54F),
    this.moonCore = const Color(0xFFFFFFFF),
    this.moonEdge = const Color(0xFFD6DCEA),
    this.moonGlow = const Color(0xFFE8EEFF),
    this.crater = const Color(0xFFCBD3E4),
    this.star = const Color(0xFFFFFFFF),
    this.cloud = const Color(0xFFFFFFFF),
  });

  /// Color at the top of the daytime sky gradient.
  final Color daySkyTop;

  /// Color at the bottom of the daytime sky gradient.
  final Color daySkyBottom;

  /// Color at the top of the night sky gradient.
  final Color nightSkyTop;

  /// Color at the bottom of the night sky gradient.
  final Color nightSkyBottom;

  /// Center color of the sun.
  final Color sunCore;

  /// Rim color of the sun, also used for its rays.
  final Color sunEdge;

  /// Color of the halo radiating from the sun.
  final Color sunGlow;

  /// Center color of the moon.
  final Color moonCore;

  /// Rim color of the moon.
  final Color moonEdge;

  /// Color of the halo radiating from the moon.
  final Color moonGlow;

  /// Color of the moon craters.
  final Color crater;

  /// Color of the stars (and of the shooting star's trail).
  final Color star;

  /// Color of the clouds.
  final Color cloud;

  /// The default daylight-to-midnight palette.
  static const SunMoonSwitchColors defaults = SunMoonSwitchColors();

  /// A cooler, deeper-contrast variant with a violet night sky.
  static const SunMoonSwitchColors midnight = SunMoonSwitchColors(
    daySkyTop: Color(0xFF9BE7FF),
    daySkyBottom: Color(0xFF2F8FD6),
    nightSkyTop: Color(0xFF35176B),
    nightSkyBottom: Color(0xFF0B0420),
    sunGlow: Color(0xFFFFC078),
    moonGlow: Color(0xFFC5B8FF),
  );

  /// Returns a copy of this palette with the given fields replaced.
  SunMoonSwitchColors copyWith({
    Color? daySkyTop,
    Color? daySkyBottom,
    Color? nightSkyTop,
    Color? nightSkyBottom,
    Color? sunCore,
    Color? sunEdge,
    Color? sunGlow,
    Color? moonCore,
    Color? moonEdge,
    Color? moonGlow,
    Color? crater,
    Color? star,
    Color? cloud,
  }) {
    return SunMoonSwitchColors(
      daySkyTop: daySkyTop ?? this.daySkyTop,
      daySkyBottom: daySkyBottom ?? this.daySkyBottom,
      nightSkyTop: nightSkyTop ?? this.nightSkyTop,
      nightSkyBottom: nightSkyBottom ?? this.nightSkyBottom,
      sunCore: sunCore ?? this.sunCore,
      sunEdge: sunEdge ?? this.sunEdge,
      sunGlow: sunGlow ?? this.sunGlow,
      moonCore: moonCore ?? this.moonCore,
      moonEdge: moonEdge ?? this.moonEdge,
      moonGlow: moonGlow ?? this.moonGlow,
      crater: crater ?? this.crater,
      star: star ?? this.star,
      cloud: cloud ?? this.cloud,
    );
  }

  /// Linearly interpolates between two palettes.
  ///
  /// Follows the usual Flutter `lerp` contract: [a] and [b] may be null, and
  /// the result is null only when both are.
  static SunMoonSwitchColors? lerp(
    SunMoonSwitchColors? a,
    SunMoonSwitchColors? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (a == null) return b;
    if (b == null) return a;
    return SunMoonSwitchColors(
      daySkyTop: Color.lerp(a.daySkyTop, b.daySkyTop, t)!,
      daySkyBottom: Color.lerp(a.daySkyBottom, b.daySkyBottom, t)!,
      nightSkyTop: Color.lerp(a.nightSkyTop, b.nightSkyTop, t)!,
      nightSkyBottom: Color.lerp(a.nightSkyBottom, b.nightSkyBottom, t)!,
      sunCore: Color.lerp(a.sunCore, b.sunCore, t)!,
      sunEdge: Color.lerp(a.sunEdge, b.sunEdge, t)!,
      sunGlow: Color.lerp(a.sunGlow, b.sunGlow, t)!,
      moonCore: Color.lerp(a.moonCore, b.moonCore, t)!,
      moonEdge: Color.lerp(a.moonEdge, b.moonEdge, t)!,
      moonGlow: Color.lerp(a.moonGlow, b.moonGlow, t)!,
      crater: Color.lerp(a.crater, b.crater, t)!,
      star: Color.lerp(a.star, b.star, t)!,
      cloud: Color.lerp(a.cloud, b.cloud, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SunMoonSwitchColors &&
        other.daySkyTop == daySkyTop &&
        other.daySkyBottom == daySkyBottom &&
        other.nightSkyTop == nightSkyTop &&
        other.nightSkyBottom == nightSkyBottom &&
        other.sunCore == sunCore &&
        other.sunEdge == sunEdge &&
        other.sunGlow == sunGlow &&
        other.moonCore == moonCore &&
        other.moonEdge == moonEdge &&
        other.moonGlow == moonGlow &&
        other.crater == crater &&
        other.star == star &&
        other.cloud == cloud;
  }

  @override
  int get hashCode => Object.hash(
        daySkyTop,
        daySkyBottom,
        nightSkyTop,
        nightSkyBottom,
        sunCore,
        sunEdge,
        sunGlow,
        moonCore,
        moonEdge,
        moonGlow,
        crater,
        star,
        cloud,
      );

  @override
  String toString() => 'SunMoonSwitchColors('
      'daySkyTop: $daySkyTop, daySkyBottom: $daySkyBottom, '
      'nightSkyTop: $nightSkyTop, nightSkyBottom: $nightSkyBottom)';
}
