#!/usr/bin/env bash
set -euo pipefail
PRESET="general"
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --graeme) PRESET="graeme" ;;
    --general) PRESET="general" ;;
    --force) FORCE=1 ;;
    -h|--help) echo "Usage: sudo ./install.sh [--graeme|--general] [--force]"; exit 0 ;;
    *) echo "Unknown option: $arg"; exit 2 ;;
  esac
done
if [ "${EUID}" -ne 0 ]; then echo "Please run: sudo ./install.sh [--graeme]"; exit 1; fi
PACK_DIR="$(cd "$(dirname "$0")" && pwd)"; SABLE_DIR="${SABLE_DIR:-/home/volumio/sable}"; PATCH="$PACK_DIR/patches/sable-empowered.patch"
SABLE_BASE="3670e503db8124de5890a6df1dc1b68b95d392a6"
[ -d "$SABLE_DIR/.git" ] || { echo "Install standard Sable first."; exit 1; }
id -u volumio >/dev/null 2>&1 || { echo "The Volumio account is missing."; exit 1; }
HEAD="$(runuser -u volumio -- git -C "$SABLE_DIR" rev-parse HEAD)"
if [ "$HEAD" != "$SABLE_BASE" ] && [ "$FORCE" -ne 1 ]; then
  echo "This release is verified with Sable $SABLE_BASE, but found $HEAD."
  echo "Nothing was changed. Re-run with --force only after taking a backup."
  exit 1
fi
# The Volumio plugin installer can change executable bits while copying files.
# Restore the repository's tracked modes before checking the patch, while leaving
# file contents untouched.
while IFS=$'\t' read -r mode path; do
  case "$mode" in
    100644) chmod 0644 "$SABLE_DIR/$path" ;;
    100755) chmod 0755 "$SABLE_DIR/$path" ;;
  esac
done < <(runuser -u volumio -- git -C "$SABLE_DIR" ls-files -s | awk '{print $1 "\t" $4}')

if runuser -u volumio -- git -C "$SABLE_DIR" apply --reverse --check "$PATCH"; then
  echo "This Quadify Empowered patch is already applied."
elif runuser -u volumio -- git -C "$SABLE_DIR" apply --check "$PATCH"; then
  runuser -u volumio -- git -C "$SABLE_DIR" apply "$PATCH"
else
  if [ "$FORCE" -ne 1 ]; then
    if [ -t 0 ]; then
      read -r -p "Sable version differs. Try Git's three-way merge? [y/N] " reply
      case "$reply" in [yY]|[yY][eE][sS]) FORCE=1 ;; *) echo "Nothing was changed."; exit 1 ;; esac
    else
      echo "Version differs. Re-run with --force to attempt a three-way merge."
      exit 1
    fi
  fi
  echo "Version mismatch: attempting Git's three-way merge by request."
  runuser -u volumio -- git -C "$SABLE_DIR" apply --3way "$PATCH"
fi
SETTINGS="$SABLE_DIR/config/settings.json"
if [ "$PRESET" = "graeme" ]; then
  PRESET_FILE="$SABLE_DIR/config/settings.graeme.json"
  [ -f "$PRESET_FILE" ] || { echo "Graeme preset was not supplied by the patch."; exit 1; }
  [ ! -f "$SETTINGS" ] || cp -a "$SETTINGS" "$SETTINGS.quadify-empowered.bak"
  install -o volumio -g volumio -m 0644 "$PRESET_FILE" "$SETTINGS"
else
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
fi
if [ "$PRESET" = "graeme" ]; then
  BOOT_CONFIG=/boot/userconfig.txt; [ -f "$BOOT_CONFIG" ] || { echo "Expected $BOOT_CONFIG was not found."; exit 1; }
  cp -a "$BOOT_CONFIG" "$BOOT_CONFIG.quadify-empowered.bak"
  for line in "dtparam=spi=on" "dtoverlay=gpio-ir,gpio_pin=27"; do grep -qxF "$line" "$BOOT_CONFIG" || printf '%s\n' "$line" >> "$BOOT_CONFIG"; done
  install -m 0644 "$SABLE_DIR/config/lirc/profiles/Apple Aluminium Remote (this unit)/lircd.conf" /etc/lirc/lircd.conf
  [ ! -f /etc/lirc/lirc_options.conf ] || sed -i -E 's|^[[:space:]]*device[[:space:]]*=.*|device   = /dev/lirc1|' /etc/lirc/lirc_options.conf
  echo "Graeme GPIO/IR preset applied. A reboot is required for the IR overlay."
fi
install -m 0644 "$SABLE_DIR/systemd/sable.service" /etc/systemd/system/sable.service
install -m 0644 "$SABLE_DIR/systemd/sable-boot-indicator.service" /etc/systemd/system/sable-boot-indicator.service
systemctl daemon-reload
systemctl enable sable.service sable-boot-indicator.service
# The Volumio web settings page lives in the plugin payload, not the source tree.
# Refresh it whenever this package changes plugin/index.js or UI configuration.
if [ -x "$SABLE_DIR/tools/build-plugin.sh" ] && command -v volumio >/dev/null 2>&1; then
  runuser -u volumio -- bash "$SABLE_DIR/tools/build-plugin.sh"
  runuser -u volumio -- bash -c 'cd "$1/plugin" && volumio plugin refresh' -- "$SABLE_DIR"
  volumio vrestart
fi
systemctl restart sable.service
# The panel can scan Wi-Fi but connection settings remain owned by Volumio.
wifi_tmp=$(mktemp)
printf '%s\n' 'volumio ALL=(root) NOPASSWD: /sbin/iwlist wlan0 scan' > "$wifi_tmp"
if visudo -cf "$wifi_tmp" >/dev/null 2>&1; then
  install -o root -g root -m 0440 "$wifi_tmp" /etc/sudoers.d/quadify-empowered-wifi
fi
rm -f "$wifi_tmp"
echo "Quadify Empowered is installed using the $PRESET preset."
