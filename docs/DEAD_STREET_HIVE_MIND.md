# Dead Street — Hive Mind

**Shared entry point for all future chats.**
Established by Brandon on 2026-09-13. Maintained by the assistant doing the work.
Coordination last reconciled: 2026-09-14, after the corrected Whittaker Estate recording.
Gameplay evidence: fresh native runs, scoped checks and deterministic replay; see current report.
This is a saved record, not an automatic feed of activity in other chats.

## The rule

**Record everything needed to preserve the intent, reasoning, current state,
and next step of Dead Street development. Update the record during the work,
including meaningful discussion that changes no code. Brandon does not have
to request documentation or prepare handoffs.**

The record must let the next chat answer: what are we building, why, what is
accepted, what is unfinished, what failed, what changed, and what should happen next?

## Where each kind of truth lives

| Record | Owns |
| --- | --- |
| [AGENTS.md](../AGENTS.md) | Short startup and mandatory recording instructions |
| **This Hive Mind** | Reading map, collaboration rules, active ownership, immediate continuation and unresolved handoff gaps |
| [Journal](DEAD_STREET_JOURNAL.md) | Dated decisions, rationale, corrections, experiments, results, work events and source provenance |
| [Project Control](DEAD_STREET_PROJECT_CONTROL.md) | Canonical milestone/feature status, architecture roadmap and development tracker |
| Topic documents and accepted references below | Detailed product rules, art standards, implementation notes and evidence |
| Git and actual working files | What is committed, what changed, and what exists now |

Use one authoritative home for each fact. The Hive Mind indexes and coordinates
the existing tracker; it does not replace the tracker or duplicate the full GDD.
A dated snapshot stays a snapshot. Update live state in its owning record.

**Precedence:** latest explicit Brandon decision → current accepted design/standards
→ current implementation evidence for what exists → validated milestone records
→ older concepts → speculation. Resolve conflicts explicitly in the journal.
Existing code does not automatically mean approved design.

## New-chat startup

1. Read AGENTS.md, this file, recent journal entries, and current dated Project
   Control milestones. Read older/topic material when the task requires it.
2. Verify the repository/branch/HEAD, status and affected source. Check whether a
   recorded active pass has finished before overlapping its work.
3. Inspect uncommitted/untracked work as well as commits. Record what is yours;
   preserve unrelated work and unfinished experiments.
4. Identify the current task, last accepted result, unresolved decisions,
   validation state, and exact next action. Resolve concrete gaps from the
   linked records or a targeted question; do not invent missing context.
5. Update the work register when ownership/scope changes, then proceed under the
   existing authorization. No ceremonial reapproval or full transcript export.

## Repository and access

- Development PC: DESKTOP-7CL4DM3.
- Device identifier: 01064661-3272-4194-85ad-718eef125dd5.
- Repository: C:\Users\brand\OneDrive\Documents\dead-street
- Documented origin: https://github.com/LeadLasso-LL/DEADSTREET.git
- Observed build branch: build/arsenal-checkpoint-20260911
- Published presentation checkpoint: 555d6925fbf1a965a3b8027bc2f5186fdd19d4bc.
- Verified remote checkpoint: 555d6925fbf1a965a3b8027bc2f5186fdd19d4bc.
- Owner feedback source, handoff and validation evidence are published; version-4 siren/card review next.
- [Standing commit/push authorization](PROJECT_WORKFLOW_AUTHORIZATION.md) applies
  to the established work/destination. Preserve scope and unrelated changes.

A fresh ChatGPT chat must have access to this repository and be directed to this
entry point. Files here do not themselves attach to every chat, update ChatGPT
Project settings, or automatically synchronize an active chat's internal context.

Suggested one-time Project instruction:
“Before Dead Street work, read AGENTS.md and docs/DEAD_STREET_HIVE_MIND.md in the
live Dead Street repository. Follow their documentation and handoff workflow.”

## Current coordination and next action

**Active objective:** Pistol card anatomy pass implemented and validated: 138 regular portraits repaired, all SW/SE static views reviewed, unchanged dual specialist included in 139-entry native check. See journal pistol-portrait-03 and tools/pistol_portrait_20260914/README.md.

**Checkpoint / publication:** PUSHED / VERIFIED: pistol art/source checkpoint 6ebfd61a59562cb3fb2d6636dcf880a92e7186f0 on origin/build/arsenal-checkpoint-20260911. Publication receipt and documentation follow-up accompany this checkpoint. See tools/pistol_portrait_20260914/checkpoint_receipt.json and journal pistol-portrait-04. Estate presentation remains version 6.

**Latest estate evidence:** 834 native HUD checks across bridge/estate and three viewports; 39707 actor-frame checks in final capture, zero presentation/route/HUD camera errors. Version-6 video 88.197s; native combat 48.30s with four Whittaker survivors. Exact accepted-battle comparison and 195 protected source hashes pass; see estate README.

**Earlier bridge evidence:** Normal 24-unit release averaged 59.67 FPS; P95 17.028 ms,
max 33.297 ms, zero frames over 33.333 ms. One five-second window was 57.90 FPS.
The cover shortcut passed 4,545 predicate/replay checks. Current-scale play is
sufficient to resume development; frame dips and larger-battle variability remain.

Read [the bounded cover report](../tools/bridge_perf/cover_close/README.md)
for source ownership, results and reproduction. The earlier
[32-unit report](../tools/bridge_perf/slow_frames/README.md) remains evidence
of unresolved expansion capacity. Revisit performance if current-scale play
regresses, the unit cap increases, or release acceptance requires it.

**Immediate next task:** Owner reviews the repaired pistol cards. Preserve accepted battle/presentation and animation assets. Future atlas rebuilds must reapply the documented portrait finishing step. Native check passes 556 checks/zero failures; no render or repair task remains running.

**Known gaps:**
- Two maximum legal convoys remain the battle ceiling. Three vehicles per
  convoy, legal combinations and final personnel cap are undecided. Raiders now pack up to three motorcycles per slot; this does not settle the global cap.
