from pathlib import Path
import json,hashlib,subprocess
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(*a):return subprocess.check_output(['git',*a],cwd=R).decode('utf-8').strip()
receipt=json.loads((O/'installed.json').read_text())
native=json.loads((O/'smoke.json').read_text())
assert native['checks']==6178 and not native['errors']
assert all(sha(R/p)==v for p,v in receipt['after'].items())
assert all(sha(R/p)==v for p,v in receipt['asset_hashes'].items())
models=json.loads((R/'assets/data/weapon_models.json').read_text())['models']
before=json.loads((O/'before/assets/data/weapon_models.json').read_text())['models']
assert {k:{a:b for a,b in v.items() if a!='price'} for k,v in models.items()}=={k:{a:b for a,b in v.items() if a!='price'} for k,v in before.items()}
pricing='''# Firearm acquisition prices — 2026-09-15

Status: authored initial balance, implemented in game data and Arsenal; campaign economy playtesting remains the tuning authority. Prices are fictional gameplay values, not retail firearm estimates.

`assets/data/weapon_models.json` owns runtime prices. `BattleWeaponCatalog.purchase_price(model_id)` is the shared quote API; unknown IDs return -1 (invalid quote). Arsenal tiles and detail panel use that API. `tools/arsenal_production/weapon_pricing.py` preserves these authored values when rebuilding the catalog. Recruitment/training and ammunition are separate. This change does not add a shop or change combat statistics.

Accessible base pistols and pump shotguns provide early equipment choices. Rifle/SMG/sniper premiums buy role-specific reach, handling, cadence and sustained damage; higher tiers cost substantially more without making every weapon of a tier identical. Existing armor brackets ($300/$750/$1,500) and early vehicle costs ($1,400/$3,800/$4,200) anchor the scale: top guns compete with squad protection and transport budgets.

Within-role choices: CZ 75 accuracy/cadence commands a modest USP premium; Desert Eagle recoil/handling keeps it below Five-seveN. MP5K trades reach for price; P90 costs above Vector for mobile reach, while Vector specializes in close burst. Mini-14 is below AK-47; shorter-range G36C below M4A1; SCAR-H hard hits above AUG control. Mossberg is the affordable short-range pump; M2 mobility above SPAS-12; Saiga below M4 for recoil/reach tradeoffs. SKS is an accessible marksman option, AWM buys extreme reach and PSG1 sustained semiautomatic output.

| Class | Firearm | Price |
|---|---|---:|
'''
for kind in ['pistol','smg','shotgun','rifle','sniper']:
 for m in sorted((m for m in models.values() if m['weapon_class']==kind),key=lambda m:m['price']):pricing+=f"| {kind.upper()} | {m['name']} | ${m['price']:,} |\n"
