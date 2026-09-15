from pathlib import Path
import json,hashlib,difflib,subprocess
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
native=json.loads((O/'native_validation.json').read_text());assert native['checks']==249 and not native['errors']
asset=json.loads((O/'asset_validation.json').read_text());assert all(sha(R/p)==h for p,h in asset['hashes'].items())
(O/'before/.gdignore').touch()
music='gameplay/sandbox_menu_music.gd'
before=(O/'before'/music).read_text(encoding='utf-8-sig');current=(R/music).read_text(encoding='utf-8-sig')
delta=''.join(difflib.unified_diff(before.splitlines(True),current.splitlines(True),fromfile='a/'+music,tofile='b/'+music))
(O/'applied_music_delta.patch').write_text(delta,encoding='utf-8')
readme='''# Sandbox emblems, precision guns and music controls — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. Reopen the normal live-source Dead Street Sandbox launcher. Owner visual acceptance remains separate.

## Completed behavior

- All 23 faction seals render without the white square canvas in both faction glossary (list/header) and Battle Setup badges, including changing either faction. Shared menu-only circle mask uses each source image's measured center/radius. Original PNGs and white interior artwork remain intact; battle emblems are unchanged.
- AK-47 and six sniper close-ups redrawn as distinct SVG illustrations: walnut/curved-magazine AK, traditional Remington stock/bolt, full-wood SKS, SVD thumbhole/vented handguard, olive SSG69, AWM chassis/brake/bipod, adjustable PSG1 stock/wood grip. Scopes have slim tubes, optical bells and lower individual mounts. `weapon_precision_art.py` is called by normal display generation. Seven SVG/PNG icons changed; combat stats, prices, unit rig/animation weapons remain intact.
- Song toast is 158x56 logical units versus the existing 123x36 Music dock. Two compact title/artist lines; long text ellipsizes. It appears above the dock, stays above an open music panel and fades toward the dock after the existing duration. Dock remains clickable while toast is visible.
- Crossed-arrow Shuffle button rebuilds a permutation of enabled tracks and immediately plays the first entry. With two or more enabled tracks it cannot start with the current song. Explicit shuffle resumes from pause. Unchecked songs stay out; zero enabled disables the button; one enabled song restarts explicitly. Natural finish and Next follow the new order. Volume and inclusion preferences are preserved.

## Native verification

Official Windows Godot4.7.2/D3D12, GTX1650: **249 checks, zero failures**, `native_validation.json` and `native.log`. Actual HUD clicks exercised eight 22-song reshuffles, uniqueness/full queue coverage, immediate playback, pause/resume, exclusions, zero/one-song cases, actual file-end advancement, Next, hidden-menu pause and three desktop sizes. User music preferences were isolated in a temporary test settings file and left intact.

All 23 emblems have four background-matching corners; masked and unmasked inner pixels match exactly. Both selector sides and every glossary faction bind the shared shader. Final screenshots of all23 emblems, actual faction pages, AK/six sniper panels and compact/open music views visually inspected. First pixel test used logical positions directly against physical screenshot pixels and failed64 checks; corrected the test's viewport conversion and grid sizing. No shader workaround was needed. First import wrapper read a PowerShell UTF16 log as UTF8; fixed BOM decoding. Failed evidence retained.

Seven icon imports refreshed using an isolated temporary project. All other734 assets from the preceding portrait/photo/icon pass match their recorded hashes. No full battle simulation or new economy balance pass was needed for these display/menu changes.

## Source ownership and reproduction

`sandbox_emblem.gd`/`.gdshader` and `assets/data/sandbox_emblem_masks.json` own menu masking. Consumers are `sandbox_glossary_panel.gd` and `sandbox_force_builder.gd`. The original assets were not edited.

Precision art: `tools/arsenal_production/weapon_precision_art.py`, integrated by `weapon_display_art.py`. Regenerate requested SVGs with the normal build_art.make / make_display_icon / save_svg calls, run render_icons.gd, then this folder's finish_assets.py. Do not rebuild unit atlases for icon changes. `install.py` is a guarded single-use takeover script and must not be rerun over newer work.

Native check: Godot `--path <repo> --script res://tools/menu_polish_20260915/check_native.gd`. Backup sources are excluded from editor import.

The live `gameplay/sandbox_menu_music.gd` belongs to the original, still-untracked opening/menu source. This task applied its narrow change there, preserving the existing player. `applied_music_delta.patch` plus baseline/validated hashes record the exact already-applied delta for that owner; do not apply it twice or stage unrelated opening sources. A checkpoint includes the delta rather than silently publishing the entire inherited source. All full music tracks, faction mappings, Harold changes and group ranges stay in their respective scopes.

The preceding approved portrait/Arsenal checkpoint is pushed and verified at dc0450543801f3b4046f39cb1f762abf0bd79e15. This pass's Git result is separately recorded in publication_receipt.json.
'''
(O/'README.md').write_text(readme,encoding='utf-8')
event='''## 20260915-menu-polish-02 - Completed and native-validated

All requested changes complete locally: remove white canvas surrounds from23 faction emblems across sandbox glossary/list/header and both setup selectors, retain emblem interior white detail; refine AK-47 and all six sniper illustrations with distinct stocks/scopes/receivers; compact now-playing toast158x56 above Music dock123x36; crossed-arrow Shuffle rebuilds enabled-song order and immediately starts a different song when alternatives exist. Pause resumes on explicit shuffle; exclusions/volume persist; zero enabled disables and one enabled explicitly restarts. Next and natural track finish follow the new order.

249 native Godot checks PASS, zero failures, with actual menu/button input, eight full22-song shuffles, all23 rendered emblems, seven native gun panels and three desktop sizes. Exact inner emblem pixel equality proves preservation; all white exterior corners cleared. Final screenshots and seven-gun board visually inspected. Earlier pixel fixture corrected logical-to-physical scaling; import log BOM decoding corrected. Other734 prior art assets remain byte-identical; no combat/stat/price/animation changes or broad battle benchmark. Source/evidence/reproduction and limits: tools/menu_polish_20260915/README.md. Owner appearance review remains separate.

Prior portrait checkpoint explicitly approved in this turn, pushed and verified at dc0450543801f3b4046f39cb1f762abf0bd79e15; its previous auto-review block is resolved. New music-menu change preserves the separately owned untracked opening source: exact already-applied delta is checkpointed instead of staging that entire inherited file. Music/faction audio catalogue, Harold and range-group changes preserved. Current pass publication receipt records actual status. Reopen the normal Sandbox launcher; no further implementation needed before owner review.
'''
milestone='''# Current milestone - sandbox emblem, precision-art and music polish - 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. All23 menu emblems lose white outer canvases; AK-47/six sniper close-ups refined; compact158x56 current-song popup; Shuffle rebuilds enabled order and immediately starts its first track.249 native checks PASS. Exact behavior, seven-gun visual evidence, source ownership/delta and reproduction: tools/menu_polish_20260915/README.md and journal menu-polish-02. Prior approved portrait checkpoint dc045054 is pushed/verified. Current publication status is separate in the task receipt. Reopen normal live-source Sandbox; owner appearance review pending. Other scope milestones remain valid below.
'''
deltas={}
for rel,block,prepend in [('docs/DEAD_STREET_HIVE_MIND.md',event,False),('docs/DEAD_STREET_JOURNAL.md',event,False),('docs/DEAD_STREET_PROJECT_CONTROL.md',milestone,True)]:
 p=R/rel;s=p.read_text(encoding='utf-8-sig')
 if block.splitlines()[0] not in s:p.write_text(block+'\n'+s if prepend else s.rstrip()+'\n\n\n'+block,encoding='utf-8')
 deltas[rel]={'block':block,'prepend':prepend}
