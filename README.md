# flash-any-japanese.nvim

[English](README.en.md) · [简体中文](README.zh-CN.md)

[flash-any.nvim](https://github.com/dirichy/flash-any.nvim) で、かな・漢字・単語を
ローマ字で検索してジャンプします。JMdict と KANJIDIC2 の読みを使い、
`shi/si`、`chi/ti` などの入力を音節ごとに組み合わせられます。

![ローマ字で検索してジャンプ](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.gif)

[MP4](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.mp4) · [検証結果](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table-verification.json)

## インストール

Neovim 0.11+、flash.nvim、make、C コンパイラが必要です。
lazy.nvim の設定例：

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

依存プラグインはコアの setup より前にロードされます。
利用時に Python や IME は必要ありません。

## 使い方

`s` を押し、読みを入力してからラベルを選びます。

| テキスト | 入力例 |
| --- | --- |
| 寿司 | `sushi` / `susi` |
| 学校・がっこう・ガッコウ | `gakkou` |
| 日本 | `nihon` / `nippon` |
| 食べる | `taberu` |
| キャット | `kyatto` |
| コーヒー | `ko-hi-` |
| いすゞ・こゝろ | `isuzu`・`kokoro` |
| う～ん | `u~n` |
| 寿司 with flash | `susi with flash` |

## 設定と範囲

既定は `full_code` です。音節ごとの頭文字も使う場合は次のように設定します。

```lua
opts = { sources = { { name = "japanese", matcher = "initial" } } }
```

`initial` では「寿司」に `ss` や `sus` も使えます。`prefix` は各音節の任意の
非空接頭辞、`letter` は完全な綴りと Neovim の ignorecase/smartcase を使います。
`full_code`、`initial`、`prefix` は小文字の綴りに正確に一致します。

全角ひらがな・カタカナ、拗音、促音、長音符、辞書収録語、漢字の音訓を対象とします。
長音符は `-`、母音の連続はそのまま入力します（`こう → kou`）。
漢字の訓読みは送り仮名の前の部分だけを漢字に割り当てます。
辞書にない活用・固有名詞の読みや文脈による読み分けは生成しません。
辞書の読みの繰り返し記号は、直前のかなと清濁に従って展開します。
正規化された `~` と `=` はそのまま入力します。半角かなは対象外です。
単独の `ゝ／ゞ／ヽ／ヾ` は記号を説明する項目で、独立した読みは割り当てません。
記号そのものによる検索は引き続き可能です。
ローマ字検索であり、IME の入力状態や変換候補は再現しません。

コードは MIT、派生辞書は CC BY-SA 4.0、かな綴り表は Mozc の BSD 条件です。
出典と変更内容は [THIRD_PARTY.md](THIRD_PARTY.md)、更新手順は
[docs/maintenance.md](docs/maintenance.md) を参照してください。
