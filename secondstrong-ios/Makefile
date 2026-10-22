.PHONY: gen build test check preview

# Regenerate the Xcode project from project.yml (the .xcodeproj is not committed).
gen:
	xcodegen generate

# Compile the app for the simulator. No signing or runtime needed.
build: gen
	xcodebuild -project SecondStrong.xcodeproj -scheme SecondStrong \
		-destination 'generic/platform=iOS Simulator' \
		CODE_SIGNING_ALLOWED=NO -quiet build

# Unit tests for the Swift package modules.
test:
	swift test

# Repo harness checks: file sizes, layer imports, doc links and index.
check:
	../scripts/check-harness.sh

# Phone-sized macOS window running the onboarding. No iOS platform needed.
preview:
	swift run OnboardingPreview