- Production remains 12 units per side; larger test fixtures do not change it.
- Stable 60 FPS, expansion headroom and final bridge-art acceptance remain open.
- Legacy whole-project core-regression status was not re-established.
- Preserve unrelated character-factory/dusk/source-recovery work.
- Full original chat transcripts were not recovered.

## Required documentation rhythm

**At a meaningful user decision/correction:** record it before dependent work.
Include what was decided, why, scope, source, status and what it supersedes.
If the user has not given a reason, say so; separate any assistant inference.

**During execution:** checkpoint useful experiments, material discoveries,
changes of approach, blockers and recoverable intermediate state. Preserve
failed approaches so future chats do not unknowingly repeat them.

**Before reporting substantive work complete:** update the journal and the
owning topic/milestone records; update this file only if coordination or next
action changed. Save evidence and record tests actually run, limitations,
uncommitted files, commit/push state, and the next step.

**For ideas without implementation:** label PROPOSED/BACKLOG, retain the actual
idea and rationale in the relevant topic/backlog, and link it from a journal event.
Do not turn brainstorming into approved scope.

**At handoff:** leave a current next action, exact checkpoint, dirty/untracked
work ownership, open questions, known failures, results and evidence paths.
The next chat reads those records directly. A full-chat export is a recovery
fallback, never the normal prerequisite.

Routine tool calls, unchanged status acknowledgments, and every transient log do
not need separate entries. Preserve the information that changes future judgment.

## Journal and maintenance conventions

Use dated, unique entries such as YYYYMMDD-topic-01. Include timezone when a time
is known. Distinguish event date from the date historical evidence was recovered.
An entry may cover one coherent decision or completed work pass.

Minimal entry:
- Type/status; source and author/chat.
- Decision/change and reason.
- Affected scope; alternatives rejected or superseded.
- Validation and evidence, or “not run / not applicable.”
- Outstanding work and exact next action; commit/push status when relevant.

Append corrections with a supersedes/reference link. Do not silently rewrite
historical approvals into rejections or erase failed attempts. When shared records
change during your work, reread and merge before saving.

Keep this entry point concise (about 200 lines). The journal is chronological;
when it becomes unwieldy, archive completed older entries under docs/history/,
retain an archive index and unresolved entries, and fix links in the same pass.
Do not create a new competing “master” for each chat.

Keep essential decision/spec text and small accepted reference examples durable
with the project. For large external assets, record persistent location, identity,
version/hash when available, and access route. Scratch paths alone are not a
durable reference. Reports should link to the actual evidence and its fixture.

## Essential reading map

| Topic | Start here |
| --- | --- |
| Current milestones and overall roadmap | [Project Control](DEAD_STREET_PROJECT_CONTROL.md) |
| Map look, scale, collision and construction | [Map standard](MAP_BUILDING_STANDARD.md), [Harold brief](HAROLD_AVE_PRODUCTION_BRIEF.md) |
| Anatomy, shoulders, weapons and visual QA | [Unit art standard](UNIT_ART_STANDARD.md) |
| Weapons, sniper behavior and known regression history | [Arsenal report](ARSENAL_PRODUCTION_REPORT.md), [attacker tactics](ATTACKER_TACTICS_2026-09-11.md) |
| Defender counterattacks and player-order authority | [Relative-strength AI](RELATIVE_STRENGTH_AI_2026-09-10.md) |
| Factions/outfits | [Faction work order](FACTION_WORK_ORDER.md), then the faction's design document |
| Vehicle rules, production and sandbox limits | [Fleet README](../tools/vehicle_fleet/README.md) |
| Individual force/loadout setup | [Sandbox README](../tools/sandbox_setup/README.md) |
| Current bridge revisions | [Bridge README](../tools/bridge_map/README.md), [V3 report](../tools/bridge_map/v3_results/BRIDGE_REVISION_2026-09-13.md) |
| Active performance evidence | tools/bridge_perf/ — inspect timestamps, fixture and source revision; do not assume every report describes latest code |

Historical evidence retains its original dates and limits. Current source, required
diagnostics and reports are included in the performance checkpoint; verify Git
and its remote before making a new synchronization claim.


### Historical Raiders correction — 2026-09-14 (superseded as active task)
The delivered Raiders recording was rejected for wrong-side arrival, synthetic music and route-line clutter. Current task: eastbound lower-carriageway arrival, convincing recorded heavy guitar, sirens 3 dB quieter, no persistent unit paths, verified Raiders-victory mobile video. Preserve the 3-bike / pickup / 3-bike formation. This was completed by the original-audio revision above; owner review is next. Performance and Whittaker remain parked.

## Parallel work register - 2026-09-14

| Chat / owner | Scope | Last verified state / next action |
| --- | --- | --- |
| Existing BUILD chat | Whittaker Estate, recording and subsequent owner feedback | Version-3 battle owner-accepted; version-6 presentation refinement validated and saved, scoped publication underway. Retains estate scope. |
| Parallel assignment chat 3ca0ac6a33c3 | Sandbox interior/top navigation; glossary panels/data; arsenal_review.gd and embedded setup; tools/sandbox_glossaries_20260914/ | IMPLEMENTED / VALIDATED: five top tabs; 23 factions / 115 paired portraits, 30 guns, 75 vehicles. 3,684 native checks pass; 79.63s MP4 saved. Owner visual review pending. PUSHED / VERIFIED: 52c8647 (journal sandbox-glossaries-05). Opening chat must refresh menu scripts/data/assets in its native pack; arsenal_review.tscn entry retained. Tutorial published previously as 04034d8. |

Brandon explicitly directed this chat to follow the shared handoff/update rhythm while awaiting a separate assignment. Preserve existing work; estate remains with the existing BUILD chat. See journal entry 20260914-parallel-onboarding-3ca0ac6a33c3-01. This is a saved ownership record, not an automatic feed of another chat.

## Music controls current - 20260914-music-controls-02

Chat3ca0ac6a33c3 completed outside-click/tap dismissal and pause/play/next icons in the live sandbox_menu_music.gd. Native15 observations PASS; playback/state/inside controls preserved, no dismissal click-through. Existing desktop launcher loads the changes on restart. Full music source remains opening chat's uncommitted ownership; only the owned delta patch/evidence/records are published. Opening chat3438f1ea0e55 should include this already-applied delta in its later opening checkpoint; portrait/audio work unchanged. See journal music-controls-02 and tools/music_controls_20260914/README.md. Owner visual acceptance pending.

