# Graph Report - secondstrong  (2026-10-21)

## Corpus Check
- 166 files · ~57,044 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 12 file(s) not represented in the graph (top: (none) 7, .css 3, .woff2 2)

## Summary
- 1320 nodes · 2941 edges · 61 communities (51 shown, 10 thin omitted)
- Extraction: 87% EXTRACTED · 13% INFERRED · 0% AMBIGUOUS · INFERRED: 380 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Web Layout & Root
- Birth Date & Coach Model
- SVG Path Geometry
- Clip Sequencer
- Repo Rules & Policy Docs
- Onboarding Screen Buckets
- Button Styles & Fonts
- Pen Line Drawing
- Bundled Images & Auth Art
- Pill Button & Meta Label
- Auth Screens & Glyphs
- Pen Anchors & Preferences
- Web Header & Pricing
- Web Dependencies
- Web Home Page
- Auth Frame & Scene Art
- Onboarding Document & Tiles
- Mascot Gallery & Palette
- Platform Views (macOS/iOS)
- Next Config & Legal Pages
- Choices & Goals
- Waitlist & Turnstile
- Coach Tickets & Family Circle
- TypeScript Config
- Preview App & Tests
- Coach Characters
- App Entry & Previews
- Coach Moods
- Auth Flow & Providers
- Onboarding Run & Top Bar
- Body Measurements
- Equipment Choices
- Coach Clip Player
- Wheel Picker
- Safety Flags
- Web Resize Test Scripts
- Onboarding Steps
- Weekdays
- Flow Layout
- Waitlist Backend
- Coach Clip Assets & Tests
- iOS Layers & Early Tickets
- Pricing Spec & Billing
- Count-Up & Hit Counter
- Safety Requirements & Coach
- iOS Build & Modules
- Menopause Stage
- Email Address Validation
- Auth Screens Enum
- Coach View
- Web README Concepts
- Birth Section
- Sign-In Previews
- AVFoundation Clip Files
- Quiz Funnel Structure
- Package Manifest
- Coach Clip Build Script
- Web Agent Rules
- Two Typefaces Rule
- Five-Tab Navigation

## God Nodes (most connected - your core abstractions)
1. `OnboardingFlow` - 110 edges
2. `OnboardingAnswers` - 51 edges
3. `SSCore` - 42 edges
4. `CoachMood` - 38 edges
5. `PenAnchor` - 37 edges
6. `Coach` - 36 edges
7. `SSDesign` - 28 edges
8. `Point` - 28 edges
9. `HomePage()` - 27 edges
10. `Goal` - 25 edges

## Surprising Connections (you probably didn't know these)
- `Non-negotiables (safety screening, conservative projections, no fabrication)` --semantically_similar_to--> `Hard rules (safety, PII, no fabrication, trademark)`  [INFERRED] [semantically similar]
  docs/business/overview.md → AGENTS.md
- `Waiting list (pre-launch) and NEXT_PUBLIC_WAITLIST_ENDPOINT` --conceptually_related_to--> `Pricing plans (Free, Weekly, Monthly, Annual, Lifetime)`  [INFERRED]
  secondstrong-web/README.md → keel-health-pricing-and-features-spec.md
- `SS-0002 Onboarding v1` --conceptually_related_to--> `In-app onboarding (organic downloads)`  [INFERRED]
  tickets/SS-0002-onboarding-v1.md → keel-health-pricing-and-features-spec.md
- `secondstrong-ios AGENTS.md` --conceptually_related_to--> `Safety requirements (section 7, non-negotiable)`  [AMBIGUOUS]
  secondstrong-ios/AGENTS.md → keel-health-pricing-and-features-spec.md
- `SS-0007 Six onboarding screens and flow controller` --implements--> `SSOnboarding module`  [INFERRED]
  tickets/SS-0007-six-onboarding-screens-and-flow-controll.md → secondstrong-ios/AGENTS.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **iOS module layer stack** — docs_architecture_ios_sscore, docs_architecture_ios_ssdesign, docs_architecture_ios_ssonboarding, docs_architecture_ios_app_root [EXTRACTED 1.00]
