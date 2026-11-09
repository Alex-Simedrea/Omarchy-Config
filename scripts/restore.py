#!/usr/bin/env python3
"""Preview or restore the curated home directory snapshot with backups."""
import argparse, datetime, hashlib, json, os, shutil
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--apply',action='store_true',help='write files (default: preview only)')
p.add_argument('--target-home',type=Path,default=Path.home(),help='alternate home for an isolated restore test')
a=p.parse_args()
root=Path(__file__).resolve().parents[1]; target=a.target_home.expanduser().resolve()
manifest=json.loads((root/'manifest.json').read_text())
for rel,expected in manifest.items():
 path=root/rel
 if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest()!=expected:
  raise SystemExit('Checksum mismatch: '+rel)
files=sorted((root/'home').rglob('*'))
files=[f for f in files if f.is_file()]
backup=target/'.local/state/omarchy-config-backups'/datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
for src in files:
 rel=src.relative_to(root/'home'); dst=target/rel
 if not a.apply:
  print(('replace ' if dst.exists() or dst.is_symlink() else 'create  ')+str(rel)); continue
 # Refuse links in destination parents to keep the restore inside this home.
 for parent in [dst.parent,*dst.parent.parents]:
  if parent==target: break
  if parent.is_symlink(): raise SystemExit('Inspect destination symlink first: '+str(parent))
 if dst.exists() or dst.is_symlink():
  saved=backup/rel; saved.parent.mkdir(parents=True,exist_ok=True)
  shutil.copy2(dst,saved,follow_symlinks=False)
  if dst.is_symlink(): dst.unlink()
 dst.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(src,dst)
print(f'{len(files)} files '+('restored. Backups: '+str(backup) if a.apply else 'would be restored. Use --apply to write.'))
print('No services, kernel modules, packages, or application restarts were changed.')
