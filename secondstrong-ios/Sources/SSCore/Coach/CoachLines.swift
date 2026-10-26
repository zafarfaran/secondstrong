import Foundation

/// What the coach says as the person moves through onboarding: a few words, one or two lines a screen, written in the margin.
/// Voice: UK English, no exclamation marks, no "just", "journey" or "reset".
// SS-0023: draft facts. The spec wants clinician sign-off on menopause content before launch.
public enum CoachLines {
    /// The lines for a screen, with the coach's name filled in. Empty where the coach says nothing.
    public static func lines(for step: OnboardingStep, coachName: String) -> [String] {
        let raw: [String]
        switch step {
        case .stage: raw = ["I'm {name}. I'll be here all the way.", "Strong bones start with lifting."]
        case .goals: raw = ["Pick what matters most.", "Nothing here is a test."]
        case .birth: raw = ["Age helps set your plan.", "We need more protein as we age."]
        case .safety: raw = ["Thank you. This keeps things safe.", "Rather not say? That's fine."]
        case .body: raw = ["Only used for your plan.", "Skip it if you like."]
        case .training: raw = ["Everyone starts somewhere.", "Two or three a week is plenty."]
        case .activity: raw = ["Be honest. It sets your numbers.", "Training counts separately."]
        case .days: raw = ["Pick days that feel doable.", "Muscles grow while you rest."]
        case .plan: raw = ["Spread protein through the day.", "Week one is gentle."]
        default:
            raw = []
        }
        return raw.map { $0.replacingOccurrences(of: "{name}", with: coachName) }
    }

    /// How long a line stays up: long enough to read, a little longer for longer lines.
    public static func seconds(for line: String) -> Double { 5 + Double(line.count) * 0.06 }
}
