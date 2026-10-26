---
id: SS-0030
title: Home screen and lock screen widgets
type: feature
status: todo
created: 2026-10-26
updated: 2026-10-26
external:
---

## Description

Widgets for protein, the day and the coach. Four designs in design/app/widgets.html; Pro only; needs a WidgetKit extension and an App Group, and a lock-screen privacy setting. Nothing built.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-26 Faran Zafar: Owner likes the lock screen and Miso widgets, wants the mascot in all of them. Round two in design/app/widgets-miso.html (four variants, three states: morning, goal reached, evening). Awaiting a pick.
- 2026-10-26 Faran Zafar: Widget preview now uses still pictures of Miso (morning, goal, evening) cut from the clips, since widgets cannot play video. Stills in design/app/art. Other coaches need the same three.
- 2026-10-26 Faran Zafar: Built B and C: SSWidgets views, WidgetSnapshot rules (tested), stills for all 8 coaches x 3 states, WidgetKit extension in Widgets/ (type-checked against the iOS SDK, not run on a device), app shares snapshot via App Group, lock-screen numbers hidden by default with a Privacy switch.
