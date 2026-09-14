## Current correction — 2026-09-14 (IMPLEMENTED / VALIDATED; owner review pending)

Local gameplay checkpoint 15c6bbc1292c745408869e545d5ae9dab31991cc is committed. Push is blocked by automatic approval review; verified remote remains 2cf7e4af5e4335683263004560127df7a08bcded on build/arsenal-checkpoint-20260911. Review declined the standing authorization recorded in the repository and requires explicit owner approval in this chat for the external GitHub payload. Do not retry or bypass that block without accepted approval.

This supersedes the earlier estate review-next state. Brandon required a substantially larger mansion facing dead left on screen, its east side continuing beyond the right edge, a separate forecourt without steps intruding into the circular drive, more actual parked-car cover/greenery, closer battle framing, organized TRC deployment, full faction names on expanded intro cards, quiet mansion-spatial music, audible faction voices and no units obscured by the HUD. He also rejected disappearing/repositioned survivors and purposeless movement at the ending.

Inherited estate architecture, property, full-name and music edits were preserved and completed. Critical defect: TacticalParticipantVisual.view_origin omitted estate from the shared 0.75 vertical projection, while scenery, arrival and outro already used it. Actors therefore appeared displaced from physical cover and jumped when phases changed. Estate now uses the shared projection, actor scale and finish. This changes presentation, not soldier positions, combat RNG, health or winner logic.

Camera safety runs after poses/HUD updates and fits living sprite bounds within the measured space above the roster and below the context card, including resize and zoom. It may limit requested zoom/pan to retain all living actors. It does not hide units or alter movement. The final valid camera transform holds when result cards replace the combat HUD. Expanded names are full for both sides; docking abbreviates only where required.

The ending takes ownership of each survivor's last displayed pose. Estate defenders hold won positions; only healthy survivors with an unassigned fallen teammate within eight world units attempt a nearby check. Wounded survivors stay in place. Ordinary actor synchronization no longer resets actors during their presentation routes. The endpoint remains honest: four Whittaker survivors, all TRC eliminated, no retreat inferred.

TRC and Whittaker now use 36 reviewed-basis pack-07 performances through a separate FactionVoices bus, maximum three concurrent players, per-unit/event arbitration and sparse chatter. Death supersedes same-tick damage/wound requests and plays once independently of the actor. Accepted group feedback includes accepted IDs, so only an accepted recipient can acknowledge. Canonical runtime IDs trc and whittaker map to matching banks; no unrelated accent fallback. Clips are 48 kHz mono Vorbis quality 4 from original PCM WAVs, with checksums/source identity in assets/audio/factions/manifest.json. The original package remains Dead_Street_Faction_Voices_07.zip (libfile_614e18fa06dc8191ba91a0a13a240247). Other 17 banks are not installed by this scoped estate pass; taking_fire clips have no pressure hook yet. Pack-07 performance/mix acceptance remains Brandon's listening decision.

Whittaker music is anchored to the mansion entrance: -25 dB arrival, another 6 dB combat reduction plus shot ducking, -18 dB centered foreground only after Whittaker victory. TRC warning horn remains contextual and quieter behind victory. Existing original compositions are retained.

Validation: official Godot 4.7.2 release, Windows D3D12/GTX 1650 Max-Q. Seven geometry routes pass, including both forecourt approaches and entrance; all 32 units legally placed. Current line-command suite passes 128 checks and native UI 43. Nine result checks and all 16 equipped HUD model labels pass. Both the resize audit and final capture perform 31,514 actor-frame checks with zero HUD overlap/hidden survivors; 1,905 camera safety frames with zero violations; zero arrival/outro route errors; maximum survivor movement per ending frame 1.434 px and final result-camera jump 0 px. Native audit includes 1920x1080 to 1280x720 resizing. Final audio loads all 36 clips, reports no missing files and never exceeds three voice players. Full names, battle placement and aftermath/result frames were visually inspected. These are bounded checks, not all-map or full-core certification.

The showcase retains seed 9146, sixteen TRC attackers and sixteen Whittaker defenders with the disclosed veteran/armor advantage from the established director fixture. Combat resolves naturally at 41.90 simulated seconds. Final movie is 74.537 seconds, 1280x720/30 fps H.264/AAC, 7,550,359 bytes, full decode verified, SHA256 98e9a795b3faf329877619f673ec754826bef6bb2bc8b8b68637947c0991dccf. Saved as version 2 of the existing recording (libfile_5962de2d811081919c16f93b3f306b4c). Stereo source peak 0.947, AAC peak 0.925; neither clipped. The previous validation falsely flagged a mono downmix, which raises combined-channel peaks; verification now measures delivered stereo without changing the valid mix.

Fresh 32-unit native sample: 44.42 FPS average over 12.01 seconds, p95 41.517 ms. Performance remains unresolved. Earlier 55.53 FPS evidence used the prior estate revision, so this is not a matched attribution of cost to one change. Offline movie recording is not proof of real-time frame rate. No broader optimization or whole-project regression campaign was reopened.

Failed/superseded checks preserved: inherited front-step fixture started inside newly placed hedge_85_78; replaced with actual forecourt route starts and expanded to seven routes. Historical checks.gd failed its obsolete fixed-position Push badge assertion; controls README already marks it superseded. No gameplay semantics changed to satisfy it; current line_checks/line_native both pass.

Evidence: record.json, record_source_hashes.json, delivery.json, geometry.json, native.json and resume_20260914/{record.json,line_checks.log,line_native.log,native_final.log}. Reproduction: run.py pack, then --check=estate_geometry / estate_audit / estate_preview / estate_native with the official runtime. record_worker.py gates on the native audit and encode.py enforces visual/audio/completeness checks. Archive a specifically identified previous raw AVI before capture; never repack while capturing.

Next: Brandon reviews the corrected video/map/audio. Keep estate performance, remaining faction voice banks, optional pressure hook, final convoy/personnel caps and riot-shield proposal explicit. Preserve unrelated character-factory, dusk/source-recovery and battle_victory_service work. This correction is technically verified, not owner-accepted.


## Previous revision (superseded)

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
