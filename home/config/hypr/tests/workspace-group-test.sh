#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$script_dir/tests/fixtures/bin:$PATH"
export XDG_CACHE_HOME="$test_dir/cache"
export HYPRCTL_LOG="$test_dir/hyprctl.log"
export WAYLE_LOG="$test_dir/wayle.log"

workspace_group="$script_dir/scripts/workspace-group"

"$workspace_group" workspace 2
grep -qx 'dispatch hl.dsp.focus({ workspace = "2" })' "$HYPRCTL_LOG"

"$workspace_group" move 4
grep -qx 'dispatch hl.dsp.window.move({ workspace = "4" })' "$HYPRCTL_LOG"

"$workspace_group" switch 2
grep -qx '2' "$XDG_CACHE_HOME/hypr-workspace-groups/current-group"

"$workspace_group" workspace 2
grep -qx 'dispatch hl.dsp.focus({ workspace = "12" })' "$HYPRCTL_LOG"

if "$workspace_group" workspace 11 >/dev/null 2>&1; then
    printf '%s\n' 'workspace 11 unexpectedly succeeded' >&2
    exit 1
fi
