import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'sun_moon_switch_colors.dart';

/// A star in the night sky, expressed in coordinates relative to the track.
@immutable
class _Star {
  const _Star(this.dx, this.dy, this.radius, this.phase, this.sparkle);

  /// Horizontal position as a fraction of the track width.
  final double dx;

  /// Vertical position as a fraction of the track height.
  final double dy;

  /// Radius as a fraction of the track height.
  final double radius;

  /// Offset into the twinkle cycle, so stars do not blink in unison.
  final double phase;

  /// Whether to draw a four-pointed sparkle instead of a plain dot.
  final bool sparkle;
}

/// A cloud in the daytime sky, expressed in coordinates relative to the track.
@immutable
class _Cloud {
  const _Cloud(this.dx, this.dy, this.width, this.phase);

  /// Horizontal center as a fraction of the track width.
  final double dx;

  /// Vertical center as a fraction of the track height.
  final double dy;

  /// Width as a fraction of the track width.
  final double width;

  /// Offset into the drift cycle.
  final double phase;
}

/// Hand-placed sky, so the composition reads well at any size.
const List<_Star> _stars = <_Star>[
  _Star(0.10, 0.26, 0.085, 0.00, true),
  _Star(0.21, 0.62, 0.050, 0.38, false),
  _Star(0.33, 0.18, 0.105, 0.72, true),
  _Star(0.30, 0.80, 0.042, 0.20, false),
  _Star(0.45, 0.48, 0.062, 0.55, true),
  _Star(0.15, 0.85, 0.038, 0.90, false),
  _Star(0.52, 0.22, 0.048, 0.12, false),
  _Star(0.58, 0.72, 0.055, 0.66, true),
];

const List<_Cloud> _clouds = <_Cloud>[
  _Cloud(0.45, 0.30, 0.21, 0.00),
  _Cloud(0.68, 0.66, 0.33, 0.45),
  _Cloud(0.84, 0.30, 0.17, 0.80),
];

/// Craters, in units of the orb radius, measured from the orb center.
const List<Offset> _craterCentres = <Offset>[
  Offset(-0.40, 0.08),
  Offset(0.14, -0.36),
  Offset(0.30, 0.32),
  Offset(-0.08, 0.50),
];

/// Crater radii, in units of the orb radius, parallel to [_craterCentres].
const List<double> _craterRadii = <double>[0.26, 0.19, 0.15, 0.11];

/// Paints a complete switch frame: sky, weather, glow and the sun/moon orb.
///
/// The painter is deliberately stateless: every frame is a pure function of
/// the animation values handed to it, which keeps [shouldRepaint] exact.
class SunMoonSwitchPainter extends CustomPainter {
  /// Creates the painter for one `SunMoonSwitch` frame.
  const SunMoonSwitchPainter({
    required this.progress,
    required this.thumbProgress,
    required this.ambient,
    required this.press,
    required this.thumbRatio,
    required this.colors,
    required this.animateAmbient,
    required this.textDirection,
  });

  /// Day (`0`) to night (`1`), clamped. Drives colors and opacities.
  final double progress;

  /// Day to night for the orb position; may overshoot for a springy feel.
  final double thumbProgress;

  /// A looping `0..1` value driving twinkles, drift, rays and shooting stars.
  final double ambient;

  /// How strongly the orb is currently pressed, `0..1`.
  final double press;

  /// Orb diameter as a fraction of the track height.
  final double thumbRatio;

  /// The palette to paint with.
  final SunMoonSwitchColors colors;

  /// Whether idle motion (twinkle, drift, rays, shooting stars) is enabled.
  final bool animateAmbient;

