# Dead Street — instructions for every build chat

## Start here

Read [the Hive Mind](docs/DEAD_STREET_HIVE_MIND.md) before planning or editing.
It is the shared entry point for current work, decisions, evidence, and handoffs.
Then read the recent [journal](docs/DEAD_STREET_JOURNAL.md), current dated
milestones in [Project Control](docs/DEAD_STREET_PROJECT_CONTROL.md), and the
linked standards relevant to your task.

Verify the live repository, branch, HEAD, working tree, and affected files.
A chat summary, old attachment, or existing implementation is not sufficient
evidence of current product intent or acceptance.

## Standing rule from Brandon — 2026-09-13

**Document everything that a future chat needs to understand, continue, or
avoid repeating the work. Do this as the work happens. The assistant owns it;
Brandon should not need to request a handoff or remind you to keep records.**

Before ending a substantive turn, record meaningful product decisions and
their reasons; approvals/rejections/corrections; implementation or asset
changes; discoveries; experiments and outcomes; measurements and validation
limits; blockers; unresolved questions; future ideas; and the exact next step.
This includes discussion-only decisions and abandoned approaches.

During long work, checkpoint after a meaningful decision, experiment, or
milestone and before a long operation or change of scope. Do not wait for
the end of a chat. Routine commands and unchanged acknowledgments need no entry.

- Append durable events to the journal with source and status.
- Update the Hive Mind's current coordination/next-action section when it changes.
- Update Project Control for milestone/feature status and the relevant topic
  document for detailed rules. Link to details instead of creating parallel truth.
- Separate IMPLEMENTED, VALIDATED, OWNER-ACCEPTED, PROPOSED, REJECTED/SUPERSEDED,
  and UNKNOWN. Tests and assistant visual inspection never imply owner acceptance.
- Record commands/fixtures, environment, results, evidence paths, and limitations
  when reporting validation. Mark tests not run. Never turn an observation cutoff
  into a battle result or a benchmark sample into a sustained performance promise.
- Preserve previous decisions; mark what supersedes them and why.
- Verify the records were saved before reporting a milestone complete. If saving
  is blocked, report the unsaved gap and keep a recoverable local checkpoint.

## Prompt completion and explicit Git approval — 2026-09-13

Finish authorized work and report promptly without compromising quality.
Acknowledge incoming notes at the first available boundary; give meaningful updates
at least every minute when control is available. Report tool delays and blockers.
Stop optional checks when the concrete risk is covered. Distinguish implementation,
verification, commit and push status; do not call unfinished publishing complete.
Brandon explicitly approved committing and pushing the pending documentation to
https://github.com/LeadLasso-LL/DEADSTREET.git on 2026-09-13. Do not re-request that
same approval. Preserve scope and unrelated changes.

## Ownership and concurrent work

Brandon owns product/creative decisions and acceptance. The assistant leads
technical implementation, sequencing, troubleshooting, validation, and records.
Use the standing repository authorization in
[PROJECT_WORKFLOW_AUTHORIZATION.md](docs/PROJECT_WORKFLOW_AUTHORIZATION.md);
do not request routine permission already granted.

Read the Hive Mind's work register before editing. A listed chat is a
last-reported owner, not proof that it is still running. Do not concurrently
edit another active pass's source files. Documentation-only work can proceed
with explicit scope, fresh reads, and conflict checks. Preserve unrelated changes.

Re-read shared files before replacing them. If another writer changed them,
merge the current content; do not overwrite with an older snapshot. Scope
staging/commits to your own changes. Never clean the mixed working tree casually.

The full maintenance and handoff protocol is in the Hive Mind.
