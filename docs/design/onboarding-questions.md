# Onboarding questions

Status: built in the prototype, SS-0019, 2026-10-21. Extends [onboarding](onboarding.md).

The shortest set that is safe and builds a real first week: 10 questions on 16 screens (the two calorie screens are skipped when no calorie target is possible). The spec
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
| 9a | How active is your day | Everyday movement, not training: mostly sitting, some of the day, most of the day, physical work (SS-0024) | One choice; skipped when no calorie target is possible |
| 9b | What do you want | Lose fat gently, maintain or build muscle, then a slider for kilos a week with live bars of maintenance against her target and the safe floor. A small "I'd rather not see calories" option turns calories off (spec section 7) | One choice, or calories off; skipped like 9a |
| 10 | Building your program | Loading moment, about 7 seconds: the pen line climbs, one milestone per step, ending on the protein number; then the coach pops in and plays its cheer clip. Plays once; Back from the plan skips it | |
| 11 | Begin your program | A calorie ring (when she chose calories) with protein beside it, the training days, a GP line only when needed, one short coach note. One Begin button | |
| 12 | Choose your plan | The paywall: Just me or Me and a helper (1 to 4), monthly or yearly, 7 days free, terms in readable type, Restore purchases. Hard, no skip. Prices from `Pricing` in SSCore | Purchase (simulated) |
| 13 | Add your helper | Only if she bought helpers: a name, an optional message, and a link to send with the system share sheet; Skip for now. The "You're all set" screen follows | |

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

- Keyboard avoidance on small phones, and the 14 screens on a 4.7-inch phone, are untested.
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
- The sign-in sky is drawn in code in the paper style (`PaperSky`) and moves, with the hills and the eight coaches cut out of the design's picture in front of it (`auth-hills`, light and dark). Night: a torn-paper crescent that sways, paper stars that twinkle, dark paper clouds drifting, meteors that loop for as long as the screen is open, two lanes on 4.8 s and 7.3 s rhythms so one is nearly always crossing and sometimes two share the sky; each crosses the whole sky from right edge to left (a white-hot head with a glow, a tapering tail, a thin second streak and a little dust; each pass differs in height, angle and length), a few fireflies. Day: a paper sun with slow rays, cream clouds, drifting dust. Nothing moves across the headline. Still with Reduce Motion.
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

## Plan, paywall and helpers

- **Prices** are decisions D11 and D12 in [family circle](family-circle.md) and live in one place, `Pricing` in SSCore (tested):
  solo 9.99 a month, one helper 12.99, each further helper +4.00, yearly at eight months' price (79.99, 103.99, 135.99, 167.99, 199.99).
- **Purchases are simulated** (`OnboardingFlow` paywall section): nothing is charged, Restore purchases finds nothing. Real in-app
  purchase needs the ten store products and a backend that shares access with invited people.
- **Invited people:** the sign-in door has a Prototype link to the invite landing ("Sam added you to their plan"). They sign in, answer
  their own questions, and skip the paywall because the plan that added them covers them. In the prototype an invited person is treated
  as a member; the helper (supporter) experience is not built.
- **Add your helper** uses a placeholder link (`example.com`) and the system share sheet. Only one helper is added during onboarding; the rest
  would be added from a Family area that does not exist yet.
- Not built: the Family area, real invites and deep links, seat limits on the server, a downgrade or cancel path, and any trial reminders.

## The coach's fall, page hops and idle moves

- **Fall.** When the coach leaves the carousel it falls to the bottom-right corner. The body is a rendered clip (`fall`, made with
  HyperFrames in `design/coach-clips`, all eight coaches): a squat and launch, a stretched, surprised fall with ears and arms
  fluttering, then a squash, a hop and a settle. The screen movement accelerates like a fall and arrives when the clip's landing starts.
- **Every page change.** The docked coach stays on screen and plays its fall in place: one body, no vanishing, no leap up.
  On the loading screen and the paywall it drops out of the bottom, and falls back in from above on the next page
  or when the person goes back. With Reduce Motion it just stays put.
- **Idle moves when it is quiet.** After about 6 seconds with no touch and no new answer, the coach on screen does one of three small
  moves, taking turns (`idleLook`, `idleYawn`, `idleBounce`), then another every 7 seconds for as long as it stays quiet. Any touch or answer
  starts the wait again. Each move plays once and returns to idle by itself; anything else the coach is asked to do cuts in at once.

## The coach's margin notes

Replacing the first bubble (owner: too slop-looking), the coach speaks as a note in the margin: a few words of handwriting low on the left, above the
Continue button, written out letter by letter, with a pen underline drawn beneath. No box. It is as wide as the space left of the coach (two or three short lines), sits just above Continue and rises higher on pages with a skip link (body, invite), so it never covers a button, a link or the text field. It stays about seven seconds, clears when the person
touches something after four, and tapping the coach says the next line. Lines are a few words each (`CoachLines`, tested for length and voice) and are
drafts until a clinician signs off the facts. The coach listens while it writes. Chosen from `design/onboarding/coach-speech.html` (option F).

## The ending: You're all set

After the trial starts (and the helper invite, if there was one) the page gives way to one short screen, replacing the zoomed-out pen line.
The coach cheers in a warm circle, a pen tick is drawn on an ink badge, and the title is "You're all set." Under it, only the money, in
two short lines: "Free until 31 October" and "then £79.99 a year", then "Cancel any time in Settings." in handwriting; the date is the end of the 7-day
trial. Someone covered by another person's plan sees "Covered by Sam's plan. Nothing to pay." instead. One button, Go to Today (in the prototype it
restarts the flow). No recap of the program and no bullet list: the Begin your program screen already did that. Chosen from
`design/onboarding/after-trial.html` (option A), then cut back to be less wordy. Light and dark.

## Maintenance and calorie target (SS-0024)

After the days screen, two screens ask how active her day is and what she wants (with a small option to hide calories), and the
plan screen then shows her estimated maintenance and daily target (modelled on MacroFactor's setup). `EnergyPlan` in SSCore does
the sums: Mifflin-St Jeor for a woman, an activity factor of 1.2 to 1.5, plus 0.03 per strength session, rounded to 10 kcal, with
a range of plus or minus 120. The pace is a slider in 0.05 kg steps, capped at 0.4 kg a week to lose and 0.2 to build (it starts at 0.25 and 0.1); the target never goes
below 1,400 kcal, whatever the slider says. The two screens are skipped, and no calories are shown, for an eating-disorder history, pregnancy or
breastfeeding or a skipped body screen; choosing "I'd rather not see calories" also hides them. All the numbers are drafts for a clinician and a nutrition
adviser. Design and open questions: [calorie tracker](calorie-tracker.md).