  /// Layout direction; in RTL the whole scene is mirrored.
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.height / 2),
      ),
    );

    if (textDirection == TextDirection.rtl) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    _paintSky(canvas, size);
    _paintStars(canvas, size);
    _paintShootingStar(canvas, size);
    _paintOrb(canvas, size);
    _paintClouds(canvas, size);
    _paintGloss(canvas, size);

    canvas.restore();
  }

  // Sky

  void _paintSky(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Color top =
        Color.lerp(colors.daySkyTop, colors.nightSkyTop, progress)!;
    final Color bottom =
        Color.lerp(colors.daySkyBottom, colors.nightSkyBottom, progress)!;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[top, bottom],
        ).createShader(rect),
    );
  }

  /// A soft highlight along the top edge plus a vignette at the bottom, which
  /// together make the track read as a physical, slightly inset capsule.
  void _paintGloss(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            const Color(0xFFFFFFFF).withValues(alpha: 0.10),
            const Color(0x00FFFFFF),
            const Color(0xFF000000).withValues(alpha: 0.12),
          ],
          stops: const <double>[0.0, 0.35, 1.0],
        ).createShader(rect),
    );
  }

  // Stars

  void _paintStars(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final Paint paint = Paint()..isAntiAlias = true;

    for (int i = 0; i < _stars.length; i++) {
      final _Star star = _stars[i];

      // Stagger, so the stars rise one after another instead of all at once.
      final double delay = i * 0.06;
      final double local = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final double eased = Curves.easeOutBack.transform(local);
      final double twinkle = animateAmbient
          ? 0.62 + 0.38 * math.sin(2 * math.pi * (ambient * 3 + star.phase))
          : 1.0;

      final double radius = star.radius * size.height * eased * twinkle;
      if (radius <= 0.05) continue;

      final Offset center = Offset(
        star.dx * size.width,
        star.dy * size.height + (1 - local) * size.height * 0.9,
      );

      paint.color = colors.star.withValues(
        alpha: (local * twinkle).clamp(0.0, 1.0),
      );

      if (star.sparkle) {
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(local * math.pi * 0.5);
        canvas.drawPath(_sparklePath(radius), paint);
        canvas.restore();
      } else {
        canvas.drawCircle(center, radius * 0.62, paint);
      }
    }
  }

  /// A four-pointed sparkle with concave sides, centred on the origin.
  Path _sparklePath(double radius) {
    final double waist = radius * 0.16;
    return Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(waist, -waist, radius, 0)
      ..quadraticBezierTo(waist, waist, 0, radius)
      ..quadraticBezierTo(-waist, waist, -radius, 0)
      ..quadraticBezierTo(-waist, -waist, 0, -radius)
      ..close();
  }

  /// A meteor that streaks across the night sky once per ambient cycle.
  void _paintShootingStar(Canvas canvas, Size size) {
    if (!animateAmbient || progress < 0.98) return;

    const double start = 0.30;
    const double end = 0.46;
    if (ambient < start || ambient > end) return;

    final double u = (ambient - start) / (end - start);
    final double fade = math.sin(math.pi * u);

    final Offset from = Offset(size.width * 0.68, -size.height * 0.15);
    final Offset to = Offset(size.width * 0.05, size.height * 0.75);
    final Offset head = Offset.lerp(from, to, Curves.easeIn.transform(u))!;
    final Offset tail = Offset.lerp(head, from, 0.42)!;

    canvas.drawLine(
      head,
      tail,
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.height * 0.035
        ..shader = LinearGradient(
          colors: <Color>[
            colors.star.withValues(alpha: 0.9 * fade),
            colors.star.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(head, tail)),
    );
    canvas.drawCircle(
      head,
      size.height * 0.028,
      Paint()..color = colors.star.withValues(alpha: fade),
    );
  }

  // Clouds

  void _paintClouds(Canvas canvas, Size size) {
    if (progress >= 0.999) return;

    final double day = 1 - progress;

    for (int i = 0; i < _clouds.length; i++) {
      final _Cloud cloud = _clouds[i];

      final double delay = i * 0.08;
      final double local = ((day - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;

      final double eased = Curves.easeOutBack.transform(local);
      final double drift = animateAmbient
          ? math.sin(2 * math.pi * (ambient + cloud.phase)) * size.width * 0.015
          : 0.0;

      final Offset center = Offset(
        cloud.dx * size.width + drift,
        cloud.dy * size.height - (1 - local) * size.height * 0.9,
      );
      final double width = cloud.width * size.width * eased;
      if (width <= 0.5) continue;

      canvas.drawPath(
        _cloudPath(center, width),
        Paint()
          ..isAntiAlias = true
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              colors.cloud.withValues(alpha: 0.96 * local),
              Color.lerp(colors.cloud, const Color(0xFFB9D9EF), 0.45)!
                  .withValues(alpha: 0.96 * local),
            ],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: width,
              height: width * 0.8,
            ),
          ),
      );
    }
  }

  /// A puffy cloud built as a single non-zero path, so overlapping lobes do
  /// not show through while the cloud is translucent.
  Path _cloudPath(Offset center, double width) {
    final double w = width;
    final double baseHeight = w * 0.30;
    return Path()
      ..fillType = PathFillType.nonZero
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center.dx - w / 2,
            center.dy - baseHeight / 2,
            w,
            baseHeight,
          ),
          Radius.circular(baseHeight / 2),
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(center.dx - w * 0.20, center.dy - w * 0.06),
          radius: w * 0.21,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(center.dx + w * 0.04, center.dy - w * 0.13),
          radius: w * 0.27,
        ),
      )
      ..addOval(
        Rect.fromCircle(
          center: Offset(center.dx + w * 0.28, center.dy - w * 0.04),
          radius: w * 0.19,
        ),
      );
  }

  // Sun and moon orb

  void _paintOrb(Canvas canvas, Size size) {
    final double diameter = size.height * thumbRatio;
    final double radius = diameter / 2;
    final double inset = (size.height - diameter) / 2;
    final double travel = math.max(0.0, size.width - diameter - inset * 2);

    // Curves may overshoot; keep the orb inside the track so it looks like it
    // presses against the edge instead of being clipped by it.
    final Offset center = Offset(
      (inset + radius + travel * thumbProgress)
          .clamp(radius, math.max(radius, size.width - radius)),
      size.height / 2,
    );

    final Color core = Color.lerp(colors.sunCore, colors.moonCore, progress)!;
    final Color edge = Color.lerp(colors.sunEdge, colors.moonEdge, progress)!;
    final Color glow = Color.lerp(colors.sunGlow, colors.moonGlow, progress)!;

    final double pulse =
        animateAmbient ? 1 + 0.045 * math.sin(2 * math.pi * ambient * 2) : 1.0;

    // Halo.
    final double haloRadius = radius * 2.1 * pulse;
    canvas.drawCircle(
      center,
      haloRadius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            glow.withValues(alpha: 0.45),
            glow.withValues(alpha: 0.16),
            glow.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.35, 0.62, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: haloRadius)),
    );

    _paintSunRays(canvas, center, radius, edge, pulse);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1 - 0.07 * press);

    // Body.
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..isAntiAlias = true
        ..shader = RadialGradient(
          center: const Alignment(-0.32, -0.38),
          radius: 0.95,
          colors: <Color>[core, edge],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );

    _paintCraters(canvas, radius);

    // Specular highlight on the upper-left rim.
    final Offset highlight = Offset(-radius * 0.30, -radius * 0.34);
    canvas.drawCircle(
      highlight,
      radius * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            const Color(0xFFFFFFFF).withValues(alpha: 0.55 - 0.25 * progress),
            const Color(0x00FFFFFF),
          ],
        ).createShader(
          Rect.fromCircle(center: highlight, radius: radius * 0.42),
        ),
    );

    canvas.restore();
  }

  void _paintSunRays(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double pulse,
  ) {
    final double strength = 1 - progress;
    if (strength <= 0.01) return;

    const int count = 12;
    final double spin = animateAmbient ? ambient * 2 * math.pi * 0.25 : 0.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(spin);

    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.55 * strength)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.13
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < count; i++) {
      final double inner = radius * 1.18 * pulse;
      final double outer = inner + radius * (i.isEven ? 0.34 : 0.20) * strength;
      canvas.save();
      canvas.rotate(i * 2 * math.pi / count);
      canvas.drawLine(Offset(inner, 0), Offset(outer, 0), paint);
      canvas.restore();
    }

    canvas.restore();
  }

  void _paintCraters(Canvas canvas, double radius) {
    if (progress <= 0.01) return;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
    // The crater field swings into place as the moon rotates in.
    canvas.rotate((1 - progress) * -math.pi * 0.45);

    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = colors.crater.withValues(alpha: progress);
    final Paint rim = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF000000).withValues(alpha: 0.06 * progress);

    for (int i = 0; i < _craterCentres.length; i++) {
      final Offset c = _craterCentres[i] * radius;
      final double r = _craterRadii[i] * radius * progress;
      rim.strokeWidth = math.max(0.5, r * 0.18);
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, rim);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SunMoonSwitchPainter old) {
    return old.progress != progress ||
        old.thumbProgress != thumbProgress ||
        old.ambient != ambient ||
        old.press != press ||
        old.thumbRatio != thumbRatio ||
        old.colors != colors ||
        old.animateAmbient != animateAmbient ||
        old.textDirection != textDirection;
  }

  @override
  bool shouldRebuildSemantics(SunMoonSwitchPainter oldDelegate) => false;
}
