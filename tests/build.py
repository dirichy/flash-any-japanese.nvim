import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('build', Path(__file__).resolve().parents[1] / 'scripts/build.py')
build = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build)


class DictionaryTests(unittest.TestCase):
    @unittest.skipUnless(os.environ.get('FLASH_ANY_ROOT'), 'set FLASH_ANY_ROOT for regeneration test')
    def test_generation_prunes_combinations_and_records_counts(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = Path(__file__).resolve().parents[1]
            shutil.copytree(source / 'scripts', root / 'scripts')
            (root / 'lua/flash-any/japanese').mkdir(parents=True)
            (root / 'lua/flash-any/tables').mkdir()
            shutil.copyfile(source / 'lua/flash-any/japanese/kana.lua',
                            root / 'lua/flash-any/japanese/kana.lua')
            jmdict = root / 'jmdict.xml'
            jmdict.write_text('''<JMdict><entry><k_ele><keb>甲乙</keb></k_ele>
              <r_ele><reb>こうおつ</reb></r_ele><r_ele><reb>きょう</reb></r_ele>
            </entry></JMdict>''', encoding='utf-8')
            kanjidic = root / 'kanjidic.xml'
            kanjidic.write_text('''<kanjidic2>
              <character><literal>甲</literal><reading_meaning><rmgroup>
                <reading r_type="ja_on">コウ</reading>
              </rmgroup></reading_meaning></character>
              <character><literal>乙</literal><reading_meaning><rmgroup>
                <reading r_type="ja_on">オツ</reading>
              </rmgroup></reading_meaning></character>
            </kanjidic2>''', encoding='utf-8')
            mozc = root / 'mozc.tsv'
            mozc.write_text('ko\tこ\nu\tう\no\tお\ntu\tつ\nkyo\tきょ\n', encoding='utf-8')
            command = ['python3', str(root / 'scripts/build.py'),
                       str(jmdict), str(kanjidic), str(mozc)]
            env = dict(os.environ, NVIM_LOG_FILE=str(root / 'nvim.log'))
            subprocess.run(command, env=env, check=True, capture_output=True, text=True)
            table = root / 'lua/flash-any/tables/japanese.tsv'
            first = table.read_bytes()
            lines = table.read_text(encoding='utf-8').splitlines()
            self.assertIn('甲\tこう', lines)
            self.assertIn('乙\tおつ', lines)
            self.assertIn('甲乙\tきょう', lines)
            self.assertNotIn('甲乙\tこうおつ', lines)
            self.assertIn('キョ\tきょ', lines)
            manifest = json.loads((root / 'data.json').read_text())
            self.assertEqual(manifest['readings'], len(lines))
            self.assertEqual(manifest['entries'], len({line.split('\t')[0] for line in lines}))
            self.assertGreater(manifest['redundant_readings_removed'], 0)
            subprocess.run(command, env=env, check=True, capture_output=True, text=True)
            self.assertEqual(first, table.read_bytes())

    def test_restrictions_and_okurigana(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            jmdict = root / 'jmdict.xml'
            jmdict.write_text('''<JMdict><entry>
              <k_ele><keb>甲</keb></k_ele><k_ele><keb>乙</keb></k_ele>
              <r_ele><reb>こう</reb><re_restr>甲</re_restr></r_ele>
              <r_ele><reb>おつ</reb></r_ele>
              <r_ele><reb>きのと</reb><re_nokanji/></r_ele>
            </entry></JMdict>''', encoding='utf-8')
            kanjidic = root / 'kanjidic.xml'
            kanjidic.write_text('''<kanjidic2><character><literal>食</literal>
              <reading_meaning><rmgroup>
                <reading r_type="ja_on">ショク</reading>
                <reading r_type="ja_kun">た.べる</reading>
                <reading r_type="pinyin">shi2</reading>
              </rmgroup></reading_meaning>
            </character></kanjidic2>''', encoding='utf-8')
            rows = build.build(jmdict, kanjidic, {'し': {'shi', 'si'}})
            self.assertEqual(rows['甲'], {'こう', 'おつ'})
            self.assertEqual(rows['乙'], {'おつ'})
            self.assertEqual(rows['きのと'], {'きのと'})
            self.assertEqual(rows['食'], {'しょく', 'た'})
            self.assertEqual(rows['シ'], {'し'})


if __name__ == '__main__':
    unittest.main()
