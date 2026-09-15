# Sandbox equipment comparison and SMG casing — 2026-09-15

IMPLEMENTED / NATIVE-VALIDATED. Reopen the usual live-source Sandbox launcher.

## Owner request and behavior

Brandon requested uppercase SMG in force composition, then direct gun comparisons by clicking one and hovering another. He extended the same interaction to Vehicles while implementation was underway.

- SMG is uppercase in both sides' Add Unit pickers, every existing unit class picker and the unit tooltip. Internal class IDs remain unchanged.
- In Arsenal or Vehicles, click an item to select the baseline; hover another for a side-by-side comparison with signed **hovered minus selected** differences. Before an explicit click, the page retains its ordinary single-item details.
- Baselines persist across class/category tabs and are independent for guns and vehicles. Click another item to replace the baseline. Hover the selected item to restore its normal details. Changing categories or leaving the page clears the hovered comparison but retains the selection.
- The last hovered comparison stays visible when the pointer enters the detail pane, so its full stat list can be scrolled without disappearing.
- Green marks a beneficial change, red a drawback, and an em dash means no displayed change. Lower cost, aim/reload time, recoil per shot and miss chance are beneficial. Graze probability, vehicle dimensions and door counts remain neutral tradeoffs. Percentage deltas use percentage points, not relative percentages. Rounded zero never renders as negative zero.
- Guns compare all 17 existing Arsenal stats from BattleWeaponCatalog. Their normal detail rows use the same formatter and source values. Vehicles compare ten common stats: price, seats including driver, road movement, upkeep, resource capacity, cover, doors and three dimensions. Cover is Yes/No and Added/Lost. Special cash/custody capacities and ability descriptions/limits are shown beneath the common vehicle comparison as applicable.

## Scope and evidence

Runtime: gameplay/equipment_comparison.gd plus narrow changes to sandbox_glossary_panel.gd and sandbox_force_builder.gd. No tuning, prices, catalogues, audio, portraits, vehicle ordering or gameplay behavior changed. Existing glossary Faction Audio source and lifecycle wiring remain untouched. Preserve concurrent Harold HQ-car/range/opening work.

Official Windows Godot 4.7.2, D3D12 Forward+, GTX 1650 Max-Q: **3,736 checks passed, zero failures**, native process exit 0 and no engine/script errors. Checks cover all 30 guns and 75 vehicles against canonical values, signed differences, all 75 vehicle price-order positions, actual clicks and hovers, cross-category baselines, reselection, scroll persistence, page cleanup, SMG pickers, neutral tradeoffs and formatting. Comparison layout checked at 1152×860, 1280×720 and 1440×1000. No battle/performance benchmark or subjective owner acceptance claimed.

Visually inspected the SMG setup, cross-class gun and vehicle comparisons, scrolled gun stats, 720p layout and bank-vehicle special-role detail. Screenshots, native_validation.json and native.log are here. Reproduce with official Godot `--path <repo> --script res://tools/arsenal_compare_20260915/check_native.gd`. The fixture runs an isolated scene and does not save owner preferences.

## Continuation and publication

before/ and baseline.json preserve clean original affected sources; before/.gdignore excludes backups from Godot imports. install.py is a guarded, single-use installer, not a script to rerun on current live source. source_diff.patch and validated_sources.json document final changes. Shared-record staging uses only this task's owned additions against the latest HEAD; do not stage the mixed working documentation wholesale.

Previous Faction Audio checkpoint 50a000753b04c7115bfeef48cb46dea0b2ddbbd4 was explicitly approved, pushed and verified. No prior publication blocker remains. This comparison checkpoint's actual publication outcome is in publication_receipt.json. Implementation and native verification are complete; reopen normal Sandbox for owner review.