- **Repo harness (map, docs, check script, tickets)** — agents, docs_index, scripts_check_harness, docs_tickets, docs_harness, docs_golden_principles [INFERRED 0.85]
- **Health data PII handling policy** — agents_hard_rules, docs_business_data_handling, agents_realitymine_ai_policy, docs_golden_principles_fake_data_only [INFERRED 0.85]
- **iOS layered module stack** — secondstrong_ios_agents_sscore, secondstrong_ios_agents_ssdesign, secondstrong_ios_agents_ssonboarding, secondstrong_ios_project_yml_secondstrong_target [EXTRACTED 0.95]
- **Onboarding v1 work breakdown (SS-0002 children)** — tickets_ss_0002_onboarding_v1, tickets_ss_0003_svg_path_parser_and_path_length_sscore, tickets_ss_0004_onboarding_model_and_plan_logic_sscore, tickets_ss_0005_design_tokens_fonts_and_art_assets, tickets_ss_0006_pen_line_engine, tickets_ss_0007_six_onboarding_screens_and_flow_controll, tickets_ss_0008_macos_preview_runner_for_onboarding [EXTRACTED 1.00]
- **Safety envelope for weight and calorie targets** — keel_health_pricing_and_features_spec_safety_screening, keel_health_pricing_and_features_spec_goal_weight_floor, keel_health_pricing_and_features_spec_calorie_free_mode, keel_health_pricing_and_features_spec_safety_requirements, keel_health_pricing_and_features_spec_ai_coach [EXTRACTED 0.95]
- **Family circle feature tickets** — tickets_ss_0013_family_circle_circle_consent_family_plan, tickets_ss_0014_family_circle_guides_to_understand_her, tickets_ss_0015_family_circle_do_small_things_for_her, tickets_ss_0016_family_circle_train_alongside_her, tickets_ss_0017_family_circle_practical_help_shopping_li, tickets_ss_0018_family_circle_legal_and_data_protection [EXTRACTED 1.00]

## Communities (61 total, 10 thin omitted)

### Community 0 - "Web Layout & Root"
Cohesion: 0.05
Nodes (80): react, bricolage, metadata, plex, RootLayout(), viewport, Built, PageLine() (+72 more)

### Community 1 - "Birth Date & Coach Model"
Cohesion: 0.05
Nodes (13): Foundation, BirthDate, BodyMeasures, FirstWeekPlan, .coachNote, OnboardingAnswers, .asksForBody, .calorieFree (+5 more)

### Community 2 - "SVG Path Geometry"
Cohesion: 0.05
Nodes (28): EllipticalArc, Array, .length, PathSegment, close, cubic, line, move (+20 more)

### Community 3 - "Clip Sequencer"
Cohesion: 0.06
Nodes (18): Action, none, play, seek, ClipManifest, ClipSegments, ClipSequencer, Phase (+10 more)

### Community 4 - "Repo Rules & Policy Docs"
Cohesion: 0.06
Nodes (51): AGENTS.md (repo map), How to work here workflow, RealityMine AI Policy, Second Strong product, CLAUDE.md (imports AGENTS.md), iOS architecture, App composition root, ClipSequencer (+43 more)

### Community 5 - "Onboarding Screen Buckets"
Cohesion: 0.08
Nodes (9): .body, Bucket, arrive, commit, none, OnboardingFlow, .plan, .stepValue (+1 more)

### Community 6 - "Button Styles & Fonts"
Cohesion: 0.08
Nodes (20): .body, PressScaleStyle, GoogleMark, SSFont, AuthDoor, .body, .card, .mark (+12 more)

### Community 7 - "Pen Line Drawing"
Cohesion: 0.11
Nodes (9): Path, InkLayer, .body, InkStroke, StrokeView, .body, BuildingSection, .body (+1 more)

