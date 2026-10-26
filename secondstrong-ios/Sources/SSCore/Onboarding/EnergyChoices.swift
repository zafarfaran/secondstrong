import Foundation

/// Everyday movement, not counting training. The factors are drafts that need a nutrition adviser's sign-off (SS-0024).
public enum ActivityLevel: String, CaseIterable, Sendable, Identifiable {
    case sit, some, most, hard

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .sit: "Mostly sitting"
        case .some: "On my feet a bit"
        case .most: "On my feet a lot"
        case .hard: "Very physical"
        }
    }

    public var example: String {
        switch self {
        case .sit: "Desk, driving"
        case .some: "Housework, short walks"
        case .most: "Teaching, nursing, retail"
        case .hard: "Lifting, carrying, all day"
        }
    }

    public var factor: Double {
        switch self {
        case .sit: 1.2
        case .some: 1.3
        case .most: 1.4
        case .hard: 1.5
        }
    }
}

public enum FoodGoal: String, CaseIterable, Sendable, Identifiable {
    case cut, hold, gain

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .cut: "Lose fat gently"
        case .hold: "Maintain"
        case .gain: "Build muscle"
        }
    }

    public var detail: String {
        switch self {
        case .cut: "Eat a little less, keep your muscle."
        case .hold: "Stay put, get stronger."
        case .gain: "Eat a little more, and lift."
        }
    }

    /// The slider's ceiling, in kilos a week. Slow on purpose; SS-0024 drafts for clinical review.
    public var maxWeeklyKilos: Double {
        switch self {
        case .cut: 0.4
        case .gain: 0.2
        case .hold: 0
        }
    }

    public var defaultWeeklyKilos: Double {
        switch self {
        case .cut: 0.25
        case .gain: 0.1
        case .hold: 0
        }
    }

    public static let kiloStep = 0.05
}

/// Calories shown (the default), or protein and habits only. Offered on the goal screen (spec section 7).
public enum FoodView: String, CaseIterable, Sendable, Identifiable {
    case calories, habitsOnly

    public var id: String { rawValue }
}
