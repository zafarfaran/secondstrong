# Docs index

Every file under `docs/` must be linked here (checked by `scripts/check-harness.sh`).
Load only what the task needs.

## Business
- [Overview](business/overview.md): who it is for, positioning, pricing and funnel in one page
- [Spec map](business/spec-map.md): where each topic lives in the 715-line spec, and how to read a slice
- [Data handling](business/data-handling.md): health data is PII; what that means for code and AI use

## Architecture
- [iOS architecture](architecture/ios.md): module layers, dependency rule, testing approach
- [Harness](harness.md): how this repo keeps context small and enforces its own rules
- [Golden principles](golden-principles.md): the rules agents follow, and the cleanup loop
- [Tickets](tickets.md): the internal ticket system, how agents use it, how it syncs later

## Design
- [Onboarding](design/onboarding.md): the chosen pen-line flow and where its prototypes are
- [Onboarding questions](design/onboarding-questions.md): the 9 questions, their rules and what was left out
- [Family circle](design/family-circle.md): paying for and looking out for a parent, with her consent (draft)

## Decisions
- [0001 Repo as system of record](decisions/0001-repo-as-system-of-record.md)
- [0002 SwiftPM modules and XcodeGen](decisions/0002-swiftpm-modules-and-xcodegen.md)
- [0003 Tickets as files](decisions/0003-tickets-as-files.md)

## Plans and quality
- [Active: onboarding v1](exec-plans/active/0001-onboarding-v1.md)
- [Tech debt](exec-plans/tech-debt.md): known gaps, one line each
- [Quality scorecard](quality.md): per-area grades, updated as work lands
- [Open questions](open-questions.md): decisions only a human can make
