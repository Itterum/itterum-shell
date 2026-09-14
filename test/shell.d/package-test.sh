#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command nix

package_path=$(nix build --no-link --print-out-paths \
  "$ROOT#packages.x86_64-linux.default")
launcher="$package_path/bin/itterum-shell"

[[ -x $launcher ]] || fail "package installs an executable launcher" "missing executable: $launcher"
pass "package installs an executable launcher"

[[ -d $package_path/share/itterum-shell/shell ]] || fail "package installs immutable shell resources"
pass "package installs immutable shell resources"

[[ -d $package_path/share/itterum-shell/config ]] || fail "package installs approved default configuration"
pass "package installs approved default configuration"

for forbidden in \
  'QT_QUICK_BACKEND=software' \
  'LIBGL_ALWAYS_SOFTWARE' \
  '/usr/share/omarchy' \
  'OMARCHY_PATH'; do
  if grep -Fq "$forbidden" "$launcher"; then
    fail "launcher does not contain $forbidden"
  fi
  pass "launcher does not contain $forbidden"
done

grep -Fq 'ITTERUM_SHELL_PATH' "$launcher" || fail "launcher exports ITTERUM_SHELL_PATH"
pass "launcher exports ITTERUM_SHELL_PATH"