## SoundCloud playlist intake - 20260914-music-import-readiness-01

Chat3ca0ac6a33c3 is ready for additional owner-supplied SoundCloud URLs; existing full-audio extraction script and title/artist rules verified. Preserve source titles; brandon becomes B-22, OB remains OB; Dead Street is the explicit signature-title exception. Signature continues through sandbox entry, remains eligible later, and must not repeat immediately after ending/skipping when another enabled song exists. Multi-track queue/Next/exclusions/now-playing behavior will be implemented and validated with actual new imports; only one track currently exists. No new audio or runtime changes in this discussion. See journal music-import-readiness-01. Next: owner supplies URLs. Concurrent portrait/faction-audio scopes preserved.

## SoundCloud track-title rule - 20260914-music-import-title-rule-01

Owner text outside a submitted SoundCloud URL is the intended track title and overrides the source title. Use it as written. URL alone: use the SoundCloud title. This updates the preceding intake rule; source provenance and artist-credit mappings remain. See journal music-import-title-rule-01. Apply to subsequent imports.

## SoundCloud OB extraction test - 20260914-soundcloud-ob-test-01

VALIDATED: Bond by OB retrieved in full from the supplied SoundCloud link under existing settings; no settings change or contact with OB needed. Full strict decode139.598s, duration/hash/size checks PASS. Candidate and reproducible evidence: tools/soundcloud_ob_test_20260914/; see journal soundcloud-ob-test-01. This was the requested extraction-only test: no playlist installation, faction mapping or runtime changes. Candidate/records are currently uncommitted. Next: report result, retain the validated track for expanded shared music catalogue/intake; preserve native intro continuity and concurrent portrait/BUILD work.

## Bond playlist and battle-loop model - 20260914-bond-playlist-02

IMPLEMENTED / VALIDATED: menu now has Dead Street/B-22 and Bond/OB, actual queue/Next/end advancement, persisted selections/volume and unobstructed now-playing popup. Native36 checks PASS. Bond battle excerpt is exactly00:21-00:51,30 seconds, native looping ready; no faction assigned. Shared catalogue assets/data/music_catalog.json + gameplay/music_catalog.gd; full tracks and derived loop share a track ID, while faction assignments stay separate. See journal bond-playlist-02 and tools/soundtrack_import_20260914/README.md for batch workflow, seam processing and evidence. Own new files/assets and applied delta patch saved locally; publication blocked by automatic approval review; original opening/music source remains separately uncommitted. Opening chat must retain combined live music source. Next: owner reviews and sends batch; BUILD coordinates explicit faction bindings/spatial mix. No generated faction audio resumed.


PUBLICATION BLOCKED (2026-09-15 UTC): automatic approval review rejected the proposed scoped commit/push twice. Fresh remote check exactly matched https://github.com/LeadLasso-LL/DEADSTREET.git at ec7a60edaaa7d25493bdae523a6ab44d42148391 and the standing workflow authorization names that destination, but the review still requires trusted explicit user approval for this code/audio payload. No bypass, staging, commit or push performed. Current local implementation works through the existing live-source launcher. New files, patch, README and validation evidence saved. Next publication action: obtain explicit owner confirmation to push the Bond assets/catalogue/music delta and owned records to that GitHub repository, then scoped publish. Other chats' work remains untouched.

## 20260915-bond-playlist-03 - Explicit upload approval received

Brandon replied "approved. report back quickly please." to the exact request to push the Bond code/audio changes to https://github.com/LeadLasso-LL/DEADSTREET. This supersedes the earlier publication blocker. Proceed with only the validated Bond assets, shared catalogue/loader, already-applied music delta/evidence and owned records on build/arsenal-checkpoint-20260911. No gameplay/audio rework or test rerun needed; native36 checks and asset/source hashes remain verified. Existing opening-source ownership and all unrelated work preserved. Publication result will be recorded in tools/soundtrack_import_20260914/publication_receipt.json and the live hive/journal.

## 20260915-bond-playlist-04 - Publication verified

PUSHED / VERIFIED: 269dbeca1382cd0fe3871f17ae140a87b9691282 on origin/build/arsenal-checkpoint-20260911. Scoped new Bond assets/shared catalogue/loader/applied music delta, evidence and owned records published under explicit owner approval. Native36 checks already passed; source/audio hashes reverified before publishing, no rework or test rerun. Local live-source launcher loads the two-song menu; Bond30-second21-51 battle loop ready, faction assignment open. Original opening/music source and unrelated work remain separately owned/uncommitted. Next: owner bulk track submission and explicit faction associations. Receipt: tools/soundtrack_import_20260914/publication_receipt.json.

## Seventeen-track batch ready - 20260915-soundtrack-batch-01

Awaiting17 URLs, each followed by separate artist/title/start-time fields. Format artists exactly OB/B-22, retain owner title, extract30s from that entry's timestamp; artist/timestamp are not title text. Reuse published Bond catalogue/player/loop model269dbec. Plan bounded concurrent downloads with saved progress, one decode/asset pass per track, per-file integrity/loop checks, one catalogue integration and consolidated native UI/loop validation. No new tracks received or processed yet; no faction mappings inferred. Exact plan and revised parsing rule: journal soundtrack-batch-01. Next: owner sends all17 entries.

## Seventeen-track batch complete - 20260915-soundtrack-batch-03

IMPLEMENTED / VALIDATED: all17 supplied tracks (5 OB/12 B-22) imported with owner titles and exact30s excerpts. Catalogue now19 menu songs/18 loops; original signature/Bond retained. Full audio validation and93 native checks PASS, all18 real loop wraps verified. Zero-start Switch/Skyfall handled without shifting starts. No runtime source edits, permission changes or faction assignments. Scope/evidence/batch mappings: tools/soundtrack_batch_20260915/README.md and journal soundtrack-batch-03. Next: scoped publication and owner use through reopened live-source sandbox; await faction associations. Preserve concurrent portrait/BUILD and original opening ownership.

