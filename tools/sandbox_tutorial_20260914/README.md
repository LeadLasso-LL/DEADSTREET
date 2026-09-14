# Sandbox Tutorial — 2026-09-14

IMPLEMENTED / VALIDATED. Owner review pending.

Open the current project sandbox scene (`gameplay/arsenal_review.tscn`) and choose **TUTORIAL**. The new panel uses a real frozen Harold Apartments battle: Mercer Saints attacking Orlov Bratva, five units per side, approximately 13 seconds into combat. It starts no simulation and changes no campaign state.

## Player behavior

- Hover or tap HUD controls, card fields, units, faction markers, cover, buildings or open ground for concise gameplay help. All six group selectors use the same explanation.
- The hovered target receives a pale tan border, translucent fill and subtle glow. One rectangular popup follows the target and stays within the viewport.
- Scroll to zoom, middle-drag to pan, Fit Image to reset; Show Hotspots reveals available help regions. Arrow keys browse help when the image has focus. Close or Escape returns to the menu.
- Help follows the current controls: left-click selected-unit move/cover/priority-target orders; Push/Fall Back line placement and cancellation; Hold nearby cover; Clear Orders; automatic aim/fire/reload; wounded survival behavior. It makes no promises about unimplemented systems.

## Files and capture

- `gameplay/sandbox_tutorial_panel.gd`: self-contained CanvasLayer overlay.
- `gameplay/arsenal_review.gd`: six added lines for the menu entry and open method.
- `assets/tutorial/harold/harold.png` and `harold.json`: captured image and 126 source-coordinate help regions. Keep them together; recapture both when the HUD/map changes. Image loader supports imported textures and raw review packs. Include the JSON in exported packages.
- `capture.gd`: real five-class fixture, actual current HUD rectangles, map cover geometry and unit locations; native 1440×1000 screenshot. Cover visual bounds extend above ground footprints.
- `run_capture.py capture|smoke|record`: separate release executable/PCK under local DeadStreetTools/sandbox_tutorial_20260914. Frozen production source snapshot plus current owned menu/panel files; never overwrites the shared release pack. Uses the installed official Godot 4.7.2 release and existing benchmark asset pack. Read `snapshot.json` and `source_hashes.json` for provenance.
- `validate.gd`: native menu click, region reachability and priority, popup bounds, wheel/fit, hotspot toggle, keyboard browsing, close/reopen, duplicate-open prevention and no-battle-state checks.
- `encode_video.py`: H.264/yuv420p/faststart preview; full decoding and SHA-256 transfer verification.

## Validation and limits

73 native checks pass with zero failures in both smoke and recording. All 126 regions are reachable. Tested at 1440×1000, 1152×860, 1280×720 and 390×844. Narrow-window popup/Close remain in bounds. Desktop rendering, Push and cover popups, and narrow layout were visually reviewed. This checks a resized desktop window, not a physical phone; touch input support is present but no physical touch device was tested.

The first harness omitted the release half of a synthetic wheel event. This retained GUI mouse capture and prevented subsequent header clicks. Sending the matching release fixed the harness; the panel required no workaround. Final smoke also validates the raw-image fallback after adding imported-texture support.

This is a static tutorial, not a playable training mission. It reflects the pictured battle state. The shared release runtime was deliberately preserved while other chats own audio/title previews; future normal pack/export work must include the tutorial image and JSON. No combat, balance, global-cap or performance change; no broad regression or benchmark rerun.

## Preview and handoff

`Dead_Street_Tutorial_Preview.mp4`: 37.1 seconds, 1440×1000, 30 fps, silent H.264, 1,418,470 bytes. SHA-256 `26f0ae3c8fc24f36effccc58b8c5ed381fb1eadfaf24e102158fa89cad5ab95f`. Full decode passed. Saved preview identity: `libfile_d56b156bea7c81919ef35265ee17c7a9`, version 0. `delivery.json` records encoding/transfer evidence.

Next: Brandon reviews the tutorial. Coordinate any future native opening-menu integration with this existing Tutorial entry; preserve BUILD's faction-audio preview scope. Source publication is recorded in `checkpoint_receipt.json` and the journal.

Publication: source checkpoint `04034d81fc1727bcefa3f261c59ee6bf91dac213` is pushed and verified on `origin/build/arsenal-checkpoint-20260911` after Brandon's direct approval. The previous automatic-approval block is resolved. Visual review remains pending.
