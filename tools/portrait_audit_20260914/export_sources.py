from pathlib import Path
import json
r=Path(__file__).resolve().parents[2]
paths=['tools/unit_source_recovery/src/build.py','tools/unit_source_recovery/src/outfits.py','tools/faction_design/eastex_outfits.py','tools/faction_design/mercer_preview.py','tools/faction_design/zangyaku_outfits.py','tools/faction_design/orlov_sniper_outfits.py','tools/arsenal_production/build_art.py','assets/art/units/factions/manifest.json','assets/art/units/mercer/manifest.json','assets/art/weapons/arsenal/manifest.json','assets/art/units/pixel_v1/manifest.json','tools/pistol_portrait_20260914/refresh_imports.py','tools/pistol_portrait_20260914/render.gd']
print('DS_SOURCE_JSON='+json.dumps({p:(r/p).read_text(encoding='utf-8-sig') for p in paths if (r/p).exists()},ensure_ascii=True))
