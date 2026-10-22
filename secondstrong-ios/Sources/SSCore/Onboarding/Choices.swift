import Foundation

public enum Stage: String, CaseIterable, Sendable, Identifiable {
    case peri, meno, post, surg, unsure

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .peri: "Perimenopause"
        case .meno: "Menopause"
        case .post: "After menopause"
        case .surg: "Surgical"
        case .unsure: "Not sure"
        }
    }
}

extension Stage {
    /// What the coach says back once a stage is chosen. Source: the prototype's ACK.
    public var acknowledgement: String {
        switch self {
        case .peri: "Perimenopause. I'll plan around the harder days."
        case .meno: "Menopause. Noted."
        case .post: "After menopause. Strength matters even more now."
        case .surg: "Thank you for telling me. We'll go gently."
        case .unsure: "That's fine. We'll work it out together."
        }
    }
}

/// What the coach acts out when a goal is chosen.
public enum GoalTheme: Sendable { case strength, energy, sleep, habits }

/// Outcomes she can tap on the goals screen. Plain words about her life, none about weight.
public enum Goal: String, CaseIterable, Sendable, Identifiable {
    case stronger, carry, family, energy, sleep, aches, independent, restart, habits, comfortable

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .stronger: "Feel stronger"
        case .carry: "Carry things without struggling"
        case .family: "Keep up with my family"
        case .energy: "Have more energy"
        case .sleep: "Sleep better"
        case .aches: "Move without aches"
        case .independent: "Stay independent as I age"
        case .restart: "Get back into exercise"
        case .habits: "Build healthy habits"
        case .comfortable: "Feel comfortable in my body"
        }
    }

    public var theme: GoalTheme {
        switch self {
        case .stronger, .carry, .aches, .independent, .restart: .strength
        case .family, .energy: .energy
        case .sleep: .sleep
        case .habits, .comfortable: .habits
        }
    }
}

public enum Weekday: Int, CaseIterable, Sendable, Identifiable, Comparable {
    case mon, tue, wed, thu, fri, sat, sun

    public var id: Int { rawValue }

    public var short: String {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][rawValue]
    }

    public var initial: String { String(short.prefix(1)) }

    public static func < (a: Weekday, b: Weekday) -> Bool { a.rawValue < b.rawValue }
}

public enum OnboardingStep: Int, CaseIterable, Sendable {
    case welcome, consent, coach, stage, goals, birth, safety, body, training, days, building, plan
}
