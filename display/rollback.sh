#!/bin/bash
set -euo pipefail
[[ $EUID == 0 ]] || { echo 'Run with sudo or pkexec.'; exit 1; }
kernel=7.2.11-14-1-ARCH
[[ -d /usr/lib/modules/$kernel ]] || { echo 'Original kernel no longer installed.'; exit 1; }
rm -f /usr/lib/modules/$kernel/updates/appledrm.ko
rm -f /etc/modprobe.d/aurora-t6030-120hz-local.conf
depmod -a "$kernel"
/usr/bin/limine-mkinitcpio linux-aurora
echo 'Stock display driver restored for the next reboot.'
