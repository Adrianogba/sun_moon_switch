import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sun_moon_switch_colors.dart';
import 'sun_moon_switch_painter.dart';

/// Predefined size presets for the sun/moon orb inside a [SunMoonSwitch].
///
/// Each preset maps to a **fraction** of the switch height, so the orb always
/// fits proportionally within the track regardless of the overall dimensions.
///
/// | Preset   | Orb ratio | Description                               |
/// |----------|-----------|-------------------------------------------|
/// | `small`  | 55 %      | Compact orb with more visible sky         |
/// | `medium` | 70 %      | Balanced default                          |
/// | `large`  | 85 %      | Prominent orb filling most of the track   |
enum SunMoonSwitchSize {
  /// A compact sun/moon, **55 %** of the switch height.
  ///
  /// Leaves more room for the sky, stars and clouds to be visible.
  small(0.55),

  /// The default sun/moon, **70 %** of the switch height.
  medium(0.70),

  /// A prominent sun/moon, **85 %** of the switch height.
  ///
  /// The orb dominates the track, giving a bolder look.
  large(0.85);

  const SunMoonSwitchSize(this.ratio);

  /// Fraction of the switch height used for the orb diameter.
  final double ratio;
}

/// A beautifully animated day/night toggle switch.
///
/// [SunMoonSwitch] transitions between a **sun** (light mode) and a **moon**
/// (dark mode). Everything is drawn by a single [CustomPainter], so it stays
/// crisp at any size and costs one layer to composite.
///
/// The animation includes:
///
/// - A glowing sun with slowly rotating rays that morphs into a cratered moon
/// - Stars that rise one after another and twinkle, plus the occasional meteor
/// - Clouds that drift and slide away when night falls
/// - Drag-to-toggle with velocity-aware snapping, and a squash while pressed
/// - Keyboard and screen reader support
///
/// ## Usage
///
/// ```dart
/// SunMoonSwitch(
///   value: _isDark,
///   onChanged: (isDark) => setState(() => _isDark = isDark),
/// )
/// ```
///
/// Like [Switch], this is a *controlled* widget: it does not keep its own
/// state. Pass a new [value] from the parent to make the switch move.
///
/// Setting [onChanged] to `null` disables the switch.
///
/// See also:
///
///  * [SunMoonSwitchColors], to restyle every color of the widget.
///  * [SunMoonSwitchSize], for the orb size presets.
class SunMoonSwitch extends StatefulWidget {
  /// Creates a [SunMoonSwitch].
  const SunMoonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.thumbSize = SunMoonSwitchSize.medium,
    this.width = 110.0,
    this.height = 48.0,
    this.duration = const Duration(milliseconds: 600),
    this.curve = SunMoonSwitch.defaultCurve,
    this.colors = SunMoonSwitchColors.defaults,
    this.animateAmbient = true,
    this.ambientDuration = const Duration(seconds: 8),
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  })  : assert(width > 0, 'width must be greater than zero'),
        assert(height > 0, 'height must be greater than zero'),
        assert(width >= height, 'width must be at least as large as height');

  /// The default toggle [curve]: an ease-in-out with a gentle overshoot that
  /// makes the orb settle with a springy nudge.
  static const Curve defaultCurve = Cubic(0.68, -0.30, 0.27, 1.28);

  /// Whether the switch is in dark mode.
  ///
  /// When `true` the moon and stars are shown, otherwise the sun and clouds.
  final bool value;

  /// Called when the user toggles the switch.
  ///
  /// The callback receives the new value: `true` for dark, `false` for light.
  /// If null, the switch is displayed as disabled and does not respond to
  /// input.
  final ValueChanged<bool>? onChanged;

  /// The preset controlling the **sun/moon orb** diameter.
  ///
  /// Defaults to [SunMoonSwitchSize.medium].
  final SunMoonSwitchSize thumbSize;

  /// The overall width of the switch. Defaults to `110.0`.
  final double width;

  /// The overall height of the switch. Defaults to `48.0`.
  final double height;

  /// The duration of the toggle animation. Defaults to `600ms`.
  final Duration duration;

  /// The curve of the toggle animation. Defaults to [defaultCurve].
  ///
  /// Curves that overshoot `[0, 1]` are supported: the orb is kept inside the
  /// track, so it appears to press against the edge and bounce back.
  final Curve curve;

  /// The palette used to paint the switch.
  ///
  /// Defaults to [SunMoonSwitchColors.defaults].
  final SunMoonSwitchColors colors;

  /// Whether idle motion is enabled: twinkling stars, drifting clouds,
  /// rotating sun rays and the occasional shooting star. Defaults to `true`.
  ///
  /// Idle motion is automatically suppressed when the platform requests
  /// reduced motion via [MediaQueryData.disableAnimations].
  final bool animateAmbient;

  /// How long one full idle-motion cycle takes. Defaults to 8 seconds.
  final Duration ambientDuration;

  /// Whether to emit platform haptic feedback when toggled. Defaults to `true`.
  final bool enableFeedback;

  /// An optional focus node to control keyboard focus for this switch.
  final FocusNode? focusNode;

  /// Whether the switch should request focus when first shown.
  final bool autofocus;

  /// The semantic label announced by screen readers.
  ///
  /// Defaults to "Dark mode". The switch already announces its on/off state,
  /// so the label should describe *what* is toggled, not its current value.
  final String? semanticLabel;

  /// Whether the switch is interactive, i.e. [onChanged] is non-null.
  bool get enabled => onChanged != null;

  @override
  State<SunMoonSwitch> createState() => _SunMoonSwitchState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        FlagProperty(
          'value',
          value: value,
          ifTrue: 'dark',
          ifFalse: 'light',
          showName: true,
        ),
      )
      ..add(
        FlagProperty(
          'enabled',
          value: enabled,
          ifFalse: 'disabled',
          showName: false,
        ),
      )
      ..add(
        EnumProperty<SunMoonSwitchSize>(
          'thumbSize',
          thumbSize,
          defaultValue: SunMoonSwitchSize.medium,
        ),
      )
      ..add(DoubleProperty('width', width, defaultValue: 110.0))
      ..add(DoubleProperty('height', height, defaultValue: 48.0))
      ..add(
        DiagnosticsProperty<Duration>(
          'duration',
          duration,
          defaultValue: const Duration(milliseconds: 600),
        ),
      );
  }
}

