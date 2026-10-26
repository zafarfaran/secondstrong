# Food tab and camera (SS-0032)

Status: built in the prototype, 2026-10-26. Designs: `design/app/food-timeline.html` (chosen: A, the quiet timeline) and
`design/app/food-camera.html` (chosen: A, the full-screen viewfinder) and the reading animation `design/app/food-scan.html` (chosen: D, the quiet checklist;
the scan band, lens and pen concepts need item positions from the model, which does not exist yet, so they wait). Earlier rounds, `food.html` and `food-alive.html`, were passed over
(the second was "too much"). The layout follows Cal AI's week strip, summary card and photo logging, with protein first.

## The Food tab (`FoodView`)

- A week strip: each past day ringed by how close she got to her protein, today a dark pill. Past days are made up in the prototype.
- One summary card: a protein ring, "23g to go" in handwriting, calories only when she has them on (spec section 7), the meal count.
  Carbs and fat are not shown: the log does not hold them yet. The design had two thin bars.
- The day down a line: time, dot, a card with the picture, name and protein. Miso's single note sits after the last meal and is
  always about protein (`FoodDiary.note`, drafts for review). A dashed card shows what comes next (`FoodDiary.next`), and tapping
  it or the round + opens the camera. Nothing after 6 pm.
- Meals added by the camera or by the coach chat both land here and in the Today totals and widgets (`TodayModel`).

## The camera (`CameraView`, `CameraFlow`)

Viewfinder with corner brackets and a hint from the coach, a gallery button and the shutter. After the shutter the coach reads the photo over a dimmed, blurred copy: a calm card with her face and three steps that tick off
(Looking at your photo, Spotting the food, Estimating portions) and a thin bar filling, then a result sheet: the name (editable),
what was spotted as chips she can take off, Small, Medium or Large, protein and calories (calories hidden when off), "Add to Lunch" (the meal
is named by the clock). It always says it is an estimate. Removing an item or changing the portion scales the numbers (`MealEstimate.adjusted`).
A photo that cannot be read gets "I could not read that one", with Choose a photo and Retake.

## Prototype limits

- The reader is fake: `MealEstimate.samples`, and every third photo fails so the state can be seen. No real food model is connected.
- On iOS the viewfinder is the back camera (`CameraSession`, permission asked on first use, strings in `project.yml`). Only type-checked
  against the iPhone SDK: no iOS runtime here, so it has not run on a device. On a Mac and in tests it shows a made-up plate.
- Not built from the design: flash, Barcode and Label modes, typing a meal in, search, a real last-photo thumbnail, editing or deleting a logged meal,
  other days (the week strip is not tappable), carbs and fat. Photos are not stored.
- Open: where photos live and for how long, and consent for sending them to a model (see [coach chat](coach-chat.md)).