### Community 8 - "Bundled Images & Auth Art"
Cohesion: 0.07
Nodes (15): ImageIO, BundledImage, AuthArt, .image, .body, Scene, expired, hero (+7 more)

### Community 9 - "Pill Button & Meta Label"
Cohesion: 0.11
Nodes (18): MetaLabel, .body, PillButton, ConsentSection, .body, DaysSection, .body, GoalsSection (+10 more)

### Community 10 - "Auth Screens & Glyphs"
Cohesion: 0.15
Nodes (5): CoreText, PenSpace, SSCore, SSDesign, SwiftUI

### Community 11 - "Pen Anchors & Preferences"
Cohesion: 0.07
Nodes (25): PenAnchor, agree, bar, birth, body, coachShow, day, dot (+17 more)

### Community 12 - "Web Header & Pricing"
Cohesion: 0.11
Nodes (23): Header(), DrawProps, Wordmark(), CTA_HREF, CTA_LABEL, CTA_SHORT, DayStep, daySteps (+15 more)

### Community 13 - "Web Dependencies"
Cohesion: 0.07
Nodes (27): eslint, eslint-config-next, react-dom, @types/node, @types/react, @types/react-dom, typescript, eslintConfig (+19 more)

### Community 14 - "Web Home Page"
Cohesion: 0.23
Nodes (21): Page(), HomePage(), End(), Faq(), Coach(), Fridge(), Gap(), Lift() (+13 more)

### Community 15 - "Auth Frame & Scene Art"
Cohesion: 0.12
Nodes (8): .body, AuthFrame, .body, SceneArt, AuthInboxScreen, .body, .codeCard, AuthFlowTests

### Community 16 - "Onboarding Document & Tiles"
Cohesion: 0.19
Nodes (12): OnboardingDocument, .body, View, ChoiceRow, SketchTile, .body, TileLabel, .body (+4 more)

### Community 17 - "Mascot Gallery & Palette"
Cohesion: 0.10
Nodes (17): MascotGallery, .body, PaperBackground, .body, Palette, AuthEmailScreen, .field, AuthExpiredScreen (+9 more)

### Community 18 - "Platform Views (macOS/iOS)"
Cohesion: 0.14
Nodes (3): ClipHost, ClipSurface, UIKit

### Community 19 - "Next Config & Legal Pages"
Cohesion: 0.18
Nodes (14): next, nextConfig, metadata, Page(), metadata, Page(), LegalPage(), linked() (+6 more)

### Community 20 - "Choices & Goals"
Cohesion: 0.11
Nodes (19): Goal, aches, carry, comfortable, energy, family, habits, .id (+11 more)

### Community 21 - "Waitlist & Turnstile"
Cohesion: 0.18
Nodes (14): Phase, STAGES, Waitlist(), load(), mountTurnstile(), Turnstile, turnstileEnabled, turnstileToken() (+6 more)

### Community 22 - "Coach Tickets & Family Circle"
Cohesion: 0.11
Nodes (20): Layered mascot rig, SS-0009 Native mascot rig with nine expressions, SS-0010 Swipeable coach carousel, Coach clips (HEVC alpha, AVPlayerLayer, ClipSequencer), SS-0012 Play new coach clips, add Miso, Family circle, SS-0013 Family circle foundation, SS-0014 Family circle guides (+12 more)

### Community 23 - "TypeScript Config"
Cohesion: 0.11
Nodes (18): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+10 more)

### Community 24 - "Preview App & Tests"
Cohesion: 0.14
Nodes (6): AppKit, StageAcknowledgementTests, PlaythroughSnapshotTests, SignInScreensSnapshotTests, SSOnboarding, Testing

### Community 25 - "Coach Characters"
Cohesion: 0.12
Nodes (15): Coach, bramble, fern, .id, luna, miso, .name, otto (+7 more)

### Community 26 - "App Entry & Previews"
Cohesion: 0.13
Nodes (9): SecondStrongApp, .body, PreviewApp, .body, LoadingScreenPreview, .body, PreviewRun, OnboardingView (+1 more)

