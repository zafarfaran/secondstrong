import Foundation

/// One thing she ate, as the Food tab lists it. `plate` picks the little picture until a real photo is kept (SS-0032).
public struct FoodEntry: Equatable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var minute: Int
    public var proteinGrams: Int
    public var calories: Int
    public var plate: PlateKind

    public init(id: UUID = UUID(), name: String, minute: Int, proteinGrams: Int, calories: Int, plate: PlateKind) {
        self.id = id
        self.name = name
        self.minute = minute
        self.proteinGrams = proteinGrams
        self.calories = calories
        self.plate = plate
    }
}

public enum PlateKind: String, CaseIterable, Sendable { case berry, cup, egg, nuts, bowl }

public struct NextMeal: Equatable, Sendable {
    public let title: String
    public let around: String
}

/// The day's food log: what the Food tab shows. Fake data only; nothing is stored (SS-0032).
public struct FoodDiary: Equatable, Sendable {
    public private(set) var entries: [FoodEntry]

    public init(entries: [FoodEntry]) { self.entries = entries.sorted { $0.minute < $1.minute } }

    public var protein: Int { entries.reduce(0) { $0 + $1.proteinGrams } }
    public var calories: Int { entries.reduce(0) { $0 + $1.calories } }
    public var lastMinute: Int { entries.last?.minute ?? 0 }

    public mutating func add(_ meal: MealEstimate, minute: Int) {
        let kinds = PlateKind.allCases
        let entry = FoodEntry(name: meal.name, minute: minute, proteinGrams: meal.proteinGrams, calories: meal.calories,
                              plate: kinds[abs(meal.name.hashValue) % kinds.count])
        entries = (entries + [entry]).sorted { $0.minute < $1.minute }
    }

    /// The same four meals as `TodaySummary.sample`, so the two tabs agree.
    public static let sample = FoodDiary(entries: [
        FoodEntry(name: "Greek yoghurt, berries", minute: 8 * 60 + 5, proteinGrams: 24, calories: 310, plate: .berry),
        FoodEntry(name: "Coffee, oat milk", minute: 8 * 60 + 40, proteinGrams: 2, calories: 60, plate: .cup),
        FoodEntry(name: "Eggs on toast, cottage cheese", minute: 12 * 60 + 40, proteinGrams: 28, calories: 480, plate: .egg),
        FoodEntry(name: "Almonds, handful", minute: 15 * 60 + 30, proteinGrams: 8, calories: 240, plate: .nuts),
    ])

    /// What comes after the last meal, shown as a dashed card. Nothing after the evening.
    public static func next(afterMinute minute: Int) -> NextMeal? {
        switch minute {
        case ..<720: NextMeal(title: "Lunch", around: "1 pm")
        case ..<900: NextMeal(title: "Snack", around: "3 pm")
        case ..<1080: NextMeal(title: "Dinner", around: "6:30 pm")
        default: nil
        }
    }

    /// Which meal a time belongs to, for the camera's "Add to Lunch".
    public static func slotName(minute: Int) -> String {
        switch minute {
        case ..<630: "Breakfast"
        case ..<900: "Lunch"
        case ..<1020: "Snack"
        default: "Dinner"
        }
    }

    public static func clock(minute: Int) -> String {
        let hour = (minute / 60 + 11) % 12 + 1
        return "\(hour):" + String(format: "%02d", minute % 60)
    }

    /// Miso's one line, about the meal just logged. Protein only: never calories, never a verdict on the food.
    public static func note(protein: Int, target: Int, afterMinute minute: Int) -> String {
        let gap = target - protein
        if gap <= 0 { return "You made it. Protein done for today." }
        if protein * 100 >= target * 70 { return minute < 1080 ? "\(gap)g to go. Dinner will do it." : "\(gap)g to go." }
        if protein * 100 >= target * 45 { return "Halfway there. Lunch carried you." }
        return "Good start. Add protein at lunch."
    }
}

/// One day on the week strip: a ring showing how close she got to her protein.
public struct WeekDay: Equatable, Sendable {
    public let initial: String
    public let dayOfMonth: Int
    public let fraction: Double
    public let isToday: Bool
}

public enum WeekStrip {
    /// Past days are made up in the prototype; future days are empty and today follows the live protein.
    static let pastSample = [0.94, 1, 0.82, 0.9, 0.7, 0.85, 1]

    public static func days(today: Date, todayFraction: Double, calendar: Calendar = .current) -> [WeekDay] {
        let weekday = (calendar.component(.weekday, from: today) - calendar.firstWeekday + 7) % 7
        let start = calendar.date(byAdding: .day, value: -weekday, to: today) ?? today
        let initials = ["M", "T", "W", "T", "F", "S", "S"]
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: i, to: start) ?? start
            let fraction = i < weekday ? pastSample[i] : i == weekday ? todayFraction : 0
            return WeekDay(initial: initials[i], dayOfMonth: calendar.component(.day, from: date), fraction: fraction, isToday: i == weekday)
        }
    }
}

public enum Portion: String, CaseIterable, Sendable {
    case small, medium, large

    public var factor: Double {
        switch self {
        case .small: 0.75
        case .medium: 1
        case .large: 1.3
        }
    }

    public var title: String { rawValue.capitalized }
}

extension MealEstimate {
    public func scaled(by portion: Portion) -> MealEstimate {
        MealEstimate(name: name, proteinGrams: Int((Double(proteinGrams) * portion.factor).rounded()),
                     calories: Int((Double(calories) * portion.factor).rounded()), items: items)
    }
}

extension MealEstimate {
    /// Taking an item off the plate lowers the numbers in proportion; a crude guess she can correct (SS-0032).
    public func adjusted(portion: Portion, removing removed: Set<String>, named newName: String? = nil) -> MealEstimate {
        let kept = items.filter { !removed.contains($0) }
        let share = items.isEmpty ? 1 : Double(kept.count) / Double(items.count)
        let scale = portion.factor * share
        return MealEstimate(name: newName ?? name, proteinGrams: Int((Double(proteinGrams) * scale).rounded()),
                            calories: Int((Double(calories) * scale).rounded()), items: kept)
    }
}
