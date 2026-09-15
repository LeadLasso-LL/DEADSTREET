from pathlib import Path
import hashlib,json,re,subprocess,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1]
report=json.loads((out/'after_report.json').read_text())
before=json.loads((out/'before_report.json').read_text())
assert not report['errors'],report
other=json.loads((out/'other_maps_report.json').read_text());assert not other['errors'],other
for log in ['arsenal_bake.log','arsenal_import.log','after_final.log','screenshot.log','other_maps.log']:
    text=(out/log).read_text(encoding='utf-8')
    assert 'SCRIPT ERROR' not in text and '\nERROR:' not in text,log
assert (out/'DEAD_STREET_Harold_Updated.png').exists()
sources=['battle/geometry/harold_street_catalog.gd','gameplay/harold_street_art.gd','battle/vehicles/battle_arrival_service.gd','tools/dusk_review/bake_harold_frontage.gd','assets/art/harold_frontage/ground.png','battle/ai/battle_vehicle_deployment_planner.gd','battle/vehicles/battle_vehicle_placement_context.gd']
markers=json.loads((out/'import_recovery.json').read_text())['ignored_evidence_folders']
files=sources+[x+'/.gdignore' for x in markers]+['tools/harold_scale_20260915/scaled_legacy_baseline/.gdignore','tools/harold_scale_20260915/door_clearance_baseline/.gdignore','tools/harold_scale_20260915/check.gd','tools/harold_scale_20260915/check_other_maps.gd']
head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip()
branch=subprocess.check_output(['git','branch','--show-current'],cwd=r,text=True).strip()
index=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).strip()
assert not index,'Another writer has staged work; do not touch it.'
hashes={name:hashlib.sha256((r/name).read_bytes()).hexdigest() for name in files}
view_hash=hashlib.sha256((r/'gameplay/tactical_battle_view.gd').read_bytes()).hexdigest()
assert view_hash=='c3dd91ae5bd1f4dd3e2a243c3e168635563070c4b9f506c3e193399a8b7578d0','Shared view changed; inspect before claiming preserved'
(out/'source_delta.patch').write_bytes(subprocess.check_output(['git','diff','--',*sources],cwd=r))
subprocess.run(['git','diff','--check','--',*sources],cwd=r,check=True)
receipt={'status':'implemented_native_validated_owner_review_pending','head':head,'branch':branch,'index_empty':not index,'source_hashes':hashes,'preserved_view_sha256':view_hash,'screenshot_sha256':hashlib.sha256((out/'DEAD_STREET_Harold_Updated.png').read_bytes()).hexdigest(),'publication':'No staging, commit or push performed for Harold. Prior range/portrait publication blockers remain separate.','before_report':before,'after_report':report}
(out/'completion_receipt.json').write_text(json.dumps(receipt,indent=2))
receipt['other_maps_report']=other
(out/'completion_receipt.json').write_text(json.dumps(receipt,indent=2))
summary=f'''Harold Apartments now uses12 actual Arsenal parked vehicles with model-specific1.6x physical footprints and the shared fleet renderer. Cheap Rattleback/Bayou cars, Workhorse, Courier and Civicline dominate; Cabrillo Lowline and Rancher Seven immediately by Saints HQ are the two modest upgrades (canonical Mercer preferences). Road widened12 to20 units (y23..43), lower sidewalk/building strip/lamps/litter shifted8; north frontage unchanged. Ground cache rebaked3456x1848. Three arrival options now allocate the full enlarged convoy length rather than the obsolete x31 lower bound. Unit scale, HUD/camera code and shared range feature preserved.

Native Windows Godot4.7.2 validation: {report['checks']} checks, zero failures. All12 canonical parked sprites/anchors/footprints checked, no static overlaps, all three heavy-convoy arrival choices clear of parked scenery, all12 transported attackers have exit routes, all available cover slots plus both entrances/alley/lower-walk endpoints reachable. Final bake/import/native logs contain zero script/engine errors. Screenshot uses a separate paused12v12 Orlov/Mercer scene with faction-appropriate Taiga/Bayou/Outlander arrivals. Assistant visually reviewed; owner appearance acceptance pending.

Harold also supplies1.52 units of authored vehicle padding for fully open doors; the shared context/planner retains its previous0.6 default everywhere else. This fixes the native Taiga/Bayou door-to-neighbor body overlap found during screenshot capture. Bridge/estate native setup/start and unchanged-clearance smokes pass{other['checks']} checks. New planner/context source was clean before editing; guarded backups preserve it. The test fixture now reopens both sides before cycling arrival options, avoiding stale defender ownership of moved vehicle cover; no collision or ownership checks were weakened.

Bounded before/after native combat observations: before frame median/p95 {before['frame_ms_median']:.3f}/{before['frame_ms_p95']:.3f}ms and advance median/p95 {before['advance_ms_median']:.3f}/{before['advance_ms_p95']:.3f}ms over {before['seconds']:.2f}s; after {report['frame_ms_median']:.3f}/{report['frame_ms_p95']:.3f}ms and advance {report['advance_ms_median']:.3f}/{report['advance_ms_p95']:.3f}ms over {report['seconds']:.2f}s ({report['battle_phase']} at cutoff). These are bounded native samples with changed geometry and concurrent project work, not a sustained60FPS promise or a full benchmark. Whole-project legacy regression suite and every fleet combination were not run.

Earlier failed attempts are retained: art identifier typo fixed; first full import timed out and exposed12 backup scripts shadowing canonical global classes; evidence folders excluded from Godot import via .gdignore, backups preserved and generated cache repaired. Clean subsequent editor import verifies the durable fix. Initial arrival test was checking an already-committed sandbox; corrected isolated fixture then exposed the real Close/Medium placement-width limit, now fixed. See import_recovery.json and logs.

Evidence/reproduction/source hashes: tools/harold_scale_20260915/README.md and completion_receipt.json. Current HEAD {head}, branch {branch}, index empty. Concurrent faction-audio publication advanced HEAD from baseline d262e8f; that work was preserved. No staging/commit/push for this map pass. Next: owner reviews screenshot, then reopen the normal live-source Sandbox to play; prior publication blockers remain separately recorded.'''
readme='''# Harold Apartments — vehicle proportions and Arsenal neighborhood pass

'''+summary+'''

## Reproduction

- Ground only: Godot --path REPO --script res://tools/dusk_review/bake_harold_frontage.gd -- --ground-only
- Import: Godot --headless --editor --import --path REPO (archive .gdignore markers must remain).
- Native checks: Godot --path REPO --script res://tools/harold_scale_20260915/check.gd
- Screenshot: same command followed by -- --screenshot.
- Engine: C:/Users/brand/OneDrive/Documents/Godot/Godot_v4.7.2-stable_win64.exe, NVIDIA GTX1650 Max-Q, native1440x1000 window.
- Final authority: after_report.json, after_final.log, arsenal_bake.log, arsenal_import.log, screenshot.log, DEAD_STREET_Harold_Updated.png.
- Before artifacts: before_report.json, before_ready.png, before_combat.png, baseline/ and baseline_hashes.json. prepare.py embeds the exact original baseline probe. Failed/intermediate records remain historical and are not final validation.
- Installer scripts are historical guarded transformations, not scripts to rerun over current source.

## Parked roster

| Curb / west to east | Arsenal model |
| --- | --- |
'''
models=json.loads((r/'assets/data/vehicle_models.json').read_text())['models']
for slot,model,x in json.loads((out/'parked_manifest.json').read_text()):
    readme+=f'| {slot} (x{x:g}) | {models[model]["name"]} |\n'