## 20260915-soundtrack-batch-04 - Batch complete locally; publication approval blocked

All17 imports and loops are implemented/file-validated/native-validated;19 menu songs/18 loops,93 native checks PASS. Automatic approval review rejected execution of tools/soundtrack_batch_20260915/run_publish.py because this is a new17-track private code/audio payload to GitHub and the explicit preceding approval covered Bond only. Destination is the established https://github.com/LeadLasso-LL/DEADSTREET.git, branch build/arsenal-checkpoint-20260911. No bypass or retry without new authorization; no staging/commit/push occurred. All unaffected local work/evidence/records are complete and saved.

Exact remaining action: ask Brandon to approve publishing the17-track code/audio batch to that repository. After confirmation, run the prepared publisher: it verifies native93 checks, source/asset hashes, branch/origin/index and exact owned scope; stages34 new audio assets, catalogue, batch evidence and owned docs only; commits/pushes and verifies remote hash. Scripts/payloads in tools/soundtrack_batch_20260915; no rerender/redownload/retesting needed unless current protected hashes differ. Current published HEAD remains269dbeca1382cd0fe3871f17ae140a87b9691282; local sandbox already reads all19 songs. Faction assignments remain open.

## 20260915-soundtrack-batch-05 - Owner explicitly approved batch upload

Brandon replied "approved" to the explicit request to upload the17-track batch to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the publication block in soundtrack-batch-04. Proceed with the validated34 new audio assets, catalogue, batch tools/evidence and owned records on build/arsenal-checkpoint-20260911; preserve other chats' work. No new processing or test reruns unless protected hashes changed. Publication receipt and final status follow.

## 20260915-soundtrack-batch-06 - Seventeen-track publication verified

PUSHED / VERIFIED: 710964102ef3f6cca3f47bcbf26a815653e59453 on origin/build/arsenal-checkpoint-20260911. All17 full MP3s and17 exact30s WAV loops,19-song shared catalogue, batch source/mappings/evidence and owned records published.93 native checks passed; source/audio hashes reverified before commit. No permission changes, runtime code edits, faction mappings or unrelated-file staging. Earlier Bond/signature retained; current total19 menu songs/18 battle loops. Next: reopen normal live-source sandbox and provide faction associations when ready. Complete source/provenance/timing/processing and receipt in tools/soundtrack_batch_20260915/.

## 20260915-soundtrack-extra-02 - Three additional tracks implemented and validated

Glock, Keys and Ripper by B-22 are imported as full menu MP3s plus exact 30-second battle WAV loops at 30–60s, 31–61s and 48–78s respectively. Current catalogue: 22 menu songs / 21 battle loops. All three files and loops pass full decoding, frame/timing/hash/seam validation; 25 focused native Godot checks and four integrity checks pass. Existing 19 catalogue entries, faction map and music consumer sources are unchanged. No account or SoundCloud permission changes.

Native checks covered each new title/artist/start, full stream, checkbox, Next playback and real loop wrap; actual file-end advance and expanded playlist scrolling also pass. No subjective listening approval or faction assignments claimed. Tools, exact mappings and evidence: tools/soundtrack_extra_20260915/README.md. Next: scoped publication to the established DEADSTREET origin/build branch under standing authorization, verify remote commit, reopen live-source sandbox for owner review. Preserve concurrent portrait/arsenal and original opening ownership.

## 20260915-soundtrack-extra-03 - Complete locally; three-track publication blocked

All three full songs and exact loops are implemented and validated locally: 22 menu songs, 21 loops, 25 native checks and four integrity checks passed. Automatic approval review rejected tools/soundtrack_extra_20260915/publish.py because the visible preceding publication approval covered the earlier 17-track batch, not this later three-track private audio/code payload to GitHub. No bypass/retry performed. Target: https://github.com/LeadLasso-LL/DEADSTREET.git on build/arsenal-checkpoint-20260911. Unaffected processing, catalogue integration, evidence, README and shared records are complete.

Remaining action: request explicit owner approval to publish Glock, Keys and Ripper (six new audio assets, catalogue, batch source/evidence and owned records) to the established repository. After approval run the prepared publish.py, which checks current branch/origin/index, source/asset hashes and validation, stages only owned changes, commits/pushes and verifies remote hash. No retrieval or processing rerun needed unless protected hashes changed. Faction associations remain pending. Live-source sandbox already reads the local 22-track catalogue.

## 20260915-soundtrack-extra-04 - Owner explicitly approved three-track publication

Brandon replied "approved" to the explicit request to publish Glock, Keys and Ripper to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the automatic-review publication block in soundtrack-extra-03. Authorized scope: six new audio assets, shared catalogue, this batch source/evidence and owned records on build/arsenal-checkpoint-20260911. Proceed with the prepared publisher and fresh branch/index/source/asset checks; preserve concurrent work. All processing and 25 native checks already passed; do not rerun absent a changed protected source. Verify remote hash and record final receipt.


## 20260915-portrait-arsenal-takeover-03 — Completed and native-validated

Owner continuation is complete in the live-source sandbox: 20 approved leader photos installed top right; 691 standing portraits normalized and visually reviewed with no remaining obvious detached shoulders/limbs observed; 75 vehicles price-sorted within existing categories; 30 canonical firearm prices displayed in Arsenal; all 30 close-up gun icons refined, especially pistol triggers/guards and SMGs. Exact prices/rationale are in docs/WEAPON_PRICING.md. Combat statistics and animation atlases remain unchanged. This certifies the reviewed standing-card scope, not unreviewed animation frames or final economy balance.

Final Windows Godot native validation: 6178 checks, zero failures. All 691 native imported portrait images match source after normal alpha-edge processing; 20 leader textures, 115 displayed role cards, 30 weapons, 75 sorted vehicles, three desktop sizes, setup/fleet/tutorial navigation and launch/return checked. Initial harness failures and fixes are documented; final smoke.json is authoritative. Source/asset hashes verified. All 23 standing boards and five weapon boards visually inspected, along with native faction/Arsenal screens. Small stray gun detail strokes were cleaned before final import/render. Evidence, reproducible scripts, source/photo provenance and review limits: tools/sandbox_finish_20260915/README.md.

