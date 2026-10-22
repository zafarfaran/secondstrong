# Tickets

Internal tracker. One markdown file per ticket in `tickets/`, named
`SS-0001-short-slug.md`. Tickets live in git, so history and review come free and
agents can read them like any other file.

## Workflow for agents

1. Before starting, run `scripts/ticket list` and look for an existing ticket.
   If none fits, `scripts/ticket new "Title" -t task -d "why and what"`.
2. `scripts/ticket status SS-NNNN in-progress` when you begin.
3. Comment on decisions, blockers and findings:
   `scripts/ticket comment SS-NNNN "Chose X because Y"`.
4. Reference the id in commit messages, plans, and business-logic comments
   (`// SS-NNNN: floor protein target at 1.0 g/kg`).
5. When finished: tick the acceptance boxes, then `scripts/ticket status SS-NNNN done`.

Set `TICKET_AUTHOR` to name the commenter; it defaults to the git user.

## File format

```
---
id: SS-NNNN
title: Short imperative title
type: task | bug | feature | chore
status: todo | in-progress | review | done | cancelled
created: 2026-10-20
updated: 2026-10-20
external:            # key in an outside tracker, empty until linked
---
## Description
## Acceptance
## Comments          # last section; one dated line per entry
```

## Commands

`new`, `list [--all]`, `show`, `comment`, `status`, `link`. Run `scripts/ticket`
with no arguments for usage. `list` hides done and cancelled tickets so context
stays small; use `--all` to see them.

## Checks

`scripts/check-harness.sh` verifies frontmatter, allowed status and type values,
unique ids, and that every `SS-NNNN` mentioned in Swift code or docs has a ticket.

## Syncing later

Ids are stable and never reused, and `external` holds the outside key, so a sync
job can match tickets one to one. `scripts/ticket link SS-NNNN PROJ-123` records
the mapping. Direction and target tracker are undecided; see
[open questions](open-questions.md). Concurrent branches can allocate the same
id; the check flags duplicates so one can be renumbered before merge.
