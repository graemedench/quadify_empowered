# Quadify Empowered

Quadify Empowered is a **post-install enhancement pack** for [Sable](https://github.com/theshepherdmatt/sable) on Volumio. It does not include, replace, or redistribute Sable itself.

## Reversible FM4 conversion

This build is designed to leave the FM4 chassis capable of being returned to its
original FM4 condition. The included mounting and rear-panel parts use existing
openings and fixing points: there is no chassis drilling or cutting. Keep the
original hardware and fasteners with the unit so the conversion can be reversed.

Any work around the original IEC/power hardware must be carried out with the
unit fully disconnected from mains power. Have a suitably competent person make
safe any original mains wiring before removing its outlet or inlet hardware.

## Personal use and original rights

Quadify Empowered is provided for **personal, non-commercial use**. It must not be sold, resold, or commercially redistributed by anyone other than the original Quadify publisher. The original Quadify publisher is expressly permitted to use, distribute, and sell these files commercially. All rights in the original Quadify project and its materials remain with the original Quadify creator and publisher; all rights in Sable remain with its publisher. This enhancement pack does not grant commercial rights in either original project to any other party.

## FM4 button print pack

[`FM4 Button Print Pack`](FM4%20Button%20Print%20Pack/) contains the matching printable button-cap files: an all-variants 3MF plate, individual two-colour FDM parts, editable blank-cap source, and one-piece single-colour resin files with 1 mm raised icons (including a plain resin blank cap). See its read-me for the recommended print workflow.

Install standard Volumio and Sable first. This pack adds reliable OLED/boot feedback, the looping front-panel LED startup pattern, display and audio-performance refinements, improved TIDAL/Sable Radio navigation, configurable radio/TIDAL shortcut buttons, IR support, networking tools, graceful shutdown, and a modern low-overhead display mode.

## Install

This release is verified against Sable commit
`3670e503db8124de5890a6df1dc1b68b95d392a6`. For a repeatable clean build:

```bash
git clone https://github.com/theshepherdmatt/sable.git /home/volumio/sable
cd /home/volumio/sable
git checkout 3670e503db8124de5890a6df1dc1b68b95d392a6
sudo bash install.sh
```

Then install this enhancement pack:

```bash
git clone https://github.com/graemedench/quadify_empowered.git /home/volumio/quadify_empowered
cd /home/volumio/quadify_empowered
sudo ./install.sh
```

The installer checks the Sable revision before it applies anything. If it is not the verified revision, it stops with no changes. For a deliberately attempted newer-version install, take a backup first and use `--force`; it then asks Git to perform a three-way merge and stops on a conflict rather than overwriting code.

## Current front-panel additions

- Button 1: tap play/pause; hold gives the quiet five-minute soft-stop state.
- Button 2 cycles Play Single, Play All, Repeat Single, Repeat All and Shuffle.
- Button 8: tap saves the current item to the TIDAL **Quadify** playlist; hold
  opens Save Shortcut. Press 5, 6 or 7, choose short/long with the encoder,
  then push the encoder to save the current radio/TIDAL source.
- Settings → Shortcuts restores the 5–7 defaults for the selected profile.
- A long encoder press returns directly to Now Playing from any menu/browse depth.
- The panel menu provides display, output, network/IP and emergency Wi-Fi setup.

## CD ripping and library tools

Audio CD offers **Rip HQ** (lossless FLAC) and **Rip MP3** (320kbps), with a choice of internal storage or a mounted USB drive. This uses `cdparanoia`, `cd-discid`, and `ffmpeg` already available on the development Volumio image; other installations need these tools available. Rips are saved under `CD Rips/<artist>/<album>` in a unique folder.

The progress bar follows each track through reading and encoding, alongside a track counter. **Cancel** keeps completed songs; **Exit and continue** returns to the panel while ripping continues. Volumio's library is refreshed after completion or cancellation.

**Settings > Music Library** offers **Refresh now** and automatic refresh: Off, every 15 minutes, or hourly. Automatic refresh defaults to Off on a fresh installation and waits while a CD rip is active. Enable it to pick up files copied over the network.

**Settings > Storage** lists internal storage and mounted USB/network drives with free space. Select a drive for free/total capacity; reopen the list to refresh it.

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
| IR receiver | HS0038 output on BCM GPIO27; 3.3 V and GND; Apple Aluminium Remote profile |
| IR device | `/dev/lirc1` |
| Shutdown button | BCM GPIO21, active-low, controlled by Sable |
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

## FM4 wiring diagram

The labelled build diagram is available at [docs/FM4-WIRING-DIAGRAM.svg](docs/FM4-WIRING-DIAGRAM.svg). It records the live FM4 GPIO, I²C, SPI, IR, rotary and shutdown-switch wiring.

The [FM4 build notes](docs/FM4-BUILD-NOTES.md) document the LED-8/IR receiver
conversion and link the included mounting-part STLs.

## Other FM4 printed parts

This repository currently includes the matching button-cap print pack, the
front-panel mounting parts (screen holder, rotary bracket and long knob
extender), and the reversible rear Ethernet-jack panel.

My FM4 build also has additional rear/enclosure pieces, and a cut-out template
for replacing the original PCB. These parts are intentionally **not included
yet** while their fit and final revision are being kept separate from the
current release. A USB-A+C rear-panel option is also planned; it will use the
existing IEC opening and have an optional backing plate to cover the original
power text, again without drilling. These will be added as and when.

