#!/usr/bin/env bash
set -euo pipefail
PRESET="general"
case "${1:-}" in "") ;; --graeme) PRESET="graeme" ;; --general) ;; -h|--help) echo "Usage: sudo ./install.sh [--graeme|--general]"; exit 0 ;; *) echo "Unknown option: $1"; exit 2 ;; esac
if [ "${EUID}" -ne 0 ]; then echo "Please run: sudo ./install.sh [--graeme]"; exit 1; fi
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"; SABLE_DIR="${SABLE_DIR:-/home/volumio/sable}"; PATCH="$PACK_DIR/patches/sable-empowered.patch"
[ -d "$SABLE_DIR/.git" ] || { echo "Install standard Sable first."; exit 1; }
id -u volumio >/dev/null 2>&1 || { echo "The Volumio account is missing."; exit 1; }
if ! runuser -u volumio -- git -C "$SABLE_DIR" apply --check "$PATCH"; then
  if [ "$FORCE" -ne 1 ]; then
    if [ -t 0 ]; then
      read -r -p "Sable version differs. Apply anyway? [y/N] " reply
      case "$reply" in [yY]|[yY][eE][sS]) FORCE=1 ;; *) echo "Nothing was changed."; exit 1 ;; esac
    else
      echo "Version differs. Re-run with --force to attempt installation."
      exit 1
    fi
  fi
  echo "Version mismatch: applying by request."
fi
runuser -u volumio -- git -C "$SABLE_DIR" apply "$PATCH"
SETTINGS="$SABLE_DIR/config/settings.json"
PRESET="$PRESET" runuser -u volumio -- python3 - "$SETTINGS" <<'PY'
import json, os, sys
path=sys.argv[1]
try:
    with open(path, encoding="utf-8") as f: cfg=json.load(f)
except FileNotFoundError: cfg={}
button=cfg.setdefault("buttons", {}).setdefault("btn_8", {})
if button.get("action") in (None, "shutdown"): button.update(action="save_track", arg="")
cfg.setdefault("audio", {})["menu_mode"]="personal" if os.environ["PRESET"]=="graeme" else "general"
if os.environ["PRESET"]=="graeme": cfg.setdefault("ir", {}).update(enabled=True, profile="Apple Aluminium Remote (this unit)")
cfg.setdefault("_meta", {})["rev"]=3
with open(path, "w", encoding="utf-8") as f: json.dump(cfg, f, indent=2); f.write("\n")
PY
if [ "$PRESET" = "graeme" ]; then
  BOOT_CONFIG=/boot/userconfig.txt; [ -f "$BOOT_CONFIG" ] || { echo "Expected $BOOT_CONFIG was not found."; exit 1; }
  cp -a "$BOOT_CONFIG" "$BOOT_CONFIG.quadify-empowered.bak"
  for line in "dtparam=spi=on" "dtoverlay=gpio-ir,gpio_pin=4" "dtoverlay=gpio-shutdown,gpio_pin=17,active_low=1,gpio_pull=up"; do grep -qxF "$line" "$BOOT_CONFIG" || printf '%s\n' "$line" >> "$BOOT_CONFIG"; done
  install -m 0644 "$SABLE_DIR/config/lirc/profiles/Apple Aluminium Remote (this unit)/lircd.conf" /etc/lirc/lircd.conf
  [ ! -f /etc/lirc/lirc_options.conf ] || sed -i -E 's|^[[:space:]]*device[[:space:]]*=.*|device   = /dev/lirc1|' /etc/lirc/lirc_options.conf
  echo "Graeme GPIO/IR preset applied. A reboot is required for the IR overlay."
fi
install -m 0644 "$SABLE_DIR/systemd/sable.service" /etc/systemd/system/sable.service
install -m 0644 "$SABLE_DIR/systemd/sable-boot-indicator.service" /etc/systemd/system/sable-boot-indicator.service
systemctl daemon-reload; systemctl enable sable.service sable-boot-indicator.service; systemctl restart sable.service
echo "Quadify Empowered is installed using the $PRESET preset."
