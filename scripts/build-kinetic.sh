#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
build="$HOME/.cache/omarchy-config/kinetic-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$build"
cp -a "$root/kinetic-scroll/source/." "$build/"
make -C "$build" -j"${JOBS:-4}" all test
c++ -O2 -std=c++2b -I"$build" "$build/tests/pixel_accumulator_test.cpp" -o "$build/tests/pixel_accumulator_test"
"$build/tests/pixel_accumulator_test"
# Never replace a loaded .so in place: existing mappings must remain intact.
out="$HOME/.local/share/hypr-kinetic-scroll/$(date +%Y%m%d-%H%M%S)-$$/hypr-kinetic-scroll.so"
install -Dm755 "$build/hypr-kinetic-scroll.so" "$out"
ln -sfn "$out" "$HOME/.local/share/hypr-kinetic-scroll/current.so"
mkdir -p "$HOME/.local/bin"
install -m755 "$root/scripts/kinetic-scroll-load" "$HOME/.local/bin/kinetic-scroll-load"
echo 'Built against the installed Hyprland headers. ABI checks remain enabled.'
echo 'Load with: ~/.local/bin/kinetic-scroll-load'
