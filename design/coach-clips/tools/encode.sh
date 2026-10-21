#!/usr/bin/env bash
# Encodes the rendered ProRes 4444 masters (renders/<coach>/<state>.mov, transparent) into delivery formats.
#   webm/<coach>/  VP9 with alpha, keyframe every 6 frames so segment jumps are instant (browser preview, Android)
#   hevc/<coach>/  HEVC with alpha for iOS. Needs macOS: Apple's VideoToolbox encoder is the only one that writes
#                  the alpha layer AVFoundation expects. Run this script on the Mac to produce them.
# Skips files that are newer than their master. Usage: bash tools/encode.sh   (from design/coach-clips)
set -euo pipefail
for src in renders/*/*.mov; do
  coach=$(basename "$(dirname "$src")"); name=$(basename "$src" .mov)
  mkdir -p "webm/$coach"
  out="webm/$coach/$name.webm"
  [[ -f "$out" && "$out" -nt "$src" ]] || ffmpeg -y -loglevel error -i "$src" -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 30 -g 6 -auto-alt-ref 0 -row-mt 1 "$out"
  [[ "$name" == idle && ! "webm/$coach/idle.png" -nt "$src" ]] && ffmpeg -y -loglevel error -i "$src" -frames:v 1 -vf "crop=220:220:90:166,scale=96:96" "webm/$coach/idle.png"   # picker thumbnail
  if [[ "$(uname)" == "Darwin" ]]; then
    mkdir -p "hevc/$coach"
    ffmpeg -y -loglevel error -i "$src" -c:v hevc_videotoolbox -alpha_quality 0.8 -allow_sw 1 -tag:v hvc1 -q:v 60 "hevc/$coach/$name.mov"
  fi
done
echo "encoded $(ls renders/*/*.mov | wc -l) clips"
[[ "$(uname)" == "Darwin" ]] || echo "HEVC with alpha skipped: run this on the Mac to make the iOS files in hevc/."
