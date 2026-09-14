#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

dock="$ROOT/shell/plugins/io.github.claudsondouglas.arcdock"

[[ -f $dock/LICENSE && -f $dock/UPSTREAM.md ]] || fail "Arc Dock attribution is preserved"
pass "Arc Dock attribution is preserved"

if grep -RIEq 'omarchy-(menu|shell|launch-webapp|webapp)|\.config/omarchy|\.local/state/omarchy' "$dock"; then
  fail "Arc Dock has no Omarchy command, web-app, or state dependency"
fi
pass "Arc Dock has no Omarchy command, web-app, or state dependency"

if grep -RIEq 'Quickshell\.Hyprland|(^|[^[:alnum:]_])Hyprland\.' "$dock"; then
  fail "Arc Dock uses the compositor facade"
fi
pass "Arc Dock uses the compositor facade"

[[ ! -e $dock/ArcHyprland.qml ]] || fail "Arc Dock has no private compositor backend"
pass "Arc Dock has no private compositor backend"

grep -F 'XDG_CONFIG_HOME' "$dock/ArcConfig.qml" >/dev/null || fail "Arc Dock config uses XDG"
grep -F '/itterum-shell' "$dock/ArcConfig.qml" >/dev/null || fail "Arc Dock config uses Itterum namespace"
pass "Arc Dock config uses the Itterum XDG namespace"
