import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('build', Path(__file__).resolve().parents[1] / 'scripts/build.py')
build = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build)


class DictionaryTests(unittest.TestCase):
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
