# Changelog

This project follows [semantic versioning](https://semver.org/).

## 1.0.0

First release.

- `SunMoonSwitch`, an animated day/night toggle drawn by a single `CustomPainter`.
  No image assets and no dependencies beyond Flutter.
- Idle motion: stars that rise one after another and twinkle, drifting clouds,
  slowly rotating sun rays, and a meteor once per cycle. Controlled with
  `animateAmbient` and `ambientDuration`.
- Interaction: tap, drag that tracks the finger one to one, velocity-aware
  snapping on release, a squash while pressed, and haptics on Android and iOS.
- Accessibility: toggled semantics with an enabled state and a tap action,
  keyboard focus with space and enter, and support for
  `MediaQueryData.disableAnimations`.
- Theming: `SunMoonSwitchColors` exposes all thirteen colors, with a `midnight`
  preset plus `copyWith` and `lerp`.
- Layout: `SunMoonSwitchSize` presets (`small`, `medium`, `large`), free `width`
  and `height`, custom `duration` and `curve`, and right-to-left support.