Current task ownership moves to COMPLETE / OWNER REVIEW. Reopen the existing desktop Sandbox launcher to load. Publication receipt will state actual Git status; do not infer publication from this local completion. Concurrent soundtrack (now 22 tracks/21 loops), selected-range, estate and opening work preserved. No further implementation required for this requested scope before owner review.

## 20260915-soundtrack-extra-05 - Glock, Keys and Ripper publication verified

PUSHED / VERIFIED: d262e8f43f34b889ce72b1705d0f4de36d7e40fd on origin/build/arsenal-checkpoint-20260911. Three full B-22 menu MP3s and three exact 30-second WAV loops published: Glock 30–60s, Keys 31–61s, Ripper 48–78s. Total 22 menu tracks / 21 battle loops. All audio validation, 25 native checks and four integrity checks passed; protected source and asset hashes verified before commit. Existing tracks, runtime sources, permissions and faction mapping unchanged. Scoped asset/catalogue/evidence and owned documentation only; concurrent work preserved. Next: reopen live-source sandbox to load all tracks; owner faction associations remain pending. Receipt and evidence: tools/soundtrack_extra_20260915/.

## 20260915-faction-music-picker-01 - Owner assignment screen ready

Owner requested quick one-screen faction/snippet matching with canonical emblems, playable titled snippets, assignment controls and screenshot capture. Explicit latest rule: TRC and NBPD KEEP EXISTING SIRENS and are excluded. Built tools/faction_music_picker_20260915/picker.gd as an isolated native review tool using all 21 eligible factions and all 21 existing 30-second loops. Each row has an emblem/name, track selector and play/pause; selecting assigns and auditions; one loop plays at a time. Autosaved draft: tools/faction_music_picker_20260915/assignments.json. Save screenshot writes Desktop/Dead-Street-Faction-Music-Assignments.png; every row fits on a 1000x750 screen. Desktop launcher: Faction Music Assignments.cmd. All 10 native checks passed and screenshot inspected. No runtime catalogue or gameplay changes, no speculative assignments. Next: owner selects snippets and returns screenshot; read draft/confirm owner choices, then implement approved faction mapping while preserving both authority sirens. Concurrent BUILD range/portrait work untouched. Utility is ready locally; no push needed for immediate use.

## 20260915-faction-music-apply-01 - Owner screenshot accepted; mapping installed

Owner returned completed21/21 faction assignment screenshot. Saved picker mapping matches all21 screenshot rows exactly, including Burn shared by Calle Ocho and La Union del Sur; Glock remains available in menu/unassigned. Approved mapping captured in tools/faction_music_apply_20260915/approved_assignments.json and registered in assets/data/music_catalog.json. TRC/NBPD excluded: existing sirens retained. Narrow audio wiring extends current spatial convoy/stronghold radio to mapped factions, suppresses old Harold beat when mapped music is present, keeps existing winner-continuity/mix and siren code. No menu, combat or presentation source edits. Next: validate all mappings, actual battle placement/playback across three maps and siren equivalence; publish scoped source/evidence/owned records. Preserve concurrent portrait/range work.

## 20260915-faction-music-apply-02 - Wiring validated; owner correcting duplicated Burn

IMPLEMENTED / NATIVE-VALIDATED audio wiring: 115 checks PASS, zero final failures. All21 screenshot mappings load on both sides and loop; actual Harold/bridge/estate sources and anchors, winning-stream continuity, loser background, exit stop and suppression of old Harold beat checked. TRC/NBPD audio/parameters match previous implementation across all three maps. Existing menu tracks/audio assets and protected consumers unchanged. Initial declaration bug fixed; harness isolation/result fixture corrections documented in tools/faction_music_apply_20260915/README.md. No commit/push performed.

LATEST OWNER CORRECTION: repeated Burn was NOT intentional. Unused track is Glock — B-22. Current screenshot has Burn for Calle Ocho and La Union del Sur. Exact unresolved choice is which of those two gets Glock. Do not infer, publish or claim final assignment approval before this is answered. Current catalogue remains provisional screenshot mapping; approved_assignments.json status now awaiting_duplicate_resolution. Next: receive selection, update that single faction to glock_b22 and check uniqueness/corrected source; preserve the other20 choices and both authority sirens. Then finalize owned records and scoped publication. Hive/current source supersedes earlier apply-01 assertion that duplicated Burn was an approved final choice.

## 20260915-faction-music-apply-03 - Calle Ocho corrected; all assignments final and validated

Owner explicitly directed Glock for Calle Ocho. Final mapping has21 distinct tracks for21 non-authority factions; La Union del Sur keeps Burn and the other20 screenshot choices are unchanged. Corrected runtime catalogue, owner assignment record and picker saved choices. TRC/NBPD retain existing sirens. All prior115 native wiring checks remain applicable to unchanged audio sources;13 focused correction checks PASS for exact Glock source on both sides, spatial anchors, actual native loop wrap, distinct mapping and Union/authority preservation. Current source hashes recorded. Full final faction/title/artist table and validation limits: tools/faction_music_apply_20260915/README.md.

No decisions remain. Next: scoped commit/push and remote hash verification; reopen normal live-source sandbox for faction playback. Preserve current concurrent portrait/Arsenal/Harold/range work, including any staged changes. No runtime menu or audio asset edits in this block. Supersedes apply-02 pending duplicate decision. The utility remains local and reopenable; active in-memory picker sessions should be reopened to display the corrected saved mapping.

## 20260915-faction-music-apply-04 - Final mapping ready locally; publication review blocked

Final owner mapping is implemented: Calle Ocho=Glock, La Union del Sur=Burn;21 unique loops for21 non-authority factions, TRC/NBPD sirens unchanged.115 native wiring checks plus13 final correction checks passed; owner mapping/evidence/README/shared records complete. Automatic approval review rejected execution of tools/faction_music_apply_20260915/publish.py, stating that private project source/documentation publication to the GitHub destination was not clearly authorized in the transcript. No staging/commit/push occurred from this rejected call; no workaround or retry performed.

