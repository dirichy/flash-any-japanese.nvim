#!/usr/bin/env python3
"""Extract kana readings from local JMdict/KANJIDIC2 and spellings from Mozc.

Python is only needed by maintainers. Reading segmentation happens in the Lua
converter at dictionary-build time, not in this script or at search time.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import unicodedata
import xml.etree.ElementTree as ET


def hiragana(text):
    return ''.join(chr(ord(c) - 0x60) if '\u30a1' <= c <= '\u30f6' else c
                   for c in unicodedata.normalize('NFKC', text))


def read_mozc(path):
    groups = {}
    for line in path.read_text(encoding='utf-8').splitlines():
        fields = line.split('\t')
        if len(fields) != 2:
            continue  # Carry-over rules are handled by the kana segmenter.
        code, kana = fields
        kana = hiragana(kana)
        if kana and all('\u3041' <= c <= '\u3096' or c in 'ー・〜。、「」『』…‥' for c in kana):
            groups.setdefault(kana, set()).add(code)
    return groups


def entries(path, tag):
    opener = gzip.open if path.suffix == '.gz' else open
    with opener(path, 'rb') as stream:
        for _, elem in ET.iterparse(stream, events=('end',)):
            if elem.tag == tag:
                yield elem
                elem.clear()


def build(jmdict, kanjidic, groups):
    rows = {}

    def add(text, reading):
        reading = hiragana(reading)
        if text and reading and not any(c in text + reading for c in '\t\r\n\0'):
            rows.setdefault(text, set()).add(reading)

    for entry in entries(jmdict, 'entry'):
        writings = [elem.text for elem in entry.findall('k_ele/keb')]
        for elem in entry.findall('r_ele'):
            reading = elem.findtext('reb')
            add(reading, reading)
            if elem.find('re_nokanji') is None:
                restricted = [node.text for node in elem.findall('re_restr')]
                for text in restricted or writings:
                    add(text, reading)
    for char in entries(kanjidic, 'character'):
        text = char.findtext('literal')
        for reading in char.findall('.//reading'):
            if reading.get('r_type') in ('ja_on', 'ja_kun'):
                # Only the portion before the dot belongs to the kanji itself;
                # the remaining okurigana is separate text in the buffer.
                add(text, reading.text.strip('-').split('.', 1)[0])
    for kana in groups:
        add(kana, kana)
        katakana = ''.join(chr(ord(c) + 0x60) if '\u3041' <= c <= '\u3096' else c for c in kana)
        add(katakana, kana)
        # Compound kana keys allow doubled consonants outside dictionary words.
        for prefix in ('っ', 'ッ'):
            if kana != 'ー':
                add(prefix + (kana if prefix == 'っ' else katakana), 'っ' + kana)
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('jmdict', type=Path)
    parser.add_argument('kanjidic', type=Path)
    parser.add_argument('mozc', type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    groups = read_mozc(args.mozc)
    rows = build(args.jmdict, args.kanjidic, groups)
    for path, data in [(root / 'lua/flash-any/japanese/kana.tsv', groups),
                       (root / 'lua/flash-any/tables/japanese.tsv', rows)]:
        with path.open('w', encoding='utf-8', newline='\n') as output:
            for text in sorted(data):
                for code in sorted(data[text]):
                    output.write(f'{text}\t{code}\n')
    manifest = {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
                for path in (args.jmdict, args.kanjidic, args.mozc)}
    manifest['entries'] = len(rows)
    manifest['readings'] = sum(map(len, rows.values()))
    manifest['kana_groups'] = len(groups)
    (root / 'data.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
