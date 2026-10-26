import Foundation

/// What a coach is doing. One case per clip state in design/coach-clips/manifest.json.
public enum CoachMood: String, CaseIterable, Sendable {
    case idle, hello, listening, thinking, proud, lifting, stretching, comfort, resting
    case suggest, cheer, wow, encourage, oops, gotit, breathe, fall
    case idleLook, idleYawn, idleBounce
}

extension CoachMood {
    /// Small moves played when nobody is doing anything. Each plays once and returns to idle by itself.
    public static let idleVariants: [CoachMood] = [.idleLook, .idleYawn, .idleBounce]

    public var isIdleVariant: Bool { Self.idleVariants.contains(self) }

    /// Idle and its variants start and end on the neutral pose, so anything can interrupt them at once.
    public var isRestful: Bool { self == .idle || isIdleVariant }

    /// How long the variant plays, in seconds.
    public var idleVariantSeconds: Double {
        switch self {
        case .idleLook: 3.2
        case .idleYawn: 3.0
        case .idleBounce: 2.0
        default: 0
        }
    }
}
