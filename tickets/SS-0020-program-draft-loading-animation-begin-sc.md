---
id: SS-0020
title: Program draft, loading animation, begin screen and paywall
type: feature
status: review
created: 2026-10-21
updated: 2026-10-24
external:
---

## Description

After the questions: a building-your-program loading animation, the drafted program (protein target and first week), a Begin your program screen, then the paywall (spec section 1.3, 1.5, 2.7: hard paywall, annual preselected, 7-day trial, renewal terms visible, restore purchases). Designs first: design/onboarding/program.html. No StoreKit yet; purchase is faked.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Design previews in design/onboarding/program.html: three loading animations, the Begin your program screen and the paywall. Waiting on the owner's pick before building.
- 2026-10-21 Faran Zafar: Owner picked loading option A (pen draws it) with the coach added. Built as BuildingSection: pen line climbs, coach rides its tip (thinking, then cheer), five status lines, milestones, protein result. Docked coach fades out meanwhile; Back from the plan skips it. Begin your program and the paywall are still waiting on the owner.
- 2026-10-21 Faran Zafar: Preview app has a Loading screen window (LoadingScreenPreview) with Replay, to watch the building screen without playing through.
- 2026-10-21 Faran Zafar: Changed after review: the coach no longer rides the line. The loading screen is the pen line alone; at the end the coach pops in and cheers beside the protein number.
- 2026-10-24 Faran Zafar: Built: Begin your program (plan page), the paywall with helpers, monthly and yearly and simulated purchase, Add your helper with the share sheet, and the invited person's landing. Pricing in SSCore with tests. 74 tests pass. Simulated: purchases, invites.
- 2026-10-24 Faran Zafar: status todo -> review
- 2026-10-24 Faran Zafar: Owner dislikes the 'Your first week, on one line' finale (zoomed-out pen line). Four replacement directions mocked in design/onboarding/finale.html: A week unrolls, B day-one stamp, C up the hill, D circled in pen. Awaiting a pick; nothing built.
- 2026-10-24 Faran Zafar: Owner clarified the ending is a welcome after payment, not another plan recap. Four welcome directions mocked in design/onboarding/welcome.html (A hello by name, B letter from the coach, C sunrise again, D door opens). The earlier finale.html (plan recaps) is superseded. Awaiting a pick; nothing built.
- 2026-10-24 Faran Zafar: Owner: the last screen after payment is about beginning, not a welcome or plan recap (they are welcomed at the start). Four 'first step' directions mocked in design/onboarding/start.html: A one small thing first, B when should I nudge you, C this is your Today, D hold to start day one. welcome.html and finale.html are superseded. Awaiting a pick; nothing built.
- 2026-10-24 Faran Zafar: Clarified: the screen to replace is the last one after the free trial starts (zoomed-out pen line, 'Your first week, on one line'). Per owner, designs first: four directions in design/onboarding/after-trial.html (A all set, B trial ticket, C seven days, D sunrise sheet). An app build was started without approval and reverted; the old ending is unchanged. start.html, welcome.html, finale.html are superseded. Awaiting a pick.
- 2026-10-24 Faran Zafar: Built the 'You're all set' ending (option A, less wordy): coach cheers, pen tick, two short money lines, one button. Replaces the zoomed-out pen line; overview scaling removed. Docs updated.
- 2026-10-24 Faran Zafar: Fixed the pen line vanishing on later pages after the zoom-out was removed: the page container needs a (no-op) scaleEffect so the tall ink layer renders. Comment left in OnboardingDocument.
- 2026-10-24 Faran Zafar: Owner wants a better-looking paywall. Four directions mocked (interactive, real prices) in design/onboarding/paywall.html: A trial timeline, B what you get, C one big yearly card, D Anna's program ticket. Rules kept: hard paywall, readable renewal terms, Restore purchases. Awaiting a pick; nothing built.
- 2026-10-24 Faran Zafar: Owner: the paywall should sell the value (what changes for her), not features like trackers. Four value-first directions in design/onboarding/paywall-value.html (A what it's for, B someone in your corner, C where we're heading, D strong your way); they echo her quiz answers per spec 2.7 and make no result claims. Supersedes paywall.html. Awaiting a pick; nothing built.
