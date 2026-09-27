# Changelog

## 2026-09-27

- Added the no-drill, reversible rear Ethernet-jack panel STL, fitting photos
  and safety-first fitting notes for the original IEC / POWER OUT opening.
- Added a 296 × 173.5 mm, photo-derived Rev-A SVG/DXF template for a reversible
  PCB replacement panel, with 3.5 mm fixing-hole clearance and test-fit notes.
- Documented the reversible FM4-conversion principle and the planned USB-A+C
  rear-panel option with optional power-text backing plate.
- Regenerated the Sable enhancement patch from the full current FM4 build.
- Added the looping boot LED animation, playback-mode display refinements,
  audio-first display settling and soft-stop behaviour.
- Added button 5–7 short/long shortcut learning: hold Save (8), press a target
  button, choose short/long with the encoder, then confirm with the encoder.
- Added Settings → Shortcuts → Reset 5–7 Defaults.
- A long encoder press now exits directly to Now Playing from menu/browse depth.
- Added a fully documented `--graeme` preset with the current button, display,
  audio and Apple IR defaults.
- The installer now identifies the verified Sable base and supports an explicit
  `--force` three-way-merge attempt for other versions.

## 2026-09-26

- Added **Settings → Shutdown** at the bottom of the Settings menu, with a confirmation step before the existing graceful shutdown routine runs.
- Added a **Back** item at the bottom of Settings and all music-browsing lists, for immediate return without waiting for the timeout.

## 2026-09-22

- Added a Network panel menu with live connection type, network name and IP-address display.
- Added Wi-Fi scanning and an emergency on-screen password picker: rotate to choose a character, press to add it; JOIN, CANCEL and DELETE are at the start of the picker.
- Wi-Fi joining is delegated to Volumio's network controller.
- Added the minimum permission needed for the Sable service to scan Wi-Fi.

## Earlier releases

- Display, boot feedback, TIDAL/Sable Radio navigation, IR controls, audio-output modes and Button 8 save-track enhancements.
- Optional network-share backup of the local Quadify playlist and its artwork-enabled TIDAL links page.
