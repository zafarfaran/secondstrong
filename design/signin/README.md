# Sign in

**Final** (canvas page "Final", opens first): https://claude.ai/artifact/6esPDoPLoRhrVhoD3UdQDR

| Step | Dark | Light |
|---|---|---|
| Sign in | the coaches on torn-paper hills at night (10a) | the same scene at sunrise (10b) |
| Email | dark email screen | email screen |
| Check your inbox | Bramble with the envelope, night paper scene | Bramble with the envelope |
| Welcome back | Miso keeping your page, night paper scene | Miso keeping your page |
| Link expired | Otto with the hourglass, night paper scene | Otto with the hourglass |

The app follows the phone's light or dark setting. The screens are in `final/` (built by
`make_final.py`); the night coach art is `art/ai/night-*.png` (`gen_art.py night-bramble night-miso night-otto`,
the 10a collage as style reference). Everything below is the exploration that led here, kept on the canvas's
Explorations page.

---

## Explorations

Canvas: https://claude.ai/artifact/6esPDoPLoRhrVhoD3UdQDR (six iPhone screens, linked so you can click through)

1. **Sign in**: one door for new and returning members. Apple, Google or email. The whole cast stands
   on a drawn line; a margin note says you pick a coach next.
2. **Email**: an emailed sign-in link by default (no password); "Use a password instead" as a fallback.
3. **Check your inbox**: Bramble points at the envelope. A six-digit code for signing in on another device.
4. **Welcome back**: a returning member who signed out. Their own coach greets them, a note from the
   coach, and the method they used last time comes first.
5. **Link expired**: Otto's oops pose, one tap for a fresh link. No red, no blame.
6. **Sign in, dark**.

## Build notes (SwiftUI + Supabase)

- Apple: `SignInWithAppleButton`, required on iOS when Google sign-in is offered. Use Apple's own button in
  the shipped app; the mock draws a matching ink pill.
- Google: Google's sign-in SDK and their official "G" mark (their colours are required, so it is the one
  place colour beyond the Sketchbook palette appears).
- Email: Supabase magic link plus OTP (`signInWithOtp`); the same email carries the link and the 6-digit code.
  Universal link opens the app; the code covers opening the email on a laptop.
- Returning: remember the last method and the member's first name and coach locally (Keychain), never the email
  on a shared screen beyond this one.
- Copy follows the content rules: UK English, no exclamation marks, no "just", "journey" or "reset".

## Art

`make_art.py` builds the illustrations in `art/` from the rendered coach clips (`../coach-clips/renders`), so the
art is the real cast at the same scale: `cast-light.png` / `cast-dark.png` (390 × 140 pt at 3x),
`miso-hello.png`, `bramble-suggest.png`, `otto-oops.png`. `screens/` is a copy of the canvas's files.

## Illustrated versions (generated)

The canvas's second row (1b, 3b, 4b, 5b, 6b) uses richer scenes made with OpenAI `gpt-image-2`, with the real coach
art sent as reference so the characters stay on-model. The first-row originals stay for comparison.

- `gen_art.py` makes them (`OPENAI_API_KEY` from the environment, never stored): `art/ai/<name>.png`.
  The single-coach prompts insist on the coach shape (one round body, no legs), since the first pass grew legs;
  that first pass is kept as `*-v1.png`.
- `blend_art.py` snaps each image's paper to the exact screen colour and writes the 3x JPEGs in `art/ai/web/`.

## Other directions, without the coaches (canvas row 3)

7. **One line**: a single continuous ink line draws a woman doing a kettlebell deadlift and runs on into a low sun.
8. **Morning table**: a gouache still life (tea, trainers, a small dumbbell, notebook) bleeds off the top and fades into the page.
9. **Paper shapes**: torn-paper hills fill the lower screen; the sign-in buttons sit on an ivory card over them.

Made with `gen_art.py line-lift morning-table paper-shapes` (prompt only, no reference images).

## Full flows for One line and Paper shapes (canvas rows 4 and 5)

Each direction now has email, check your inbox, welcome back, link expired and dark sign-in, linked from its sign-in
screen so Play walks the whole flow. Art: `gen_art.py line-* paper-*`; the dark one-line drawing is the light one
recoloured (warm off-white line, lighter terracotta sun). `make_flows.py <canvas project folder>` writes the ten
screens from shared pieces.

- **One line**: the drawing leads each screen on plain ivory (a hand drawing the line; an open envelope with a
  terracotta seal; a woman lacing her trainers; an hourglass).
- **Paper shapes**: torn paper at the edges. Email and inbox keep the hills at the bottom with the actions on an
  ivory card, like sign-in; welcome back and expired use a collage band (the sun risen high; a paper hourglass).

## Coaches on paper (canvas row 6)

The coaches placed in the torn-paper night collage (picked from 9e), as sign-in screens in the paper layout:
10a night (soft coaches), 10b sunrise (light), 10c night with the coaches made of torn paper too.
`gen_art.py mascot-paper-night mascot-paper-day mascot-papercut-night` sends the paper collage as the style
reference and the cast as the character reference.
