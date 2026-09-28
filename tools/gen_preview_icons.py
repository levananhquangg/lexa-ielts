#!/usr/bin/env python3
"""Extract the icon path strings from Shared/Icons.swift into preview/icons.js
so the HTML design preview renders the exact same custom icons as the app."""
import re, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

src = open(os.path.join(ROOT, 'Shared', 'Icons.swift'), encoding='utf-8').read()
pairs = re.findall(r'case (\w+) = "([^"]*)"', src)
if not pairs:
    print('no icons found — check Icons.swift format', file=sys.stderr)
    sys.exit(1)

out_dir = os.path.join(ROOT, 'preview')
os.makedirs(out_dir, exist_ok=True)
entries = ',\n  '.join(f'"{n}": "{d}"' for n, d in pairs)
with open(os.path.join(out_dir, 'icons.js'), 'w', encoding='utf-8') as f:
    f.write('// Generated from Shared/Icons.swift — do not edit by hand.\n')
    f.write('const ICONS = {\n  ' + entries + '\n};\n')
print(f'icons.js written with {len(pairs)} icons:', ', '.join(n for n, _ in pairs))
