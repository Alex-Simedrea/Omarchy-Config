# Sources and verification

Captured on 2026-11-09. `snapshot.json` records exact Hyprland/kernel metadata and
the Trackpad Plus revision. `packages-versions.txt` records installed packages.

- Omarchy: https://github.com/basecamp/omarchy — the `alex.menu` and `alex.emojis`
  directories are user-owned copies of the installed built-in plugins, preserving
  their author and `clonedFrom` metadata. The menu has Control+N/P support and
  scroll handling; the emoji picker has its own scroll handling (multiplier 4).
- Trackpad Plus: https://github.com/davefano/omarchy-trackpad-plus — vendored at the
  commit in `snapshot.json`; upstream LICENSE retained. Device JSON and generated
  Hyprland Lua both included. Sensor measurements: X -5896..6416 at 98 units/mm,
  Y -7363..163 at 97 units/mm. Curve calibration uses 98 units/mm.
- macOS pointer export:
  https://gist.github.com/Alex-Simedrea/020892cefc5eb5f430ca4245d853a9ba — original
  JSON in `home/.config/trackpad-plus/profiles/`; converted points in trackpad state.
- Kinetic scrolling: https://github.com/mihap/hypr-kinetic-scroll, revision
  `df9c399da0844fb1f52eaf9c002777f324e003c4` (fork of savonovv; upstream README
  declares MIT). `kinetic-scroll/source/` contains the tested source plus the local
  pixel accumulator and regression test. `tail-fix.patch` records the complete local
  patch, including the new header, test and Makefile dependency.
  It accumulates fractional movement into whole logical pixels, preserves direction
  and travel to within a fractional pixel, and resets at new gestures/reversals.
  The user confirmed the launcher/LibreOffice end-of-scroll glitch was resolved.
  No ABI check bypass or benchmark logs are restored.
- Display source: https://github.com/omacom/linux-aurora at
  `4fdd0fc5c931ef9f14474942b37c3d451e97fc04`. Driver subtree and original SPDX
  headers retained; GPL-2.0 and MIT license texts are in `display/licenses/`.
  Timestamp fix: https://github.com/omacom/linux-aurora/pull/358.
  Optional early flip: https://github.com/omacom/linux-aurora/issues/31#issuecomment-6112008976.
  This installation tested and disabled early flip. Before applying the patch,
  the rebuilt driver's .text/.data matched the packaged driver's byte for byte.
  The kernel-specific module's checksum is enforced by `display/install.sh`.
- Wluma: https://github.com/maximbaz/wluma, release 5.0.4. The installer downloads
  the aarch64 release binary and checks the same SHA256 used for this installation.
  Its learned display/keyboard profiles contain brightness calibration only.

Third-party files retain their original licensing. This snapshot does not claim
ownership of upstream projects. The display module is specific to the original
kernel, while kinetic scrolling must be rebuilt for the installed compositor.

Validation for this archive: plugin manifest checks, shell syntax checks, Python
syntax/JSON/checksum checks, isolated restore and backup tests, and kinetic physics,
gesture and fractional-scroll tests. No kernel driver was installed, no boot image
was rewritten, and no live desktop config was replaced during archive creation.
