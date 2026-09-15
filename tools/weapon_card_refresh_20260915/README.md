# Current Arsenal weapons in unit cards

Implemented: distinct curved trigger blades and truly open guards for all six shotguns, Ruger Mini-14 and AUG. The AUG keeps its larger hand guard. The SVG-native display generator now includes weapon_trigger_art.py, so regular icon rebuilding retains these refinements.

All 691 reachable cards now hold the current Arsenal source SVG artwork: 23 factions x 30 regular gun models plus both weapons in Mercer's dual-Glock specialist portrait. This includes the latest pistol/SMG detail, M4, AK-47 and all six sniper designs. The existing shared card paths update glossary, setup and tactical portrait consumers together; no runtime UI edits were needed.

The exact accepted anatomy-corrected SVG source is retained. Only weapon child groups are replaced. Hand transforms, body/outfits, connected shoulders, face, stance and 90x80 crop remain intact. Sniper artwork uses a uniform 0.9 scale about the existing right grip to fit the frame without resizing the unit; the firearm itself is the same canonical artwork. World animation atlases and gameplay weapon stats were not regenerated.

Validation:
- 691 installed baseline crops matched accepted source renders exactly before modification.
- 1,382 SW/SE structural comparisons preserve every non-weapon SVG node.
- All 691 updated images installed and recorded in assets/data/unit_card_weapon_art.json with current source and image hashes.
- Native Godot catalogue binding, loaded pixels, every canonical faction/model combination, actual glossary images, and eight Arsenal icons: see native_validation.json.
- Framing check covers both views of every card; zero new side clipping after the sniper fit.
- Visually inspected all 30 gun designs in Mercer cards, all 115 faction/class glossary portraits, eight trigger illustrations, and native Mercer/Orlov pages. Owner acceptance remains separate; no combat benchmark was needed for static card art.
- The initial icon equality test did not account for the configured fix_alpha_border import step. Applying the same alpha-edge treatment to the source reference yields exact visible-pixel equality for all eight icons; no tolerance was relaxed or runtime loading changed. Direct PNG byte decoding keeps the test logs free of irrelevant export warnings.

Reproduction: build_cards.py reads accepted_card_sources.zip and accepted_baseline_renders.zip, then renders current Arsenal SVGs using render.gd and the existing palette rules. Review candidates before installation. install.py requires unchanged baseline target hashes and refreshes only changed imported images through an isolated Godot project; do not rerun it on an already-installed or later-edited checkout without a fresh guarded baseline. check_native.gd verifies the installed result. Before portraits and source art are retained for recovery. Do not crop an older world atlas over the updated card portraits after a future full animation build; finish them from current Arsenal artwork again. unit_card_weapon_art.json can detect stale firearm/card sources.

Scope excludes concurrent Harold HQ vehicle, menu comparisons/SMG labels, music and other chats' changes.

Publication: complete locally; new GitHub publication blocked by automatic approval review pending explicit owner approval. See publication_receipt.json and Hive weapon-cards-05. Refresh publication-plan README hash and own record additions before executing publisher after approval; do not rerun asset production.

Owner explicitly approved this artwork batch for GitHub publication in the following turn. The prior approval-review blocker is resolved; final publication_receipt.json records verified completion.
