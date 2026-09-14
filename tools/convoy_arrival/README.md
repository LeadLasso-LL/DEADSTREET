# Raiders grouped convoy and arrival

Brandon approved this direction on September 14, 2026. The Stateline Raiders can
pack up to three consecutive motorcycles into one convoy slot. Each motorcycle
remains an individual vehicle with its own driver, passenger capacity, cost and
collision body. Bicycles do not qualify. Other factions retain one vehicle per
slot. This does not establish a new universal three-slot convoy limit.

The requested recording uses six Ironhorse V-Twins and one Mesa Crew in the order
**three bikes / pickup / three bikes**. The occupancy manifest is
`[2, 1, 1, 5, 1, 1, 1]`: seven motorcycle occupants, including one pillion passenger,
and five pickup occupants. Three ride inside the Mesa and two ride in its bed.
Total model capacity remains five; bed seating reallocates existing seats.

`convoy_formation_catalog.gd` owns packing and manifest validation.
`tactical_convoy_setup.gd` associates each real participant with one physical
vehicle and records seat/bed placement before tactical deployment. The sandbox
vehicle selector shows the grouped slots. An edited convoy clears a stale
explicit passenger manifest. Automatic seating fills enclosed vehicles before
motorcycle passenger seats and uses available pickup-bed seating within capacity.

Bridge arrivals preserve the grouped order in staggered, collision-checked
positions. Presentation moves the whole convoy into those canonical positions;
it does not move the combat collision bodies or teleport combatants. Riders use
arrival-only seated poses with their actual faction heads, bent limbs and vest
silhouettes. Pillion and bed passengers are actual participants, not extras.
Bed occupants climb toward a rear exit, and all occupants follow legal navigation
paths to deployment positions. Arrival-only poses disappear at handoff.

West-approach bridge convoys face east on the lower carriageway, with every body
inside y=31..44. The oncoming road is not overflow parking; normal placement fails
if a convoy cannot fit. The arrival camera frames the formation below the banner.

The current original radio cue is an 84 BPM Drop-A heavy riff from `build_audio.py`.
Twelve sustained power-chord strikes across eight bars replace the rejected busy
48-attack pattern; root notes stay at A with rare flat-second tension, without a
lead melody. Sparse half-time percussion, softer clipping and a 58–2200 Hz radio
response retain the low body. All material is authored/procedural; no outside music
or samples. Asset provenance and composition metadata are in
`assets/audio/convoy/original_radio.json`.

The radio's -18 dB arrival source fades another 14 dB over the final two arrival
seconds and stays at -32 dB or lower through ready and active battle. At resolution,
the winning radio returns to -18 dB and becomes centered foreground audio;
losing/background emitters remain subdued.
This explicit transition is independent of camera distance and first gunfire.
NBPD sirens retain -29 dB source gain. Existing spatial falloff, mute and ducking
remain. Recording telemetry stores native gains at 6, 10.5, 11.5, 13 and 20 seconds.

Context roles ATTACKING and DEFENDING share a baseline beneath faction names.
ROAD BLOCKADE sits right aligned in the context box top-right corner.

Persistent unit route and target connectors are hidden; brief command placement
and Hold acknowledgements remain. The current recording intentionally favors
veteran, better-armored Raiders against regular unarmored NBPD to show the requested
Raiders victory. This changes the showcase fixture, not global gameplay balance.

## Reproduction

1. `python tools/convoy_arrival/build_audio.py`
2. `python tools/tactical_controls/run.py pack`
3. Release Godot with `-- --check=convoy_native` checks rules, assignments and the
   rendered arrival; results are under `tools/raiders_recording/convoy_native.*`.
4. `-- --check=raiders_probe` exercises live combat with the staged player decisions.
5. The recorder uses `raiders_record.gd`, fixed 30 FPS MovieMaker and a temporary
   full-HD pack override. `tools/raiders_recording/encode.py` produces H.264/AAC MP4.

## Validation and acceptance

Native validation and final recording results are recorded in the accompanying
JSON reports and project journal. Owner acceptance of the animation, mix and
faction ability remains separate from those checks. Other factions' unique
abilities are an open design topic; they are not invented by this change.


## Battle audio and result presentation — owner approved 2026-09-14

Every battle should establish the entering and defending factions through their
music/ambience, lower the music during combat, and give the winner the foreground
at the victory-card outro. Winner identity comes from the resolved side, not a
hard-coded assumption that the attacker wins. Keep subdued battlefield ambience.
The current convoy implementation fades the winning radio back to its arrival
gain over ending seconds 0.35–1.8, removing spatial attenuation and panning while
continuing the same riff. Sirens remain background sounds. Broader faction music
assets and legacy building-emitter integration are still future work.

Both result panels show X Units Remaining, counting living wounded survivors.
Only an explicit terminal `BattleVictoryResult.retreated_side_ids` entry adds
“Retreated from battle” to the defeated side. Tactical flee execution is not yet
implemented; its eventual resolver must supply this field. Tactical Fall Back,
a wounded unit moving rearward, and merely having survivors are not terminal retreats.

The intro displays NEW BRIARPORT POLICE DEPARTMENT on two lines, transitioning to
NBPD as the context card contracts. Compact battle HUD cards display their actual
weapon model under the class, with room reserved for orders and wounded status.
The final recording holds victory cards five seconds longer; continuation controls
in gameplay are unchanged.
