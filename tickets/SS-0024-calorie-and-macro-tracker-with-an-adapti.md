---
id: SS-0024
title: Calorie and macro tracker with an adaptive maintenance estimate
type: feature
status: in-progress
created: 2026-10-24
updated: 2026-10-24
external:
---

## Description

A MacroFactor-style experience inside the safety envelope of spec section 7: protein first, estimated maintenance that learns from weight trend and intake, targets for losing fat gently, maintaining or building, a weekly check-in, and calorie-free mode. Design and previews first; nothing built until the owner approves.

## Acceptance

- [ ] TBD

## Comments

- 2026-10-24 Faran Zafar: Design proposal in docs/design/calorie-tracker.md and interactive preview design/onboarding/calorie-tracker.html. Floor 1,400 kcal and paces 0.5 kg lose / 0.25 kg build are drafts for clinical sign-off. Nothing built.
- 2026-10-24 Faran Zafar: status todo -> in-progress
- 2026-10-24 Faran Zafar: Owner wants this in onboarding like MacroFactor: ask activity level, then compute maintenance and target ourselves. Interactive preview design/onboarding/onboarding-numbers.html (activity, goal and pace, food view, numbers reveal; safety branch). Formula, factors, floor and paces are drafts for clinical review. Nothing built.
- 2026-10-24 Faran Zafar: Built the onboarding part: ActivityLevel, FoodGoal, GoalPace, FoodView and EnergyPlan in SSCore (tested), three new onboarding screens after training (skipped when no calorie target is possible), numbers on the plan screen. Formula, factors, floor and paces are drafts for clinical sign-off.
- 2026-10-24 Faran Zafar: Trimmed copy across onboarding (owner: too wordy, reads like AI slop) and added paper icons and hills art to the three food screens; numbers now told after the plan is built (loading result and Begin screen). New art prompts queued in gen_extra.py, needs OPENAI_API_KEY in the environment.
- 2026-10-24 Faran Zafar: Generated nine paper icons (activity-sit/some/most/hard, food-goal-cut/hold/gain, food-view-cal/free) with gen_extra.py and wired them into the three food screens. Key was only ever in the command environment, not stored.
- 2026-10-24 Faran Zafar: Owner: Begin screen too wordy/cluttered; goal screen should have a slider and graph of how calories change. Three options each in design/onboarding/energy-screens.html (bars, dial, week of calories; two big numbers, program ticket, ring and week). Calories-only graphs, slider capped 0.4/0.2 kg a week, floor holds. Awaiting a pick; nothing built.
- 2026-10-24 Faran Zafar: Built owner's picks: bars graph with a kg-a-week slider on the goal screen (continuous, capped, floor holds; GoalPace removed) and the ring-and-week Begin screen. Days screen now comes before the three food screens so maintenance matches on the goal screen and the plan.
- 2026-10-24 Faran Zafar: Removed the how-would-you-like-to-see-food screen (owner: pointless now that calories are tracked). Calories are the default; spec 7 still wants calorie-free offered in onboarding, so a small 'I'd rather not see calories' option sits on the goal screen. Coach note dropped on that screen.
