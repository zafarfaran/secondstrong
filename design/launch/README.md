# Launch screen (option A)

The still screen iOS shows the moment the icon is tapped: the heavy **S** and its clay dot, centred on almond. It matches the app icon, so the iOS zoom from the home screen is seamless. When the app is ready, the dot comes alive and hands over to the birds-on-a-wire intro (`../onboarding/coldstart.html`).

| | Light | Dark |
|---|---|---|
| Background | `#EDE3D6` almond | `#211B17` |
| S | `#3B322C` ink | `#F1E9DF` |
| Dot | `#C08E82` clay | `#C08E82` clay |

`preview.png` shows both. `options-light.png` and `options-dark.png` show the three options that were compared.

## Files

- `Assets.xcassets/LaunchMark.imageset/`: PNG @1x, @2x, @3x with dark variants (86.6 × 75.7 pt).
- `Assets.xcassets/LaunchBackground.colorset/`: the background colour, light and dark.
- `launch-mark.svg`, `launch-mark-dark.svg`: vector masters. The S is outlined from Bricolage Grotesque at weight 800, so no font is needed.
- `make_launch.py`: regenerates everything above. `python design/launch/make_launch.py` (needs fonttools, brotli and Chrome).

## In Xcode

Copy both sets into the app's asset catalogue, then add to Info.plist:

```xml
<key>UILaunchScreen</key>
<dict>
  <key>UIColorName</key><string>LaunchBackground</string>
  <key>UIImageName</key><string>LaunchMark</string>
  <key>UIImageRespectsSafeAreaInsets</key><true/>
</dict>
```

The first SwiftUI frame should draw the same mark at the same size and position, so the hand-off to the intro animation doesn't jump.
