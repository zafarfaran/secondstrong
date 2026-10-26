import Foundation

public enum Habit: String, CaseIterable, Sendable, Identifiable {
    case protein, strength, movement, fibre, sleep

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .protein: "Protein"
        case .strength: "Strength"
        case .movement: "Move"
        case .fibre: "Fibre"
        case .sleep: "Sleep"
        }
    }
}

public struct TrainingSession: Equatable, Sendable {
    public let title: String
    public let minutes: Int
    public let detail: String

    public init(title: String, minutes: Int, detail: String) {
        self.title = title
        self.minutes = minutes
        self.detail = detail
    }
}

/// What the Today tab shows. Protein leads; calories are nil in calorie-free mode; nothing here is about weight (SS-0025).
public struct TodaySummary: Equatable, Sendable {
    public var name: String
    public var coach: Coach
    public var proteinGrams: Int
    public var proteinTarget: Int
    public var caloriesEaten: Int
    public var calorieTarget: Int?
    public var steps: Int
    public var stepTarget: Int
    public var done: Set<Habit>
    public var session: TrainingSession?
    /// Something she said she would try, which the coach may ask about once, kindly (SS-0026).
    public var openThread: String?

    public init(name: String, coach: Coach, proteinGrams: Int, proteinTarget: Int, caloriesEaten: Int, calorieTarget: Int?,
                steps: Int, stepTarget: Int, done: Set<Habit>, session: TrainingSession?, openThread: String? = nil) {
        self.name = name
        self.coach = coach
        self.proteinGrams = proteinGrams
        self.proteinTarget = proteinTarget
        self.caloriesEaten = caloriesEaten
        self.calorieTarget = calorieTarget
        self.steps = steps
        self.stepTarget = stepTarget
        self.done = done
        self.session = session
        self.openThread = openThread
    }

    public var proteinFraction: Double { Self.fraction(proteinGrams, proteinTarget) }
    public var stepsFraction: Double { Self.fraction(steps, stepTarget) }
    public var proteinToGo: Int { max(0, proteinTarget - proteinGrams) }
    public var habitsDone: Int { done.count }

    /// Nil when she runs on protein and habits alone (spec section 7).
    public var caloriesLeft: Int? { calorieTarget.map { max(0, $0 - caloriesEaten) } }

    public mutating func toggle(_ habit: Habit) {
        if done.contains(habit) { done.remove(habit) } else { done.insert(habit) }
    }

    private static func fraction(_ value: Int, _ target: Int) -> Double {
        target > 0 ? min(1, max(0, Double(value) / Double(target))) : 0
    }

    /// Made-up data for previews and tests only. No real health data anywhere (data handling).
    public static let sample = TodaySummary(
        name: "Anna", coach: .miso, proteinGrams: 62, proteinTarget: 85, caloriesEaten: 1090, calorieTarget: 1540, steps: 4820, stepTarget: 8000,
        done: [.movement, .sleep], session: TrainingSession(title: "Upper body", minutes: 20, detail: "Dumbbells at home"),
        openThread: "eggs at lunch")
}

public enum DayPart: Sendable {
    case morning, afternoon, evening, night

    public static func at(hour: Int) -> DayPart {
        switch hour {
        case 5..<12: .morning
        case 12..<17: .afternoon
        case 17..<22: .evening
        default: .night
        }
    }

    public var greeting: String {
        switch self {
        case .morning: "Good morning"
        case .afternoon: "Good afternoon"
        case .evening, .night: "Good evening"
        }
    }

    /// The warm morning scene by day, the dusk scene from late afternoon on.
    public var usesMorningScene: Bool { self == .morning || self == .afternoon }
}
