# Coach chat: voice and check-ins (SS-0026)

Status: built in the prototype (`SSToday`), chosen from `design/app/coach.html`. Voice uses real system speech out but simulated listening;
replies are canned; nothing is sent or stored.

## What the owner asked for

A coach that feels like a character you talk to, like Muse: a chat that can also be a **voice conversation**, and a coach that is
**proactive**, writing first rather than waiting. (Read as Meta's Muse: a personal agent with a chat, a customisable avatar and
voice and video. The exact look of Muse and of "Instinct" was not checked in the apps; correct this if the intent differs.)

## What is built

- **Chat** with the thread the coach started: times, quick replies under its questions, a session card whose Start simulates finishing it.
- **Voice** (waveform button): the mascot listens, thinks and speaks with its own clips; her words are written in handwriting; mute, end, type.
  The voice is the system voice (en-GB). Listening is simulated with a short script; real speech recognition is not connected.
- **Check-ins** (bell): morning plan, protein check, a thread to follow up, after your session, wind down; quiet hours; a daily cap.
  `CheckInPlanner` in SSCore decides what is due (tested): never weight or calories, capped, silent in quiet hours, backs off after
  three ignored in a row, no protein check unless she is 20g or more off. Unread messages show a badge on the Coach tab.

## Instinct (looked up)

Instinct is an invite-only personal agent you text (iMessage, WhatsApp) or call; it texts you first, follows up on threads you dropped
and acts on your behalf with your accounts. We take the proactive part only: a coach that writes first, within rules she controls.
We do not take its agency (no acting for her), and its data practices (training on by default, keeping data after disconnect)
are what we do the opposite of: off unless she says yes, and nothing kept without consent.

## The four screens in the preview

- **A, Chat.** The thread starts with what Miso wrote to her ("Miso started this chat"), with times, quick replies and a session card.
  A waveform button at the top and in the message bar opens voice.
- **B, Voice on the paper scene.** The big mascot on its hill with its own clips: listening, thinking, speaking. Handwritten words under
  it, three round controls: mute, end, type.
- **C, Voice, ambient.** The same conversation as a dark, immersive screen with a glow and pulsing rings and plain captions.
- **D, Reaching out.** What a message looks like when it arrives, and the quiet controls: which check-ins (morning plan, protein
  check, after a session, wind down), quiet hours, and a daily cap of one to three.

## Rules for a coach that writes first (proposal)

- Opt-in, with the notification permission asked in plain words first. Off by default until she says yes.
- At most her chosen number a day (default two), never inside quiet hours (default 9 pm to 7 am).
- Backs off if she ignores several in a row; never guilts a missed day.
- Never about weight, and never about calories for someone in calorie-free mode (spec section 7). No fasting, deficit or "how little" talk.
- Messages come from rules she can see (the four check-ins), not from guesses; the coach's real lines need clinical review.

## Open questions

- Voice engine: on-device speech recognition with a system voice, or a realtime speech service. This decides latency, cost and
  where her words go. Voice and transcripts are health-related PII (see [data handling](../business/data-handling.md)): consent,
  retention, nothing sent without it, and a microphone permission with plain wording.
- Does the coach reply with its own voice, one per coach (eight)? How is a speaking mascot driven (the existing speaking clip, or lip-sync)?
- Free or Pro: spec section 3 says AI coach chat is Pro only.
- Notifications: local scheduling only, or server push as well?
- Video (the avatar on a live call) is out of scope.
