# Whittaker Estate — corrected perspective / faction audio

## 2026-09-14 — Whittaker Estate perspective and faction-audio correction (IMPLEMENTED / VALIDATED; owner review pending)

The delivered first pass was rejected by Brandon for a camera-facing, shallow mansion, incoherent property composition, insufficient TRC foghorn presence, and creepy/tough rather than Southern/Dixie music. This revision supersedes that recording and its aesthetic assumptions. Tests and assistant inspection do not imply owner acceptance.

The white mansion now has a west/southwest-facing entrance oriented toward the road/fountain approach, upright walls, a visible two-storey body, a hipped roof with separate planes, recessed windows, attached wings, columns and entrance steps. A narrower porch roof keeps the entrance legible. The initial skewed-rise cabinet-projection attempt was reviewed and superseded internally; the final model rotates/shears the ground footprint while elevation remains upright. Mansion collision uses the same affine floor-plan transform as rendering, conservatively represented by two-world-unit horizontal strips (up to about one unit of edge bias), not an unrelated axis-aligned house rectangle. Porch columns and step cheeks also have matching physical footprints. This is an approximation for the existing collision service, not exact polygon physics.

The overall property pass warms the lawn and landscaping, connects gate/drive/fountain/entrance, reduces the oversize fountain, clarifies parking and the service garage, and adds coherent paving, planting and garden boundaries. Gatehouse, main gate, north garden approach and south service route provide several fighting lanes. Existing prepared cover and faction-appropriate parked fleet are retained. Static architecture/prop caches preserve code-native pixel art while avoiding repeated detailed draw work. Existing faction units, weapons and vehicle art are reused; no replacement units were generated.

Whittaker music is an original 106 BPM G-major Southern picking/shuffle composition with alternating bass, major chord thirds and restrained picked answers; the darker first-pass cue is superseded. TRC uses an original 12-second warning-horn loop with two long low blasts and stronger audible harmonics, not a police siren. The horn is anchored to the convoy, starts at -13.5 dB, ducks another 6 dB for combat plus short 2 dB shot ducking, and remains quieter behind the winning Whittakers at the outro. The porch guitar starts at -18 dB, recedes 14 dB for combat, then returns to -18 dB and centered foreground on victory. Both assets contain no outside recordings/samples. Horn telemetry confirms playing emitters during arrival and active combat; gain and winner takeover samples are in record.json.

The showcase remains 16 TRC attackers / 16 Whittaker defenders. The disclosed showcase loadout gives the Whittakers tier-3 veterans/reinforced carriers against tier-1 TRC troops/patrol vests; this secures the requested defender-win scenario without altering global balance. Seed 9146 resolves naturally in 34.43 simulated seconds with Whittakers winning; no mid-battle health/winner override. Results: {"attacker": {"remaining": 0, "retreated": false, "text": "0 Units Remaining"}, "defender": {"remaining": 8, "retreated": false, "text": "8 Units Remaining"}}. Contextual support Hold and a defender counterattack use the normal order service, rather than forcing every command into the video. Geometry route checks, 32-unit deployment, arrival/outro route checks, nine result-summary checks and all sixteen equipped HUD model labels pass. Exact evidence is in the estate folder. The extended result-card hold, survivor counts, hidden movement paths and winner-audio rules are preserved.

Native 1920x1080 sample: 55.53 FPS over 12.02 seconds, p95 20.37 ms, 32 initial units, no arrival route errors. This is below 60 FPS and is not a sustained-play or expansion-headroom acceptance result. The fixed-30-fps recording is an offline movie capture, not proof of live 60 FPS. No broad optimization campaign or whole-project regression certification was performed. Runtime validation includes the pre-existing unrelated battle_victory_service.gd working-tree change, which is preserved and excluded from this checkpoint.

Revised mobile MP4: 74.20 seconds, 7538956 bytes, 1280x720 at 30 FPS, H.264 8-bit 4:2:0 full-range/AAC, fast-start index. SHA256 9f9a424122221b3afd14014399c6bf2fe94633f8c7c9ee5650cf78187496eef6. The full output decodes to the end and stays below 8 MB to avoid repeating the earlier truncated mobile-delivery problem. Previous recording/source files remain recoverable under local owner_rejected_v1 / rejected_v1_sources; those intermediates and raw AVI are not Git deliverables. The revised video replaces the existing Dead Street recording attachment, not a new competing canonical copy.

Scope/next: owner visual and listening review of this revised map/video. Production convoy/personnel caps are unchanged by this map-specific 16-per-side fixture. Riot-shield specialist remains PROPOSED. The vocals handoff and faction pack were located and verified, but voice runtime integration remains paused while the latest visual/audio correction takes priority. Existing character-factory, dusk-review and source-recovery work is unrelated and remains untouched/uncommitted. This scoped checkpoint uses standing Git push authorization; verify actual HEAD/origin for synchronization state.

The first corrected capture failed its outro gate: one surviving sniper could not find a free reachable spot beside the single chosen fallen teammate. The shared outro now preserves the normal closest-teammate path when valid, then tries wider approach rings and other fallen teammates when that spot is blocked/crowded. It does not teleport units or suppress route errors. The failed cut is preserved under route_rejected_v2, and the replacement capture must pass zero outro errors before delivery. The rehearsal and native capture differ in survivor/timing details; each report preserves its actual result rather than treating the rehearsal as an exact movie replay.

