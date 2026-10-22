# secondstrong-ios

Native SwiftUI iPhone app. Swift 6, iOS 17+, strict concurrency.

Read [architecture](../docs/architecture/ios.md) before adding a module or
moving code between layers. Onboarding design: [onboarding](../docs/design/onboarding.md).

## Layout

```
Package.swift        modules (SwiftPM), one target per layer or feature
Sources/SSCore       pure Foundation: models, rules, parsing. No UI imports.
Sources/SSDesign     palette, type, reusable SwiftUI components
Sources/SS<Feature>  one folder per feature (SSOnboarding, ...)
Tests/               one test target per module that has logic
App/                 composition root + assets; no feature logic
project.yml          XcodeGen spec. The .xcodeproj is generated, never edited
```

## Rules

- Layer order: SSCore -> SSDesign -> features -> App. Features never import
  each other; share code by moving it down a layer.
- New logic goes in SSCore with a test first. Views stay thin.
- Add a module by editing `Package.swift` and, if the app uses it,
  `project.yml`. Never hand-edit `SecondStrong.xcodeproj`.
- One primary type per file, under 600 lines.
- Comments: 3 lines max per block, only for business logic and its ticket
  (`// SS-NNNN: protein target never drops below floor`). Never narrate code.
- Colours come from `Palette`, never inline hex.
- Use fake data only. No real health data anywhere in code or tests.

## Commands

```
make test     # swift test (macOS host, runs SSCore tests)
make gen      # regenerate SecondStrong.xcodeproj
make build    # gen + xcodebuild for the iOS Simulator (needs iOS platform installed)
make preview  # macOS window running the onboarding
make check    # ../scripts/check-harness.sh
```
