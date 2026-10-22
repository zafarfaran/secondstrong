# Harness

The repo is set up so an agent can work from a small entry point and pull in
only what it needs. The approach follows OpenAI's "harness engineering" write-up:
the repo is the system of record, AGENTS.md is a table of contents, and rules
are enforced by tooling rather than by reminders.

## Principles

1. **Map, not manual.** AGENTS.md files stay under 120 lines and point to
   `docs/`. A giant instruction file crowds out the task and rots.
2. **Progressive disclosure.** Start at `docs/index.md`; open one doc at a time.
   Big source documents get a map (see [spec map](business/spec-map.md)).
3. **Repo is the record.** Anything not in the repo does not exist for the next
   agent. Decisions made in chat get written into `docs/`.
4. **Enforce mechanically.** Size limits, layer imports, link validity and index
   coverage are checked by `scripts/check-harness.sh`. Errors say how to fix them.
5. **Plans are artifacts.** Work above a small fix has a plan in
   `docs/exec-plans/active/`, moved to `completed/` when done.
6. **Garbage collection.** Known gaps go in [tech debt](exec-plans/tech-debt.md);
   the [scorecard](quality.md) is refreshed as areas change. Prune stale docs.

## Limits

| Thing | Max lines | On breach |
|---|---|---|
| AGENTS.md / CLAUDE.md | 120 | move detail into `docs/` |
| Any file in `docs/` | 600 | split into focused files |
| Any Swift file | 600 | extract a type into its own file |
| Consecutive `//` comment lines | 3 | cut it; move reasoning to `docs/` |

The product spec at the repo root is over the doc limit. It is legacy and
tracked in tech debt; the check only covers `docs/`.

## Tickets

Every change is tracked by a ticket in `tickets/`, and the check verifies that
every ticket id mentioned in code or docs exists. See [tickets](tickets.md).

## Adding a rule

Prefer a check in `scripts/check-harness.sh` over a sentence in AGENTS.md.
Write the failure message as an instruction: what broke, how to fix it.
