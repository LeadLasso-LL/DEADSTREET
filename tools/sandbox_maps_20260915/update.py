from pathlib import Path
import json,hashlib,sys
r=Path(__file__).resolve().parents[2];out=Path(__file__).parent
payload=json.loads((out/'update.json').read_text(encoding='utf-8'));installed=json.loads((out/'installed.json').read_text())
for rel,text in payload.items():
 p=r/rel
 if p.exists():assert rel in installed and hashlib.sha256(p.read_bytes()).hexdigest()==installed[rel],rel+' changed concurrently'
for rel,text in payload.items():
 p=r/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(text,encoding='utf-8');installed[rel]=hashlib.sha256(p.read_bytes()).hexdigest()
(out/'installed.json').write_text(json.dumps(installed,indent=2));print('Updated',len(payload),'guarded files')
entry="\n\n## 20260915-sandbox-maps-03 - Native layout and convoy integration pass\nInstalled central map selector, responsive full-width menu,80px faction emblems,16-unit cap,3-slot convoy rules and image-driven fleet picker. Native302checks pass: all4presets and16v16actual starts on all4maps; legal seats/drivers; noncontiguous3-bike packing forStateline/Blacktop/NBPD/TRC; fourthRoadwarden/insufficient final-seat/driver additions blocked; removals reenable valid additions.31/32Harold and28/32bridge actors occupy cover at16; all32estate/yard; existing deployment fallback retained. Not a32-unitperformance certification. Next real map-thumbnail bake, visual layout/mouse review, mixed bike convoy startup checks. Current source/audio preserved by hash guards; no staging/push.\n"
for name in ['DEAD_STREET_HIVE_MIND.md','DEAD_STREET_JOURNAL.md','DEAD_STREET_PROJECT_CONTROL.md']:
 p=r/'docs'/name;t=p.read_text(encoding='utf-8')
 if '20260915-sandbox-maps-03' not in t:p.write_text(t+entry,encoding='utf-8')
