from pathlib import Path
import subprocess,json,shutil,zipfile,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');d=r/'tools/tactical_controls/hud_fixed_20260914';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
rows=json.loads((d/'source_payload.json').read_text(encoding='utf-8'))
for row in rows:
 p=r/row['path'];assert (not p.exists()) if row['original'] is None else (p.read_text(encoding='utf-8').rstrip()==row['original']),('Source changed',row['path'])
assert not (d/'preinstall_all.zip').exists()
with zipfile.ZipFile(d/'preinstall_all.zip','w',zipfile.ZIP_DEFLATED) as z:
 for row in rows:
  p=r/row['path']
  if p.exists():z.write(p,row['path'])
 for folder in ['assets/art/whittaker_estate','assets/audio/convoy']:
  for p in (r/folder).rglob('*'):
   if p.is_file():z.write(p,p.relative_to(r).as_posix())
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write("\n\n## 20260914-active-resume-10 - Fence, assault arrival and three-person flank; first implementation\n\nAdditional owner directions: finish the lower estate fence, leaving a garage-aligned opening with a visible open gate; arriving attackers must immediately occupy opening cover before combat. TRC vehicles should make an assault approach over grass with useful diagonal/sideways positions, using vehicles and front fencing as initial shelter. Brandon also suggested a three-person TRC flank to the new lower gate. Implement as this estate showcase order, not a forced rule for every battle; ordinary player movement can replace it.\n\nCurrent implementation pass: fixed 226-logical-unit bridge HUD with scale bounded by 1152x800 reference dimensions, condensed two-row cards; faction voice service/assets moved out of runtime into tools/parked_faction_voices; original archive/history retained. New procedural broken TRC warning siren replaces horn, engine and Whittaker music sources preserved. Complete lower fence and outward-open service gate, usable outside verge, oriented vehicle parking, legal occupied vehicle/fence cover for all attackers. Showcase carries three mixed-role flankers in rear transport and issues one replaceable navigation path through gate. No simulation teleport or forced winner. Native geometry/layout validation starting; no acceptance claimed yet.\n")
p=r/'docs/DEAD_STREET_HIVE_MIND.md';s=p.read_text(encoding='utf-8');s=s.replace('replace TRC foghorn with a broken warning siren while preserving driving audio.','replace TRC foghorn with a broken warning siren while preserving driving audio, complete the lower fence/gate, and rebuild covered assault arrival plus a three-person showcase flank.',1);p.write_text(s,encoding='utf-8')
for row in rows:
 p=r/row['path'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(row['updated'].encode('utf-8'))
park=r/'tools/parked_faction_voices';park.mkdir(exist_ok=True);shutil.move(str(r/'gameplay/tactical_faction_voices.gd'),str(park/'tactical_faction_voices.gd'));shutil.move(str(r/'assets/audio/factions'),str(park/'factions'));shutil.move(str(r/'assets/audio/convoy/trc_horn.wav'),str(park/'superseded_trc_horn.wav'))
(park/'README.md').write_text('PARKED by Brandon, 2026-09-14. All faction vocals removed from active battle playback and runtime packaging. Premise/source/converted clips remain here for recovery only; no expansion or replacements are active tasks. Original full package: Dead_Street_Faction_Voices_07.zip, Library libfile_614e18fa06dc8191ba91a0a13a240247. The old TRC horn is also preserved here; its replacement is an original broken warning siren.\n',encoding='utf-8')
(r/'tools/whittaker_estate/owner_feedback_20260914').mkdir(exist_ok=True)
print('SOURCE_INSTALLED; voices parked; unrelated work preserved',flush=True)
def run(args,label,timeout=120):
 result=subprocess.run(args,cwd=r,capture_output=True,timeout=timeout);t=(result.stdout+result.stderr).decode('utf-8',errors='replace');(d/(label+'.log')).write_bytes(t.replace('\r','').encode());bad=result.returncode or any(k in t for k in ['SCRIPT ERROR','HUD_FAIL','ESTATE_FAIL','CONTROLS_FAIL']);print(label,'exit',result.returncode,'errors',bool(bad),t[-7000:] if bad else t[-1200:],flush=True);assert not bad,label
run([sys.executable,str(r/'tools/whittaker_estate/build_trc_siren.py')],'siren')
run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'pack')
run([str(base/'godot.exe'),'--headless','--','--check=estate_geometry'],'geometry')
run([str(base/'godot.exe'),'--','--check=hud_layout_review'],'hud_layout')
run([str(base/'godot.exe'),'--','--check=line_native'],'line_native')
print('INITIAL_NATIVE_GATES_COMPLETE',flush=True)