pricing+='\nTune after observing acquisition timing, replacement costs and squad loadout diversity. Avoid a pure damage-per-second formula: reach, movement, reload exposure, recoil and protection budgets affect usefulness.\n'
(R/'docs/WEAPON_PRICING.md').write_text(pricing,encoding='utf-8')
readme='''# Portrait and Arsenal continuation — completed 2026-09-15

Owner requested completion after the previous conversation exhausted context. Implemented in the live-source sandbox; owner appearance acceptance and economy playtesting remain separate.

- Recovered the exact approved 20-leader gallery, bound complete-frame 288x359 photo derivatives to the upper-right faction header. Manifest records source/output SHA256 and source gallery Library identity/version. Conditional merger leaders remain undisclosed.
- Installed 691 fixed 90x80 standing portraits: 23 factions x30 weapons plus Mercer dual-Glock specialist. All 691 reviewed visually on 23 fixed-scale boards in `review/`. No remaining obvious detached shoulders/limbs or noticeable anatomy fault observed in these standing cards. This is not a claim about every animation/facing. Unit atlases were not rebuilt.
- Recovered source finishing adapter joins shoulder roots and whole elbow-to-hand forearms while preserving body/torso/lower-body/muzzle signatures across 1,382 SW/SE structural checks. Most earlier files were only candidates. Tight 64x50 Mercer/Orlov base crops caused enlarged UI figures; all card canvases now share scale. Specialist baseline differs from stale installed art and was reviewed separately (`review/specialist_before_after.png`).
- All 75 vehicles sort ascending purchase price within each existing category; equal prices sort by name. No vehicle price/stat changes.
- All 30 firearms have canonical game prices and identical Arsenal quotes; combat data is unchanged. See `docs/WEAPON_PRICING.md`.
- Editable display-art pass improves first pistol frame/trigger guard, pistols/SMGs and restrained long-gun material detail. Normal icon generation imports `weapon_display_art.py`; all 30 SVG sources and PNG icons refreshed. This changes close-up illustrations, not unit animation weapons/rigs.

## Validation and evidence

Official Windows Godot 4.7.2, native D3D12: **6,178 checks, zero failures** (`smoke.json`, `native.log`). Tested 23 faction pages/115 visible paired cards, all 20 photo bindings, all 30 prices/spec panels, all 75 vehicle entries/order, all 691 imported portrait textures, desktop navigation at 1152x860, 1280x720 and 1440x1000, fleet/tutorial/setup preservation, and one launch/return without battle simulation. Native screenshots are saved alongside this report. All five gun boards were visually reviewed. Gun detail strokes outside a wood stock and small stray pistol highlights were corrected before final rendering.

Raw PNG comparison applies Godot's configured `fix_alpha_edges()` before byte comparison, exactly matching lossless texture import processing. All 741 affected texture imports refreshed. Warnings from diagnostic `Image.load_from_file` are expected in this development-only harness; production uses imported textures.

Initial harness failed because global input injection mismatched Windows coordinates; corrected to viewport-local `root.push_input(e,true)`. Second attempt flagged transparent-edge RGB processing and an unsupported 390px Windows window request. Corrected import-parity comparison and tested the three actual supported desktop sizes. Failed logs retained as `native_attempt1.log` / `native_attempt2.log`; do not mistake them for final results. No production input workaround or phone-support claim.

## Reproduction and handoff

Native check: Godot `--path <repo> --script res://tools/sandbox_finish_20260915/check_native.gd -- --fast`.

`tools/portrait_audit_20260914/run_build.py` plus worker/anatomy/render sources regenerate standing candidates and structural evidence. It generates candidates, not installed outputs. For future source changes regenerate from the then-current portrait inventory, review fixed-scale SW/SE candidates, then explicitly install each candidate at the inventory portrait path. Keep 90x80 crops and the anatomy adapter; do not overwrite corrected cards with tight or uncorrected atlas crops. The takeover installer is deliberately single-use and guards original hashes; do not rerun it on updated content.

`finish_assets.py` renders icons and refreshes isolated texture imports; it does not generate source SVGs. For display-art regeneration call `weapon_art.make(model, build_art.ORIGINAL)`, `make_display_icon(model, art)`, then `build_art.save_svg` into `assets/art/weapons/arsenal/source/<id>.svg`; normal full `build_art.py` also uses the module. Do not rebuild all unit atlases for an icon edit. Catalog regeneration retains prices via `weapon_pricing.py`.

`installed.json` contains before/after hashes and all affected asset paths. `before/` retains prior files locally. Publication scope explicitly excludes transfer payloads, caches and unrelated music/opening/BUILD work. Reopen the normal Dead Street Sandbox desktop launcher to load changes. Publication result is recorded separately; native completion does not imply owner acceptance.
'''
(O/'README.md').write_text(readme,encoding='utf-8')
entry='''## 20260915-portrait-arsenal-takeover-03 — Completed and native-validated

Owner continuation is complete in the live-source sandbox: 20 approved leader photos installed top right; 691 standing portraits normalized and visually reviewed with no remaining obvious detached shoulders/limbs observed; 75 vehicles price-sorted within existing categories; 30 canonical firearm prices displayed in Arsenal; all 30 close-up gun icons refined, especially pistol triggers/guards and SMGs. Exact prices/rationale are in docs/WEAPON_PRICING.md. Combat statistics and animation atlases remain unchanged. This certifies the reviewed standing-card scope, not unreviewed animation frames or final economy balance.

Final Windows Godot native validation: 6178 checks, zero failures. All 691 native imported portrait images match source after normal alpha-edge processing; 20 leader textures, 115 displayed role cards, 30 weapons, 75 sorted vehicles, three desktop sizes, setup/fleet/tutorial navigation and launch/return checked. Initial harness failures and fixes are documented; final smoke.json is authoritative. Source/asset hashes verified. All 23 standing boards and five weapon boards visually inspected, along with native faction/Arsenal screens. Small stray gun detail strokes were cleaned before final import/render. Evidence, reproducible scripts, source/photo provenance and review limits: tools/sandbox_finish_20260915/README.md.

Current task ownership moves to COMPLETE / OWNER REVIEW. Reopen the existing desktop Sandbox launcher to load. Publication receipt will state actual Git status; do not infer publication from this local completion. Concurrent soundtrack (now 22 tracks/21 loops), selected-range, estate and opening work preserved. No further implementation required for this requested scope before owner review.
'''
art='''## All-loadout standing-card continuity — 2026-09-15

All standing cards use the fixed 90x80 canvas and shared body scale, including Mercer/Orlov base roles. Preserve continuous shoulder roots and elbow-to-hand forearms from tools/portrait_audit_20260914/portrait_anatomy.py; the takeover reviewed all 691 installed standing cards. Future full builds must regenerate/review/reapply this standing-card finishing pass instead of replacing it with an uncorrected or tight atlas crop. Crop rules, source adapter, exhaustive review evidence and native import parity are in tools/sandbox_finish_20260915/README.md. This extends the pistol continuity rule; it does not certify all animation frames.
'''
milestone='''# Current milestone — portrait and Arsenal continuation — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED; owner visual review and economy playtesting remain. All 20 approved leader photographs installed upper right; all 691 standing portraits reviewed and normalized; 75 vehicles ordered by ascending price within category; 30 canonical firearm prices integrated in Arsenal; gun close-ups refined with emphasis on pistols/SMGs. Native 6178 checks PASS. No combat-stat or animation-atlas changes. Exact evidence, review scope and continuation: tools/sandbox_finish_20260915/README.md and journal portrait-arsenal-takeover-03. Reopen normal live-source sandbox. Publication status is separate in the task receipt. Other milestones below remain valid for their own scopes.
'''
doc_deltas={}
for rel,block,prepend in [('docs/DEAD_STREET_JOURNAL.md',entry,False),('docs/DEAD_STREET_HIVE_MIND.md',entry,False),('docs/UNIT_ART_STANDARD.md',art,False),('docs/DEAD_STREET_PROJECT_CONTROL.md',milestone,True)]:
 p=R/rel;raw=p.read_text(encoding='utf-8-sig')
 if block.splitlines()[0] not in raw:p.write_text(block+'\n'+raw if prepend else raw.rstrip()+'\n\n\n'+block,encoding='utf-8')
 doc_deltas[rel]={'block':block,'prepend':prepend}
