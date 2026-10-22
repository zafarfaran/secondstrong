# Golden principles

Opinionated, mechanical rules that keep the codebase legible to agents. Where a
rule can be checked by a script it is, in `scripts/check-harness.sh`. The rest
are reviewed during the recurring cleanup (see [harness](harness.md)).

1. **Parse at the boundary.** Anything entering the app (quiz answers, stored
   data, network responses) is parsed into typed values in SSCore once. Inner
   code never handles raw strings or optional-everything shapes.
2. **Shared helpers over hand-rolled copies.** If two features need it, move it
   down a layer. Do not duplicate it.
3. **Boring, well-known tech.** Prefer SwiftUI, Foundation, SwiftPM and
   Swift Testing. Add a dependency only with an ADR in `docs/decisions/`.
4. **Layers point one way.** SSCore -> SSDesign -> features -> App. Checked.
5. **Small files.** Over-limit files get split, not exempted. Checked.
6. **Terse comments.** At most 3 lines per block, mostly business logic, with
   the ticket id where one applies. Checked for length.
7. **One source of truth per fact.** Palette hexes live in `Palette`, business
   rules in `docs/business/`, product copy rules in the spec. Link, do not copy.
8. **The repo is the record.** Decisions made in chat get written down before
   the work is finished. Work is tracked in [tickets](tickets.md).
9. **Tests encode behaviour.** New logic in SSCore ships with a test. Fix a bug
   by writing the failing test first.
10. **Fake data only.** No real health or personal data in code, tests, logs or
   prompts. See [data handling](business/data-handling.md).
11. **Errors teach.** Scripts and assertions say what broke and how to fix it.

## Cleanup loop

Periodically (weekly while the app is young): run the harness check, scan for
violations of the unchecked rules above, update [quality](quality.md), and open
small fixes. Record anything not fixed in [tech debt](exec-plans/tech-debt.md).
