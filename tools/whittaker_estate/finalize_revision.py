from pathlib import Path
import json
p=Path(r'C:\Users\brand\OneDrive\Documents\dead-street\tools\whittaker_estate\owned_revision_paths.json');assert not p.exists(),'Finalizer already run';p.write_text('[\n  "assets/art/whittaker_estate/ground.png",\n  "assets/audio/convoy/estate_audio_manifest.json",\n  "assets/audio/convoy/trc_horn.wav",\n  "assets/audio/convoy/whittaker_radio.wav",\n  "battle/geometry/whittaker_estate_catalog.gd",\n  "docs/DEAD_STREET_HIVE_MIND.md",\n  "docs/DEAD_STREET_JOURNAL.md",\n  "docs/DEAD_STREET_PROJECT_CONTROL.md",\n  "gameplay/arsenal_battle_fixture.gd",\n  "gameplay/estate_battle_setup.gd",\n  "gameplay/sandbox_force_builder.gd",\n  "gameplay/sandbox_force_config.gd",\n  "gameplay/tactical_battle_audio.gd",\n  "gameplay/tactical_battle_presentation.gd",\n  "gameplay/tactical_battle_view.gd",\n  "gameplay/tactical_command_hud.gd",\n  "gameplay/tactical_convoy_audio.gd",\n  "gameplay/whittaker_estate_art.gd",\n  "tools/tactical_controls/estate_bake.gd",\n  "tools/tactical_controls/estate_director.gd",\n  "tools/tactical_controls/estate_geometry.gd",\n  "tools/tactical_controls/estate_native.gd",\n  "tools/tactical_controls/estate_preview.gd",\n  "tools/tactical_controls/estate_probe.gd",\n  "tools/tactical_controls/estate_record.gd",\n  "tools/tactical_controls/run.py",\n  "tools/whittaker_estate/README.md",\n  "tools/whittaker_estate/build_audio.py",\n  "tools/whittaker_estate/encode.py",\n  "tools/whittaker_estate/record_worker.py"\n]',encoding='utf-8')
"""Record the verified estate revision; never stage unrelated work or large captures."""
from pathlib import Path
import json,hashlib,subprocess,re
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); out=r/'tools/whittaker_estate'
assert 'ESTATE_RECORDING_COMPLETE' in (out/'revision_capture.log').read_text(encoding='utf-8')
record=json.loads((out/'record.json').read_text(encoding='utf-8'))
delivery=json.loads((out/'delivery.json').read_text(encoding='utf-8'))
native=json.loads((out/'native.json').read_text(encoding='utf-8'))
geometry=json.loads((out/'geometry.json').read_text(encoding='utf-8'))
assert record['phase']=='resolved' and record['winner']=='defender'
assert not record['arrival_route_errors'] and not record['outro_errors']
assert record['horn_gain_samples'] and all(x['playing'] for x in record['horn_gain_samples'])
assert all(x['matches'] for x in record['hud_weapon_models']) and len(record['hud_weapon_models'])==16
assert not record['result_summary_checks']['errors']
for rel,expected in json.loads((out/'record_source_hashes.json').read_text(encoding='utf-8')).items():
 assert hashlib.sha256((r/rel).read_bytes()).hexdigest()==expected, 'Source changed during capture: '+rel