(O/'owned_doc_deltas.json').write_text(json.dumps(doc_deltas,indent=2),encoding='utf-8')
core=list(dict.fromkeys(receipt['changed']+receipt['asset_paths']+['tools/arsenal_production/weapon_pricing.py','tools/arsenal_production/weapon_display_art.py']))
extras=['docs/WEAPON_PRICING.md']
extras += [str(p.relative_to(R)).replace('\\','/') for p in O.glob('*') if p.is_file() and (p.suffix in ['.py','.gd','.png'] or p.name in ['README.md','installed.json','leader_manifest.json','smoke.json','owned_doc_deltas.json','native.log','native_attempt1.log','native_attempt2.log','render_icons.log'])]
extras += [str(p.relative_to(R)).replace('\\','/') for p in (O/'review').glob('*.png')]
for name in ['run_build.py','worker.py','portrait_anatomy.py','render.gd','inventory_before.json','inventory.json','build_validation.json']:
 p=R/'tools/portrait_audit_20260914'/name
 if p.exists():extras.append(str(p.relative_to(R)).replace('\\','/'))
scope=list(dict.fromkeys(core+extras))
for rel in list(core):
 if (R/(rel+'.import')).exists():scope.append(rel+'.import')
scope=list(dict.fromkeys(scope))
baseline_conflicts=[]
for rel in receipt['before']:
 try:head=subprocess.check_output(['git','show','HEAD:'+rel],cwd=R,stderr=subprocess.DEVNULL)
 except subprocess.CalledProcessError:continue
 if hashlib.sha256(head).hexdigest()!=receipt['before'][rel]:baseline_conflicts.append(rel)
report={'head':git('rev-parse','HEAD'),'branch':git('branch','--show-current'),'origin':git('remote','get-url','origin'),'native':native,'scope':scope,'hashes':{p:sha(R/p) for p in scope},'baseline_differs_from_head':baseline_conflicts,'publication':'prepared; not yet attempted'}
(O/'publication_plan.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps({'records':'saved','scope_files':len(scope),'baseline_conflicts':baseline_conflicts,'head':report['head'],'native_checks':native['checks']}))
