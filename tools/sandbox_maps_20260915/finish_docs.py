from pathlib import Path
import json,re,hashlib
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
p=json.loads((out/'handoff.json').read_text(encoding='utf-8'))
(out/'README.md').write_text(p['readme'],encoding='utf-8')
(out/'library_receipt.json').write_text(json.dumps(p['library'],indent=2),encoding='utf-8')
(out/'source_scope_snapshot.json').write_text(json.dumps(p['source_scope'],indent=2),encoding='utf-8')
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 path=r/'docs'/name;before=path.read_bytes();text=before.decode('utf-8')
 if '20260915-sandbox-maps-04' not in text:text+='\n'+p['entry']
 if name=='DEAD_STREET_HIVE_MIND.md':
  text=re.sub(r'Coordination last reconciled:.*','Coordination last reconciled: 2026-09-15, after native sandbox map/convoy validation. Concurrent Freight status remains in its latest dated entry.',text,count=1)
  text=re.sub(r'\*\*Active objective \(2026-09-15\):\*\*[^\n]*','**Active objective (2026-09-15):** Sandbox map/convoy refresh complete, owner review next. Canonical Harold Ave. / Calder Memorial Bridge / Calder River; central images, larger emblems, 16-per-side cap and three-slot visual convoy builder. See sandbox-maps-04 and tools/sandbox_maps_20260915/README.md. Freight Exchange is a separate concurrent map scope; use its newest entry below. Doble Ocho final video remains delivered.',text,count=1)
  text=re.sub(r'\*\*Immediate next task:\*\*[^\n]*','**Immediate next task:** Owner reopens live-source Dead Street Sandbox to test map selection, presets and convoy building. Native mouse, legal seating/packing and four-map 16v16 starts pass; large-battle performance still requires review. Preserve concurrent Freight night/rain work and use its newest handoff for continuation.',text,count=1)
  old='- Two maximum legal convoys remain the battle ceiling. Three vehicles per\n  convoy, legal combinations and final personnel cap are undecided. Raiders now pack up to three motorcycles per slot; this does not settle the global cap.\n- Production remains 12 units per side; larger test fixtures do not change it.'
  new='- Owner-set sandbox rules now enforce 16 units per side and three convoy slots. Stateline/Blacktop/NBPD/TRC may pack three motorcycles per slot. This supersedes the former undecided/12-unit live-state notes.\n- Actual 16v16 starts on the four existing maps pass. Stable 60 FPS at that cap is not certified; existing bridge/Harold cover fallback counts are recorded in sandbox-maps-04. Freight tests belong to its separate pass.'
  text=text.replace(old,new,1)
  text=text.replace('| Individual force/loadout setup | [Sandbox README](../tools/sandbox_setup/README.md) |','| Individual force/loadout setup and current convoy limits | [Current sandbox refresh](../tools/sandbox_maps_20260915/README.md), then historical [Sandbox README](../tools/sandbox_setup/README.md) |',1)
  marker='| BUILD / fourth map |'
  if '| BUILD / sandbox refresh |' not in text:
   at=text.index(marker);text=text[:at]+'| BUILD / sandbox refresh | Central map images/names, full-width setup, larger emblems, 16-unit cap and visual three-slot convoys | COMPLETE / native-validated / owner review. See sandbox-maps-04 and tools/sandbox_maps_20260915/README.md. Preserve concurrent Freight additions; no commit/push by this pass. |\n'+text[at:]
 assert path.read_bytes()==before,'Concurrent documentation changed: '+name
 path.write_text(text,encoding='utf-8')
print('Updated README, receipt, scope snapshot, Hive Mind, Journal and Project Control without replacing concurrent entries.')
