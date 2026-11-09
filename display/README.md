# Local M3 Pro 120 Hz display fix

Target kernel: `7.2.11-14-1-ARCH`, package `linux-aurora 7.2.11.aurora14-1`.
Source: `omacom/linux-aurora` at `4fdd0fc5c931ef9f14474942b37c3d451e97fc04`.
Compiler: Clang 18.1.8. Linker: LLD 18.1.6, from Arch Linux ARM packages.
Downloaded compiler packages were checked against the installed repository's SHA256 records.

Before patching, the rebuilt module's `.text` and `.data` sections were byte-for-byte
identical to the packaged module. Module version magic and all original parameters matched.
Both baseline and patched module builds completed, including MODPOST and BTF.

Changes in `combined-fix.patch`:

- T6030 `.swap_timestamps = true`, from https://github.com/omacom/linux-aurora/pull/358
- Optional `t6030_early_flip`, ported from
  https://github.com/omacom/linux-aurora/issues/31#issuecomment-6112008976

The early-flip code is off by default in the module. The local installation disables
it through a modprobe configuration file after testing both settings. The author notes
that early completion can release a buffer too soon for two-buffer direct-scanout
clients. It may also worsen pacing on some machines, so compare both settings.

The installer preserves the packaged module, installs a kernel-specific override
under `updates/`, backs up the boot images/configuration under
`/var/lib/aurora-120hz-fix/`, and rebuilds the Limine UKI. It does not reboot or
unload the active display driver. It restores the previous boot files on failure.

After reboot, check:

```sh
modinfo -n appledrm
cat /sys/module/appledrm/parameters/t6030_early_flip
```

Temporarily disable early flip while keeping timestamp correction:

```sh
echo 0 | sudo tee /sys/module/appledrm/parameters/t6030_early_flip
```

Full rollback, followed by a reboot:

```sh
sudo bash /home/alex/.local/share/aurora-120hz-fix/rollback.sh
```

The override is only for this exact kernel. It does not automatically carry forward
to a new kernel version; rebuild or use the upstream fix after a kernel update.

## Post-reboot verification, 2026-11-09

The patched module loaded successfully. A 12-second mpv 1280x720@120 test with
`--vo=gpu --gpu-api=opengl --gpu-context=wayland --video-sync=display-resample`
measured about 75.6 fps with early flip enabled, versus 118.9 fps with it disabled.
Reported jitter fell from about 0.760 to 0.096; mpv reported zero dropped frames.
The timestamp fix stays enabled; early flip is now disabled both live and at boot.
The optional code remains available for comparison, but is not needed on this machine.
