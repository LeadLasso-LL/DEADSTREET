# Exact cover positions and command confirmation
Status: implemented and focused native/renderer validation passed, 2026-09-15. Owner playtest acceptance pending.

- With one healthy friendly selected, quick-click cover retains automatic slot selection.
- Hold left-click on cover for 0.25 seconds to reveal currently available, reachable existing slots. All markers share a silverish-white color, unaffected by night lighting.
- Move the pointer to highlight the nearest slot and preview its yellow route. Existing orders continue until release; previewing never reserves cover.
- Release commits that exact slot after fresh legality/reachability checks. Other slots disappear. The confirmed marker stays for 0.5 seconds, then fades over 0.25 seconds. The selected unit's command path remains independent of this marker.
- The cover artwork temporarily fades while choosing; normal opacity and existing occlusion effects return on completion/cancellation.
- Escape, right-click, release over HUD/outside viewport, losing window focus, or losing the selected unit cancels. Dragging before the hold threshold remains box selection. Unit emblems and bodies retain input priority when beginning a gesture.
- Group cover quick-click behavior and autonomous unit cover management are unchanged. Freight railcars use their existing corner/end positions; this feature does not add geometry slots.
- Accepted move, target, cover, hold, push, fall-back, clear and cover-release commands acknowledge through the existing mechanical/two-tone sound family. One sound per input, including repeated orders during pause. Single-unit orders have a subtly higher pitch; group receipts retain original pitch. Unavailable orders use the existing failure tone. Audio toggle applies.
- Gesture timing, marker fade, previews and acknowledgment run independently of paused simulation time.

Source: gameplay/tactical_cover_picker.gd, tactical_orders_controller.gd, tactical_command_feedback.gd, tactical_order_audio.gd.
Evidence: tools/cover_slot_picker_20260915/validation.json and native/visual/railcar result files (246 checks).
The saved standalone friends-playtest package predates these changes; release owner will rebuild after the owner finishes current playtest fixes.
