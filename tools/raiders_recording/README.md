# Stateline Raiders attack NBPD — scripted battle recording

Requested by Brandon on 2026-09-14: resume the battle video; Stateline Raiders MC
attacking NBPD; use tactical commands when appropriate, not as a controls demo.

The live bridge sandbox supplies arrivals, disembarkation, combat audio, faction
art, casualties, victory and aftermath. Scripted player decisions use the current
public tactical-order controller. NBPD is autonomous; no hit, health, damage or
winner manipulation. Twelve participants per side, unit tier 2, patrol vests,
normal class-default weapons. Raiders: Ironhorse trio / Mesa Crew pickup / Ironhorse trio (seven bike occupants, five in the pickup including two in the bed);
NBPD: Interceptor / Warden / Bulwark convoy. Seed 9141.

`../tactical_controls/raiders_director.gd` owns the reproducible setup and decisions:
advance a stalled assault element through cover, hold support after actual covered
contact, release support that loses contact, and withdraw a damaged isolated fighter
only if locally outnumbered. Commands can be absent when their conditions do not occur.
`raiders_probe.gd` checks pacing under ordinary runtime. `raiders_record.gd` captures
the actual arsenal scene, smooth camera movement, full arrival, fight and aftermath.

Capture uses official Godot 4.7.2 release Movie Maker at 30 FPS. `encode.py` creates
H.264 / AAC / yuv420p / fast-start MP4 with short endpoint fades, validates decoding
and audio, and extracts a six-frame visual review. Large media/transfer pieces are
ignored by Git; the shareable video is attached in the conversation. JSON reports
are the exact runtime/command/media receipt. Performance metrics from Movie Maker
must not be compared with normal-play performance.

Packaging uses `tools/tactical_controls/run.py pack` and a recorder-only `override.cfg`
inside that temporary launcher pack to set 1920×1080 before Movie Maker initializes.
The production project settings are unchanged. The new convoy presentation and audio are production code; see [arrival rules](../convoy_arrival/README.md). Rebuild the normal
launcher with `run.py pack` after recording. The recorder's first trial used an invalid
optional diagnostic call; it was stopped before combat, corrected, and not delivered.

Run `python tools/raiders_recording/record_worker.py` for the bounded capture/encode job; it restores the normal preview launcher automatically.

Next: Brandon reviews the video, arrival, audio and command feel. Whittaker Estate remains deferred.

Phone sharing: `python tools/raiders_recording/mobile_export.py` creates the 1280×720
H.264 copy with the verified AAC audio unchanged. `mobile.json` records its exact
size/hash and the full-HD master hash. The September 14 recording is 112.64 seconds;
the mobile copy is 15.52 MiB. Full-HD master retained on the build machine.


## Final original-audio recording — 2026-09-14

Current deliverable: `Dead_Street_Raiders_Victory_Mobile.mp4`.
Master: `Dead_Street_Raiders_Victory.mp4`. Earlier videos are superseded.
Build the original radio with `python tools/convoy_arrival/build_audio.py`, then
run `record_worker.py` for capture, master encode, mobile export and pack restoration.
The encoder requires a resolved attacker victory and clean arrival/outro routes.
`record.json` contains the full disclosed showcase loadout, seed and original-radio
provenance. `original_source_hashes.json` records sources at capture. Lane/arrival
validation has 102 checks; the final capture validates runtime/audio/export separately.
No third-party music or credit overlay is part of this final recording.


## Revised sparse radio and combat fade — 2026-09-14

The current `Dead_Street_Raiders_Victory_Mobile.mp4` supersedes the earlier 102 BPM
radio delivery. Current cue: 84 BPM Drop-A, twelve sustained chord attacks over
eight bars. `record.json` includes `radio_gain_samples`, verifying -18 dB arrival
and -32 dB or lower in combat. `heavy_radio_source_hashes.json` captures this
revision's inputs. Same capture/export commands and Raiders-winning fixture.
ATTACKING is under the attacker name; ROAD BLOCKADE is at the context top right.
Owner listening approval remains pending; file/telemetry checks do not imply it.
