#!/usr/bin/env bash
# Encodes the rendered ProRes 4444 masters (renders/*.mov, transparent) into delivery formats.
#   webm/  VP9 with alpha, keyframe every 6 frames so segment jumps are instant (browser preview, Android)
#   hevc/  HEVC with alpha for iOS. Needs macOS: Apple's VideoToolbox encoder is the only one that writes
#          the alpha layer AVFoundation expects. Run this script on the Mac to produce them.
# Usage: bash tools/encode.sh            (from design/coach-clips)
set -euo pipefail
mkdir -p webm hevc
for src in renders/*.mov; do
  name=$(basename "$src" .mov)
  ffmpeg -y -loglevel error -i "$src" -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 30 -g 6 -auto-alt-ref 0 -row-mt 1 "webm/$name.webm"
  if [[ "$(uname)" == "Darwin" ]]; then
    ffmpeg -y -loglevel error -i "$src" -c:v hevc_videotoolbox -alpha_quality 0.8 -allow_sw 1 -tag:v hvc1 -q:v 60 "hevc/$name.mov"
  fi
  echo "encoded $name"
done
[[ "$(uname)" == "Darwin" ]] || echo "HEVC with alpha skipped: run this on the Mac to make the iOS files in hevc/."
