# Plan 0001: onboarding v1

Ticket: SS-0002. Status: prototype flow built (macOS-verified); questions to add.

## Goal

A tappable onboarding flow in SwiftUI for the chosen pen-line direction, using
fake data only, ending at a placeholder plan reveal.

## Steps

- [x] Model the prototype answers in SSCore with tests
- [x] Bundle the prototype's fonts; add them to SSDesign
- [x] Build the screens (14 in the flow now) end to end with the pen line
- [ ] Verify on an iOS simulator or device; fix anything iOS-only
- [ ] Add the peek loader between screens and the birds-on-a-wire intro
- [x] Animate the coaches with the master clips (16 states, 8 coaches, SS-0012)
- [ ] Add the real questions (separate design pass)
- [ ] Add the safety screening block per spec section 7
- [ ] Analysis moment and plan reveal placeholder

## Notes

Design reference: [onboarding design](../../design/onboarding.md). Move this file
to `completed/` when done.
