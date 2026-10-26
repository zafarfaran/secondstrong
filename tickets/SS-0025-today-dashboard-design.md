---
id: SS-0025
title: Today dashboard design
type: task
status: review
created: 2026-10-24
updated: 2026-10-26
external:
---

## Description

Design the Today tab (daily dashboard) in the app's paper style: protein first, calories and steps, five healthy-ageing habits, focus card, coach, calorie-free mode, Free plan view. Four approaches previewed in design/app/dashboard.html; awaiting a pick. Nothing built.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-24 Faran Zafar: Owner wants proper phone screens and a premium, minimal look in the paper style. Redrew the four approaches at true iPhone size (402x874) in a device frame with Dynamic Island, status bar, floating tab bar; ruled lines and boxes removed. design/app/dashboard.html.
- 2026-10-25 Faran Zafar: Generated dashboard art with gen_dashboard.py: four hero scenes (morning/evening, light/dark) with a flat hill for the mascot, and five paper habit icons (protein, strength, move, fibre, sleep). Redrew the four approaches with the mascot visible, a coach line, and tap-to-open Coach screen. design/app/dashboard.html. Key only used in the command environment.
- 2026-10-25 Faran Zafar: Built the full-bleed Today tab: SSToday module (TodayView, HeroScene, TodaySheet, CoachTabView, floating tab bar), TodaySummary/TodayLines/DayPart in SSCore with tests, hero scenes in SSDesign, habits as line icons. Onboarding now hands over to it (Go to Today). docs/design/today.md.
- 2026-10-25 Faran Zafar: status todo -> review
- 2026-10-26 Faran Zafar: Removed every drop shadow from Today, Coach, Profile, check-ins and the tab bar (owner: too much). Hairline edges instead.
