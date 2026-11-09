#!/bin/bash
set -euo pipefail

kernel=7.2.11-14-1-ARCH
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
artifact="$script_dir/appledrm-patched.ko"
stock=/usr/lib/modules/$kernel/kernel/drivers/gpu/drm/apple/appledrm.ko
override=/usr/lib/modules/$kernel/updates/appledrm.ko
config=/etc/modprobe.d/aurora-t6030-120hz-local.conf
backup=/var/lib/aurora-120hz-fix/$(date +%Y%m%d-%H%M%S)

[[ $EUID == 0 ]] || { echo 'Run with pkexec or sudo.'; exit 1; }
[[ $(uname -r) == "$kernel" ]] || { echo 'Kernel changed; rebuild first.'; exit 1; }
echo '79a62a72cf226b95e83df8e18de0664192ce0b6ff239854e437f94ef4ce110d6  '"$artifact" | sha256sum -c -
echo '69a9b5cf60b5b5540df4dad85cf0cd6ed6fcd7ddd9234db0d5e177a29cdba57a  '"$stock" | sha256sum -c -
[[ ! -e $override && ! -e $config ]] || { echo 'An override already exists; inspect it first.'; exit 1; }
[[ $(modinfo -F vermagic "$artifact") == "$(modinfo -F vermagic "$stock")" ]]
modinfo -F parm "$artifact" | grep -q '^t6030_early_flip:'

install -d -m 700 "$backup"
exec > >(tee "$backup/install.log") 2>&1
echo "Backing up existing boot images and configuration to $backup"
boot_files=(/boot/initramfs-linux-aurora.img)
while IFS= read -r -d '' file; do boot_files+=("$file"); done < <(
  find /boot/efi -type f \( -name '*linux-aurora*' -o -name 'limine.conf' \) -print0
)
tar -cpf "$backup/boot-before.tar" -- "${boot_files[@]}"
cp -a "$stock" "$backup/appledrm-stock.ko"
printf '%s\n' "$backup" > /var/lib/aurora-120hz-fix/latest-backup

rollback_on_error() {
  status=$?
  trap - ERR
  echo 'Installation failed; removing override and restoring boot backup.'
  rm -f "$override" "$config"
  depmod -a "$kernel"
  tar -xpf "$backup/boot-before.tar" -C /
  exit "$status"
}
trap rollback_on_error ERR

install -Dm644 "$artifact" "$override"
cat > "$config" <<'EOF'
# Local M3 Pro 120 Hz fix: timestamps in the module, early flip disabled here.
# Both come from linux-aurora PR #358 / issue #31.
# Toggle early flip live through /sys/module/appledrm/parameters/t6030_early_flip.
options appledrm t6030_early_flip=0
EOF
chmod 644 "$config"
depmod -a "$kernel"
[[ $(realpath "$(modinfo -k "$kernel" -n appledrm)") == "$override" ]]

# Omarchy boots a Limine UKI; use its supported image rebuild command.
/usr/bin/limine-mkinitcpio linux-aurora
uki=/boot/efi/EFI/Linux/omarchy_linux-aurora.efi
[[ -s $uki ]]
verify=$(mktemp -d /tmp/aurora-120hz-verify.XXXXXX)
objcopy --dump-section ".initrd=$verify/initrd" "$uki" "$verify/uki-copy"
lsinitcpio -l "$verify/initrd" > "$backup/initramfs-contents.txt"
grep -q 'updates/appledrm.ko' "$backup/initramfs-contents.txt"
grep -q 'aurora-t6030-120hz-local.conf' "$backup/initramfs-contents.txt"
rm -rf "$verify"

trap - ERR
echo 'Installed and verified in the boot image. Reboot to activate.'
echo "Rollback: sudo bash \"$script_dir/rollback.sh\""