### Community 27 - "Coach Moods"
Cohesion: 0.12
Nodes (17): CoachMood, breathe, cheer, comfort, encourage, gotit, hello, idle (+9 more)

### Community 28 - "Auth Flow & Providers"
Cohesion: 0.14
Nodes (14): AuthProvider, apple, google, AuthStage, choose, email, expired, returning (+6 more)

### Community 29 - "Onboarding Run & Top Bar"
Cohesion: 0.15
Nodes (7): OnboardingRun, .body, .companion, CoachSection, .body, .carousel, .nameField

### Community 30 - "Body Measurements"
Cohesion: 0.23
Nodes (5): BodySection, .body, .heightSpec, .units, .weightSpec

### Community 31 - "Equipment Choices"
Cohesion: 0.14
Nodes (13): Equipment, bands, dumbbells, gym, .id, .title, Experience, .id (+5 more)

### Community 32 - "Coach Clip Player"
Cohesion: 0.23
Nodes (3): CoachClipPlayer, .currentMood, Slot

### Community 33 - "Wheel Picker"
Cohesion: 0.24
Nodes (5): Item, WheelColumn, .body, WheelRow, .body

### Community 34 - "Safety Flags"
Cohesion: 0.14
Nodes (13): SafetyFlag, diabetes, eatingHistory, heart, .id, .isExclusive, kidney, .needsGPNote (+5 more)

### Community 35 - "Web Resize Test Scripts"
Cohesion: 0.19
Nodes (8): chrome, evaluate(), out, pending, results, send(), shot(), size()

### Community 37 - "Onboarding Steps"
Cohesion: 0.15
Nodes (13): OnboardingStep, birth, body, building, coach, consent, days, goals (+5 more)

### Community 38 - "Weekdays"
Cohesion: 0.17
Nodes (11): Weekday, fri, .id, .initial, mon, sat, .short, sun (+3 more)

### Community 40 - "Waitlist Backend"
Cohesion: 0.30
Nodes (10): ALLOWED, cors(), fetch(), hits, HOSTS, humanVerified(), json(), limited() (+2 more)

### Community 42 - "iOS Layers & Early Tickets"
Cohesion: 0.27
Nodes (11): iOS layer order (SSCore, SSDesign, features, App), Palette (colour tokens), SSCore module, SSDesign module, SS-0002 Onboarding v1, SS-0003 SVG path parser and path length, SS-0004 Onboarding model and plan logic, SS-0005 Design tokens, fonts and art assets (+3 more)

### Community 43 - "Pricing Spec & Billing"
Cohesion: 0.20
Nodes (7): Keel Health Pricing & Feature Specification, Feature matrix Free vs Pro, Keel brand and positioning (predates Second Strong), Open items (trademark, GDPR, recipes, legal), Reserved premium tier (Keel+), Pricing plans (Free, Weekly, Monthly, Annual, Lifetime), Retention offers and win-back

### Community 44 - "Count-Up & Hit Counter"
Cohesion: 0.31
Nodes (7): CountUp(), CountUpProps, expoOut(), hits, listeners, subscribe(), useHit()

### Community 45 - "Safety Requirements & Coach"
Cohesion: 0.25
Nodes (6): AI Coach with guardrails, AI inference cost control, Analysis moment (building your plan), Paywall placement and Apple compliance, Calorie-free mode, Plan reveal screen

### Community 46 - "iOS Build & Modules"
Cohesion: 0.22
Nodes (9): secondstrong-ios AGENTS.md, Makefile commands (test, gen, build, preview, check), SSOnboarding module, secondstrong-ios CLAUDE.md, project.yml (XcodeGen spec), SecondStrong app target, SecondStrongKit package dependency, SS-0001 Scaffold iOS project and repo harness (+1 more)

### Community 47 - "Menopause Stage"
Cohesion: 0.22
Nodes (9): Stage, .acknowledgement, .id, meno, peri, post, surg, .title (+1 more)

