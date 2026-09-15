# Freight Exchange - 2026-09-15
Status: IMPLEMENTED / NATIVE-VALIDATED / LIVE-SOURCE REVIEW READY. Owner visual/audio acceptance pending. No new commit or push in this pass; preserve the concurrent sandbox-maps source work when preparing publication.

## Owner request and art direction
Fifth map, approximately bridge scale, intended for10v10. Accepted Freight Exchange idea: stationary freight cars, visible rail crossings, loading platforms and a service-road flank. Added rainy night, rain sound and designed lighting. Owner corrected 'always' to 'also': no global always-night requirement, no weather selector requested. Default map10per side; compatible with current universal16cap and3convoy slots.

## Implementation
Map key freight_exchange / authored ID freight_exchange_v1 /164x76world units (bridge180x58).
Six stationary freight cars (including loaded timber flatcar),3marked cross-track routes, east-west lanes, low cargo/reels/concrete stops, loading platforms, receiving shed and dispatch office. Movement/LOS solids and cover follow native footprints. Tall railcars expose corner cover;1.35body clearance and2.4slot spacing. Partial actor overlap under45percent leaves railcar opaque; actual obscured actors trigger local fade.
West-road convoy arrives northbound in up to3slots, with real vehicle bodies/seats/door exits and separate bike members. Defenders already hold the east yard. Capture preset Orlov versus McAllister is illustrative, not new territory ownership canon.
Night: map-local CanvasModulate,9warm/cool point lights, local solid shadows, amber office windows, puddles and wet glints.610rain streaks plus splashes, below HUD. Two original synthesized20second44.1kHz stereo WAV rain loops: global rain bed and positional metal-roof patter. Audio toggle pauses/resumes both. Faction tracks/assignments unchanged; defender radio anchored to actual dispatch entrance(142,19.5).
Integrated current map picker via fifth IDS/DATA row, legal10v10preset and authored night thumbnail assets/menu/maps/freight_exchange.png. No sandbox_force_builder/convoy UI overwrite.

## Validation
-411native10v10checks PASS:20participants in valid cover, spacing, all cover reachable,3crossings and4east-west lanes, actual transport exits, arrival endpoints, fixed defenders, normal combat begin and dispatcher radio.
-15seconds deterministic combat sample: frame median16.643ms,p95 18.189ms; simulation advance median6.410ms,p95 8.224ms.
-751native16v16/menu/weatherchecks PASS: all32in cover, map-picker preset10v10legal, thumbnail loaded,9lights, both rain stems play/loop/mute/restore,2second16v16combat sample. Frame median23.707ms,p95 28.019ms; simulation advance median9.578ms,p9513.100ms.
-Native arrival recording reaches READY at22.638s with no path errors. No script errors. Exit reports10ObjectDBinstances; no runtime growth/leak investigation in this scope.
-15second1280x80030FPSH.264/AACMP4 decodes through end, stereo audio RMS.03313/peak.15044.1,319,716bytes;sha256e1c8b03e854d3dc6dce6a53988b14a38c1f893d515626a2470e3776931cc5966.
-Reviewed actual native overview,10v10opening and encoded-video poster. Initial harness disabled presentation before its reset; corrected harness explicitly resets and begins arrival. Initial defender-facing filter excluded perpendicular low cover; corrected before pass.

## Evidence / reproduction
tools/freight_exchange_20260915 contains validation.json,capacity.json,rain_audio_validation.json,movie.json,delivery.json,final_scope.json,validated_sources.zip and integration baseline ZIPs. Capture reproducible with preview_movie.gd / capture_worker.py; native checks via run_native.py review review.gd or capacity review.gd. Ground bake via run_native.py bake, night thumbnail via run_native.py night_overview preview.gd. Rebuilding audio uses build_rain.py.
New task-owned source/assets and10additive shared files are listed in final_scope.json. Main mixed-work HEAD remains35e0db12aae4d114364c911a69ae2136de30ee4e. Do not blindly commit all shared-file diffs; latest map picker is concurrent work.
Preview delivered in chat as DEAD_STREET_Freight_Exchange_Preview.mp4;15s native arrival/atmosphere excerpt with sound. Durable file identitylibfile_a6e056e806d48191a0d9d8b2a1b9ade7.

## Remaining
Owner review of lighting/rain/layout. No full battle-to-victory balance certification, long-session profiling or general regression of other maps claimed. Ready for coordinated commit/publication with the active sandbox-menu pass; current implementation playable via the live-source sandbox launcher.
