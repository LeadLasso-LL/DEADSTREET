# Harold battle effects, aftermath, and audio

The approved map and battle presentation remain the baseline. This pass implements the requested stronger blood, faster exposed cover moves, unobscured victory actions, cleaner hit feedback, and original apartment music.

## Combat feedback and movement

- Hit spray has six fragments instead of five, with slightly larger droplets and spread.
- Wounded trails leave modestly larger drops at 11 pixels / 0.7 seconds of movement instead of 13 / 0.8.
- Death pools grow from 3.1 to 3.55 base size and seven fragments instead of six.
- No hit circles or floating combat-state text over bodies. Projectiles, muzzle flashes, blood, and HUD states remain.
- Exposed navigation toward a reserved or explicitly ordered cover slot uses a temporary 1.18 movement multiplier. Occupied cover, ordinary moves, dead units, and unrelated destinations do not qualify. Base movement speed and wounded penalties are preserved; collision and waypoint limits still apply.

## Victory aftermath

Results are snapshotted at resolution and remain hidden until survivor routes and settling actions finish. Continue becomes available after the results fade in.

| Result | Survivors' action |
|---|---|
| Attacker victory | Navigate to the objective doorway and enter |
| Defender victory with fallen comrades | Approach reachable positions beside a fallen teammate and kneel to check them |
| Defender victory without casualties | Regroup at the objective entrance; wounded enter, healthy survivors aim outward |

Routes use actual map navigation, staggered starts, and separate approach positions. The dedicated ten-frame `check_comrade` clip lowers the weapon and settles into a kneel. It is built from the approved outfit/rig sources in all eight directions. Footsteps continue during aftermath movement.

Aftermath is presentation-only: it does not alter the result, vitality, wound state, or canonical battle positions. Campaign consequences remain deferred.

## Original audio

Weapon revision 3 removes the delayed reverberant repeats and diffuse noise wash, using short pressure cracks, irregular low body, and restrained mechanical detail. Three deterministic variants remain per weapon.

The replacement apartment instrumental is original procedural synthesis: 72 BPM, four bars, sustained/sliding 808 bass, eighth-note hats (every two sixteenth-note steps), and snares every eight steps. A 780 Hz wall filter muffles the percussion. The seamless loop is attached to a reusable positional apartment emitter and ducks slightly during gunfire. No external recordings, music, or licensed samples are used.

`tools/battle_audio/build_audio.py` rebuilds the base sounds and then applies the current weapon and apartment generators. `APARTMENT_TRAP.json` and `WEAPON_REVISION.json` document those outputs. The heartbeat/start and nine other ambience/foley assets are checked against `aed913a` for exact byte identity.

## Reproduction and review

- `tools/battle_finish/validate.gd`: cover-movement measurements, all three outcome fixtures, navigation, final poses, result timing, and canonical-state preservation. `--visual` writes review captures.
- `tools/battle_finish/build_check_pose.py`, `render_check_pose.gd`, and `finish_check_pose.py`: generate and palette-match the separate aftermath atlas. The main showcase builder leaves this auxiliary clip to that pipeline.
- `tools/battle_finish/record.ps1` and `encode_video.py`: capture an actual 4v4 with covered deployment, intro, combat, aftermath, and results, then produce H.264/AAC MP4.
- `docs/references/battle_finish`: validation and capture evidence. Outcome fixtures intentionally exercise each branch; they are not presented as ordinary battle outcomes.

The audio receives waveform, loop-boundary, import/playback, and full recording decode checks. Perceived gunshot realism remains a listening judgment for review. Seed trials are samples, not an AI balance guarantee; some command/cover combinations can remain unresolved.

## Verified delivery

The targeted finish suite passed 115 checks; the existing presentation suite passed 121 and the showcase suite passed 717. The selected recording uses seed 2002: 44.77 seconds of combat, 69 shots, and two surviving defenders. Its 8.58-second aftermath completes with no route errors before the results. Total MP4 duration is 72.13 seconds, 1920×1080 at 30 fps with H.264/AAC. The decoded mix peaks at -10.37 dBFS.

Sample 2003 remained active at the 180-second review cutoff; no artificial result or forced damage was applied.
