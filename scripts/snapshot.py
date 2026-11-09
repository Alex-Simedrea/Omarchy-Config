#!/usr/bin/env python3
"""Refresh only explicitly selected desktop configuration; never copy all of ~/.config."""
from pathlib import Path
import shutil, subprocess, json, hashlib
ROOT = Path(__file__).resolve().parents[1]
HOME = Path.home()
FILES = [
 '.local/state/omarchy/asahi-mic-gain.json', '.config/chromium-flags.conf', '.config/xdg-terminals.list',
 '.config/mimeapps.list', '.config/hyprland-mimeapps.list',
 '.config/omarchy/shell.json', '.config/omarchy/extensions/omarchy-menu.jsonc',
 '.config/wluma/config.toml', '.config/systemd/user/wluma.service',
 '.local/state/omarchy/local-touchpads/settings.json',
 '.local/state/omarchy/toggles/hypr/flags.lua',
 '.local/state/omarchy/toggles/hypr/zz-local-touchpads.lua',
 '.local/state/wluma/eDP-1.yaml', '.local/state/wluma/keyboard.yaml',
]
DIRS = [
 '.config/wireplumber', '.config/hypr', '.config/xkb', '.config/trackpad-plus/profiles',
 '.config/ghostty', '.config/foot', '.config/alacritty', '.config/kitty',
 '.config/omarchy/plugins/alex.menu', '.config/omarchy/plugins/alex.emojis',
 '.config/omarchy/plugins/davefano.trackpad-plus',
 '.local/state/omarchy/workspace-layouts',
]
def ignore(directory, names):
 return [n for n in names if n in ('.git','__pycache__') or '.bak' in n or n.endswith(('.pyc','.lock'))]
def copy(src, dst):
 dst.parent.mkdir(parents=True, exist_ok=True)
 if src.is_dir():
  if dst.exists(): shutil.rmtree(dst)
  shutil.copytree(src,dst,ignore=ignore)
 else: shutil.copy2(src,dst)
for rel in FILES+DIRS:
 src=HOME/rel
 if src.exists(): copy(src,ROOT/'home'/rel)
 else: print('Missing (skipped):',rel)
# Only specific non-sensitive appearance preferences, never a whole dconf database.
for schema in ['org.gnome.desktop.interface','org.gnome.desktop.peripherals.touchpad']:
 result=subprocess.run(['gsettings','list-recursively',schema],text=True,capture_output=True)
 (ROOT/'docs'/f'{schema}.txt').write_text(result.stdout)
for args,filename in [(['pacman','-Q'],'packages-versions.txt'),(['pacman','-Qqen'],'packages-native.txt'),(['pacman','-Qqem'],'packages-foreign.txt')]:
 r=subprocess.run(args,text=True,capture_output=True)
 if r.returncode not in (0,1): raise RuntimeError(r.stderr)
 (ROOT/'docs'/filename).write_text(r.stdout)
metadata={
 'snapshot_date':subprocess.check_output(['date','--iso-8601=seconds'],text=True).strip(),
 'kernel':subprocess.check_output(['uname','-r'],text=True).strip(),
 'hyprland':subprocess.check_output(['hyprctl','version'],text=True),
 'theme':(HOME/'.local/state/omarchy/current/theme.name').read_text().strip(),
 'trackpad_plus_commit':subprocess.check_output(['git','-C',str(HOME/'.config/omarchy/plugins/davefano.trackpad-plus'),'rev-parse','HEAD'],text=True).strip(),
}
(ROOT/'docs'/'snapshot.json').write_text(json.dumps(metadata,indent=2)+'\n')
print('Desktop snapshot refreshed. Review git diff before pushing.')