(out/'README.md').write_text(readme,encoding='utf-8')
entry='\n\n## 20260915-harold-scale-07 - Complete locally; native-validated\n\n'+summary+'\n'
for name in ['docs/DEAD_STREET_JOURNAL.md','docs/HAROLD_AVE_IMPLEMENTATION.md']:
    with (r/name).open('a',encoding='utf-8') as f:f.write(entry)
short=f'\n\n## 20260915-harold-scale-07 - Harold Arsenal vehicles and widened street complete\nIMPLEMENTED / NATIVE-VALIDATED:12 actual Arsenal parked vehicles, mostly poor-neighborhood models with Cabrillo/Rancher upgrades by HQ; shared1.6x per-model cover footprints, road20 units wide, lower streetscape shifted coherently and three arrival choices corrected for convoy length. {report["checks"]} native checks pass, zero final errors; screenshot inspected, owner review next. Backups preserved; .gdignore import hygiene fixes historical duplicate-class registration. See tools/harold_scale_20260915/README.md, completion_receipt.json and journal harold-scale-07. Reopen normal live-source Sandbox. No Harold commit/push; concurrent audio/portrait/range work preserved.\n'
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_PROJECT_CONTROL.md']:
    with (r/name).open('a',encoding='utf-8') as f:f.write(short)
