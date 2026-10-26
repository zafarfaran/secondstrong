---
id: SS-0013
title: Family circle: circle, consent, family plan, for-someone-I-love path
type: feature
status: todo
created: 2026-10-21
updated: 2026-10-24
external:
---

## Description

Foundation of the family circle (docs/design/family-circle.md). Circle with payer, members and supporters; explicit revocable consent with a consent log; per-item sharing; family plan on one bill; welcome-screen path for people buying for someone else. Blocks SS-0014 to SS-0017. Nothing is built; the design needs owner answers to its open questions first.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Design written: docs/design/family-circle.md. Open questions are in docs/open-questions.md item 7.
- 2026-10-24 Faran Zafar: Owner set the family plan price (provisional): 8.99 covers buyer plus one free person, then 5.99 per extra person. Open: currency, period, max people, overlap with solo pricing. Recorded in docs/design/family-circle.md (D11).
- 2026-10-24 Faran Zafar: Pricing preview: design/onboarding/pricing.html (price list and live paywall for family plans, option A suggested ladder and option B owner numbers billed yearly, cap of five people, GBP). Waiting for the owner's pick.
- 2026-10-24 Faran Zafar: Owner: start the family plan at 9.99 a month (buyer plus one free person), extra people 5.99 (assumed), revisit prices later. Recorded as D11 in docs/design/family-circle.md; prices to live in one place in code.
- 2026-10-24 Faran Zafar: Owner: solo 9.99 a month; solo plus one helper (supporter, e.g. a son) 12.99. Supersedes the 9.99 family-pair price. Open: further helpers, yearly, helper capabilities, replacing the spec's solo prices. Recorded as D11.
- 2026-10-24 Faran Zafar: Pricing page rebuilt for the new structure (solo 9.99, solo + helper 12.99): design/onboarding/pricing.html, with a switch for the price of further helpers, suggested yearly prices (monthly x 8) and what you keep.
- 2026-10-24 Faran Zafar: Decided (to revisit later): solo 9.99 a month; solo + 1 helper 12.99; each further helper +4.00; yearly at eight months' price (79.99, 103.99, 135.99, 167.99, 199.99). Recorded as D11 and D12 in docs/design/family-circle.md. pricing.html updated.
- 2026-10-24 Faran Zafar: Prototype of the add-someone flow is in the onboarding: paywall helper stepper, Add your helper, invited landing. Not built: Family area, real invites, server-side seats, supporter experience.
