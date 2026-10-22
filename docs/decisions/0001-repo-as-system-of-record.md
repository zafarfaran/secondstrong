# 0001 Repo as system of record

Status: accepted, 2026-10-20

## Context

Business context, design decisions and code all need to be available to coding
agents, who can only act on what they can read. Large instruction files crowd
out the task and go stale.

## Decision

Follow OpenAI's harness engineering approach. Keep short AGENTS.md files as
maps, put knowledge in `docs/` with an index, record plans and decisions as
files, and enforce structure with `scripts/check-harness.sh`. Limits: AGENTS.md
120 lines, docs 600, Swift files 600. Comments are capped at 3 lines per block.

## Consequences

Decisions made in chat must be written down. The existing 715-line spec is over
the limit and is handled with a [spec map](../business/spec-map.md) until it is
split. See [harness](../harness.md).
