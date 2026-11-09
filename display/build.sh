#!/usr/bin/env bash
# Rebuild ONLY the Apple DRM module against the matching installed kernel headers.
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
kernel=7.2.11-14-1-ARCH
[[ $(uname -r) == "$kernel" ]] || { echo 'This recipe is pinned to kernel 7.2.11-14-1-ARCH. Port/review the patch for other kernels.'; exit 1; }
headers="/usr/lib/modules/$kernel/build"
[[ -s "$headers/Module.symvers" ]] || { echo 'Install the matching linux-aurora-headers first.'; exit 1; }
work="${DISPLAY_BUILD_DIR:-$HOME/.cache/omarchy-config/display-120hz}"
mkdir -p "$work/packages" "$work/toolchain" "$work/module"
while read -r name url; do
 file="$work/packages/${url##*/}"
 [[ -s "$file" ]] || curl -fL --retry 3 "$url" -o "$file"
done < "$root/package-urls.txt"
(cd "$work/packages" && sha256sum -c "$root/package-SHA256SUMS")
for file in "$work"/packages/*.pkg.tar.xz; do tar -xf "$file" -C "$work/toolchain"; done
export PATH="$work/toolchain/usr/lib/llvm18/bin:$PATH"
export LD_LIBRARY_PATH="$work/toolchain/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
clang --version
[[ $(clang -dumpversion) == 18.1.8 ]] || { echo 'Unexpected compiler version.'; exit 1; }
# Fresh source for every build; never patch an already patched working tree.
cp -a "$root/source/." "$work/module/"
patch -d "$work/module" -p1 < "$root/combined-fix.patch"
make -C "$headers" M="$work/module" LLVM=1 -j"${JOBS:-4}" modules
modinfo "$work/module/appledrm.ko"
echo "Built: $work/module/appledrm.ko"
echo 'The installer uses the archived, tested artifact; review and update its checksum before installing a different build.'
