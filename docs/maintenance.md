# Maintenance / 维护

Run commands from the source plugin directory. Python 3 is only a maintainer
dependency. Download current upstream dictionaries and the Mozc table explicitly;
the build script never downloads or changes upstream files.
以下命令在 source 包目录执行。Python 仅供维护者使用；构建脚本不联网。

```sh
curl -fL https://www.edrdg.org/pub/Nihongo/JMdict_e.gz -o /tmp/JMdict_e.gz
curl -fL https://www.edrdg.org/kanjidic/kanjidic2.xml.gz -o /tmp/kanjidic2.xml.gz
curl -fL https://raw.githubusercontent.com/google/mozc/master/src/data/preedit/romanji-hiragana.tsv -o /tmp/romanji-hiragana.tsv
python3 scripts/build.py /tmp/JMdict_e.gz /tmp/kanjidic2.xml.gz /tmp/romanji-hiragana.tsv
python3 tests/build.py
FLASH_ANY_ROOT=/absolute/path/to/flash-any.nvim nvim --clean -l tests/run.lua
```

Keep the input snapshots to reproduce their hashes. `data.json` records compressed
input hashes, extracted entry/reading counts and the basic group count. Regeneration
is deterministic for the same inputs. Update dictionaries regularly and review the
new counts, unsupported readings and licence notices when updating snapshots.
保留原始输入以便复现；同一输入生成相同 TSV 和 manifest。定期更新数据，复查数量、
不支持读音和上游声明，并同步 THIRD_PARTY.md 的日期及数量。

The shipped TSV retains kana readings. The factory supplies the file, converter
and groups. `kana.split()` converts a contiguous kana reading to space-separated
group names, selecting the longest recognized kana unit, including contracted and
doubled-consonant forms. Groups contain all supported spellings for that unit.
The converter runs only when the core builds a dictionary; runtime searches use C.
No word-level spelling Cartesian product is generated. Metadata caching tracks
the source's Lua/TSV files; restart Neovim after updating them.

分音 helper 在 `lua/flash-any/japanese/kana.lua`，TSV 不提前转罗马音。
词典收录负责汉字词的真实读音；促音和拗音在分音时处理，不按汉字各自拼读词组。
converter 仅在构建缓存时执行，查询由 C 逐组匹配，更新后重启 Neovim。

The current snapshot has 227211 distinct reading strings. The segmenter expands
hiragana and katakana iteration marks using the previous full-size kana: an unvoiced
mark repeats its unvoiced form, and a voiced mark repeats its voiced form. For example,
いすゞ becomes いすず and こゝろ becomes こころ. Marks without a valid preceding kana
cannot produce a pronunciation. This normalization runs on dictionary readings;
it does not rewrite buffer text or infer readings for unlisted words.

JMdict also defines the symbols themselves in entries 1000000 (ヽ), 1000010 (ヾ),
1000020 (ゝ), and 1000030 (ゞ). Their reb fields contain the symbols rather than
phonetic readings; their glosses describe katakana/hiragana repetition marks.
Only these four standalone symbol definitions remain without romaji readings.
They still match literal queries. Tests assert this exact remaining set.

The reading う~ん comes from JMdict's search-only spelling う～ん, a drawn-out
interjection. The equals sign in おび=わん・けのーび comes from オビ＝ワン・ケノービ
(Obi-Wan Kenobi). NFKC changes full-width ～/＝ to ASCII ~/=; explicit groups retain
those characters as literal input instead of dropping their entire readings.

目前只有四条独立的重复符释义没有罗马音读音，不能把“解释符号的条目”误认为漏掉的
发音。读音内的重复符在 converter 调用的分音 helper 中按清浊音展开；没有前文或
前文不是完整假名时不猜测。波浪号和等号来自原词条的实际写法，保留字面输入。
原始 TSV 不变，更新后由核心自动重建缓存。暂不生成半角假名、未收录的活用和
人名专用读音，不解析形态学，也不把带长音符号的拉丁转写自动归一化。

## Demo / 录制演示

The package follows the core's source tutorial and table-demo templates. Run from
the core checkout using the existing recording entry point:
本包复用核心 source 教程和录制模板。在核心仓库中执行：

```sh
sh demos/record.sh table /absolute/path/to/flash-any-japanese.nvim/demo.lua
```

demo.lua loads the source factory and reuses its real dictionary, converter,
groups and matcher. Only the target text and narration are specific to the
recording: hon → 本, then hon with flash → ほん with flash. The first scene
shows several real labels; the second mixes kana readings with literal ASCII.
本是“书”，读 hon；并非“日语”的意思。两段分别展示汉字及假名与 ASCII 混输。
配置复用工厂返回值，避免另建一份演示专用转换或匹配规则。

The recorder writes media, verification reports and README.local.md under the
core's demos/output directory. Optional local preview copies can be kept under
this package's ignored demos/output directory. Keep generated media out of Git.
录制产物保存在核心的 demos/output；包内同名目录仅供本地预览，不提交到 Git。

The [demo workflow](https://github.com/dirichy/flash-any-japanese.nvim/actions/workflows/demo.yml)
runs on main pushes and manual dispatch. Both uses and flash-any-ref follow the
core's main branch, so each new run uses the latest published recorder and core.
Core pushes alone do not trigger this workflow; start a new manual run after a
core update. Review the resulting recording and verification reports. To reproduce
a specific core revision, temporarily set both refs to that same commit SHA.
工作流在 main 推送或手动触发时运行，两处核心引用均跟随 main，自动使用最新代码。
仅推送核心仓库不会触发此工作流；核心更新后请手动发起一次新运行，并检查画面及
验证报告。若需复现特定核心版本，可临时将两处引用改为同一个提交 SHA。

Successful recordings on main publish GIF, MP4, PNG and JSON reports to the demos
prerelease. Workflow artifacts also include README.local.md and recording logs.
The READMEs link to the workflow while the demos release has no published assets.
After the first successful publication, replace those links with the GIF embed,
MP4 and table-verification.json release asset links. Do not link to ignored local files.
main 上录制成功后，媒体及 JSON 报告发布到 demos 预发布；工作流附件还包含本地报告
和录制日志。首次发布附件后，再将各语言 README 的工作流入口替换为 GIF、MP4 及
验证 JSON 的发布附件链接：

```text
https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.gif
https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table.mp4
https://github.com/dirichy/flash-any-japanese.nvim/releases/download/demos/table-verification.json
```
