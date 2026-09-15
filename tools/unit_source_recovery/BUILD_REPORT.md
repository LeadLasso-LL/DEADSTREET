# Dead Street — approved queue build report

Date: 2026-09-09

## Queue status

| Approved item | Result |
|---|---|
| Cover animations | Built as review candidates: duck/rise/fire/duck and a crouched edge lean. Actual cover height and threat-relative exposure still need live-game matching. |
| Wounded and death animations | Built hit reaction, reduced-stride injured locomotion, and a fall ending in a held ground pose. |
| Reloading and weapon handling | Built magazine-hand motion and return to support grip for pistol, SMG and AK; earlier raise/lower/fire work is preserved. |
| Integrate into the tactical game | Blocked. The desktop connection was offline on initial and subsequent checks. No live repository changes were made. |
| Small street firefight and performance test | Live test blocked by the same access issue. A separate scripted street animation rehearsal was produced and labeled accordingly. |

## Deliverables

- Six action clips across three outfits, three shared weapons and eight directions: **432 clips / 12,672 frame entries**.
- 54 transparent sprite atlases, an action manifest, and editable Python/SVG source.
- A self-contained action reviewer with independent outfit/weapon selection, frame scrubbing and slower playback. Non-looping clips hold their last frame; death does not automatically restart.
- Six default Russian-mafia/AK GIF previews.
- A 13-second scripted street rehearsal using the recovered detailed scenery, with three outfits, depth-sorted objects and movement/facing tied to the scripted route.
- An integration handoff describing clip timing, anchors, equipment keys and checks for the actual presenter/catalog.

## Corrections made during review

- Corrected a side-view fall that initially only crouched.
- Reworked final leg placement so front/rear falls no longer leave a leg sticking out vertically.
- Let the hands settle away from the firing grip during the fall; the gun stops rendering as the body falls. Persistent dropped equipment is not implemented.
- Reduced excessive sideways torso tilt in front/rear crouches.
- Reviewed magazine removal, belt reach, reinsertion and support-hand return across all three weapon types.
- Moved the scripted car and dumpster users out of those objects' footprints and behind them before reviewing occlusion.

## Validation and limits

All 12,672 frame entries were decoded and checked for nonempty 128×128 output. Contact sheets were visually inspected across cover/fall directions and reload stages. The approved parent-source hashes remain unchanged. Reviewer JavaScript was syntax-checked; the browser controls were not exercised in a live browser. The street video was exported and its composition inspected.

These are **visual review candidates**, not automatic product acceptance. Pixel-level shape checks and a scripted video do not establish tactical AI, line of sight, protection from cover, combat balance, ammo handling, animation interruption rules, frame pacing or multiplayer behavior.

The action clips animate in place. Integration must synchronize movement with distance traveled and use simulation events for firing, reload completion, injury and death. The scripted rehearsal provides a scenery/scale check, not a substitute for that work. No casualty persistence, stat changes, loot rules or new faction restrictions were introduced.

## Remaining work when desktop access returns

1. Inspect the live repository and preserve its existing dirty changes.
2. Map preview equipment keys and clips into the existing presenter and animation catalog.
3. Bind simulation-controlled movement, target facing, cover exposure, reload and casualty states.
4. Run the approved small street firefight in the actual game, fix findings and report measured behavior.

The remaining queue stays authorized. The blocker is access to the laptop, not a missing creative decision.