Exact remaining action: ask owner approval to publish the final faction-audio mapping/wiring and assignment utility/evidence to https://github.com/LeadLasso-LL/DEADSTREET.git on build/arsenal-checkpoint-20260911. Once explicitly approved, run the prepared publisher after its built-in branch/origin/index/hash/report guards. It stages only the three owned audio/catalogue sources, final mapping/utility/evidence and owned shared-record sections, then pushes and verifies remote hash. No repeat processing/full testing needed absent changed owned hashes. Preserve concurrent menu shuffle/toast, Harold geometry, range and portrait work. No faction choice remains unresolved; local sandbox loads final mapping after reopen.

## 20260915-faction-music-apply-05 - Owner explicitly approved final faction audio publication

Brandon replied "approved" to the explicit request to push the finalized faction audio setup to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the automatic-review block in apply-04. Scope: final21 unique faction assignments with Calle Ocho=Glock and La Union del Sur=Burn; three audio source/catalogue files; assignment utility, evidence and owned shared records. TRC/NBPD keep existing sirens. Proceed on build/arsenal-checkpoint-20260911 using prepared publisher with fresh branch/origin/index/hash guards; preserve concurrent work.115 wiring checks and13 correction checks already passed. Verify remote hash and record receipt; no optional retesting absent changed owned hashes.


## 20260915-menu-polish-02 - Completed and native-validated

All requested changes complete locally: remove white canvas surrounds from23 faction emblems across sandbox glossary/list/header and both setup selectors, retain emblem interior white detail; refine AK-47 and all six sniper illustrations with distinct stocks/scopes/receivers; compact now-playing toast158x56 above Music dock123x36; crossed-arrow Shuffle rebuilds enabled-song order and immediately starts a different song when alternatives exist. Pause resumes on explicit shuffle; exclusions/volume persist; zero enabled disables and one enabled explicitly restarts. Next and natural track finish follow the new order.

249 native Godot checks PASS, zero failures, with actual menu/button input, eight full22-song shuffles, all23 rendered emblems, seven native gun panels and three desktop sizes. Exact inner emblem pixel equality proves preservation; all white exterior corners cleared. Final screenshots and seven-gun board visually inspected. Earlier pixel fixture corrected logical-to-physical scaling; import log BOM decoding corrected. Other734 prior art assets remain byte-identical; no combat/stat/price/animation changes or broad battle benchmark. Source/evidence/reproduction and limits: tools/menu_polish_20260915/README.md. Owner appearance review remains separate.

Prior portrait checkpoint explicitly approved in this turn, pushed and verified at dc0450543801f3b4046f39cb1f762abf0bd79e15; its previous auto-review block is resolved. New music-menu change preserves the separately owned untracked opening source: exact already-applied delta is checkpointed instead of staging that entire inherited file. Music/faction audio catalogue, Harold and range-group changes preserved. Current pass publication receipt records actual status. Reopen the normal Sandbox launcher; no further implementation needed before owner review.

## 20260915-faction-music-apply-06 - Final faction soundtrack publication verified

PUSHED / VERIFIED 22342c76c969c77d2749a488da794bd6133ad618 on origin/build/arsenal-checkpoint-20260911. Final21 unique faction loops installed, including Calle Ocho=Glock and La Union del Sur=Burn; exact other20 screenshot choices retained. TRC/NBPD keep their prior sirens. Three audio source/catalogue files, owner mappings, assignment utility, native evidence and owned documentation only.115 wiring checks plus13 correction checks passed; source hashes verified. Reopen live-source sandbox for faction audio. No mapping decisions remain; subjective mix review can follow in normal play. Menu playlist and audio assets unchanged.

## 20260915-faction-music-audit-01 - Spatial/level behavior confirmed; interior filtering missing

Owner asked whether imported snippets preserve arriving-vehicle/defending-building placement, louder arrival, quieter combat and interior muffling. Current tactical_convoy_audio.gd confirms moving convoy source, Harold/estate defender entrance (bridge defenders use vehicles), existing arrival-to-combat drops of14dB vehicle/6dB building plus shot ducking, and same-loop winner foreground. Read-only verification found no low-pass/filter routing for these new players: battle excerpts were prepared with timing/seam/headroom only, so imported loops currently remain clean aside from positional gain/panning. Interior vehicle/building sound design was not carried over and remains a real gap; do not claim otherwise. No runtime changes made in this confirmation block. TRC/NBPD sirens and clean menu tracks remain unchanged.

## 20260915-radio-interior-01 - Subtle interior filtering implemented

Owner authorized restrained, well-done vehicle/building muffling. Implemented per-source12dB/oct low-pass: vehicles2400Hz, buildings1800Hz, resonance0.5/no gain boost; winner smoothly opens to7500Hz using existing outro mix without replacing/restarting its loop. Each radio owns a separate temporary bus and cleans it up on exit. Sirens/menu sources never attach this treatment. Existing spatial anchors, gain/ducking, timing and assets unchanged. Scope: new gameplay/tactical_radio_filter.gd plus three narrow convoy-audio wiring lines; evidence in tools/radio_interior_20260915/. Next: native signal-response, source isolation, cleanup, transitions and siren checks; record final results and publish scoped change. Preserve concurrent Harold/Arsenal/menu/range work.

## 20260915-radio-interior-02 - Interior treatment validated

Closed the faction-radio muffling gap with restrained per-source low-pass filtering: vehicles 2,400 Hz; defending buildings 1,800 Hz; 12 dB/oct, resonance 0.5 and no gain boost. Winning radio smoothly opens to 7,500 Hz using the existing outro mix while the loser stays enclosed. Each radio owns and cleans up its bus. Existing spatial placement, arrival level, combat ducking and looping remain identical; menu music and TRC/NBPD sirens are unchanged. Native Godot: 141 checks passed across all 21 mappings, three layouts, real loop wraps, winner continuity, authority sources and bus cleanup. Captured audio response plus protected-file checks: 8 passed; bass retained, high frequencies attenuated, no clipping or resonant boost. No independent listening signoff claimed. Evidence: tools/radio_interior_20260915/{README.md,native_validation.json,measured_response.json,source_hashes.json}. Next: scoped publication and owner review after reopening the live sandbox. Preserve concurrent BUILD/Harold, Arsenal and menu changes.

