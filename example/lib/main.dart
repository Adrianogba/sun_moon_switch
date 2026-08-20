import 'package:flutter/material.dart';
import 'package:sun_moon_switch/sun_moon_switch.dart';

void main() => runApp(const SunMoonSwitchDemo());

/// A sunset-flavoured palette, built by tweaking the defaults.
const SunMoonSwitchColors kSunsetColors = SunMoonSwitchColors(
  daySkyTop: Color(0xFFFFC48C),
  daySkyBottom: Color(0xFFF2709C),
  nightSkyTop: Color(0xFF3A1C71),
  nightSkyBottom: Color(0xFF10061F),
  sunCore: Color(0xFFFFF6E5),
  sunEdge: Color(0xFFFF7B54),
  sunGlow: Color(0xFFFFB26B),
  moonGlow: Color(0xFFD3A4FF),
);

/// Demo app for `SunMoonSwitch`.
class SunMoonSwitchDemo extends StatelessWidget {
  /// Creates the demo app.
  const SunMoonSwitchDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SunMoonSwitch',
      debugShowCheckedModeBanner: false,
      home: DemoPage(),
    );
  }
}

/// The single page of the demo.
class DemoPage extends StatefulWidget {
  /// Creates the demo page.
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _isDark = false;

  static const Duration _fade = Duration(milliseconds: 600);
  static const Curve _fadeCurve = Curves.easeInOut;

  void _set(bool value) => setState(() => _isDark = value);

  @override
  Widget build(BuildContext context) {
    final Color ink =
        _isDark ? const Color(0xFFEAF0FF) : const Color(0xFF12243A);
    final Color subtleInk = ink.withValues(alpha: 0.62);

    return Scaffold(
      body: AnimatedContainer(
        duration: _fade,
        curve: _fadeCurve,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isDark
                ? const <Color>[Color(0xFF1B1B3F), Color(0xFF07070F)]
                : const <Color>[Color(0xFFEAF6FF), Color(0xFFC8E6F7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Title(ink: ink, subtleInk: subtleInk),
                    const SizedBox(height: 36),

                    // The hero switch
                    Center(
                      child: SunMoonSwitch(
                        value: _isDark,
                        onChanged: _set,
                        width: 232,
                        height: 96,
                        thumbSize: SunMoonSwitchSize.large,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _fade,
                        curve: _fadeCurve,
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                  color: ink,
                                ),
                        child: Text(_isDark ? 'Night mode' : 'Day mode'),
                      ),
                    ),

                    const SizedBox(height: 36),
                    _Card(
                      isDark: _isDark,
                      ink: ink,
                      subtleInk: subtleInk,
                      title: 'Sizes',
                      child: Column(
                        children: <Widget>[
                          for (final SunMoonSwitchSize size
                              in SunMoonSwitchSize.values)
                            _Row(
                              label: size.name,
                              ink: subtleInk,
                              child: SunMoonSwitch(
                                value: _isDark,
                                onChanged: _set,
                                thumbSize: size,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _Card(
                      isDark: _isDark,
                      ink: ink,
                      subtleInk: subtleInk,
                      title: 'Palettes',
                      child: Column(
                        children: <Widget>[
                          _Row(
                            label: 'default',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: _set,
                            ),
                          ),
                          _Row(
                            label: 'midnight',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: _set,
                              colors: SunMoonSwitchColors.midnight,
                            ),
                          ),
                          _Row(
                            label: 'sunset',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: _set,
                              colors: kSunsetColors,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _Card(
                      isDark: _isDark,
                      ink: ink,
                      subtleInk: subtleInk,
                      title: 'States',
                      child: Column(
                        children: <Widget>[
                          _Row(
                            label: 'calm',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: _set,
                              animateAmbient: false,
                            ),
                          ),
                          _Row(
                            label: 'snappy',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: _set,
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          _Row(
                            label: 'disabled',
                            ink: subtleInk,
                            child: SunMoonSwitch(
                              value: _isDark,
                              onChanged: null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.ink, required this.subtleInk});

  final Color ink;
  final Color subtleInk;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedDefaultTextStyle(
          duration: _DemoPageState._fade,
          curve: _DemoPageState._fadeCurve,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: ink,
              ),
          child: const Text('SunMoonSwitch'),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: _DemoPageState._fade,
          curve: _DemoPageState._fadeCurve,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(height: 1.4, color: subtleInk),
          child: const Text(
            'Tap it, drag it, or focus it and press space.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.isDark,
    required this.ink,
    required this.subtleInk,
    required this.title,
    required this.child,
  });

  final bool isDark;
  final Color ink;
  final Color subtleInk;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _DemoPageState._fade,
      curve: _DemoPageState._fadeCurve,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.70),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedDefaultTextStyle(
            duration: _DemoPageState._fade,
            curve: _DemoPageState._fadeCurve,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: subtleInk,
                ),
            child: Text(title.toUpperCase()),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.ink, required this.child});

  final String label;
  final Color ink;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: _DemoPageState._fade,
              curve: _DemoPageState._fadeCurve,
              style:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(color: ink),
              child: Text(label),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
