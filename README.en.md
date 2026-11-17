# flash-any-japanese.nvim

[日本語](README.md) · [简体中文](README.zh-CN.md)

Search kana, kanji and dictionary words with romaji in
[flash-any.nvim](https://github.com/dirichy/flash-any.nvim).
Uses JMdict and KANJIDIC2 readings, with spelling variants shared per syllable.

[Demo recordings and verification](https://github.com/dirichy/flash-any-japanese.nvim/actions/workflows/demo.yml)

## Install

Requires Neovim 0.11+, flash.nvim, make and a C compiler. With lazy.nvim:

```lua
{
  "dirichy/flash-any.nvim",
  branch = "main",
  version = false,
  dependencies = {
    "folke/flash.nvim",
    "dirichy/flash-any-japanese.nvim",
  },
  build = "make",
  opts = { sources = { "japanese" } },
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash-any").jump() end },
  },
}
```

Dependencies load before the core setup. Python and an IME are unnecessary for users.

## Use

Press `s`, type a reading, then select a label. Examples: `sushi`/`susi` → 寿司,
`gakkou` → 学校/がっこう/ガッコウ, `nihon`/`nippon` → 日本, `taberu` → 食べる,
`kyatto` → キャット, `ko-hi-` → コーヒー. Mix ordinary ASCII:
`susi with flash` → 寿司 with flash. Variants such as shi/si and chi/ti combine
independently, so `shiti` also matches しち.
Iteration marks within dictionary readings are expanded: `isuzu` matches いすゞ
and `kokoro` matches こゝろ. Normalized punctuation stays literal: `u~n` matches う～ん.

## Configuration and limits

Default matcher: `full_code`. To allow each syllable's first letter as well:

```lua
opts = { sources = { { name = "japanese", matcher = "initial" } } }
```

`initial` also accepts `ss` and `sus` for 寿司. `prefix` accepts each syllable's
nonempty prefixes. `letter` uses complete spellings and Neovim's ignorecase/smartcase.
Full_code, initial and prefix compare lowercase spellings exactly.

Covers full-width hiragana/katakana, contracted sounds, doubled consonants, long
vowel marks, dictionary words, and kanji on/kun readings. Type `-` for ー and retain
vowel sequences (`こう → kou`). Only the portion before the okurigana delimiter is
assigned to an individual kanji. Unlisted conjugations, names and contextual
readings are not inferred. Half-width kana is unsupported. Iteration marks within
readings repeat the previous kana with the indicated voicing; normalized `~` and `=`
remain literal inputs. The four standalone iteration-mark definitions have no
independent pronunciation and remain searchable by their original text.
This is romaji search, without IME conversion state.

Project code: MIT. Derived dictionaries: CC BY-SA 4.0. Kana spelling data: Mozc BSD.
See [attribution and modifications](THIRD_PARTY.md) and [maintenance](docs/maintenance.md).