## 20260915-radio-interior-03 - Final gentler interior treatment validated

Closed the faction-radio muffling gap with restrained per-source low-pass filtering: vehicles 2,400 Hz; defending buildings 1,800 Hz; 6 dB/oct, resonance 0.5 and no gain boost. Winning radio smoothly opens to 7,500 Hz using the existing outro mix while the loser stays enclosed. Each radio owns and cleans up its bus. Existing spatial placement, arrival level, combat ducking and looping remain identical; menu music and TRC/NBPD sirens are unchanged. Native Godot: 141 checks passed across all 21 mappings, three layouts, real loop wraps, winner continuity, authority sources and bus cleanup. Captured audio response plus protected-file checks: 8 passed; bass retained, high frequencies attenuated, no clipping or resonant boost. No independent listening signoff claimed. Evidence: tools/radio_interior_20260915/{README.md,native_validation.json,measured_response.json,source_hashes.json}. Next: scoped publication and owner review after reopening the live sandbox. Preserve concurrent BUILD/Harold, Arsenal and menu changes.

## 20260915-radio-interior-04 - Final tuning and publication ready

The initial FILTER_12DB pass was deliberately eased after measuring its response. Final runtime uses Godot FILTER_6DB, vehicles 2,400 Hz and buildings 1,800 Hz; measured bass change at 120 Hz is only -0.02/-0.04 dB, with 4 kHz softened -11.74/-15.74 dB. Winner opens smoothly to 7,500 Hz (-1.95 dB at 4 kHz). This supersedes the initial 12 dB setting recorded above. Final 141 native checks plus 8 captured-response/protected-file checks pass. Source files/catalogue hashes checked. Other chat advanced HEAD to 070469580f055e3352fae8eabaf2425fb171c40f and cleared its own staging during validation; preserve that new menu checkpoint. Publish only this helper, three convoy wiring lines, its narrow evidence, and this chat's shared-record sections. Owner can review by reopening the normal live-source Sandbox launcher. No independent listening signoff claimed.


## 20260915-faction-preview-02 - Implemented and native-validated

Faction Audio label and filled play/stop button installed beneath every glossary leader photograph. Plays exact 21 mapped snippets plus existing TRC/NBPD sirens (TRC 0.75 pitch), as fresh one-shot preview resources. Preview pauses the menu player and Stop/natural finish resumes the same song at its held position. Only one preview; faction/tab/Tutorial/hidden-page/removal transitions stop it. Pre-existing manual pause is respected; Next/Shuffle cannot overlap preview. Existing menu volume controls audition level. Catalogue, source WAVs, battle looping/spatial filters, portraits and art unchanged.

250 official Windows Godot native checks PASS, zero failures: actual controls for all 23 sources and icon states, byte identity, pause/position/play-count continuity, real clip end, navigation/cleanup, manual-pause and Shuffle interaction, three desktop layouts. Actual Mercer playing/stopped and NBPD screenshots visually inspected. Existing unrelated Tutorial anchor warning recorded; no broad battle benchmark or owner appearance acceptance claimed. Source/evidence/reproduction in tools/faction_audio_preview_20260915/README.md; exact live music delta preserved separately from untracked opening ownership. Narrow scope includes new preview node, glossary, one menu-navigation stop line and external menu-pause API.

Brandon's preceding explicit approval was fulfilled: menu-polish checkpoint 070469580f055e3352fae8eabaf2425fb171c40f pushed/remote verified. That prior blocker is resolved. Current preview implementation/evidence/records are complete; publication receipt states actual Git result. Reopen normal live-source Sandbox. Preserve parallel radio-interior/Harold/range work; no implementation work remains before owner review.


## 20260915-arsenal-compare-01 - Owner requested SMG casing and direct equipment comparisons

Brandon requested SMG always uppercase in the sandbox force picker and click-one/hover-another Arsenal stat comparisons, then explicitly extended the same interaction to Vehicles. Scope: glossary UI, force-builder presentation, a shared equipment stat formatter and tools/arsenal_compare_20260915/. Both affected existing sources are clean at baseline; preserve parallel Harold HQ-car, range and opening work. No combat/stat/price tuning. Vehicle comparisons include price, upkeep, seats, road movement, resources, cover and neutral dimensions/door counts, with special-role descriptions preserved. Implement a clicked baseline that persists across class tabs; show both values and signed hovered-minus-selected differences. Lower price/aim/reload/recoil/miss chance is beneficial; graze probability is a neutral tradeoff. Keep hovered details stable for scrolling. Verify actual native input, cross-class comparisons, formatting and screen fit.

Prior Faction Audio publication is complete and remotely verified at 50a000753b04c7115bfeef48cb46dea0b2ddbbd4; no prior approval blocker remains. Current work is a separate UI request.


## 20260915-arsenal-compare-02 - Gun and vehicle comparison complete and validated

IMPLEMENTED / NATIVE-VALIDATED: SMG uppercase in both force-builder Add Unit selectors, existing unit rows and tooltips. Arsenal and Vehicles now use clicked baselines and hover comparisons across class/category tabs. Both source values and signed hovered-minus-selected differences shown; green benefits, red drawbacks, neutral tradeoffs, unchanged em dash, percentage-point deltas. Last hovered comparison persists for scrolling; new click changes baseline; hover selected restores details; page/category change clears hover while preserving selected baseline. Guns compare 17 stats; vehicles compare 10 common stats with applicable special-role/capacity and ability details below. Source values remain canonical; no combat/economy/art/audio changes.

3,736 native Windows Godot checks PASS, zero failures, exit 0/no engine-script errors: all 30 gun and 75 vehicle source values/deltas, price ordering, actual click/hover and cross-category controls, selection/scroll/page lifecycle, SMG labels, formatting and three desktop layouts. Six relevant screenshots visually inspected. No battle benchmark, full regression suite or owner appearance acceptance implied. README/evidence/commands/protected hashes: tools/arsenal_compare_20260915/. Only gameplay/equipment_comparison.gd, glossary equipment UI and force-builder presentation are owned. Faction Audio source/lifecycle, catalogues, ordering and concurrent Harold/range/opening work preserved.

