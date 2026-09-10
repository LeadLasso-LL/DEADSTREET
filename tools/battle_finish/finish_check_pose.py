from pathlib import Path
import sys
r=Path(__file__).resolve().parents[2];sys.path.insert(0,str(r/'tools/unit_source_recovery'))
from showcase_finish import finish
for path in (r/'assets/art/units/pixel_v1/check_comrade').glob('*.png'):
 finish(path)
print('Check poses palette-matched to the approved outfits')
