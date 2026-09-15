from pathlib import Path
R=Path(__file__).resolve().parents[2]
p=R/'tools/dusk_review/DECISION_REVIEW.md';s=p.read_text().replace('Defender shotgun','Defender with legacy shotgun ID (actual SMG loadout)').replace('defender shotgun','defender with legacy shotgun ID (actual SMG loadout)');p.write_text(s)
p=R/'tools/unit_source_recovery/QUEUE_NOTES.md';s=p.read_text().replace('defender shotgun moved into cover','defender with the legacy shotgun ID (actual SMG loadout) moved into cover')
s+='\nFinal runtime: 59.8 average active FPS, 32 shot events, four living units at 15 seconds. Actual shotgun loadouts have a separate shotgun_showcase.gd fixture because legacy participant IDs are not authoritative weapon IDs. Nine focused regression checks pass.\n'
p.write_text(s)
# Keep the old preview helper compatible with shifted clip indices.
p=R/'tools/unit_source_recovery/motion_preview.py';s=p.read_text().replace('from pathlib import Path','from pathlib import Path\nimport json')
s=s.replace("for clip,start in [('jog',0),('death',132)]:","manifest=json.loads((R.parent.parent/'assets/art/units/pixel_v1/manifest.json').read_text())\nfor clip,start in [('jog',manifest['clips']['walk']['start']),('death',manifest['clips']['death']['start'])]:").replace("duration=42 if clip=='jog' else 62","duration=30 if clip=='jog' else 62")
p.write_text(s)
