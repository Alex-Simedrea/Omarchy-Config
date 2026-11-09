#!/usr/bin/env bash
set -euo pipefail
[[ -x "$HOME/.local/bin/wluma" && -x "$HOME/.local/bin/kinetic-scroll-load" ]] || {
 echo 'Restore configs, install Wluma, and build kinetic scrolling first.'; exit 1;
}
systemctl --user daemon-reload
systemctl --user enable --now wluma.service
config="$HOME/.config/hypr/autostart.lua"
line='o.exec_on_start(os.getenv("HOME") .. "/.local/bin/kinetic-scroll-load")'
if ! rg -Fq -- "$line" "$config"; then
 cp -a "$config" "$config.bak.$(date +%s)"
 printf '\n-- Restore kinetic scrolling at login.\n%s\n' "$line" >> "$config"
fi
hyprctl reload
errors=$(hyprctl configerrors)
[[ -z "$errors" ]] || { printf '%s\n' "$errors"; exit 1; }
"$HOME/.local/bin/kinetic-scroll-load"
echo 'Brightness enabled; kinetic scroll enabled now and on future logins.'
