# Second Strong

A strength and nutrition coaching app for women at any stage of life, including
perimenopause and after. Native SwiftUI iPhone app first, plus a web funnel.
The product name is **Second Strong**. The spec and brand assets still say
Keel; they predate this decision, so use Second Strong in anything new.

This file is a map. Read the pointers below, not everything. Start at
[docs/index.md](docs/index.md).

## Repo map

| Path | What lives there |
|---|---|
| `docs/` | The system of record: business, architecture, design decisions, plans |
| `secondstrong-ios/` | The SwiftUI app. Has its own [AGENTS.md](secondstrong-ios/AGENTS.md) |
| `secondstrong-web/` | Next.js site (own AGENTS.md, read it before editing) |
| `secondstrong-waitlist/` | Waitlist backend (`index.ts`, `schema.sql`) |
| `design/` | Prototypes, mascots and launch assets. Reference only, not shipped code |
| `assets/`, `UI/` | Brand identity assets and UI source images |
| `keel-health-pricing-and-features-spec.md` | The product spec (715 lines). Do not read whole; see [spec map](docs/business/spec-map.md) |
| `tickets/` | Internal ticket tracker, one markdown file per ticket |
| `scripts/` | Repo tooling: `check-harness.sh`, `ticket` |

## How to work here

1. Read the area's AGENTS.md, then only the docs it points to.
2. For anything bigger than a small fix, write or update a plan in
   `docs/exec-plans/active/` first. Move it to `completed/` when done.
3. Business rules live in docs, not in your head or in chat. If a decision is
   made in conversation, record it in `docs/` (an ADR in `docs/decisions/` for
   architecture, otherwise the relevant doc) before finishing.
4. Keep files small. Limits are enforced: AGENTS.md/CLAUDE.md 120 lines, any
   doc 600, any Swift file 600. Split rather than grow.
5. Comments: at most 3 lines per block, mostly explaining business logic. No
   narration of what the code does. Longer reasoning goes in `docs/`.
6. Every change is tracked by a ticket in `tickets/` (see
   [tickets](docs/tickets.md)). Find or create one before starting, reference its
   id (SS-0001) in commits, plans and business-logic comments, and comment on it
   with progress and decisions.
7. Run `scripts/check-harness.sh` before finishing. Its failures say how to fix.

## Hard rules

- Safety requirements in the spec (section 7) are non-negotiable. Read
  [spec map](docs/business/spec-map.md) before touching onboarding questions,
  projections or anything weight-related.
- The quiz collects health data (weight, menopause stage, allergies,
  symptoms). It is PII. Follow RealityMine's
  [AI Policy](https://realitymine.atlassian.net/wiki/spaces/BMS/pages/3012362282/AI+Policy):
  no real user data in prompts, fixtures, logs or screenshots. See
  [data handling](docs/business/data-handling.md).
- Never fabricate user numbers, testimonials or scarcity (spec section 1.3, 2.4).
- Nothing in `assets/` is cleared for production until trademark clearance
  completes.

## Commands

```
scripts/check-harness.sh     # structure, size, comment, layer, link, ticket checks
scripts/ticket list          # open tickets; see docs/tickets.md for the rest
cd secondstrong-ios && make test    # package unit tests
cd secondstrong-ios && make build   # generate project and build the app
```
