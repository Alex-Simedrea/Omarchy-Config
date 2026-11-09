#!/usr/bin/env python3
"""Validate the archive, or refresh its SHA256 manifest after reviewing changes."""
from pathlib import Path
import argparse, ast, hashlib, json, subprocess
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--write-manifest',action='store_true');a=p.parse_args()
files=[f for f in sorted(root.rglob('*')) if f.is_file() and not any(part in ('.git','__pycache__') for part in f.relative_to(root).parts) and f.suffix not in ('.so','.o','.pyc') and f != root/'manifest.json' and f.name not in ('physics_test','gesture_test','pixel_accumulator_test')]
for f in files:
 if f.suffix=='.py': ast.parse(f.read_text(),filename=str(f))
 if f.suffix=='.json': json.loads(f.read_text())
 if f.suffix=='.sh' or f.name=='kinetic-scroll-load': subprocess.run(['bash','-n',str(f)],check=True)
 if f.is_symlink(): raise SystemExit('Unexpected symlink: '+str(f))
hashes={str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for f in files}
manifest=root/'manifest.json'
if a.write_manifest: manifest.write_text(json.dumps(hashes,indent=2)+'\n')
elif json.loads(manifest.read_text())!=hashes: raise SystemExit('Manifest differs; review changes and refresh it.')
print(f'PASS: syntax, JSON and SHA256 manifest ({len(files)} files)')