title='## 2026-09-14 — Whittaker Estate perspective and faction-audio correction (IMPLEMENTED / VALIDATED; owner review pending)'
assert title not in (r/'docs/DEAD_STREET_JOURNAL.md').read_text(encoding='utf-8'), 'Already documented; inspect rather than append twice'
results=json.dumps(record['result_summaries'],ensure_ascii=False)
summary=f'''The delivered first pass was rejected by Brandon for a camera-facing, shallow mansion, incoherent property composition, insufficient TRC foghorn presence, and creepy/tough rather than Southern/Dixie music. This revision supersedes that recording and its aesthetic assumptions. Tests and assistant inspection do not imply owner acceptance.

The white mansion now has a west/southwest-facing entrance oriented toward the road/fountain approach, upright walls, a visible two-storey body, a hipped roof with separate planes, recessed windows, attached wings, columns and entrance steps. A narrower porch roof keeps the entrance legible. The initial skewed-rise cabinet-projection attempt was reviewed and superseded internally; the final model rotates/shears the ground footprint while elevation remains upright. Mansion collision uses the same affine floor-plan transform as rendering, conservatively represented by two-world-unit horizontal strips (up to about one unit of edge bias), not an unrelated axis-aligned house rectangle. Porch columns and step cheeks also have matching physical footprints. This is an approximation for the existing collision service, not exact polygon physics.

The overall property pass warms the lawn and landscaping, connects gate/drive/fountain/entrance, reduces the oversize fountain, clarifies parking and the service garage, and adds coherent paving, planting and garden boundaries. Gatehouse, main gate, north garden approach and south service route provide several fighting lanes. Existing prepared cover and faction-appropriate parked fleet are retained. Static architecture/prop caches preserve code-native pixel art while avoiding repeated detailed draw work. Existing faction units, weapons and vehicle art are reused; no replacement units were generated.

Whittaker music is an original 106 BPM G-major Southern picking/shuffle composition with alternating bass, major chord thirds and restrained picked answers; the darker first-pass cue is superseded. TRC uses an original 12-second warning-horn loop with two long low blasts and stronger audible harmonics, not a police siren. The horn is anchored to the convoy, starts at -13.5 dB, ducks another 6 dB for combat plus short 2 dB shot ducking, and remains quieter behind the winning Whittakers at the outro. The porch guitar starts at -18 dB, recedes 14 dB for combat, then returns to -18 dB and centered foreground on victory. Both assets contain no outside recordings/samples. Horn telemetry confirms playing emitters during arrival and active combat; gain and winner takeover samples are in record.json.

The showcase remains 16 TRC attackers / 16 Whittaker defenders. The disclosed showcase loadout gives the Whittakers tier-3 veterans/reinforced carriers against tier-1 TRC troops/patrol vests; this secures the requested defender-win scenario without altering global balance. Seed {record['seed']} resolves naturally in {record['combat_seconds']:.2f} simulated seconds with Whittakers winning; no mid-battle health/winner override. Results: {results}. Contextual support Hold and a defender counterattack use the normal order service, rather than forcing every command into the video. Geometry route checks, 32-unit deployment, arrival/outro route checks, nine result-summary checks and all sixteen equipped HUD model labels pass. Exact evidence is in the estate folder. The extended result-card hold, survivor counts, hidden movement paths and winner-audio rules are preserved.

Native 1920x1080 sample: {native['average_fps']:.2f} FPS over {native['seconds']:.2f} seconds, p95 {native['p95_frame_ms']:.2f} ms, 32 initial units, no arrival route errors. This is below 60 FPS and is not a sustained-play or expansion-headroom acceptance result. The fixed-30-fps recording is an offline movie capture, not proof of live 60 FPS. No broad optimization campaign or whole-project regression certification was performed. Runtime validation includes the pre-existing unrelated battle_victory_service.gd working-tree change, which is preserved and excluded from this checkpoint.

Revised mobile MP4: {delivery['seconds']:.2f} seconds, {delivery['bytes']} bytes, 1280x720 at 30 FPS, H.264 yuv420p/AAC, fast-start index. SHA256 {delivery['sha256']}. The full output decodes to the end and stays below 8 MB to avoid repeating the earlier truncated mobile-delivery problem. Previous recording/source files remain recoverable under local owner_rejected_v1 / rejected_v1_sources; those intermediates and raw AVI are not Git deliverables. The revised video replaces the existing Dead Street recording attachment, not a new competing canonical copy.

Scope/next: owner visual and listening review of this revised map/video. Production convoy/personnel caps are unchanged by this map-specific 16-per-side fixture. Riot-shield specialist remains PROPOSED. The vocals handoff and faction pack were located and verified, but voice runtime integration remains paused while the latest visual/audio correction takes priority. Existing character-factory, dusk-review and source-recovery work is unrelated and remains untouched/uncommitted. This scoped checkpoint uses standing Git push authorization; verify actual HEAD/origin for synchronization state.
'''
summary+='\nThe first corrected capture failed its outro gate: one surviving sniper could not find a free reachable spot beside the single chosen fallen teammate. The shared outro now preserves the normal closest-teammate path when valid, then tries wider approach rings and other fallen teammates when that spot is blocked/crowded. It does not teleport units or suppress route errors. The failed cut is preserved under route_rejected_v2, and the replacement capture must pass zero outro errors before delivery. The rehearsal and native capture differ in survivor/timing details; each report preserves its actual result rather than treating the rehearsal as an exact movie replay.\n'
p=r/'docs/DEAD_STREET_JOURNAL.md'
with p.open('a',encoding='utf-8') as f:f.write('\n\n'+title+'\n\n'+summary)
p=r/'docs/DEAD_STREET_HIVE_MIND.md'; t=p.read_text(encoding='utf-8')
t=re.sub(r'Coordination last reconciled:[^\n]*','Coordination last reconciled: 2026-09-14, after the corrected Whittaker Estate recording.',t)
t=re.sub(r'\*\*Active objective:\*\*[^\n]*','**Active objective:** Corrected Whittaker Estate map/audio and verified 16 v 16 mobile recording are implemented; owner visual/listening review next. See [estate report](../tools/whittaker_estate/README.md). Optional vocals remain paused.',t)
t=re.sub(r'\*\*Immediate next task:\*\*[^\n]*','**Immediate next task:** Brandon reviews the revised estate perspective, property composition, TRC warning horn and Southern Whittaker music. Do not resume vocals or expand scope without resolving that review.',t)
t=t.replace('| Scripted battle recording | This receiving chat | Final winner-audio / result-count / equipped-model cut validated; owner review next. |','| Scripted battle recording | This receiving chat | Corrected estate 16 v 16 / Whittaker-win mobile cut validated; owner review next. |')
t=t.replace('| Whittaker Estate sandbox map | This receiving chat | Authorized 2026-09-14; map, 16 v 16 recording and original audio in progress. |','| Whittaker Estate sandbox map | This receiving chat | First pass rejected; rebuilt perspective, property composition and original faction audio validated. Owner acceptance pending. |')
t=t.replace('**Latest evidence:** Normal 24-unit release averaged 59.67 FPS;',f'**Latest estate evidence:** 32 initial units; {native["average_fps"]:.2f} FPS native sample, p95 {native["p95_frame_ms"]:.2f} ms. Routes, 16 HUD models and resolved Whittaker-win capture checked. See estate report; sustained 60 FPS remains unproven.\n\n**Earlier bridge evidence:** Normal 24-unit release averaged 59.67 FPS;')
t=t.replace('### Active owner correction — 2026-09-14','### Historical Raiders correction — 2026-09-14 (superseded as active task)')
t=t.replace('Next: Brandon reviews the completed original-audio Raiders-victory video. Performance and Whittaker Estate remain parked.','Historical next step above is superseded by the current estate review; performance remains parked.')
p.write_text(t,encoding='utf-8')
p=r/'docs/DEAD_STREET_PROJECT_CONTROL.md'; t=p.read_text(encoding='utf-8')
p.write_text('## Current milestone — corrected Whittaker Estate — 2026-09-14\n\nIMPLEMENTED / VALIDATED; owner visual and listening review pending. Rebuilt road-facing mansion with upright volume, shared render/collision footprint, improved fountain court, gatehouse, service building, parking and landscaping. Original 106 BPM Southern-major guitar replaces the rejected dark cue; persistent TRC warning horn is louder on arrival, ducked in combat and subdued behind Whittaker victory music. Existing units/fleet/weapons reused. Verified 16 v 16 defender-win mobile recording, complete decode, survivor cards and HUD models. This fixture does not raise production caps.\n\nSee [estate report](../tools/whittaker_estate/README.md) and latest journal for exact evidence, failed/superseded attempts and limits. Native 32-unit sample remains below 60 FPS. Vocals integration is paused; riot shield remains a proposal. Next: Brandon reviews this corrected map and audio. All earlier conflicting next-step statements below are historical.\n\n'+t,encoding='utf-8')
p=out/'README.md'; old=p.read_text(encoding='utf-8')
old=old.replace('Status: APPROVED / IN PROGRESS. Map, recording and voices are not yet validated.','Historical first-pass status (superseded): approved/in progress at briefing time. See current correction status above.')
p.write_text('# Whittaker Estate — corrected perspective / faction audio\n\n'+title+'\n\n'+summary+'''\n## Reproduction and evidence

- `python tools/tactical_controls/run.py pack` builds the official release overlay from current working files.
- Launch that release with `-- --check=estate_bake` for ground; `estate_bake_props` for static prop caches; `estate_preview` for overview/house/combat frames; `estate_geometry` for routes/deployment; `estate_probe` for the seed-9146 rehearsal; `estate_native` for the bounded native sample.
- `python tools/whittaker_estate/build_audio.py assets/audio/convoy` regenerates original audio and manifest (NumPy required).
- `python tools/whittaker_estate/record_worker.py` records and invokes `encode.py` (NumPy/imageio_ffmpeg). It refuses to overwrite an existing raw capture: archive a specifically identified prior capture before recording again. Do not repack/change runtime sources concurrently with movie capture.
- `geometry.json`, `native.json`, `probe.json`, `record.json`, `record_source_hashes.json`, `delivery.json`, `revision_source_manifest.json` preserve checks and provenance.
- `estate_overview.png`, `estate_house_detail.png`, `arrival.png`, `results.png` are reviewed native reference frames, not owner-accepted final art.
- The full MP4 is the versioned Dead Street recording attachment; large masters/transfer chunks are excluded from Git.

## Historical owner brief (retained for provenance)

'''+old,encoding='utf-8')
owned=json.loads((out/'owned_revision_paths.json').read_text(encoding='utf-8'))
for path in ['gameplay/estate_architecture.gd','gameplay/tactical_battle_outro.gd','tools/tactical_controls/estate_bake_props.gd']+[f'tools/whittaker_estate/{x}' for x in ['geometry.json','native.json','probe.json','record.json','record_source_hashes.json','delivery.json','estate_overview.png','estate_house_detail.png','arrival.png','results.png']]:
 if path not in owned:owned.append(path)
catalog=(r/'battle/geometry/whittaker_estate_catalog.gd').read_text(encoding='utf-8')
for p in (r/'assets/art/whittaker_estate/props').glob('*.png'):
 # All baked props are local to this estate pass; no other user's asset directories.
 owned.append(p.relative_to(r).as_posix())
owned=sorted(set(owned))
manifest={p:hashlib.sha256((r/p).read_bytes()).hexdigest() for p in owned if (r/p).is_file() and not p.startswith('docs/') and not p.endswith('README.md')}
(out/'revision_source_manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
owned.append('tools/whittaker_estate/revision_source_manifest.json')
(out/'owned_revision_paths.json').write_text(json.dumps(owned,indent=2),encoding='utf-8')
print('ESTATE_RECORDS_FINALIZED',len(owned),flush=True)
