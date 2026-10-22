---
id: SS-0019
title: Onboarding questions v1: consent, birth year, safety, body, training, words
type: feature
status: review
created: 2026-10-21
updated: 2026-10-21
external:
---

## Description

Build the agreed short question set into the pen-line onboarding: consent, in-your-words, birth year (adult gate), safety screening, height and weight, strength experience and equipment. Protein target from weight. Flow becomes 12 screens. Design: docs/design/onboarding-questions.md.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-21 Faran Zafar: Built: consent, words, birth year, safety, numbers, strength screens; rules in SSCore with tests; plan echoes her words; pen rings the new answers. 52 tests pass incl. a 12-screen playthrough. Not run on iOS; wording needs legal and clinical review.
- 2026-10-21 Faran Zafar: status todo -> review
- 2026-10-21 Faran Zafar: Fixes after review: consent is now a privacy card with an Agree and continue button (no checkbox); birth year is typed (the picker misbehaved); coach name follows the coach again (a field echoing its text had locked it as edited), with tests.
- 2026-10-21 Faran Zafar: Birthday is now a full date (day, month, year) with an exact 18+ check; height and weight are sliders that must be moved to count.
- 2026-10-21 Faran Zafar: Chosen from design/onboarding/inputs.html: ruler for height and weight, three wheels for birthday. Built as RulerPicker and WheelColumn in SSDesign. Not tried by touch.
- 2026-10-21 Faran Zafar: Goals and words merged into one screen: set list of ten outcomes (max 3) plus optional sentence. Flow is 11 screens. 56 tests pass.