Owner's in-turn vehicle extension is fulfilled. Previous Faction Audio 50a0007 is pushed/remote verified. Current comparison publication outcome is separate in publication_receipt.json. Next: reopen live-source Sandbox and review; implementation is complete. Scoped publisher preserves other chats' working records and source edits.

## 20260915-radio-interior-05 - Published and verified

Scoped interior-radio filtering checkpoint pushed and remote branch verified at db2da64b0cb8a11c5b57a056b0829dcea246d289. Final restrained FILTER_6DB configuration, vehicle/building placement and gain preservation, smooth winner clarity, unchanged menu/sirens, and 149 passing native/measured checks are recorded in tools/radio_interior_20260915/. All pre-existing unstaged work preserved; only owned record sections checkpointed. Reopen normal Sandbox launcher for owner listening review. No remaining implementation task in this scope.

## 20260915-weapon-cards-01 - Trigger and card artwork refresh in progress

Owner requested clearer shotgun triggers, then added Ruger Mini-14 and AUG triggers; also every unit image card must hold the latest Arsenal weapon art. Confirmed current icon-only polish is absent from portrait weapons. Scope: eight SVG-native trigger/guard refinements and all 691 reachable portraits (23 factions x 30 models plus Mercer dual-pistol specialist). Preserve accepted final anatomy/outfits/hand transforms/framing by replacing only the existing weapon groups in exact accepted card SVGs; shared runtime and world animation atlases stay untouched. Reuse current Arsenal source SVGs as the single weapon-art input, including new AK/sniper detail. Working source clean before edit; HEAD 50a000753b04c7115bfeef48cb46dea0b2ddbbd4. Concurrent Harold HQ car and glossary/comparison/menu changes are outside scope. Baseline portraits and SVG jobs backed up in tools/weapon_card_refresh_20260915/. Next: render triggers, refresh weapon-only card layers, check full catalogue coverage and native texture loading, visual review, update records and scoped publication.

## 20260915-weapon-cards-02 - Trigger artwork and all card weapons installed

Eight requested trigger assemblies refined with open guards and distinct curved trigger blades (six shotguns plus Mini-14/AUG). All 691 canonical unit portraits now embed current Arsenal SVG artwork, including all 30 regular weapon models and both specialist pistols. Verified exact accepted source match for every baseline and structurally identical non-weapon SVG nodes in both standing directions (1,382 checks): existing anatomy corrections, hands, clothing and card framing are retained. New assets/data/unit_card_weapon_art.json records each source SVG and installed portrait hash for future freshness checks. Refreshed only changed imported images in an isolated Godot import. Other chats' current UI, Harold maps, music and world atlases preserved. Evidence in tools/weapon_card_refresh_20260915/. Next: native catalogue/card/texture checks, final visual review, records and scoped publication; owner acceptance remains separate.

## 20260915-weapon-cards-03 - Trigger and current card weapon artwork validated

IMPLEMENTED / VALIDATED: six shotgun triggers/guards plus Ruger Mini-14 and AUG; all 691 unit cards now hold current Arsenal source SVGs, including latest AK/sniper/pistol/SMG detail and both specialist Glocks. The eight trigger designs are part of the normal display generator. Exact accepted baseline match for all 691 portraits and 1,382 non-weapon SVG equality checks preserve fixed shoulders, hands, outfit geometry and framing. Initial longer sniper art caused edge clipping in 140 angle views; fixed by uniform 0.9 weapon scale about the right grip, keeping unit framing unchanged. Final both-angle framing check shows zero new side clipping. 3578 native Godot checks passed: actual runtime paths/current pixels, all 690 faction/model combinations, specialist, 115 glossary cards and eight icons. Visually reviewed all weapon designs, all faction/class glossary images and native pages. Added source/portrait freshness manifest assets/data/unit_card_weapon_art.json and reproducible accepted source/render archives. No changes to weapon stats, audio, runtime card layout or world animation atlases. Initial native icon comparison was corrected to account for the existing fix_alpha_border import step; final exact visible-pixel checks pass without a relaxed tolerance. Owner visual acceptance remains separate. Evidence/commands/limits: tools/weapon_card_refresh_20260915/README.md. Next: scoped publish and reopen live Sandbox for review; preserve concurrent Harold, SMG label and gun comparison work.

## 20260915-weapon-cards-05 - Complete locally; new publication blocked

All eight trigger improvements and 691 current-weapon portraits are installed in the live sandbox and validated (3,578 native checks, 1,382 non-weapon structural comparisons, zero new side clipping). Automatic approval review rejected execution of tools/weapon_card_refresh_20260915/publish.py before it ran: the current 742-file artwork/evidence payload and GitHub destination need explicit approval in trusted user text. No staging/commit/push occurred and no workaround/retry attempted. Target https://github.com/LeadLasso-LL/DEADSTREET.git, branch build/arsenal-checkpoint-20260911. Prepared publisher verifies fresh HEAD/branch/index/protected-source/owned-file hashes and stages only owned source/art/evidence plus owned shared-record sections. Remaining step: owner explicitly approves this new batch, then execute the prepared publisher with its guards and verify remote receipt; no repeat production/testing needed unless validated files change. Reopen normal live-source Sandbox for immediate review now. Preserve concurrent Harold and menu/comparison changes.

## 20260915-weapon-cards-06 - Owner explicitly approved artwork publication

Brandon replied "Approved" to this chat's request to push the new shotgun/Mini-14/AUG trigger improvements and all 691 current-weapon card portraits to https://github.com/LeadLasso-LL/DEADSTREET. This resolves the automatic-review publication block in weapon-cards-05. Existing 3,578 native checks and both-angle framing checks remain valid; all non-documentation owned file hashes and protected source hashes are unchanged. Proceed with the prepared scoped publisher on build/arsenal-checkpoint-20260911, preserving concurrent Harold cover/stair work and previously published comparison UI. Record remote verification; no repeated art generation or optional validation is needed.
