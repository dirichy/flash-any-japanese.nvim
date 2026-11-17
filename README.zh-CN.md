# flash-any-japanese.nvim

[日本語](README.md) · [English](README.en.md)

为 [flash-any.nvim](https://github.com/dirichy/flash-any.nvim) 提供日语罗马音搜索：
覆盖假名、汉字和词典中的词组，用 JMdict、KANJIDIC2 提供读音，逐音节共享拼写变体。

![用罗马音搜索并跳转](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.gif)

[MP4](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.mp4) · [验证报告](https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table-verification.json)

## 安装

需要 Neovim 0.11+、flash.nvim、make 和 C 编译器。lazy.nvim 配置示例：

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

依赖会在核心 setup 前加载。使用者无需 Python 或日语输入法。

## 使用

按 `s`，输入读音，再选择标签跳转：

| 文字 | 输入示例 |
| --- | --- |
| 寿司 | `sushi` / `susi` |
| 学校、がっこう、ガッコウ | `gakkou` |
| 日本 | `nihon` / `nippon` |
| 食べる | `taberu` |
| キャット | `kyatto` |
| コーヒー | `ko-hi-` |
| いすゞ、こゝろ | `isuzu`、`kokoro` |
| う～ん | `u~n` |
| 寿司 with flash | `susi with flash` |

`shi/si`、`chi/ti` 等变体可以逐音节混用，例如 `shiti` 匹配「しち」。

## 配置与范围

默认 `full_code`，要求每个音节完整输入。逐音节简拼可设置：

```lua
opts = { sources = { { name = "japanese", matcher = "initial" } } }
```

`initial` 还允许用 `ss`、`sus` 匹配「寿司」。`prefix` 接受每个音节任意非空前缀；
`letter` 使用完整拼写并遵循 Neovim 的 ignorecase/smartcase。
`full_code`、`initial`、`prefix` 精确比较小写编码。

支持全角平片假名、拗音、促音、长音符、词典词组和汉字音训。
长音符输入 `-`，连写元音保留原拼写，如 `こう → kou`。
汉字训读仅取送假名前属于该汉字的部分，例如「食」可按 `ta` 搜索，
「食べる」可输入 `taberu`。不推导未收录的活用、专名或上下文读音。
词条读音中的假名重复符按前一假名展开，清浊音分别处理；规范化后的 `~`、`=`
保留为字面输入。暂不覆盖半角假名。单独的 `ゝ／ゞ／ヽ／ヾ` 是符号解释条目，
没有可推导的独立读音，仍可用原文搜索。
这是罗马音搜索，不模拟输入法的输入状态和转换候选。

代码使用 MIT；派生词典使用 CC BY-SA 4.0；假名拼写表遵循 Mozc 的 BSD 条款。
来源及修改见 [THIRD_PARTY.md](THIRD_PARTY.md)，更新与验证见
[维护说明](docs/maintenance.md)。
