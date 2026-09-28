#!/usr/bin/env python3
"""Build Resources/vocab.json from curated TSVs + ECDICT cache."""
import csv, json, re, sys, os

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, 'all_ielts_cache.json')
OUT = os.path.join(HERE, '..', 'Resources', 'vocab.json')
TOPICS = {'education','work','technology','environment','health','society','money',
          'media','travel','culture','science','law','government','urban','food','global'}
BANDS = {5:'5.0-5.5', 6:'6.0-6.5', 7:'7.0-7.5', 8:'8.0-9.0'}

def band_of(bnc):
    if bnc <= 1500: return 5
    if bnc <= 3000: return 6
    if bnc <= 7000: return 7
    return 8

def clean_ipa(ipa):
    if not ipa: return ''
    # ECDICT stores variants separated by ". "; keep the first, drop syllable dots
    first = ipa.split('. ')[0]
    first = first.strip().strip('/')
    first = first.replace('.', '')
    return ('/' + first + '/') if first else ''

POS_RE = re.compile(r'^(n|v|a|s|adj|adv|prep|conj|pron|num|int|u|vi|vt|r)\.?\s+', re.I)

def clean_def(senses):
    lines = []
    for chunk in senses:
        for ln in chunk.split('\\n'):
            ln = ln.strip()
            if not ln: continue
            m = POS_RE.match(ln)
            if m: ln = ln[m.end():].strip()
            if ln and ln not in lines: lines.append(ln)
    parts, total = [], 0
    for s in lines:
        s = s.strip().strip(';').strip()
        if not s: continue
        if total + len(s) > 160 and parts: break
        parts.append(s); total += len(s)
        if total > 150: break
    if not parts: return ''
    d = '; '.join(parts)
    d = d[0].upper() + d[1:]
    return d.rstrip('.') + ('.' if d.endswith((',', ';')) else '')

with open(CACHE, encoding='utf-8') as f:
    cache = json.load(f)

words, seen = {}, set()
errors = []
for name in ('curated_1.tsv', 'curated_2.tsv', 'curated_3.tsv'):
    path = os.path.join(HERE, name)
    with open(path, encoding='utf-8') as f:
        for i, line in enumerate(f, 1):
            line = line.rstrip('\n')
            if not line.strip(): continue
            cols = line.split('\t')
            if len(cols) != 4:
                errors.append(f'{name}:{i}: expected 4 columns, got {len(cols)}: {line[:60]}'); continue
            w, topic, vi, ex = (c.strip() for c in cols)
            if topic not in TOPICS:
                errors.append(f'{name}:{i}: unknown topic {topic}'); continue
            if w in seen:
                errors.append(f'{name}:{i}: duplicate word {w}'); continue
            if w not in cache:
                errors.append(f'{name}:{i}: word not in ECDICT cache: {w}'); continue
            seen.add(w)
            e = cache[w]
            ipa = clean_ipa(e.get('ipa', ''))
            d = clean_def(e.get('senses', []))
            if not d: errors.append(f'warning: no definition for {w}')
            words[w] = {
                'id': w, 'w': w,
                'ipa': ipa, 'pos': e.get('pos', ''),
                'band': band_of(e['bnc']),
                'topics': [topic],
                'def': d, 'ex': ex, 'vi': vi,
            }

for e in errors: print(e, file=sys.stderr)

out_words = [words[k] for k in sorted(words)]
payload = {'version': 1, 'words': out_words}
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(payload, f, ensure_ascii=False, separators=(',', ':'))

# stats
from collections import Counter
band_c = Counter(w['band'] for w in out_words)
topic_c = Counter(t for w in out_words for t in w['topics'])
cell = Counter((w['band'], t) for w in out_words for t in w['topics'])
no_ipa = sum(1 for w in out_words if not w['ipa'])
no_def = sum(1 for w in out_words if not w['def'])
print(f'\n== vocab.json: {len(out_words)} words ==')
print('bands:', dict(sorted(band_c.items())))
print('topics:')
for t in sorted(TOPICS):
    print(f'  {t:12}', topic_c.get(t, 0))
empty = [(b, t) for b in BANDS for t in sorted(TOPICS) if cell[(b, t)] == 0]
print(f'empty band/topic cells: {len(empty)} -> {empty}')
print(f'missing ipa: {no_ipa}, missing def: {no_def}')
