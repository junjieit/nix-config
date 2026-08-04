#!/usr/bin/env bash
set +e
OUT=/mnt/nix-config/sddm-debug.log
{
  echo "===== [1] generation ====="; readlink -f /nix/var/nix/profiles/system
  echo; echo "===== [2] sddm wrapper env ====="
  grep -nE 'QT_PLUGIN_PATH|NIXPKGS_QT6_QML_IMPORT_PATH|QML|Qt5Compat' /run/current-system/sw/bin/sddm 2>&1 | head -20
  echo; echo "===== [3] sddm binaries ====="
  ls -la /run/current-system/sw/bin/ 2>&1 | grep -i sddm
  echo; echo "===== [4] themes ====="
  ls -la /run/current-system/sw/share/sddm/themes/ 2>&1
  echo; echo "===== [5] display-manager status ====="
  systemctl status display-manager --no-pager -l 2>&1 | head -40
  echo; echo "===== [6] journal display-manager ====="
  journalctl -b -u display-manager --no-pager 2>&1 | tail -200
  echo; echo "===== [7] journal grep ====="
  journalctl -b --no-pager 2>&1 | grep -iE 'sddm|qml error|Qt5Compat|VirtualKeyboard|weston|kiosk|layer.shell|wlr|greeter|GraphicalEffects|virgl|EGL|GL ' | tail -200
  echo; echo "===== [8] /etc/sddm.conf ====="
  cat /etc/sddm.conf 2>&1
} > "$OUT" 2>&1
echo "saved: $OUT ($(wc -c < "$OUT") bytes)"
