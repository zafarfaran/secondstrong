#!/usr/bin/env bash
# Renders every composition to a transparent ProRes 4444 master, four at a time.
# Skips clips whose master is newer than its composition. Usage: bash tools/render.sh [coach ...]
set -uo pipefail
coaches=("$@"); [[ ${#coaches[@]} -eq 0 ]] && coaches=($(ls compositions))
jobs=()
for c in "${coaches[@]}"; do
  mkdir -p "renders/$c"
  for f in compositions/$c/*.html; do
    s=$(basename "$f" .html); out="renders/$c/$s.mov"
    [[ -f "$out" && "$out" -nt "$f" ]] || jobs+=("$c/$s")
  done
done
echo "${#jobs[@]} clips to render"
printf '%s\n' "${jobs[@]}" | xargs -P 4 -I{} sh -c 'npx hyperframes render -c compositions/{}.html --format mov -o renders/{}.mov >/dev/null 2>&1 && echo "done {}" || echo "FAIL {}"'
