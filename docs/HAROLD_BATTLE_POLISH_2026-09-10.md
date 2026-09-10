# Harold battle polish — September 10, 2026

User scope: complete battle intelligence/flow review, deployment, and battle presentation; improve gun audio while preserving the heartbeat. Discuss the second map before building it. Broader campaign work remains deferred.

## Battle flow

The baseline exposed cached staging holds that could persist without any further shooting: seed 2003 Push was still active at 180 seconds with 164 seconds of silence; seed 2005 Focus Right had 170 seconds of silence. Explicit all-Hold at long range is a legitimate standoff, not a defect to override.

Healthy units under Push or a flank command now reconsider a firing position after ten seconds without movement or a successful shot. A recovery bound must lead to unoccupied, reachable cover, face the threat, improve distance by at least two world units, and stay within an eleven-unit step / fourteen-unit path. Searches are throttled to once per three seconds and complete a selected bound before replanning. Wounded survival, individual player orders, Defend Position, Hold, Fall Back, and the adaptive AI's local safety checks take precedence. Recovery decisions are recorded alongside force decisions; combat damage and random outcomes are unchanged.

The clean four-opening comparison resolved the three aggressive cases in 18.53, 16.03, and 23.67 seconds. The Hold case remained quiet as ordered. Six additional Close/Medium/Far trials resolved in 18–35 seconds. All six were defender victories: this is flow validation, not evidence of balanced win rates.

## Deployment and presentation

- Close, Medium, Far arrival anchors are selectable before commitment.
- Changing arrival clears uncommitted attacker placements; the player can place units manually or use Auto Cover, then Confirm Deployment.
- Four separately rendered open doors use the approved sedan paint and glazing palette.
- Each door has an ordinary cover object, slot, and movement footprint. Cover remains available during combat.
- Four disembark routes use front/rear origins; canonical positions and combat time do not change during the cinematic.
- The persistent context panel is 476 rather than 620 logical pixels wide, preserving its height, text sizes, emblems, and seamless transition.
- Authored ground is rebuilt if a geometry refresh removes its retained surface node, preventing missing road/sidewalk art after deployment updates.
- The existing two-faction result animation retains exact HUD cards and waits for Continue.

## Audio

Twelve weapon-only waveforms replace the original gunshots. The revision uses a short broadband crack, irregular low-frequency pressure body, distinct weapon decay, filtered irregular street reflections, and restrained mechanical detail. A brief 2.5–3 dB ambience/music duck gives shots room without permanently raising the mix.

The original city, apartment beat, engine, footsteps, impacts, reload, and start/heartbeat assets are preserved byte-for-byte. No third-party audio or paid assets were used. Waveforms and encoded mix are checked for valid samples and clipping; subjective sound quality still benefits from the user's listening review.

## Review

See `docs/references/battle_polish` for validation reports, simulation traces, recording metadata, and captured visual evidence. `tools/battle_polish/review.gd` records an ordinary 4v4 fight with an initial covered pause followed by the player's Focus Left order. Defending Saints receive no staged orders, damage edits, or forced result.

Still deferred: a second battlefield, broader campaign UI, morale/intelligence/fog-of-war design, and campaign expansion. This pass does not claim general AI balance across maps.

### Campaign handoff finding

The existing bridge forwards the winning side as an attacker-won boolean to the campaign HQ resolver. It does not forward individual tactical health or wound records; the Soldier model has no health/wound fields. Exact per-unit aftermath persistence therefore remains campaign work, rather than something this battle presentation pass can claim to have completed. Tactical result cards remain accurate and the Continue gate is verified.
