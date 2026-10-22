# Onboarding questions

Status: built in the prototype, SS-0019, 2026-10-21. Extends [onboarding](onboarding.md).

The shortest set that is safe and builds a real first week: 8 questions on 12 screens. The spec
(section 2.3) lists 26 to 30 for the web quiz and 12 to 15 in-app; this is deliberately below that.
Rule: ask only what is needed to be safe or to build week one. Everything else is asked later,
in context.

## Flow

| # | Screen | Collects | Gate |
|---|---|---|---|
| 0 | Welcome | The logo (the S with its rose dot over the Second Strong wordmark), a line of copy, the paper scene | |
| 1 | Before we begin | Consent to use health answers: three plain points and one "Agree and continue" button | Tapping the button is the consent |
| 2 | Pick your coach | Coach and name | |
| 3 | Where are you | Menopause stage | One choice |
| 4 | What would you like to achieve | Up to three from a set list of ten, plus an optional sentence (140 characters) | At least one goal |
| 5 | Birthday | Full date of birth on three styled wheels (day, month, year) | Must be 18 or over today |
| 6 | Anything we should know | Safety list, multi-select | At least one (incl. "none", "rather not say") |
| 7 | Your numbers | Height and weight on a draggable ruler, metric or imperial | Both moved, or Skip |
| 8 | Your strength | Lifting experience, equipment | Both |
| 9 | Your days | Two to four training days | Two to four |
| 10 | Building your program | Loading moment, about 7 seconds: the pen line climbs, one milestone per step, ending on the protein number; then the coach pops in and plays its cheer clip. Plays once; Back from the plan skips it | |
| 11 | Your first week | Plan: protein, days, her words, note (becomes Begin your program, then the paywall: SS-0020) | |

## Rules in code (SSCore, tested)

- **Consent first.** Health answers are special-category data under UK GDPR; nothing health-related is asked before the agree step. The wording is a placeholder until legal approves it ([open question 3](../open-questions.md)).
- **Adult gate.** Exact to the day from the full date of birth, self-declared. SS-0018 decides whether anything stronger is needed. Impossible dates (31 February) are refused.
- **Safety list** (spec 2.6, 7). "None" and "rather not say" stand alone. Conditions (diabetes, thyroid, heart, kidney) add a "check with your GP" note and never block. Wording is neutral and never says she was flagged.
- **Disordered-eating history** means calorie-free: the numbers screen asks for nothing, the protein target is the default, her free text is not quoted back, and the plan says no calorie counting.
- **Pregnant or breastfeeding** also skips body numbers.
- **Numbers** are stored metric. Ruler ranges are 120 to 220 cm (4' to 7'2" in imperial) and 35 to 250 kg. Each ruler has to be moved before it counts, so a starting position is never taken as an answer. On the wheels, moving any wheel records all three shown values. Skipping is allowed.
- **Protein target** is 1.2 g per kg, kept within 60 to 140 g and rounded to 5, or 100 g with no weight. Needs clinician sign-off.

## Goals

Ten outcomes in plain words, none about weight: feel stronger, carry things without struggling, keep up with my family,
have more energy, sleep better, move without aches, stay independent as I age, get back into exercise, build healthy
habits, feel comfortable in my body. Each maps to a theme (strength, energy, sleep, habits) that decides how the coach
reacts. Her optional sentence is quoted in the plan, except for calorie-free accounts. "Lose weight" is left out on
purpose; she can still write it, and the plan handles that safely.

## Left out on purpose

Goal weight (optional in the spec; no goal weight means no projection to guard), food preferences
and allergies (asked the first time meals are opened; allergies must be asked before any meal is shown),
symptoms, sleep, cooking time, who she cooks for, education cards, readiness slider. None are used by the first-week plan.

## Pen line

Each answered screen is ringed by the pen: the agree row, safety choices, strength and equipment, as well as stage, goals and days.

## Not done

- Keyboard avoidance on small phones, and the 12 screens on a 4.7-inch phone, are untested.
- Not run on iOS yet. The ruler and wheels (`RulerPicker`, `WheelPicker` in SSDesign) have not been tried by touch on a device; the picks came from `design/onboarding/inputs.html`.
- Date of birth, goal weight and the food questions are later work.

## Account

Sign-in and sign-up are the first thing anyone sees, before the pen-line onboarding, in the final look from `design/signin`,
light and dark: one door for new and returning members (Apple, Google or email, over the torn-paper hills), an email screen,
Check your inbox with a six-digit code for another device, Welcome back for a returning member (their coach greets them and
the way they came in last time comes first), and Link expired. New members go straight on to the welcome page.

- Sign-in is simulated (`OnboardingFlow` account section, SS-0021): nothing is sent or stored, and any six digits work.
  Debug builds add "Prototype only" links to reach the returning and expired screens, and "Open Mail" stands in for the link.
  The preview app's Sign-in screens window shows all five screens, light and dark.
- Dark mode: `Palette` follows the phone's setting for the whole app (design/signin tokens: ground #211B17, ink #F1E9DF).
  Only the sign-in screens were designed for dark; the onboarding screens are the same layouts in the dark palette.
- The sign-in sky is drawn in code in the paper style (`PaperSky`) and moves, with the hills and the eight coaches cut out of the design's picture in front of it (`auth-hills`, light and dark). Night: a torn-paper crescent that sways, paper stars that twinkle, dark paper clouds drifting, a shooting star every 12 seconds, a few fireflies. Day: a paper sun with slow rays, cream clouds, drifting dust. Nothing moves across the headline. Still with Reduce Motion.
- Google's four-colour "G" is drawn from the design's paths. Apple's logo is the system symbol.
- Not built: the password fallback, real Apple and Google sign-in (entitlements, a backend), the buy-for-someone path
  (open question 8). The returning member is made up (Anna, Miso, Apple).

## Paper look

The screens use the torn-paper art from `design/onboarding/paper` with the app's own animation kept on top: the pen line, the
animated coach clips and the loading climb. Welcome, days and the building screen sit on paper scenes (day and night); the
coach pick has one paper platform fixed in the centre; the coaches slide across it, and the one on it comes alive (no swap of artwork). When a coach lands it plays its hello and its temperament line writes itself out in handwriting; stages are paper moons; each goal chip has a
paper icon; consent, birthday, safety, numbers and strength carry a small paper badge. The five badges and six goal icons were
generated with `design/onboarding/paper/gen_extra.py` (OpenAI image model, key from the environment only, never stored).
The pen routes and the coach's spot at the flag are fitted by eye; the other screens are not redrawn.
