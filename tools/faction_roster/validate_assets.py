"""Release gate for complete production assets and anatomy/edge reports."""
from pathlib import Path
import json, math
from PIL import Image
ROOT=Path(__file__).resolve().parents[2]
DEST=ROOT/'assets/art/units/factions'

def run():
    manifest=json.loads((DEST/'manifest.json').read_text())
    assert manifest['complete'] and len(manifest['models'])==690 and len(manifest['variants'])==636
    folders={'units':(4096,6144),'death_back':(4096,1024),'check_comrade':(4096,1024),'blood_masks':(4096,6144),'portraits':(90,80)}
    checked=0; size=0
    for variant,definition in manifest['variants'].items():
        report=json.loads((DEST/'validation'/(variant+'.json')).read_text())
        assert report['variant']==variant and report['model']==definition['model']
        assert report['frames']==1840 and report['clips']==17 and report['directions']==8
        assert report['body_checks']==40 and not report['borders'],report
        for folder,dimensions in folders.items():
            path=DEST/folder/(variant+'.png')
            with Image.open(path) as image:
                assert image.size==dimensions,(path,image.size)
                image.verify()
            size+=path.stat().st_size
        anchors=json.loads((DEST/'anchors'/(variant+'.json')).read_text())
        assert len(anchors['muzzles'])==400 and len(anchors['abdomen'])==384,variant
        assert all(len(p)==2 and all(math.isfinite(v) for v in p) for table in anchors.values() for p in table.values())
        checked+=1
    result=dict(new_variants=checked,pairings=690,outfits=115,frames=checked*1840,geometry_checks=checked*40,border_touches=0,png_bytes=size)
    (ROOT/'tools/faction_roster/asset_validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print('ROSTER_ASSETS',json.dumps(result))
if __name__=='__main__':run()
