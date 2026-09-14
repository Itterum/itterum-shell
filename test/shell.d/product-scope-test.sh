#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command nix
require_command jq

package_path=$(nix build --no-link --print-out-paths \
  "$ROOT#packages.x86_64-linux.default")
runtime="$package_path/share/itterum-shell"
config="$runtime/config/shell.json"

if grep -RIEq 'OMARCHY_PATH|/usr/share/omarchy|\.config/omarchy|\.local/state/omarchy' "$runtime"; then
  fail "runtime uses only Itterum and XDG resource paths"
fi
pass "runtime uses only Itterum and XDG resource paths"

if grep -RIEq 'omarchy-(pkg|install|remove|update)|(^|[^[:alnum:]_])(pacman|paru|yay)([^[:alnum:]_]|$)|web-?app|webapp|lazy-install' "$runtime"; then
  fail "runtime has no package mutation, update, or web-app provider"
fi
pass "runtime has no package mutation, update, or web-app provider"

excluded_ids=(
  omarchy.agents
  omarchy.disk-speedtest
  omarchy.dropbox
  omarchy.speedtest
  omarchy.system-update
  omarchy.tailscale
  omarchy.weather
  omarchy.wifiqr
)

for plugin_id in "${excluded_ids[@]}"; do
  if grep -RIEq '"id"[[:space:]]*:[[:space:]]*"'"$plugin_id"'"' "$runtime/shell/plugins"; then
    fail "package excludes plugin $plugin_id"
  fi
  pass "package excludes plugin $plugin_id"
done

jq -e '
  .version == 1 and
  ([.bar.layout[][] | .id] | index("omarchy.workspaces") != null) and
  ([.bar.layout[][] | .id] | index("omarchy.active-window") != null) and
  ([.bar.layout[][] | .id] | index("omarchy.clock") != null) and
  (.bar.layout.right[-1].id == "omarchy.tray")
' "$config" >/dev/null || fail "default bar contains core widgets with tray rightmost"
pass "default bar contains core widgets with tray rightmost"

[[ ! -d $ROOT/daemon ]] || fail "obsolete dual-backend prototype is removed"
pass "obsolete dual-backend prototype is removed"
