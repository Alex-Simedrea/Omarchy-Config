# Restore the M3 Pro 120 Hz display fix

The working configuration corrects T6030 display timestamps. The optional early
flip implementation is included but **disabled** (`t6030_early_flip=0`). On this
machine the tested patched driver delivered about 118.9 fps with early flip off,
versus about 75.6 fps with it on. Stock behavior had been around 60 fps despite
Hyprland advertising a 120 Hz mode. Do not re-enable early flip as part of restore.

## Exact original kernel

The archived `appledrm-patched.ko` was built for:

- `uname -r`: `7.2.11-14-1-ARCH`
- package: `linux-aurora 7.2.11.aurora14-1`
- source: `omacom/linux-aurora`, commit in `source-commit`
- compiler Clang 18.1.8, linker LLD 18.1.6
- DCP firmware 14.7, T6030 built-in panel

For that **exact kernel**, from a terminal:

```bash
sudo bash display/install.sh
# Read the successful initramfs/UKI verification, then reboot yourself.
```

The installer checks the running kernel, SHA256 of the tested artifact and original
packaged module, matching vermagic, and that no override/config already exists.
It leaves the packaged module intact, saves boot files under
`/var/lib/aurora-120hz-fix/`, installs an `updates/appledrm.ko` override and an
`/etc/modprobe.d/` option file, then runs `limine-mkinitcpio linux-aurora` and checks
that the resulting UKI contains both. It does not reboot automatically.
This requires the original Omarchy Limine layout and a mounted EFI filesystem.

After reboot:

```bash
uname -r
modinfo -n appledrm
cat /sys/module/appledrm/parameters/t6030_early_flip
hyprctl monitors
```

The module path should end in `updates/appledrm.ko`; the early-flip value should be
`N`. Verify actual presentation with a 120 fps workload, rather than relying only
on the advertised monitor mode.

Rollback for the original kernel:

```bash
sudo bash display/rollback.sh
# Reboot yourself after the boot image has been rebuilt successfully.
```

## Rebuilding / newer kernels

`source/` contains the original Apple DRM driver subtree from the pinned source.
`combined-fix.patch` has portable relative paths. `package-urls.txt` and
`package-SHA256SUMS` record the compiler packages originally verified and used.
The repository includes the tested module so reinstalling the exact old kernel
need not depend on old mirror packages remaining available.

`bash display/build.sh` is a reconstructed build recipe for the original kernel.
It downloads and verifies the original toolchain packages, copies the saved
original driver, applies the patch, and builds only this module against matching
installed `linux-aurora-headers` and their `Module.symvers`. It requires several
hundred MB of scratch space. No full kernel build is needed for the original
compatible driver patch. The archived binary was tested; this packaged rebuild
script was syntax-checked but has not been used to rebuild it again.

For a different kernel, first inspect its driver: the timestamp fix might already
be present. Otherwise obtain that kernel's exact source/headers/config/compiler,
review and port the patch, rebuild and verify module compatibility. Do not reuse
the old subtree, binary or checksum by changing only a version string. The pinned
installer intentionally refuses a new artifact until its checksums are reviewed.
There is no automatic cross-kernel installation hook.

The original session notes remain in `README.md`; its old absolute artifact paths
are historical. Use the repository-relative scripts documented here.
