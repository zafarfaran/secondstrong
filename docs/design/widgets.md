# Widgets (SS-0030)

Status: built, but not yet run on a device. The owner chose B (lock screen) and C (small and medium home widgets) from `design/app/widgets-miso.html`. Preview: `design/app/widgets.html` (home screen, large, coach, lock screen, at real iPhone sizes).
Spec: widgets are Pro only (section 3) and listed in section 4.12.

## The four designs

- **A, small and medium (home screen).** Small: protein as a big number with a thin bar and "23g to go" in handwriting. Medium: the same plus
  calories left (habits done in calorie-free mode) and steps.
- **B, large.** Protein with a small ring, the day as three stops (lift, lunch, a walk) and the five habit dots.
- **C, coach.** The paper scene with Miso and a line from it, in small and medium. Tapping opens the Coach chat.
- **D, lock screen.** A circular protein ring, a wider protein bar, a status line under the clock, and a message from Miso. White on the wallpaper.

## Round two: Miso first (`design/app/widgets-miso.html`)

The owner liked the lock screen and Miso designs and wants the agent picture in every widget. Four variants, each with three states (morning,
goal reached, evening), where Miso changes pose and her line changes: A Miso peeking up on the lock screen with her face inside the protein
ring and a line from her; B her face in the lock widgets with her message as a notification; C a small widget (her face in the protein ring)
and a medium one (her with a speech note and protein); D a large widget with the scene, her note, protein, calories and the five habits.
A widget cannot play video, so the preview now shows the stills the real widgets would use: `design/app/art/miso-morning.png` (calm, eyes
open), `miso-goal.png` (arms up, sparkles) and `miso-evening.png` (asleep, with a Z), cut from the Miso clips. The other seven coaches need the same three stills.

## Rules

Protein leads. Weight never appears; nothing is a streak. Calories disappear everywhere in calorie-free mode. Tapping any widget opens the app
(the coach widget opens the Coach tab). Light and dark follow the phone. A free account sees a prompt to upgrade instead of numbers.

## How it would be built (not started)

A WidgetKit extension that reads a small summary the app shares through an App Group (protein, target, steps, the next item, the coach line).
Widgets cannot animate video, so the coach is a still picture; Live Activities and interactive buttons are a later step. The shared summary is
health data on the lock screen, which anyone can see: it needs a privacy setting ("Hide numbers on the lock screen") before it ships.

## Open

Which sizes ship first; whether the lock screen shows numbers by default; the free-plan version; how often the summary refreshes; the Live Activity for a session.

## What is built (SS-0030)

- **Home:** small (the coach's face inside the protein ring, "62 of 85g") and medium (the coach with a speech note, protein and a bar).
- **Lock screen:** a circle (face inside the ring) and a rectangle (protein as a bar). They are the chosen B; the "Miso message" in B is an ordinary
  push notification, not a widget, and is not built (it comes with the check-ins).
- **States:** morning, goal reached and evening change the still picture and the two-line note (`WidgetSnapshot`, tested). Stills for all eight
  coaches in all three states are in `SSDesign/Resources/Images` (`still-<coach>-<morning|goal|evening>.png`), cut from the clips.
- **Privacy:** the lock screen can be seen by anyone, so by default the lock widgets show no numbers (no ring, "Open to see your day"). Privacy and data
  has a switch, "Hide numbers on the lock screen", to turn the numbers on. Home widgets always show protein. No widget shows weight or calories.
- **Wiring:** the app (`TodayModel`) saves a `WidgetSnapshot` into the App Group `group.com.secondstrong.app` at start and whenever protein, the coach
  or the privacy switch changes, and asks WidgetKit to reload. The extension (`Widgets/MisoWidgets.swift`, target `MisoWidgets` in `project.yml`) reads
  it and draws `SSWidgets`. The pose changes at 7 pm and 5 am.
- **Not done:** running it on a phone or the simulator (this Mac has the iOS SDK but no iOS runtime, so the extension was type-checked against the SDK and
  the views were drawn offscreen); the App Group needs enabling on the Apple developer account; the free-plan upgrade prompt; a coach picker.
