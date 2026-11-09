# Alex’s Omarchy configuration

A curated snapshot of the working Omarchy setup on a MacBook Pro 14-inch M3 Pro
(`Mac15,6`, `apple,j514s`, T6030). Captured November 9, 2026.

This restores customizations **after installing Omarchy/Aurora for Apple Silicon**.
It is not an OS installer, disk image, firmware backup, or backup of personal files.

## What is included

| Area | Saved behavior / files |
| --- | --- |
| Keyboard | Apple English ISO extra key becomes left Shift; physical ± becomes grave/tilde; Caps tap Escape / hold Control, including launcher chords |
| Editing shortcuts | Option+Backspace deletes a word, Command+Backspace deletes to line start, Option/Command arrows navigate/select by word/line, double Space inserts a period |
| Gestures | Three-finger horizontal swipe moves through windows in Hyprland scrolling layout; saved workspace modes |
| Pointer | Trackpad Plus source, measured 98 units/mm calibration, original macOS export, converted imported acceleration curve |
| Scrolling | Progressive curve, global factor 0.0081, app adjustments, kinetic scroll source and local end-of-scroll twitch fix |
| Menu / emoji picker | Separate user-owned plugin copies; menu Control+N/P; menu multiplier 16, emoji multiplier 4; system inertia rather than another fling implementation |
| Display | Panel scale 2, GDK scale 2; tested 120 Hz appledrm module, original driver source, patch, compiler package checksums, install/rollback/build scripts |
| Brightness | Wluma config and service, learned screen and keyboard brightness values, pinned verified Wluma installer |
| Chromium | Wayland settings and UI scale 0.85, separate scrolling adjustment |
| Terminals | Ghostty preference, font size 9 and scroll settings; Foot, Kitty and Alacritty configs |
| Audio | Bluetooth A2DP autoconnect and KEF USB speaker no-suspend rules; saved Asahi microphone gain state |
| Desktop | Shell/bar/dock settings, menu extension file, night light, appearance and other Hyprland overrides |
| Reference | Installed package names/versions, selected GNOME preferences, hardware/software notes and source provenance |

The haptic "lighter click" experiment was reverted because it produced double
haptics. No experimental haptic module parameters are restored.

## Reinstall / restore

1. Install the Apple Silicon version of Omarchy, boot its graphical session, and
   install required applications. See `docs/packages-native.txt` and
   `docs/packages-foreign.txt` for the captured package inventory; do not blindly
   downgrade packages to the old version list. In particular retain Aurora's
   Apple drivers, firmware and audio packages, plus Ghostty, Chromium, Python,
   ripgrep, Git and the JetBrains Mono Nerd Font.
2. Clone this repository and preview the files:

   ```bash
   git clone https://github.com/Alex-Simedrea/Omarchy-Config.git
   cd Omarchy-Config
   python scripts/restore.py
   ```

3. Restore the home-directory files, with backups of anything replaced:

   ```bash
   python scripts/restore.py --apply
   ```

   Backups go under `~/.local/state/omarchy-config-backups/`. The script verifies
   the repository's checksums first. It copies files; it does not install packages,
   modify `/etc`, enable services, or restart programs. Restore before changing
   these files so the generated trackpad Lua and its authoritative JSON agree.
   The three shell plugins are included directly: no marketplace download needed.

4. Install the pinned Wluma binary, then compile kinetic scrolling:

   ```bash
   bash scripts/install-wluma.sh
   # Install any missing build dependencies using Omarchy's package manager.
   # Required: base-devel, pkgconf, Hyprland headers matching the running
   # compositor, pixman, libdrm, pango, libinput, systemd-libs, wayland,
   # libxkbcommon, and libeis. The recorded Hyprland package includes headers.
   bash scripts/build-kinetic.sh
   bash scripts/enable-services.sh
   ```

   Kinetic compilation runs the upstream physics/gesture tests and local
   fractional-scroll regression test. ABI checks remain enabled. After Hyprland
   updates, rebuild with matching headers and log out/in to load the new build.
   Do not bypass the version check. The loader avoids loading a second copy.
   Chromium keeps its own inertia because `disable_in_browser` stays enabled.
   `enable-services.sh` adds the kinetic loader to user autostart and enables
   Wluma. That login persistence is a restore addition; the original session used
   a manually loaded trial plugin.

5. Apply the saved theme and restart the shell:

   ```bash
   omarchy theme set tokyo-night
   hyprctl reload
   hyprctl configerrors
   omarchy restart shell
   ```

   Existing Chromium processes must fully exit and relaunch to read the saved
   flags. A browser-internal restart alone may retain the previous command line.
   Log out/in if the keyboard layout or environment is not picked up immediately.
   See `docs/org.gnome.desktop.interface.txt` for additional GNOME preferences;
   those are references and are not automatically imported as a whole schema.

6. Treat the display driver separately: follow [display/RESTORE.md](display/RESTORE.md).
   The archived module **only works with kernel `7.2.11-14-1-ARCH`**. Never install
   it on another kernel. A newer Aurora kernel may already contain the fix.

## Keep the backup up to date

```bash
python scripts/snapshot.py
python scripts/check.py --write-manifest
python scripts/check.py
python scripts/restore.py   # preview only
# Review before publishing:
git diff --stat
git diff
git add .
git commit -m "Update desktop configuration"
git push
```

`snapshot.py` uses an explicit allowlist. It refreshes home configs, calibrated
trackpad state, package lists and software metadata. It excludes nested Git
repositories, bytecode, locks, and backup files. It does not automatically replace
the separately archived display or kinetic source; review those when changing them.
The manifest detects accidental changes; it is not a cryptographic signature.

## What is deliberately excluded

Browser profiles and cookies, password stores/keyrings, SSH/GPG keys, GitHub login
credentials, Superwhisper cloud credentials and recordings, clipboard and
notification history, personal documents, Wi-Fi credentials, shell history,
old experimental backups, build caches, toolchains, initramfs/UKI images and
machine boot/disk identifiers. Reauthenticate applications after reinstalling.
The snapshot does not copy `/etc/fstab`, partition UUIDs, or bootloader configuration
from this installation onto a new disk.

This is a hardware- and Omarchy-version-specific snapshot. The shell plugins use
the Omarchy QML API from the capture date; future API changes may need adaptation.
See [docs/PROVENANCE.md](docs/PROVENANCE.md) for upstream sources and licenses.
