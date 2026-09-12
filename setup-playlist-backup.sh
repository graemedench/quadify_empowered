#!/usr/bin/env bash
# Optional playlist backup setup for Quadify Empowered.
set -euo pipefail
if [ "${EUID}" -ne 0 ]; then echo "Please run: sudo ./setup-playlist-backup.sh"; exit 1; fi
read -r -p "Backup server name or IP: " BACKUP_SERVER
read -r -p "Share name: " BACKUP_SHARE
read -r -p "Share username: " BACKUP_USER
read -r -s -p "Share password: " BACKUP_PASSWORD
echo
[ -n "$BACKUP_SERVER" ] && [ -n "$BACKUP_SHARE" ] && [ -n "$BACKUP_USER" ] || { echo "Server, share and username are required."; exit 1; }

install -d -m 700 /etc/quadify
printf 'username=%s\npassword=%s\n' "$BACKUP_USER" "$BACKUP_PASSWORD" > /etc/quadify/playlist-backup.credentials
chmod 600 /etc/quadify/playlist-backup.credentials
printf 'server=%s\nshare=%s\n' "$BACKUP_SERVER" "$BACKUP_SHARE" > /etc/quadify/playlist-backup.conf
chmod 600 /etc/quadify/playlist-backup.conf

cat > /usr/local/sbin/quadify-playlist-backup <<'SCRIPT'
#!/bin/sh
set -eu
. /etc/quadify/playlist-backup.conf
PLAYLIST=/data/playlist/Quadify
CREDS=/etc/quadify/playlist-backup.credentials
STATE=/var/lib/quadify-playlist-backup-slot
HTML=/var/lib/quadify-tidal-links.html
[ -s "$PLAYLIST" ] || { logger -t quadify-playlist-backup "Quadify playlist is missing"; exit 1; }
/usr/bin/python3 - "$PLAYLIST" "$HTML" <<'PY'
import html, json, re, sys
src, dst = sys.argv[1:]
with open(src, encoding="utf-8") as f: tracks = json.load(f)
rows = []
for item in tracks:
    match = re.search(r"tidal://(?:song|track)/(\d+)", str(item.get("uri", "")))
    if not match: continue
    title, artist = html.escape(str(item.get("title", "Unknown track"))), html.escape(str(item.get("artist", "Unknown artist")))
    album, art = html.escape(str(item.get("album", ""))), html.escape(str(item.get("albumart", "")), quote=True)
    image = f'<img src="{art}" alt="" loading="lazy">' if art else '<div class="blank"></div>'
    rows.append(f'<li>{image}<div><a href="https://tidal.com/browse/track/{match.group(1)}">{title}</a><br><small>{artist} — {album}</small></div></li>')
page = """<!doctype html><html><head><meta charset="utf-8"><title>Quadify TIDAL links</title><style>body{font-family:system-ui,sans-serif;max-width:760px;margin:2rem auto;padding:0 1rem}li{display:flex;gap:14px;align-items:center;margin:1rem 0;min-height:72px}img,.blank{width:72px;height:72px;object-fit:cover;background:#ddd;border-radius:5px}a{font-size:1.08rem}small{color:#555}</style></head><body><h1>Quadify TIDAL links</h1><p>Open a track, then use TIDAL’s Save/Add to playlist option.</p><ol>""" + "".join(rows) + "</ol></body></html>"
with open(dst, "w", encoding="utf-8") as f: f.write(page)
PY
slot=$(cat "$STATE" 2>/dev/null || echo 0)
slot=$((slot % 3 + 1))
/usr/bin/smbclient "//$server/$share" -A "$CREDS" -c "put $PLAYLIST Quadify-latest.playlist; put $PLAYLIST Quadify-backup-$slot.playlist; put $HTML Quadify-TIDAL-links.html"
printf '%s\n' "$slot" > "$STATE"
logger -t quadify-playlist-backup "Quadify playlist backup completed (slot $slot)"
SCRIPT
chmod 700 /usr/local/sbin/quadify-playlist-backup

cat > /etc/systemd/system/quadify-playlist-backup.service <<'UNIT'
[Unit]
Description=Back up Quadify playlist to a network share
Wants=network-online.target
After=network-online.target
[Service]
Type=oneshot
ExecStartPre=/bin/sleep 20
ExecStart=/usr/local/sbin/quadify-playlist-backup
[Install]
WantedBy=multi-user.target
UNIT
cat > /etc/systemd/system/quadify-playlist-backup.timer <<'UNIT'
[Unit]
Description=Weekly Quadify playlist backup
[Timer]
OnCalendar=Sun *-*-* 03:15:00
Persistent=true
[Install]
WantedBy=timers.target
UNIT
systemctl daemon-reload
systemctl enable --now quadify-playlist-backup.service quadify-playlist-backup.timer
echo "Playlist backup is configured: every boot and every Sunday at 03:15."