class _SunMoonSwitchState extends State<SunMoonSwitch>
    with TickerProviderStateMixin {
  /// Drives the day↔night transition.
  late final AnimationController _toggleController;

  /// The curved view of [_toggleController]; flattened to linear while
  /// dragging so the orb tracks the finger exactly.
  late final CurvedAnimation _position;

  /// Drives the squash applied while the switch is held down.
  late final AnimationController _pressController;

  /// Drives all idle motion. Loops forever while mounted and visible.
  late final AnimationController _ambientController;

  bool _dragging = false;
  bool _reduceMotion = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _toggleController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.value ? 1.0 : 0.0,
    );
    _position = CurvedAnimation(parent: _toggleController, curve: widget.curve);

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: widget.ambientDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce && reduce != _reduceMotion) {
      // Reduce-motion switched on mid-flight: land immediately.
      _toggleController.value = widget.value ? 1.0 : 0.0;
    }
    _reduceMotion = reduce;
    _syncAmbient();
  }

  @override
  void didUpdateWidget(SunMoonSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.duration != oldWidget.duration) {
      _toggleController.duration = widget.duration;
    }
    if (widget.curve != oldWidget.curve && !_dragging) {
      _position.curve = widget.curve;
    }
    if (widget.ambientDuration != oldWidget.ambientDuration) {
      _ambientController.duration = widget.ambientDuration;
      if (_ambientController.isAnimating) {
        _ambientController.repeat();
      }
    }
    if (widget.animateAmbient != oldWidget.animateAmbient) {
      _syncAmbient();
    }
    if (widget.value != oldWidget.value) {
      _animateToValue();
    }
  }

  @override
  void dispose() {
    _position.dispose();
    _toggleController.dispose();
    _pressController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  // Animation plumbing

  bool get _ambientEnabled => widget.animateAmbient && !_reduceMotion;

  void _syncAmbient() {
    if (_ambientEnabled) {
      if (!_ambientController.isAnimating) _ambientController.repeat();
    } else if (_ambientController.isAnimating) {
      _ambientController.stop();
      _ambientController.value = 0;
    }
  }

  void _animateToValue() {
    if (_reduceMotion) {
      _toggleController.value = widget.value ? 1.0 : 0.0;
      return;
    }
    if (widget.value) {
      _toggleController.forward();
    } else {
      _toggleController.reverse();
    }
  }

  // Interaction

  void _emitFeedback() {
    if (!widget.enableFeedback) return;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        HapticFeedback.selectionClick();
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        break;
    }
  }

  void _setValue(bool value) {
    if (value == widget.value || !widget.enabled) {
      // Nothing to report upwards, but the orb may have been dragged away
      // from its resting position. That happens if the switch was disabled
      // part-way through a drag.
      _animateToValue();
      return;
    }
    _emitFeedback();
    widget.onChanged!(value);
  }

  void _handleTap() {
    if (!widget.enabled) return;
    _setValue(!widget.value);
  }

  void _handleTapDown(TapDownDetails _) => _press(true);
  void _handleTapUp(TapUpDetails _) => _press(false);
  void _handleTapCancel() => _press(false);

  void _press(bool down) {
    if (!widget.enabled) return;
    if (down) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }

  void _handleDragStart(DragStartDetails _) {
    if (!widget.enabled) return;
    _dragging = true;
    // Track the finger 1:1. An eased curve would lag behind it.
    _position.curve = Curves.linear;
    _pressController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || !_dragging) return;
    final double travel = _travel;
    if (travel <= 0) return;
    final double delta = details.primaryDelta! / travel;
    _toggleController.value +=
        Directionality.of(context) == TextDirection.rtl ? -delta : delta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_dragging) return;
    _dragging = false;
    _position.curve = widget.curve;
    _pressController.reverse();

    // Respect a deliberate fling even if the orb has not crossed the midpoint.
    final double velocity = Directionality.of(context) == TextDirection.rtl
        ? -details.primaryVelocity!
        : details.primaryVelocity!;
    const double flingThreshold = 200.0;

    final bool target = velocity.abs() > flingThreshold
        ? velocity > 0
        : _toggleController.value >= 0.5;

    _setValue(target);
  }

  double get _travel {
    final double diameter = widget.height * widget.thumbSize.ratio;
    final double inset = (widget.height - diameter) / 2;
    return widget.width - diameter - inset * 2;
  }

  // Build

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection direction = Directionality.of(context);
    final bool enabled = widget.enabled;

    return Semantics(
      container: true,
      enabled: enabled,
      toggled: widget.value,
      label: widget.semanticLabel ?? 'Dark mode',
      onTap: enabled ? _handleTap : null,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor:
            enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (bool value) {
          if (value != _focused) setState(() => _focused = value);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: _handleTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: AnimatedBuilder(
              animation: Listenable.merge(<Listenable>[
                _position,
                _pressController,
                _ambientController,
              ]),
              builder: (BuildContext context, Widget? child) {
                final double raw = _position.value;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      if (_focused)
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.65),
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(widget.width, widget.height),
                      isComplex: true,
                      painter: SunMoonSwitchPainter(
                        progress: raw.clamp(0.0, 1.0),
                        thumbProgress: raw,
                        ambient: _ambientController.value,
                        press: _pressController.value,
                        thumbRatio: widget.thumbSize.ratio,
                        colors: widget.colors,
                        animateAmbient: _ambientEnabled,
                        textDirection: direction,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
