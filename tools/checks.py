#!/usr/bin/env python3
"""Static sanity checks for the Lexa project (no Swift toolchain needed)."""
import yaml, json, glob, re, sys

ok = True

try:
    p = yaml.safe_load(open('project.yml', encoding='utf-8'))
    print('project.yml OK — targets:', list(p['targets'].keys()))
except Exception as e:
    ok = False
    print('project.yml FAIL:', e)

for f in ['Resources/vocab.json',
          'Resources/Assets.xcassets/Contents.json',
          'Resources/Assets.xcassets/AppIcon.appiconset/Contents.json',
          'Resources/Assets.xcassets/AccentColor.colorset/Contents.json']:
    try:
        json.load(open(f, encoding='utf-8'))
        print(f, 'OK')
    except Exception as e:
        ok = False
        print(f, 'FAIL:', e)

def strip_strings_and_comments(src):
    """Char-level scan: removes // comments and string literal contents,
    keeping parens/braces that live outside both."""
    out = []
    i, n = 0, len(src)
    in_string = False
    while i < n:
        c = src[i]
        if in_string:
            if c == '\\' and i + 1 < n:
                i += 2
                continue
            if c == '"':
                in_string = False
                out.append('"')
            i += 1
            continue
        if c == '"':
            in_string = True
            out.append('"')
            i += 1
            continue
        if c == '/' and i + 1 < n and src[i + 1] == '/':
            while i < n and src[i] != '\n':
                i += 1
            continue
        out.append(c)
        i += 1
    return ''.join(out)


for path in glob.glob('App/*.swift') + glob.glob('Shared/*.swift') + glob.glob('Widget/*.swift'):
    s = strip_strings_and_comments(open(path, encoding='utf-8').read())
    b = s.count('{') - s.count('}')
    q = s.count('(') - s.count(')')
    if b or q:
        ok = False
        print('%-36s UNBALANCED braces=%d parens=%d' % (path, b, q))
    else:
        print('%-36s OK' % path)

keys_used = set()
for path in glob.glob('App/*.swift') + glob.glob('Widget/*.swift'):
    for m in re.findall(r'L10n\.tr\("([a-z][a-zA-Z0-9.]+)"', open(path, encoding='utf-8').read()):
        keys_used.add(m)
TOPICS = ('education', 'work', 'technology', 'environment', 'health', 'society', 'money',
          'media', 'travel', 'culture', 'science', 'law', 'government', 'urban', 'food', 'global')
keys_used |= {'stats.' + x for x in ('week', 'month', 'quarter', 'year')}
keys_used |= {'topic.' + t for t in TOPICS}

src = open('Shared/L10n.swift', encoding='utf-8').read()
tables = {'vi': set(), 'en': set()}
for lang in ('vi', 'en'):
    block = src.split('"%s": [' % lang)[1].split('\n        ],')[0]
    for m in re.findall(r'"([a-zA-Z0-9.]+)":\s*"', block):
        tables[lang].add(m)
missing = [k for k in sorted(keys_used) if k not in tables['vi'] or k not in tables['en']]
print('L10n keys used:', len(keys_used), '| missing:', missing if missing else 'none')
if missing:
    ok = False

print('ALL OK' if ok else 'ISSUES FOUND')
sys.exit(0 if ok else 1)
