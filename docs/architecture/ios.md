# iOS architecture

Swift 6, iOS 17+, SwiftUI. Code is split into SwiftPM modules so the compiler
enforces the dependency direction. `scripts/check-harness.sh` also checks it in
source and prints how to fix violations.

## Layers

```
SSCore        pure Foundation: models, rules, parsing, quiz logic
  ^
SSDesign      palette, type, reusable SwiftUI components (imports SSCore)
  ^
SS<Feature>   one module per feature (imports SSCore, SSDesign)
              today: SSOnboarding
  ^
App/          composition root: wires features, owns app lifecycle
```

- A module imports only layers below it. Features never import each other.
- To share code between features, move it down into SSCore or SSDesign.
- SSCore must not import SwiftUI, UIKit or AppKit.
- Add a feature: a target in `Package.swift`, a folder in `Sources/`, and a
  product entry; add it to `project.yml` dependencies if the app uses it.

## Boundaries

Parse external input into typed values at the edge (see
[golden principles](../golden-principles.md)). Quiz answers become typed models
in SSCore; views bind to those, not to strings.

## What lives where

- **SSCore:** SVG path parser, point and rect types, coaches, stages, goals,
  answer rules, first-week plan. No UI, no CoreGraphics.
- **SSDesign:** palette, bundled fonts (`SSFont`), the coach clips (`CoachView`,
  `CoachClipPlayer`), shapes from SVG data, pill button. Images are plain PNGs in
  `Resources/Images`, not an asset catalog, so they load under `swift test` too.
- **SSOnboarding:** `PenPlanner` (pure line geometry), `OnboardingFlow`
  (controller), one view per screen, `OnboardingDocument` (pages plus ink).

## Coach clips

Coaches are transparent video, not layers: 16 states per coach for eight coaches, rendered
from the mascot board (`design/coach-clips/`). The app plays HEVC-with-alpha `.mov` files in
`SSDesign/Resources/Clips/<coach>/<state>.mov` through `AVPlayerLayer`. Each state has an in,
a loop and an out (`manifest.json`); `ClipSequencer` in SSCore is the pure rule for when to
loop, leave and hand over, and `CoachClipPlayer` follows it with two players taking turns so
the next clip is already cued. Idle gives way at once; other states finish their loop first.
`CoachView` frames the 400 px clip over the mascot grid (-20,-50 to 220,190), so callers
size it like the old 200 grid and the pen outlines still line up. Reduce Motion shows the poster.

Rebuild the iOS files with `scripts/build-coach-clips.sh` (macOS: needs ffmpeg, `avconvert`).

## Testing

- Logic is tested with Swift Testing on the macOS host: `make test`.
- `PlaythroughSnapshotTests` plays the whole onboarding in an offscreen macOS
  window and saves a PNG per step. Run it with
  `SS_SNAPSHOT_DIR=/some/dir swift test --filter Playthrough` (about 40 s).
- Simulator and UI tests need an installed iOS platform; see
  [tech debt](../exec-plans/tech-debt.md).

## Project generation

`secondstrong-ios/project.yml` (XcodeGen) generates `SecondStrong.xcodeproj`,
which is gitignored. Never edit the project file by hand. See
[ADR 0002](../decisions/0002-swiftpm-modules-and-xcodegen.md).

## Assets

Launch screen assets are copied from `design/launch/` into
`App/Resources/Assets.xcassets`. Design prototypes in `design/` are reference,
not shipped code.
