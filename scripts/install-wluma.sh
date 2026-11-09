#!/usr/bin/env bash
set -euo pipefail
[[ $(uname -m) == aarch64 ]] || { echo 'This pinned binary is for aarch64.'; exit 1; }
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
curl -fL --retry 3 https://github.com/maximbaz/wluma/releases/download/5.0.4/wluma-aarch64-linux-gnu -o "$work/wluma"
echo '60c6fcd4b439dde467af3d9604e824e425bd9ad9774b95e52618c6d1065dd0e3  '"$work/wluma" | sha256sum -c -
install -Dm755 "$work/wluma" "$HOME/.local/bin/wluma"
"$HOME/.local/bin/wluma" --version
