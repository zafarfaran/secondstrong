# 0003 Tickets as files

Status: accepted (agent's call, open to change), 2026-10-20

## Context

Every change should be tracked, and agents must be able to read and update the
tracking with the same tools they use for code. The team may sync to an outside
tracker later.

## Decision

Tickets are markdown files with simple frontmatter in `tickets/`, managed by
`scripts/ticket` and validated by `scripts/check-harness.sh`. IDs are `SS-NNNN`,
stable and never reused. An `external` field holds the key in any outside system.
Details in [tickets](../tickets.md).

## Consequences

No server to run, and history lives in git. Id collisions across branches are
possible and are caught by the check. Search and reporting are limited to
grep and `scripts/ticket list` until a sync exists.