## Reproduction and evidence

- `python tools/tactical_controls/run.py pack` builds the official release overlay from current working files.
- Launch that release with `-- --check=estate_bake` for ground; `estate_bake_props` for static prop caches; `estate_preview` for overview/house/combat frames; `estate_geometry` for routes/deployment; `estate_probe` for the seed-9146 rehearsal; `estate_native` for the bounded native sample.
- `python tools/whittaker_estate/build_audio.py assets/audio/convoy` regenerates original audio and manifest (NumPy required).
- `python tools/whittaker_estate/record_worker.py` records and invokes `encode.py` (NumPy/imageio_ffmpeg). It refuses to overwrite an existing raw capture: archive a specifically identified prior capture before recording again. Do not repack/change runtime sources concurrently with movie capture.
- `geometry.json`, `native.json`, `probe.json`, `record.json`, `record_source_hashes.json`, `delivery.json`, `revision_source_manifest.json` preserve checks and provenance.
- `estate_overview.png`, `estate_house_detail.png`, `arrival.png`, `results.png` are reviewed native reference frames, not owner-accepted final art.
- The full MP4 is the versioned Dead Street recording attachment; large masters/transfer chunks are excluded from Git.

## Historical owner brief (retained for provenance)

# Whittaker Estate — first playable pass

## Owner-approved brief — 2026-09-14

Brandon authorized this overnight build after the Raiders bridge recording. Build
a large city-outskirts estate for 16 TRC attackers versus 16 Whittaker defenders;
the Whittakers win the scripted showcase. The bridge is better suited to roughly
8 v 8 in the owner's view; this is guidance, not a retroactive rules/cap change.
The 16-per-side estate pass supersedes the older 20-plus estate test concept.

The public road runs vertically along the far left. Its driveway enters a fenced
property through a defended gate with a security hut, then reaches a circular
drive and fountain in front of a large white estate. Include generous lawns,
parked faction-appropriate vehicles, prepared improvised cover, and a useful
outbuilding. Woods and a restrained distant city skyline establish the outskirts.
Keep the accepted elevated pixel-art perspective, material depth, physical cover,
vehicle scale, unit outfits, readable HUD, and live combat/order behavior.

Assistant layout decisions for this first pass: a central gate approach plus a
north garden entrance and southern service entrance; a maintenance/garage building
on the service side; layered defenders across the gate, fountain court and house.
These first-pass placements await owner visual/play acceptance.

TRC ambience: original eerie low two-tone warning horn, distinct from police.
Whittaker ambience: original Southern guitar instrumental, using an actual plucked
string synthesis and deliberate guitar phrasing. No external recordings/samples.
Establish both sources on arrival, reduce music during combat, then restore the
winning Whittaker music for aftermath and the extended result-card hold. Retain
subdued TRC warning ambience. Follow the shared winner-audio rules.

Priority: finish and deliver the complete mobile battle video first. Then locate
and integrate the faction vocals handoff if available, using sparse contextual
events and cooldowns. The suggested TRC riot-shield specialist is to be assessed;
do not silently pretend a cosmetic shield provides protection.

## Delivery and verification rules

Use actual weapons, seats and a legal convoy. The showcase may use an explicitly
documented fixed loadout/seed to obtain the requested winner; never change health
mid-battle or fabricate a resolved outcome. Use commands when tactically useful.
Validate map geometry, alternative route connectivity, reachable cover and exits,
native rendering, correct winner, HUD count/model labels and complete audio/outro.
Measure a representative 32-unit run without reopening a broad optimization pass.

The preceding Raiders video's 50-second freeze coincided exactly with an 8 MiB
delivery boundary. Its full source was valid. A two-pass 720p export below 8 MB
was delivered with all 2,950 frames and the full 98.35 seconds. Future mobile
exports must use a duration-based bitrate budget below 8 MB, standard yuv420p,
H.264/AAC and fast-start metadata, and validate the saved complete file.

Historical first-pass status (superseded): approved/in progress at briefing time. See current correction status above.


### Estate playable rehearsal — 2026-09-14

Implemented the large estate map using existing Whittaker/TRC unit atlases, fleet and weapons. All 32 units deploy; native arrival paths report no errors. Added map-specific 16-unit sandbox capacity and a compact two-row deck. Original Whittaker guitar and TRC warning horn are wired to arrival/combat/victory dynamics. Rehearsals preserved in tools/whittaker_estate: early configurations either favored TRC or stalled; a contextual defender counterattack uses the normal line-command service. Latest selected seed 9146 resolves with Whittaker victory at 45.73 seconds. No mid-battle health overrides. Decorative perimeter cover slots were reduced; native 1920x1080 sample improved from 43.8 to 50.6 FPS, still below a demonstrated sustained 60 FPS. Performance claim remains limited. Mobile capture and outcome/audio validation are next. Riot-shield idea remains proposed; no replacement unit art was made. Vocals remain last priority after the completed video.