### Community 48 - "Email Address Validation"
Cohesion: 0.25
Nodes (3): EmailAddress, .canSendLink, EmailAddressTests

### Community 49 - "Auth Screens Enum"
Cohesion: 0.22
Nodes (8): Screen, door, email, expired, .id, inbox, returning, .stage

### Community 51 - "Web README Concepts"
Cohesion: 0.25
Nodes (8): secondstrong-web README, Boot script (lib/motion/boot.ts), Line measurement lookup table (measure.ts), Page line (PageLine, route.ts), Pinned scroll sections (Hero, Facts, Day), Scroll films (HyperFrames videos), content/site.ts (all copy), Waiting list (pre-launch) and NEXT_PUBLIC_WAITLIST_ENDPOINT

### Community 52 - "Birth Section"
Cohesion: 0.38
Nodes (5): BirthSection, .body, .date, .message, .readout

### Community 53 - "Sign-In Previews"
Cohesion: 0.40
Nodes (4): PreviewScreen, .body, SignInScreensPreview, .body

### Community 55 - "Quiz Funnel Structure"
Cohesion: 0.40
Nodes (5): Build sequencing (V1 MVP), Seven funnel entry points, In-app onboarding (organic downloads), Web-to-app onboarding quiz funnel, Quiz structure (6 blocks)

## Ambiguous Edges - Review These
- `Safety requirements (section 7, non-negotiable)` → `secondstrong-ios AGENTS.md`  [AMBIGUOUS]
  secondstrong-ios/AGENTS.md · relation: conceptually_related_to

## Knowledge Gaps
- **223 isolated node(s):** `PackageDescription`, `enter`, `loop`, `leave`, `none` (+218 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 407 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **10 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OnboardingFlow` connect `Onboarding Screen Buckets` to `Birth Date & Coach Model`, `SVG Path Geometry`, `Button Styles & Fonts`, `Pen Line Drawing`, `Pill Button & Meta Label`, `Auth Screens & Glyphs`, `Pen Anchors & Preferences`, `Auth Frame & Scene Art`, `Onboarding Document & Tiles`, `Mascot Gallery & Palette`, `Choices & Goals`, `App Entry & Previews`, `Auth Flow & Providers`, `Onboarding Run & Top Bar`, `Body Measurements`, `Onboarding Steps`, `Weekdays`, `Email Address Validation`, `Birth Section`, `Sign-In Previews`?**
  _High betweenness centrality (0.176) - this node is a cross-community bridge._
- **Are the 17 inferred relationships involving `OnboardingFlow` (e.g. with `PreviewRun` and `OnboardingAnswers`) actually correct?**
  _`OnboardingFlow` has 17 INFERRED edges - model-reasoned connections that need verification._
- **What connects `PackageDescription`, `enter`, `loop` to the rest of the system?**
  _223 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Web Layout & Root` be split into smaller, more focused modules?**
  _Cohesion score 0.05431140892258861 - nodes in this community are weakly interconnected._
- **Why does `View` connect `Onboarding Document & Tiles` to `Wheel Picker`, `Clip Sequencer`, `Button Styles & Fonts`, `Pen Line Drawing`, `Bundled Images & Auth Art`, `Pill Button & Meta Label`, `Auth Screens & Glyphs`, `Pen Anchors & Preferences`, `Auth Frame & Scene Art`, `Mascot Gallery & Palette`, `Coach View`, `Birth Section`, `Sign-In Previews`, `App Entry & Previews`, `Onboarding Run & Top Bar`, `Body Measurements`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **Are the 20 inferred relationships involving `OnboardingAnswers` (e.g. with `OnboardingFlow` and `.toggle()`) actually correct?**
  _`OnboardingAnswers` has 20 INFERRED edges - model-reasoned connections that need verification._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Safety requirements (section 7, non-negotiable)` and `secondstrong-ios AGENTS.md`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._