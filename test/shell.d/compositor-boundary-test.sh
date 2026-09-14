#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command rg

violations=$(cd "$ROOT" && rg -n \
  "import[[:space:]]+Quickshell\\.Hyprland|[\"']hyprctl([\"']|[[:space:]])" \
  shell \
  --glob '!shell/services/compositor/**' || true)

[[ -z $violations ]] || fail "Hyprland access stays behind the compositor facade" "$violations"
pass "Hyprland access stays behind the compositor facade"

[[ -f $ROOT/shell/services/compositor/Compositor.qml ]] || fail "compositor facade exists"
pass "compositor facade exists"

[[ -f $ROOT/shell/services/compositor/HyprlandBackend.qml ]] || fail "Hyprland backend exists"
pass "Hyprland backend exists"
