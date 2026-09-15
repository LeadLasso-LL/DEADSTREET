# Doble Ocho revision and Ravicci raid — 2026-09-15

Status: implemented, native-validated, video delivered for owner review. Uncommitted/unpushed; index empty. Current HEAD9604323afae49ee63915b378048cfac9940f1f66 includes concurrent menu-only work.

## Owner changes
Yard70→86units wide (+22.9%), map112x70. Six-/seven-a-side concept and1.6fleet scale retained. Continuous sidewalks, dropped-curb gate aprons, connected neighboring shops/backlots, road dumpster relocated to interior pad. Incoming yard radio gain+10%linear only before combat. Shared combat/winner mix and music assignments preserved.

## Final film
Ravicci Family assaults Calle Ocho. Seven tier-three attackers vs seven tier-two defenders, stock weapons; Monarch4passengers/Obsidian3. Assigned Bond track spatially in arriving transport. Native seed91517, scripted tactical orders,23.90s combat,three Ravicci survivors. No health/damage/RNG/winner overrides. This is an owner-directed winning showcase, not balance evidence. The reusable sandbox preset remains Sierra Roja.
Remote: ravicci/DEAD_STREET_Ravicci_Raid_Doble_Ocho.mp4;53.7967s,1280x720@30,H264/AAC fast-start,7377431bytes. SHA256 ec3fdff9efa7bae722f4abe833df58b72b99bc5367a864a140f621db3b3e38c6. Native movie viewport1152x648; delivery upscale1280x720. Full decode/audio finite peak0.49665; visual intro/combat/results inspection complete.
Saved video: libfile_256c8cb686c48191b888746f6984d2ad v0. Screenshot: libfile_c8ff339d0d6881918a267f3f3eaf2dcd v0.
Chat files: /workspace/scratch/6a4bd31e258d/yard_revision/DEAD_STREET_Ravicci_Raid_Doble_Ocho.mp4 and DEAD_STREET_Doble_Ocho_Revised.png.

## Evidence and scope
229native cover/exit/spacing/routes;68820approach collision sweep;55map integration including6v6 and other-map starts;8Ravicci cast/audio checks. All pass. Camera/arrival/outro zero errors. See ravicci/{record,first_pass,approach_review,integration_review,delivery}.json; shared integration_review.json; preservation.json.
Four production scripts modified: battle/geometry/doble_ocho_catalog.gd, gameplay/doble_ocho_setup.gd, gameplay/doble_ocho_art.gd, gameplay/tactical_convoy_audio.gd. Generated assets/art/doble_ocho/ground.png and isolated tool scripts. Exact pre-edit bytes in before/; immutable248-source baseline.json.244other production scripts intact;251capture hashes intact. Music catalogue was concurrently updated/published by its owner; mappings preserved per that journal.
Initial transfer-added newline tripped installer. Auto-review blocked baseline reset; original backup/SHA comparison proved live files unchanged, verified_install.py uses immutable byte guards. Initial art loop parse typo corrected. Earlier Sierra revision film retained separately (defenders won); final Ravicci film is the deliverable.

## Continue / reproduce
Live source Sandbox shortcut picks up map edits. Select Doble Ocho preset for reusable7v7; select Ravicci and matching convoy/tier config manually to match film. Tool capture config in ravicci/capture_config.gd. Source guards forbid overwriting existing raw capture: use a new take directory before rerunning ravicci/run_all.py. Rebuild plate via run_native.py bake only after art edits. Record_worker.py validates/freeze-hashes native source and invokes encode.py.
Next: owner visual/play feedback; preserve mixed Harold/range/map/menu/art work. Do not blindly stage shared files. Earlier first-map publication dependencies in tools/fourth_map_20260915/README.md remain. Harold cover/stairs and broader performance/full regression remain separate; this revision does not resolve them.
