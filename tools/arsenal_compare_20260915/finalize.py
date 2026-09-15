from pathlib import Path
import hashlib,json,subprocess
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def git(*args):return subprocess.check_output(['git',*args],cwd=R)
report=json.loads((O/'native_validation.json').read_text())
assert report['checks']==3736 and report['errors']==[] and report['guns']==30 and report['vehicles']==75
core=['gameplay/sandbox_glossary_panel.gd','gameplay/sandbox_force_builder.gd','gameplay/equipment_comparison.gd']
protected=['battle/combat/battle_weapon_catalog.gd','campaign/vehicles/vehicle_model_catalog.gd','assets/data/vehicle_models.json','gameplay/faction_audio_preview.gd','gameplay/sandbox_menu_panels.gd']
assert not git('diff','HEAD','--',*protected), 'Protected source changed; inspect ownership before publishing'
diff=git('diff','--',*core)
assert b'func show_faction' not in b'\n'.join(line for line in diff.splitlines() if line.startswith((b'+',b'-')))
(O/'source_diff.patch').write_bytes(diff)
git('diff','--check','--',*core)
(O/'validated_sources.json').write_text(json.dumps({p:sha(R/p) for p in core+protected},indent=2))
readme='''# Sandbox equipment comparison and SMG casing — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. Reopen the usual live-source Sandbox launcher.

## Owner request and behavior

Brandon requested uppercase SMG in force composition, then direct gun comparisons by clicking one and hovering another. He extended the same interaction to Vehicles while implementation was underway.

- SMG is uppercase in both sides' Add Unit pickers, every existing unit class picker and the unit tooltip. Internal class IDs remain unchanged.
- In Arsenal or Vehicles, click an item to select the baseline; hover another for a side-by-side comparison with signed **hovered minus selected** differences. Before an explicit click, the page retains its ordinary single-item details.
- Baselines persist across class/category tabs and are independent for guns and vehicles. Click another item to replace the baseline. Hover the selected item to restore its normal details. Changing categories or leaving the page clears the hovered comparison but retains the selection.
- The last hovered comparison stays visible when the pointer enters the detail pane, so its full stat list can be scrolled without disappearing.
- Green marks a beneficial change, red a drawback, and an em dash means no displayed change. Lower cost, aim/reload time, recoil per shot and miss chance are beneficial. Graze probability, vehicle dimensions and door counts remain neutral tradeoffs. Percentage deltas use percentage points, not relative percentages. Rounded zero never renders as negative zero.
- Guns compare all 17 existing Arsenal stats from BattleWeaponCatalog. Their normal detail rows use the same formatter and source values. Vehicles compare ten common stats: price, seats including driver, road movement, upkeep, resource capacity, cover, doors and three dimensions. Cover is Yes/No and Added/Lost. Special cash/custody capacities and ability descriptions/limits are shown beneath the common vehicle comparison as applicable.

## Scope and evidence

Runtime: gameplay/equipment_comparison.gd plus narrow changes to sandbox_glossary_panel.gd and sandbox_force_builder.gd. No tuning, prices, catalogues, audio, portraits, vehicle ordering or gameplay behavior changed. Existing glossary Faction Audio source and lifecycle wiring remain untouched. Preserve concurrent Harold HQ-car/range/opening work.

Official Windows Godot 4.7.2, D3D12 Forward+, GTX 1650 Max-Q: **3,736 checks passed, zero failures**, native process exit 0 and no engine/script errors. Checks cover all 30 guns and 75 vehicles against canonical values, signed differences, all 75 vehicle price-order positions, actual clicks and hovers, cross-category baselines, reselection, scroll persistence, page cleanup, SMG pickers, neutral tradeoffs and formatting. Comparison layout checked at 1152×860, 1280×720 and 1440×1000. No battle/performance benchmark or subjective owner acceptance claimed.

Visually inspected the SMG setup, cross-class gun and vehicle comparisons, scrolled gun stats, 720p layout and bank-vehicle special-role detail. Screenshots, native_validation.json and native.log are here. Reproduce with official Godot `--path <repo> --script res://tools/arsenal_compare_20260915/check_native.gd`. The fixture runs an isolated scene and does not save owner preferences.

## Continuation and publication

before/ and baseline.json preserve clean original affected sources; before/.gdignore excludes backups from Godot imports. install.py is a guarded, single-use installer, not a script to rerun on current live source. source_diff.patch and validated_sources.json document final changes. Shared-record staging uses only this task's owned additions against the latest HEAD; do not stage the mixed working documentation wholesale.

Previous Faction Audio checkpoint 50a000753b04c7115bfeef48cb46dea0b2ddbbd4 was explicitly approved, pushed and verified. No prior publication blocker remains. This comparison checkpoint's actual publication outcome is in publication_receipt.json. Implementation and native verification are complete; reopen normal Sandbox for owner review.
'''
(O/'README.md').write_text(readme,encoding='utf-8')
done='''## 20260915-arsenal-compare-02 - Gun and vehicle comparison complete and validated

IMPLEMENTED / NATIVE-VALIDATED: SMG uppercase in both force-builder Add Unit selectors, existing unit rows and tooltips. Arsenal and Vehicles now use clicked baselines and hover comparisons across class/category tabs. Both source values and signed hovered-minus-selected differences shown; green benefits, red drawbacks, neutral tradeoffs, unchanged em dash, percentage-point deltas. Last hovered comparison persists for scrolling; new click changes baseline; hover selected restores details; page/category change clears hover while preserving selected baseline. Guns compare 17 stats; vehicles compare 10 common stats with applicable special-role/capacity and ability details below. Source values remain canonical; no combat/economy/art/audio changes.

3,736 native Windows Godot checks PASS, zero failures, exit 0/no engine-script errors: all 30 gun and 75 vehicle source values/deltas, price ordering, actual click/hover and cross-category controls, selection/scroll/page lifecycle, SMG labels, formatting and three desktop layouts. Six relevant screenshots visually inspected. No battle benchmark, full regression suite or owner appearance acceptance implied. README/evidence/commands/protected hashes: tools/arsenal_compare_20260915/. Only gameplay/equipment_comparison.gd, glossary equipment UI and force-builder presentation are owned. Faction Audio source/lifecycle, catalogues, ordering and concurrent Harold/range/opening work preserved.

Owner's in-turn vehicle extension is fulfilled. Previous Faction Audio 50a0007 is pushed/remote verified. Current comparison publication outcome is separate in publication_receipt.json. Next: reopen live-source Sandbox and review; implementation is complete. Scoped publisher preserves other chats' working records and source edits.
'''
milestone='''# Current milestone - gun and vehicle comparison / SMG labels - 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED: click to select a gun or vehicle; hover another to compare both values and signed changes across categories. SMG uppercase throughout force selection. 3,736 native checks PASS for 30 guns / 75 vehicles and three layouts. No stat/economy changes. Evidence, interaction rules, scope and continuation: tools/arsenal_compare_20260915/README.md and journal arsenal-compare-02. Current publication receipt records actual Git outcome; prior Faction Audio 50a0007 is published. Reopen Sandbox for owner review.
'''
start=json.loads((O/'owned_doc_deltas.json').read_text())['start']
deltas={}
for rel in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    p=R/rel;s=p.read_text(encoding='utf-8-sig')
    if done.splitlines()[0] not in s:p.write_text(s.rstrip()+'\n\n\n'+done,encoding='utf-8')
    deltas[rel]={'block':start+'\n\n'+done,'prepend':False}
rel='docs/DEAD_STREET_PROJECT_CONTROL.md';p=R/rel;s=p.read_text(encoding='utf-8-sig')
if milestone.splitlines()[0] not in s:p.write_text(milestone+'\n'+s,encoding='utf-8')
deltas[rel]={'block':milestone,'prepend':True}
(O/'owned_publication_docs.json').write_text(json.dumps(deltas,indent=2))
scope=core+[str(p.relative_to(R)).replace('\\','/') for p in O.iterdir() if p.is_file() and p.name not in ['publication_plan.json','publication_receipt.json']]
plan={'scope':scope,'hashes':{p:sha(R/p) for p in scope},'checks':3736}
(O/'publication_plan.json').write_text(json.dumps(plan,indent=2))
print(json.dumps({'records_saved':True,'checks':3736,'failures':0,'scope_files':len(scope)}),flush=True)
