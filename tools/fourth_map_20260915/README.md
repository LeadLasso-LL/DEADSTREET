# Doble Ocho Auto Yard — first playable map

2026-09-15 BUILD handoff. Owner requested a surprise fourth tactical battlefield between Harold and the bridge, suited to6v6/7v7, plus a scripted battle video. Native implementation is in the existing live-source sandbox, not a separate mockup.

## Setting and encounter

A fenced repair/parts yard on New Briarport's south side, held by Calle Ocho. Cártel de Sierra Roja raids the business. Both factions' south-side roots and rivalry come from the established faction references; Doble Ocho itself and this raid are newly authored under the owner's delegated creative scope, awaiting visual/story acceptance.

96x64 world units, versus Harold64x54 and bridge180x58. Two working garages, an oily concrete yard, stacked tires, drums, pallets, a central parts container and six canonical vehicles. The surrounding commercial district continues beyond the combat boundary and remains visible during the unaltered wide intro concept. Roof corrugation, masonry, inset shutters, vents, drains, power lines and litter provide material depth.

## Play

Reopen the normal **Dead Street Sandbox** desktop shortcut. It launches the live repository through `gameplay/sandbox_opening.tscn`.

Battle Setup → **Doble Ocho Auto Yard** → **LOAD YARD7 vs7** → Start.

The preset uses Sierra Roja against Calle Ocho, seven experienced units per side, all five gun classes, no armor. It changes the force only when its button is pressed. Normal custom faction/equipment setup remains available; intended scale is6–7 per side, and oversized vehicle choices fail with a clear setup error when they cannot fit safely.

The preset's Mesa carries four actual units and its Outlander carries three. The lead takes the west approach around roadside obstacles into the main gate; the second continues on the correct carriageway and brakes diagonally near the service gate. Passengers exit their real transports and occupy reachable opening cover before fighting. Normal players control subsequent orders; the video director is a separate tool.

## Tactical layout

- Main gate: four-person assault team, arrival pickup and tires for initial cover.
- Southern service gate: three-person team, exterior fence positions and a wide visibly open secondary entrance.
- Garage line: defenders use parked vehicles, parts and drums in front of the two workshops.
- Central container: solid sight/fire/movement blocker, usable corner firing positions, circulation on both sides; fades immediately if it obscures a living actor, then recovers smoothly.
- Gates have visible open leaves and physical posts; entrances and connecting routes are navigable.

New-map cover uses1.35-world standoff and2.4-world offered-slot spacing. Shared1.6 vehicle proportions and1.48 actor scale; physical and drawn feet coincide. Existing bridge-width HUD, individual/same-class soft range displays, survivor-first results and parked-vocals rule are retained.

Faction music uses the owner's exact existing mappings: Sierra Roja / Break Bad B-22; Calle Ocho / Glock B-22. Defender music is anchored at the garage and ducked for combat. No generated faction music, vocals, siren revisions or unrelated audio changes.

## Validation and evidence

- `first_pass.json`:220 native7v7 geometry, reachable cover, body-spacing, route and actual dismount checks pass.
- `approach_review.json`: both actual vehicle bodies swept against every authored prop at120Hz; no intersections. Earlier run reproduced the roadside-dumpster clip and is retained in `approach_before_godot.log`.
- `integration_review.json`:39 checks pass, including the actual preset button,6v6 seating/deployment/exits, individual/class selection rules and native start smoke checks on all four maps.
- `native_perf.json`:15.01s native1280x720 wall-clock combat sample,14 initial units,53.68 average FPS,17.87ms median and23.23ms p95 frame time. Similar range to the recorded Harold54–55FPS baseline, but different geometry/unit count; this is not controlled comparative benchmarking or a sustained60FPS claim.
- `record.json`, `capture_source_hashes.json`, `delivery.json`: final native movie, frozen-source verification, real outcome and mobile encode checks.
- Native/encode logs retain failures and corrections. Integration fixture initially shadowed Godot's native Range class; corrected to SelectionRange. First7v7 fixture used an invalid manifest shape, then an endpoint inside a parked vehicle; corrected fixtures without weakening runtime geometry.

## Reproduce

Use the installed Python at `%LOCALAPPDATA%/DeadStreetTools/python/python.exe` and Godot4.7.2.

`python tools/fourth_map_20260915/run_native.py bake`

`python tools/fourth_map_20260915/run_native.py review review.gd`

`python tools/fourth_map_20260915/run_native.py approach approach_review.gd`

`python tools/fourth_map_20260915/run_native.py integration integration_review.gd`

`python tools/fourth_map_20260915/run_native.py native_perf native_perf.gd`

