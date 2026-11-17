# Data sources / 数据来源

Original project code uses [MIT](LICENSE). Data retains its upstream terms;
the project code license does not relicense dictionary data.
项目代码使用 MIT；以下数据保留上游许可。

## JMdict and KANJIDIC2

This package uses the JMdict and KANJIDIC2 dictionary files. These files are the
property of the Electronic Dictionary Research and Development Group, and are
used in conformance with the Group's licence.

- [JMdict project](https://www.edrdg.org/wiki/index.php/JMdict-EDICT_Dictionary_Project)
- [KANJIDIC project](https://www.edrdg.org/wiki/index.php/KANJIDIC_Project)
- Downloads: https://www.edrdg.org/pub/Nihongo/JMdict_e.gz and
  https://www.edrdg.org/kanjidic/kanjidic2.xml.gz
- [EDRDG licence statement](licenses/EDRDG.html)
- [Creative Commons Attribution-ShareAlike 4.0](licenses/CC-BY-SA-4.0.txt)

`lua/flash-any/tables/japanese.tsv` extracts writing/reading pairs, honors JMdict
re_restr and re_nokanji, adds kana spellings as text, and retains only ja_on/ja_kun
KANJIDIC2 readings. For individual kanji, text after the okurigana dot is omitted;
boundary hyphens are removed. Readings are NFKC-normalized and katakana is mapped
to hiragana. Duplicate pairs, glosses, frequencies and other metadata are omitted.
Original dictionary copyright remains with James William Breen and EDRDG.

Multi-character reading pairs reproducible by concatenating the runtime kana group
sequences of individual characters are omitted. Other readings of the same text
remain, including special word readings and groups spanning character boundaries.

提取文字与读音，保留 JMdict 的读音适用范围，补充假名文字和汉字音训。
单字训读省略送假名后缀，去掉读音边界连字符；读音转 NFKC 和平假名，去重并省略释义等字段。
提取后逐读音移除可由单字音节组拼接的冗余项，保留特殊词读音及跨字音节组。
精简文件含 159293 个文字条目、188590 个读音对，移除了 328699 个冗余读音对；
并非所有读音都有罗马音匹配。
Data was retrieved on 2026-11-17; source hashes and counts are recorded in [data.json](data.json).

## Mozc spelling table

`lua/flash-any/japanese/kana.tsv` derives kana/romaji alternatives from
[google/mozc romanji-hiragana.tsv](https://github.com/google/mozc/blob/master/src/data/preedit/romanji-hiragana.tsv).
It reverses completed kana rules, omits carry-over rules and unrelated symbols,
normalizes kana, and deduplicates spellings. Contextual doubled-consonant groups
are generated in Lua, without expanding dictionary word spellings.

Copyright 2010-2018, Google Inc. [BSD licence and upstream notices](licenses/mozc-BSD.txt).
The source hash is recorded in [data.json](data.json).

反转 Mozc 的完整假名输入规则，保留假名和少量日语标点，去重并统一假名形式。
带残留输入的规则不直接导入；促音组合由 Lua 根据下一音节生成。
