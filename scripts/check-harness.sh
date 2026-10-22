#!/usr/bin/env bash
# Mechanical checks that keep the repo legible to agents and humans.
# Every failure prints what broke and how to fix it. Run: scripts/check-harness.sh
# Rules are explained in docs/harness.md.
set -u
cd "$(dirname "$0")/.."

MAX_AGENTS=120   # AGENTS.md / CLAUDE.md: a map, not a manual
MAX_DOC=600      # any file under docs/
MAX_SWIFT=600    # any Swift source or test file
MAX_COMMENT=3    # consecutive // lines in Swift; comments explain business logic
FAILS=0

fail() {
  echo "FAIL: $1"
  echo "  fix: $2"
  FAILS=$((FAILS + 1))
}

check_size() { # file max fix
  local n
  n=$(wc -l < "$1" | tr -d ' ')
  if [ "$n" -gt "$2" ]; then fail "$1 has $n lines (max $2)" "$3"; fi
}

find_files() { # name-pattern dirs...
  local pat=$1; shift
  find "$@" -name "$pat" \
    -not -path '*/node_modules/*' -not -path '*/.build/*' -not -path '*/.git/*' 2>/dev/null
}

# 1. Size limits ------------------------------------------------------------
while IFS= read -r f; do
  check_size "$f" "$MAX_AGENTS" "move detail into docs/ and link to it from $f"
done < <(find_files 'AGENTS.md' . ; find_files 'CLAUDE.md' .)

while IFS= read -r f; do
  check_size "$f" "$MAX_DOC" "split $f into focused files and link them from docs/index.md"
done < <(find_files '*.md' docs)

while IFS= read -r f; do
  check_size "$f" "$MAX_SWIFT" "extract a type or helper into its own file in the same module"
done < <(find_files '*.swift' secondstrong-ios)

# 1b. Comment blocks stay short ---------------------------------------------
while IFS= read -r f; do
  hits=$(awk -v f="$f" -v max="$MAX_COMMENT" '
    /^[[:space:]]*\/\// { run++; if (run == max + 1) print f ":" NR; next }
    { run = 0 }' "$f")
  if [ -n "$hits" ]; then
    fail "comment block longer than $MAX_COMMENT lines at: $hits" \
      "cut it to at most $MAX_COMMENT lines, only explaining business logic; move longer explanations to docs/"
  fi
done < <(find_files '*.swift' secondstrong-ios)

# 2. Layer imports ----------------------------------------------------------
# SSCore -> SSDesign -> features -> App. Features never import each other.
check_imports() { # dir allowed-regex layer-name
  [ -d "$1" ] || return 0
  local bad
  bad=$(grep -rnE '^import +SS' "$1" --include='*.swift' \
    | grep -vE "^[^:]+:[0-9]+:import +($2)[[:space:]]*$")
  if [ -n "$bad" ]; then
    fail "$3 imports a module above or beside it:"$'\n'"$bad" \
      "respect the layer order in docs/architecture/ios.md; move shared code down into SSCore or SSDesign"
  fi
}

check_imports secondstrong-ios/Sources/SSCore 'NONE' SSCore
check_imports secondstrong-ios/Sources/SSDesign 'SSCore' SSDesign
for dir in secondstrong-ios/Sources/*/; do
  name=$(basename "$dir")
  case "$name" in SSCore | SSDesign) continue ;; esac
  check_imports "${dir%/}" 'SSCore|SSDesign' "$name"
done

ui=$(grep -rnE '^import +(SwiftUI|UIKit|AppKit)' secondstrong-ios/Sources/SSCore --include='*.swift')
if [ -n "$ui" ]; then
  fail "SSCore imports a UI framework:"$'\n'"$ui" "SSCore is pure Foundation; put UI code in SSDesign or a feature module"
fi

# 3. Markdown links resolve -------------------------------------------------
while IFS= read -r f; do
  dir=$(dirname "$f")
  while IFS= read -r link; do
    target=${link#\](}; target=${target%\)}; target=${target%%#*}
    case "$target" in '' | http* | mailto:*) continue ;; esac
    if [ ! -e "$dir/$target" ]; then
      fail "$f links to missing path: $target" "fix the path or remove the link"
    fi
  done < <(grep -oE '\]\([^)]+\)' "$f")
done < <(find_files '*.md' docs; find_files 'AGENTS.md' .)

# 4. Every doc is reachable from the index ----------------------------------
while IFS= read -r f; do
  rel=${f#docs/}
  [ "$rel" = "index.md" ] && continue
  if ! grep -qF "($rel)" docs/index.md; then
    fail "docs/index.md does not link to $rel" "add a one-line entry for it in docs/index.md"
  fi
done < <(find_files '*.md' docs)

# 5. Tickets are well formed and references resolve -------------------------
ticket_field() { # file key
  awk -v k="$2" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 { i = index($0, ":"); if (substr($0, 1, i - 1) == k) { v = substr($0, i + 1); sub(/^ +/, "", v); print v; exit } }
  ' "$1"
}

seen=""
for f in tickets/SS-*.md; do
  [ -e "$f" ] || continue
  fid=$(basename "$f" | sed -E 's/^(SS-[0-9]{4})-.*/\1/')
  if [ "$(ticket_field "$f" id)" != "$fid" ]; then
    fail "$f: id in frontmatter does not match filename" "set id to $fid or rename the file"
  fi
  case " $seen " in *" $fid "*) fail "duplicate ticket id $fid" "renumber one with a new id and update its references" ;; esac
  seen="$seen $fid"
  for key in title type status created updated; do
    if [ -z "$(ticket_field "$f" $key)" ]; then fail "$f: missing '$key'" "add '$key:' to the frontmatter"; fi
  done
  case " task bug feature chore " in *" $(ticket_field "$f" type) "*) ;; *) fail "$f: bad type" "use task, bug, feature or chore" ;; esac
  case " todo in-progress review done cancelled " in *" $(ticket_field "$f" status) "*) ;; *) fail "$f: bad status" "use scripts/ticket status" ;; esac
  grep -q '^## Comments' "$f" || fail "$f: missing '## Comments' section" "add it as the last section"
  check_size "$f" "$MAX_DOC" "close the ticket and open a follow-up for the remaining work"
done

refs=$(grep -rhoE 'SS-[0-9]{4}' secondstrong-ios docs AGENTS.md tickets 2>/dev/null \
  --include='*.swift' --include='*.md' | sort -u)
for ref in $refs; do
  if ! ls tickets/"$ref"-*.md > /dev/null 2>&1; then
    fail "$ref is referenced but no such ticket exists" "create it with scripts/ticket new, or fix the reference"
  fi
done

if [ "$FAILS" -gt 0 ]; then
  echo; echo "$FAILS check(s) failed."; exit 1
fi
echo "Harness checks passed."
