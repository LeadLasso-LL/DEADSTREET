# Faction radio interior treatment

Restrained interior coloration for the 21 mapped faction snippets. Each source has a private 6 dB/oct low-pass bus: 2,400 Hz for vehicles, 1,800 Hz for defending buildings. Bass is preserved with no gain boost, distortion or reverb. The existing smooth winner outro mix opens that source alone toward 7,500 Hz without restarting the loop.

Three integration lines in tactical_convoy_audio.gd attach/update the helper. Existing world anchors, arriving vehicle poses, intro gain, combat ducking, distances, loop assets and timing remain intact. Menu music and TRC/NBPD sirens keep their existing routes and audio. Source exit removes its own bus.

Validation: 141 native Godot checks passed, covering all 21 faction mappings, three layouts, real 30-second loop wraps, before/after spatial and gain equivalence, isolated winner transitions, existing authority behavior, and bus cleanup without touching an unrelated bus. Eight signal/protected-file checks also passed. measured_response.json contains the actual captured frequency response. This is native and measured validation, not an independent listening approval.

Re-run check_native.gd with the project Godot executable, then analyze.py. The probe WAV and before_tactical_convoy_audio.gd are narrow test fixtures, not game assets. Raw .f32 captures are disposable measurement output. Do not re-run install.py after application.

Scope excludes concurrent Harold geometry, Arsenal and menu work. Existing user faction assignments remain unchanged, including Calle Ocho -> Glock — B-22.

Final tuning: the initial FILTER_12DB setting was too enclosed on measured response. Final FILTER_6DB setting is deliberately gentler: bass120Hz changes only -0.02/-0.04dB; 4kHz changes -11.74/-15.74dB for vehicle/building, and -1.95dB at the winning foreground setting. These are the measured responses; the engine setting name is not used as a substitute for that evidence.