(O/'owned_doc_deltas.json').write_text(json.dumps(deltas,indent=2))
scope=['gameplay/sandbox_glossary_panel.gd','gameplay/sandbox_force_builder.gd','gameplay/sandbox_emblem.gd','gameplay/sandbox_emblem.gdshader','assets/data/sandbox_emblem_masks.json','tools/arsenal_production/weapon_display_art.py','tools/arsenal_production/weapon_precision_art.py']
for id in ['ak47','rem700','sks','svd','ssg69','awm','psg1']:scope += ['assets/art/weapons/arsenal/source/'+id+'.svg','assets/art/weapons/arsenal/icons/'+id+'.png']
scope += [str(p.relative_to(R)).replace('\\','/') for p in O.iterdir() if p.is_file() and p.suffix in ['.py','.gd','.png','.patch','.json','.md','.log'] and p.name not in ['publication_plan.json','publication_receipt.json']]
plan={'scope':scope,'hashes':{p:sha(R/p) for p in scope},'live_music_hash':sha(R/music),'music_before_hash':sha(O/'before'/music),'native_checks':249,'publication':'prepared, not attempted'}
(O/'publication_plan.json').write_text(json.dumps(plan,indent=2))
print(json.dumps({'saved_records':True,'checks':249,'scope_files':len(scope),'music_delta_saved':True}))
