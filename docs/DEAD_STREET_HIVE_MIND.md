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