`python tools/fourth_map_20260915/run_native.py rehearsal showcase.gd`

`record_worker.py` captures the director at fixed30FPS and invokes `encode.py`. It refuses to overwrite an existing named raw capture; choose a new version explicitly. The final export is1280x720 H.264/AAC with front-loaded MP4 index, complete decode verification and under8MB. Godot initializes its movie viewport at1152x648 on this machine; the mobile delivery is scaled to1280x720. Movie frame rate is offline capture, not live performance evidence. Do not alter production sources during recording.

Director seed91517 schedules ordinary cover/Move/Push orders. It never changes health, hit probability, damage, combat randomness or winner. Every real passenger and the actual natural result is recorded. Early kills can prevent an individual scripted order; rejected/dead-unit orders remain visible in the report.

## Ownership and continuation

New implementation: `battle/geometry/doble_ocho_catalog.gd`; `gameplay/doble_ocho_{art,setup,scenario}.gd`; `assets/art/doble_ocho/ground.png`.

Narrow integration edits: arsenal fixture, sandbox config/builder, tactical view/presenter/participant visual, arrival service, battle presentation/outro and convoy audio. Baseline exact bytes for the ten existing edited files are under `before/` with `.gdignore`; initial hashes are in `baseline.json`. Initial branch `build/arsenal-checkpoint-20260911`, HEAD408f62cb2c3642e4ba9e33713f531c35757a6a2f, initially empty index. Keep prior Harold, range, victory, character and other mixed work.

No staging, commit or push for this map at first delivery. `checkpoint_scope_review.json` identifies shared uncommitted Harold prerequisites in the participant visual, view and arrival service; an eventual checkpoint must separate those carefully rather than commit entire shared files indiscriminately. The live-source sandbox already loads the map. Raw movies/temporary transfer data are local evidence, not a Git payload.

Next: owner watches the completed video and plays the preset. Preserve the recorded first-pass battle/layout pending feedback. Campaign location selection is not part of this sandbox map. Expanded convoy combinations and larger-than-intended battles are not exhaustively certified. Earlier unrelated map/art publication and review items retain their own status.


## Final delivery receipt
IMPLEMENTED / NATIVE-VALIDATED / OWNER REVIEW: Doble Ocho Auto Yard,96x64,6v6/7v7 betweenHarold andbridge. Calle Ocho south-side repair yard under Sierra Roja assault; specific business/encounter newly authored under delegated scope. Normal Sandbox → Battle Setup → Doble Ocho Auto Yard → LOAD YARD7vs7. Correct4+3 transport, strategic two-gate approach, real opening cover before combat, complete fence/open leaves, canonical1.6 cars and grounded1.48 actors, developed surroundings, sharedfullwidthHUD/ranges/survivor-firstresults. Owner's exact Break Bad/Glock music mappings; no vocals or new music.
Final50.2667s mobile MP4 (7355422bytes,1280x720/30FPS H.264/AAC, faststart) saved as libfile_b4c01a1910b08191b39c2aed27fde7ba v0; opening screenshot libfile_146ee1caf4a4819196e95e5ace3db5ee v0. SHA256241e1d23923ed937fd8c7f86038844c698b4d581e5ed0e8c60ded0d2d7f9381b. Full video decode and finite nonclipping audio pass; exact transferred bytes verified. Native movie initializes1152x648 then export scales to1280x720, no claim of native720 recording. Scripted ordinary orders only; seed91517 natural21.3667s combat,SierraRoja5survivors/0CalleOcho;0camera violations across1236samples,0arrival/outroerrors. Final immediate container occlusion reveal inspected. Rawv1 andv2/first_export preserve iteration.
Validation:220native7v7checks,39integration/preset/6v6/old-map-startchecks,120Hz both-car body sweeps againstallprops clear. Native15.01s14unit sample53.68FPS average,p9523.23ms; not60FPS/headroomcertification. Six movie shutdown ObjectDB leak warnings remain in native logs; capture exits0, no script/runtime error or truncated video. Existing weapon/body visuals were not modified.
Source and existing mixed work verified at completion; exact protected count/hashes,HEAD,branch andstatus in tools/fourth_map_20260915/completion_receipt.json. Index remains empty; no mapcommit/push. Three shared integration files rely on unpublished Harold spacing/view prerequisites; future scoped publication must separate/preserve these, not blindly stage wholefiles. Full handoff README, baseline exact backups, owned_source_delta.patch, repro scripts and final evidence in samefolder. Immediate next action: owner watches/reviews/plays newmap; no further automatic battle/layout changes pending feedback. Earlier Harold appearance and unrelated review/publication items keep their separate status.
