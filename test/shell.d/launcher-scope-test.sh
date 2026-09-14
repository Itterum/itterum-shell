#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

launcher_sources=(
  "$ROOT/shell/services/AppLibrary.qml"
  "$ROOT/shell/plugins/menu"
)

violations=$(rg -n \
  'execDetached\([^\n]*omarchy-|\.run\("omarchy-|command:[^\n]*omarchy-|(^|[^[:alnum:]_])(pacman|paru|yay)([^[:alnum:]_]|$)|write[^\n]*\.desktop|appLibrary\.remove\(' \
  "${launcher_sources[@]}" || true)

[[ -z $violations ]] || fail "launcher has no package, web-app, removal, or public shell actions" "$violations"
pass "launcher has no package, web-app, removal, or public shell actions"

grep -Fq 'uwsm-app -- gtk-launch' "$ROOT/shell/services/AppLibrary.qml" || fail "launcher uses installed desktop entries"
pass "launcher uses installed desktop entries"
