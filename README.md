# Quadify Empowered

Quadify Empowered is a **post-install enhancement pack** for [Sable](https://github.com/theshepherdmatt/sable) on Volumio. It does not include, replace, or redistribute Sable itself.

## Personal use and original rights

Quadify Empowered is provided for **personal, non-commercial use**. It must not be sold, resold, or commercially redistributed by anyone other than the original Quadify publisher. The original Quadify publisher is expressly permitted to use, distribute, and sell these files commercially. All rights in the original Quadify project and its materials remain with the original Quadify creator and publisher; all rights in Sable remain with its publisher. This enhancement pack does not grant commercial rights in either original project to any other party.

## FM4 button print pack

[`FM4 Button Print Pack`](FM4%20Button%20Print%20Pack/) contains the matching printable button-cap files: an all-variants 3MF plate, individual two-colour FDM parts, editable blank-cap source, and one-piece single-colour resin files with 1 mm raised icons (including a plain resin blank cap). See its read-me for the recommended print workflow.

Install standard Volumio and Sable first. This pack adds quicker visible boot feedback, display reliability, a 10-second return to Now Playing, improved TIDAL/Sable Radio navigation, Button 8 save-track, IR support, and a modern low-overhead display mode.

## Install

```bash
git clone https://github.com/graemedench/quadify_empowered.git /home/volumio/quadify_empowered
cd /home/volumio/quadify_empowered
sudo ./install.sh
```

The installer checks the Sable version before it applies anything. If it is not compatible, it stops with no changes. For a deliberately attempted newer-version install, take a backup first and confirm the prompt (or use --force for unattended use); conflicts still stop rather than overwriting files.

## Output-menu presets

The default **general** menu detects usable Volumio outputs, hides HDMI, shows the built-in headphone output as variable-volume, and lists external outputs by their detected name.

Graeme's personal menu is restored with:

```bash
sudo ./install.sh --graeme
```

| Menu item | Hardware mapping |
| --- | --- |
| Lineout Fixed | Graeme's SMSL USB DAC, fixed volume |
| Lineout Variable | Graeme's SMSL USB DAC, software volume starting at 50% |
| Headphone Variable | Raspberry Pi built-in Audio Jack, software volume starting at 50% |

No music-service credentials or personal Volumio login details are included.

## Graeme hardware preset

`--graeme` also restores this Pi-specific configuration and backs up `/boot/userconfig.txt` first:

| Function | Configuration |
| --- | --- |
| OLED / panel SPI | `dtparam=spi=on` |
| IR receiver | HS0038 output on BCM GPIO4; 3.3 V and GND; Apple Aluminium Remote profile |
| IR device | `/dev/lirc1` (this unit also has the standard GPIO27 IR overlay) |
| Shutdown button | BCM GPIO17, active-low with pull-up |
| Button 8 | Save current track to Volumio's local `Quadify` playlist |

Reboot after `--graeme` so the IR overlay becomes active. The panel and GPIO wiring must match this profile.

## Updates

```bash
cd /home/volumio/quadify_empowered
git pull
sudo ./install.sh --graeme   # omit the switch for general mode
```

Update standard Sable separately using its own instructions. This remains an add-on, preserving the original project and its licensing.
## Optional playlist backup

To back up the local Volumio `Quadify` playlist (and a clickable, artwork-enabled TIDAL-links page) to your own Windows/NAS SMB share, run:

```bash
cd /home/volumio/quadify_empowered
sudo ./setup-playlist-backup.sh
```

It asks for the server, share, username and password **on the Pi**. None of these values are stored in Git. The credentials are saved only on that Pi in a root-only file. Backups run after every boot and every Sunday at 03:15, retaining `latest` plus three rotating numbered copies.

## Quick Back navigation

Every Settings submenu and music-browsing list ends with **Back**. Select it to return immediately; there is no need to wait for the automatic timeout.

## Shutdown from the panel

At the bottom of **Settings**, choose **Shutdown**, then **Confirm Shutdown**. This uses Sable's graceful shutdown sequence; it stops playback cleanly and turns off the display before power-off.

## Network menu

**Settings → Network** shows the active connection type and network name, for example Wi-Fi: MyNetwork, and can display its current IP address. It also includes an emergency Wi-Fi setup flow: scan for a network, select its SSID, then use the panel control to select password characters. The current password is visible only during entry; JOIN, CANCEL, and DELETE are the first picker options. Joining is passed to Volumio's own network controller, so it remains responsible for saved Wi-Fi settings.
