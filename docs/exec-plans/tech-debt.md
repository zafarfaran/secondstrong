# Tech debt

One line each. Remove when fixed.

- The product spec (715 lines) exceeds the 600-line doc limit. Split it into
  per-section files under `docs/business/spec/` and update the spec map.
- No iOS platform or simulator installed locally, so `make build` and UI tests
  have not been run. Install via Xcode > Settings > Components.
- App icon not set; launch assets copied from `design/launch/` by hand.
- The app has never been compiled for iOS (no iOS platform installed); only macOS
  builds and tests have run. First real build may surface iOS-only issues.
- Coach clips add about 59 MB (128 HEVC-alpha files). Re-encode at lower quality or trim
  states before release. Offscreen macOS snapshots cannot capture video layers, so clip
  playback is checked by `CoachClipPlayerTests`, not by screenshots. Idle gives way mid-loop
  with a hard cut; the breathing is subtle, but watch for a pop on device.
- The suggest bubble and breathe cues from the clip manifest are not used yet.
- Protein target is a fixed 100 g placeholder in `FirstWeekPlan`.
- Pen strokes are not yet tested on small phones (iPhone SE height).
- Prototype was built with the 4-question flow; the long quiz is not designed yet.
- No CI. Add a workflow running `scripts/check-harness.sh` and `swift test`.
- No automated recurring cleanup yet (see [golden principles](../golden-principles.md)).
- Bundle id `com.secondstrong.app` and display name are placeholders.
- Ticket sync to an external tracker is not built; only the `external` field exists.
- No commit-msg hook requiring a ticket id in commit messages.
