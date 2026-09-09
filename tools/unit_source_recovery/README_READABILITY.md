# Editable unit source recovery and readability pass

Recovered from the user's saved dead_street_action_queue.zip.
The source now lives beside the Godot project; cloud scratch is not required.

Changes:
- Fuller upper arms, forearms and joined elbows.
- Lower elbow positions to reduce compressed bends.
- Separate near-black weapon contours.
- Steel-grey Uzi receiver with dark grip, magazine, barrel and stock.
- New Uzi finish respects detached magazines during reload.
- Existing unit outline and native pixel sampling retained.

Build from repository root using the task-local Python installation:
1. python tools/unit_source_recovery/export_review.py
2. Godot --headless --path . --script tools/unit_source_recovery/render_native.gd
3. python tools/unit_source_recovery/finish_review.py
4. Review arms_review.png and review_atlases before copying to assets/art/units/pixel_v1.
5. Import in Godot and run tools/dusk_review/runtime_review.gd.

Python dependencies: numpy and Pillow.
Windows installation: %LOCALAPPDATA%/DeadStreetTools/python/python.exe.
Godot renders the SVG sources; Inkscape is not required for this export path.
Frame layout, counts, playback rates and equipment grip anchors remain unchanged.
Exported idle/aim/fire poses use explicit settled parameters in export_review.py.
Other action states come from the recovered render.py state functions.
Muzzle flashes are handled at runtime.

Previous sprite files are backed up outside the repository in
dead-street-before-pixel-integration/before_arm_readability.
Generated intermediate SVGs and review atlases are reproducible and not committed.
