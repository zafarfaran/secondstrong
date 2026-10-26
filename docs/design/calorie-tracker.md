# Calorie and macro tracker (SS-0024)

Status: the onboarding part is built in the prototype (activity, goal, food view, numbers on the plan screen); the Today screen, food logging and weekly check-in are still proposals. Preview: `design/onboarding/calorie-tracker.html` (four interactive screens).
Read first: spec section 4.1 (nutrition), section 7 (safety, non-negotiable), section 2.6 (screening). Health and
weight data is PII: fake data only in code, tests, fixtures and screenshots (see [data handling](../business/data-handling.md)).

## In onboarding (owner request: replicate MacroFactor's setup)

Preview: `design/onboarding/onboarding-numbers.html` (interactive; the reveal recalculates from the other screens).
After the body, strength and days screens (age from birth date, height, weight and training days already asked), four screens are added:

1. **How active is your day?** Everyday movement, separate from training: mostly sitting, on my feet some of the day, most of
   the day, physical work. Plain examples under each.
2. **What do you want?** Lose fat gently, maintain or build muscle, then a slider for kilos a week (0.05 steps, capped at 0.4 to lose and 0.2 to build; drafts) with live
   bars of maintenance against her target and a dashed safe floor.
   Under the slider, a small "I'd rather not see calories" option switches to protein and habits only (spec section 7 wants
   calorie-free offered in onboarding). A positive disordered-eating screen, pregnancy or breastfeeding skips both screens.
3. **Begin your program.** The calorie ring with protein beside it, the training days and one short coach note.

**Starting maintenance** (draft): Mifflin-St Jeor for a woman (10 x kg + 6.25 x cm - 5 x age - 161) times an activity factor of
1.20, 1.30, 1.40 or 1.50 for the four answers, plus 0.03 per strength session a week; rounded to 10 kcal and shown as a range of
plus or minus 120. The women-only equation is assumed because the product is for women: confirm. If she skipped weight or
height, we do not guess a calorie target; the reveal shows protein and habits and we estimate from her first weeks of logs.

## What it is

A MacroFactor-style experience: log food quickly, see an estimated **maintenance** number that learns from her own weight
trend and intake, pick a goal (lose fat gently, maintain, build muscle) and get a daily calorie target, then a weekly
check-in that adjusts it. Where it differs from MacroFactor on purpose:

- **Protein first.** The Today screen leads with protein; calories sit beside it. Protein target is the same whatever the goal.
- **Estimates with a range.** Never a single exact number, and it says how sure it is ("week 2 of about 4").
- **No weight gamification.** The weekly check-in describes the trend in plain words ("gently down"), never "you lost".
  Streaks apply to habits (logging, protein, training), never to weight or a kept deficit (spec section 7).
- **Calorie-free mode** hides every calorie number; offered in onboarding and in Today, always reversible.
- **Gentle.** Goal names are "Lose fat gently", "Maintain", "Build muscle"; paces are slow.

## The maths (proposal, for a clinician and a nutrition adviser to review)

1. **Start**: maintenance from Mifflin-St Jeor with a modest activity factor, shown as a range of plus or minus 100 kcal.
2. **Trend weight**: an exponentially smoothed weight, so daily wobble (water, cycle, salt) does not move targets.
3. **Learn**: maintenance is re-estimated weekly as average intake minus (trend change in kg times 7,700) over the days,
   blended with the formula estimate and weighted by how many days she logged. Under about 10 logged days it stays mostly
   formula. A missed week changes nothing; no logging never produces a "target".
4. **Target**: maintenance minus (pace in kg a week times 7,700 / 7) to lose; plus the same for building; maintenance to hold.
   Paces are capped at 0.5 kg a week to lose and 0.25 kg a week to build (drafts).
5. **Hard floor**: the target never goes below 1,400 kcal (draft; a clinician sets the real figure, section 7). If the pace
   would cross it, the pace is clamped and the screen says so. The floor is tested in `SSCore` and applies to the coach too.

## Safety envelope (all from spec section 7 and 2.6; none of it is optional)

- Disordered-eating screen positive: starts in calorie-free mode, no goal weight, no projections, a kind explanation.
- Pregnancy or breastfeeding: no calorie targeting, no goal weight.
- Low-intake note: a supportive message with a route to support after several days well under target; copy by a clinician.
- The coach never proposes or endorses a target below the floor, extreme deficits, or "how little can I eat".
- No before-and-after imagery; progress photos stay private and opt-in.

## Experience (the four screens in the preview)

1. **Today**: protein card, calories left, other macros and fibre, meals, Add food by photo, barcode, voice or search.
2. **Your energy**: maintenance with range and confidence, goal selector, pace slider, the daily target, a small disclaimer.
3. **Weekly check-in**: trend line with the raw dots, habits ("logged 6 of 7 days"), what maintenance did, keep or accept the new target.
4. **How would you like to see food**: protein and calories, or protein and habits only; the gentle low-intake note.

## Proposed order

1. `SSCore`: trend weight, maintenance estimator, target with floor and pace caps, with tests first (all fake data).
2. Calorie-free mode and the screening routing in onboarding (the choice screen, default for a positive screen).
3. Today, Add food (text and search first; photo, barcode and voice later) and the weekly check-in.

## Open questions

- Who signs off the floor, the paces, the activity factors and the low-intake wording (clinician and nutrition adviser)?
- Is this inside Pro only, or is the maintenance estimate also free? (spec section 3 gates Today to calories, protein, steps for free.)
- Food database: the UK supermarket and ready-meal source, and the cost of AI photo and voice logging (spec section 1.8).
- Should "Build muscle" appear for a first-time user, or only after a few weeks of strength training?
- Spec section 4.1 needs an entry for the adaptive maintenance estimate once this is approved.
