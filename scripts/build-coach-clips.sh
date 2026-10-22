#!/usr/bin/env bash
# Rebuilds the iOS coach clips from the WebM masters in design/coach-clips (macOS only).
# WebM -> ProRes 4444 -> HEVC with alpha (avconvert); the encoder ffmpeg ships drops the alpha.
set -euo pipefail
cd "$(dirname "$0")/.."
out=secondstrong-ios/Sources/SSDesign/Resources/Clips
tmp=$(mktemp -d)
for src in design/coach-clips/webm/*/*.webm; do
  coach=$(basename "$(dirname "$src")"); name=$(basename "$src" .webm)
  mkdir -p "$out/$coach"
  ffmpeg -y -loglevel error -c:v libvpx-vp9 -i "$src" -c:v prores_ks -profile:v 4444 -pix_fmt yuva444p10le "$tmp/$name.mov"
  rm -f "$out/$coach/$name.mov"
  avconvert --preset PresetHEVC1920x1080WithAlpha --source "$tmp/$name.mov" --output "$out/$coach/$name.mov" >/dev/null
  rm -f "$tmp/$name.mov"
done
cp design/coach-clips/manifest.json "$out/manifest.json"
echo "built $(ls "$out"/*/*.mov | wc -l) clips"
