#!/usr/bin/env bash
# Stitches the frames written by `flutter test tool/record_media_test.dart`
# into the GIFs used by the README. Requires ffmpeg on PATH.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d .media/hero ]; then
  echo "No frames found. Run: flutter test tool/record_media_test.dart" >&2
  exit 1
fi

mkdir -p screenshots doc

# scene -> width fps colors output
stitch() {
  local scene=$1 width=$2 fps=$3 colors=$4 out=$5
  echo "→ $out"
  ffmpeg -v error -y -framerate 30 -i ".media/$scene/frame_%03d.png" \
    -vf "fps=$fps,scale=$width:-1:flags=lanczos,split[a][b];\
[a]palettegen=max_colors=$colors:stats_mode=diff[p];\
[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
    -loop 0 "$out"
}

stitch hero     520 30 192 screenshots/demo.gif
stitch drag     480 30 192 doc/drag.gif
stitch palettes 400 25 128 doc/palettes.gif
stitch sizes    400 25 128 doc/sizes.gif

# Static stills for the pub.dev gallery come from the example app:
#   cd example && flutter test tool/shoot_test.dart