with (r/'docs/MAP_BUILDING_STANDARD.md').open('a',encoding='utf-8') as f:
    f.write('\n\n## Harold parked-vehicle standard — 2026-09-15\nSupersedes the earlier5.15x2.1 generic sedan scale for Harold curb traffic: use VehicleModelCatalog model length/width times TACTICAL_SCALE (currently1.6) and fleet_vehicle_art.gd at the same ground-centre anchor. Keep artwork, obstacle rectangles, cover slots and baked shadows aligned. The12 chosen models and positions are authored in HaroldStreetCatalog.PARKED_CARS. Mostly inexpensive neighborhood transport; Cabrillo Lowline/Rancher Seven are the two modest HQ upgrades. Road is20 units wide and both sidewalk curbs/props follow catalog geometry. Legacy generic-sedan10% height treatment does not apply to canonical fleet sprites. Detailed evidence: tools/harold_scale_20260915/README.md.\n')
hive=r/'docs/DEAD_STREET_HIVE_MIND.md';original=hive.read_bytes();text=original.decode('utf-8-sig')
text,n=re.subn(r'\*\*Active objective \(2026-09-15\):\*\*[^\n]*','**Active objective (2026-09-15):** Harold Apartments vehicle/street pass is implemented and native-validated; owner screenshot review next. Twelve Arsenal parked vehicles reflect the poor Mercer neighborhood with two modest HQ upgrades. See harold-scale-07 and tools/harold_scale_20260915/README.md. Individual/class-group range work remains complete; parallel portrait and faction-audio state is governed by their latest dated entries below.',text,count=1);assert n==1
text,n=re.subn(r'\*\*Immediate next task:\*\*[^\n]*','**Immediate next task:** Owner reviews the updated Harold screenshot and plays via the existing live-source Sandbox launcher. Continue any new feedback from the current source; preserve other chats\' work. Faction-audio interior-filtering gap and earlier feature publication blockers remain with their owning entries.',text,count=1);assert n==1
text=re.sub(r'\| Existing BUILD chat \|[^\n]*',f'| BUILD / Harold pass | Harold vehicles/street and prior estate feedback | Harold complete locally: {report["checks"]} native checks plus {other["checks"]} bridge/estate checks pass; screenshot ready for owner review. Accepted estate and range work preserved. See harold-scale-07. |',text,count=1)
assert hive.read_bytes()==original,'Concurrent hive update; rerun only the fresh paragraph merge.'
hive.write_text(text,encoding='utf-8',newline='\n')
print(json.dumps({'checks':report['checks'],'errors':report['errors'],'head':head,'screenshot_sha256':receipt['screenshot_sha256'],'records_saved':True},indent=2))
