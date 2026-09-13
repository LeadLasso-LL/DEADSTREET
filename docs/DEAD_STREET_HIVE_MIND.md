# Dead Street — Hive Mind

**Shared entry point for all future chats.**
Established by Brandon on 2026-09-13. Maintained by the assistant doing the work.
Coordination last reconciled: 2026-09-13, after the receiving-chat headroom pass.
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
- Last observed gameplay checkpoint: e2c9a1374c5f82336126c59becc9d59a9d5090d3,
  “Add playable river suspension bridge with contextual convoys and shared tactical art.”
- This workflow setup adds documentation after that gameplay checkpoint.
  Use Git to find the actual latest HEAD; do not reset to the snapshot above.
- [Standing commit/push authorization](PROJECT_WORKFLOW_AUTHORIZATION.md) applies
  to the established work/destination. Preserve scope and unrelated changes.

A fresh ChatGPT chat must have access to this repository and be directed to this
entry point. Files here do not themselves attach to every chat, update ChatGPT
Project settings, or automatically synchronize an active chat's internal context.

Suggested one-time Project instruction:
“Before Dead Street work, read AGENTS.md and docs/DEAD_STREET_HIVE_MIND.md in the
live Dead Street repository. Follow their documentation and handoff workflow.”

## Current coordination and next action

**Objective:** 60 FPS at the current battle scale, with room for larger battles.
The receiving chat owns continuation. The headroom optimization pass is verified;
steady 60 FPS and expansion headroom remain unfinished.

| Work | Owner | State / scope |
| --- | --- | --- |
| Collision, targets, navigation, cover, visibility and actor preparation | This receiving chat | Implemented and checked; see current report and Git checkpoint. |
| Shared records and reproducible benchmarks | This receiving chat | Updated with progression, failures, validation and remaining limits. |
| Release-runtime capacity comparison | This receiving chat | Blocked by automatic approval review: executable download/run needs explicit authorization. |

**Latest evidence:** normal native 24-unit 59.05 FPS, P95
19.143 ms, worst 46.517 ms;
32-unit 48.55 FPS, P95 24.651 ms,
worst 58.916 ms. Both samples had zero frames over 100 ms.
Uncapped 24-unit throughput was 61.31 FPS, still with budget misses.
11,022 focused/replay/actor checks passed; final logs have zero script errors.
These are development-executable measurements. Release performance is unknown.

Read [the headroom report](../tools/bridge_perf/HEADROOM_2026-09-13.md)
and [reproduction instructions](../tools/bridge_perf/headroom/README.md).
The [previous cleanup report](../tools/bridge_perf/RUNTIME_CLEANUP_2026-09-13.md)
and [archived handoff](handoffs/DEAD_STREET_BUILD_HANDOFF_2026-09-13.md) are historical.

**Immediate next task:** obtain explicit authorization to download/run the
matching official Godot release runtime, compare 24 and 32 units, then optimize
the remaining measured costs until steady 60 FPS and headroom are demonstrated.
Do not claim a release-runtime change is a proven fix before measuring it.

**Known gaps:**
- Two maximum legal convoys remain the battle ceiling. Three vehicles per
  convoy, legal combinations and final personnel cap are undecided.
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
