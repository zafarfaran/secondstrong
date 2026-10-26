import Foundation

/// What the member has chosen so far. Holds the selection rules so views stay thin.
public struct OnboardingAnswers: Equatable, Sendable {
    public static let maxGoals = 3
    public static let minDays = 2
    public static let maxDays = 4
    public static let maxNameLength = 14
    public static let maxIntentionLength = 140
    public static let adultAge = 18

    public private(set) var coach: Coach = .bramble
    public private(set) var stage: Stage?
    public private(set) var goals: [Goal] = []
    public private(set) var days: [Weekday] = []
    public private(set) var name: String = Coach.bramble.name
    public private(set) var consented = false
    public private(set) var intention = ""
    public private(set) var birthDate: BirthDate?
    public private(set) var safety: Set<SafetyFlag> = []
    public private(set) var heightCm: Double?
    public private(set) var weightKg: Double?
    public private(set) var bodySkipped = false
    public private(set) var experience: Experience?
    public private(set) var equipment: Equipment?
    public private(set) var activity: ActivityLevel?
    public private(set) var foodGoal: FoodGoal?
    public private(set) var weeklyKilos = FoodGoal.cut.defaultWeeklyKilos
    public private(set) var foodView = FoodView.calories
    private var nameEdited = false

    public init() {}

    /// The name falls back to the coach's own until the member types one.
    public mutating func select(coach: Coach) {
        self.coach = coach
        if !nameEdited { name = coach.name }
    }

    /// A field that hands back the text it was given, or a coach's own name, is not a typed name:
    /// the name keeps following the coach until the member really types one.
    public mutating func rename(_ newName: String) {
        let capped = String(newName.prefix(Self.maxNameLength))
        guard capped != name else { return }
        name = capped
        let typed = capped.trimmingCharacters(in: .whitespaces)
        nameEdited = !typed.isEmpty && !Coach.allCases.contains { $0.name == typed }
    }

    public var displayName: String {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? coach.name : trimmed
    }

    public mutating func select(stage: Stage) { self.stage = stage }

    /// Returns false when a third goal is refused, so the UI can shake.
    @discardableResult
    public mutating func toggle(goal: Goal) -> Bool {
        if let i = goals.firstIndex(of: goal) {
            goals.remove(at: i)
            return true
        }
        guard goals.count < Self.maxGoals else { return false }
        goals.append(goal)
        return true
    }

    /// Returns false when a fifth training day is refused.
    @discardableResult
    public mutating func toggle(day: Weekday) -> Bool {
        if let i = days.firstIndex(of: day) {
            days.remove(at: i)
            return true
        }
        guard days.count < Self.maxDays else { return false }
        days = (days + [day]).sorted()
        return true
    }

    // MARK: consent, birth year, safety

    public mutating func consent(_ agreed: Bool) { consented = agreed }

    public mutating func write(intention text: String) { intention = String(text.prefix(Self.maxIntentionLength)) }

    public mutating func select(birthDate date: BirthDate?) { birthDate = date }

    /// Self-declared. SS-0018 decides whether anything stronger is needed.
    public func isAdult(on today: BirthDate = .today()) -> Bool {
        guard let birthDate else { return false }
        return birthDate.age(on: today) >= Self.adultAge
    }

    public mutating func toggle(safety flag: SafetyFlag) {
        if safety.contains(flag) { safety.remove(flag); return }
        if flag.isExclusive { safety = [flag] } else { safety.subtract(SafetyFlag.allCases.filter(\.isExclusive)); safety.insert(flag) }
    }

    /// Eating-disorder history means calorie-free mode: no weights asked, nothing weight-like echoed back.
    public var calorieFree: Bool { safety.contains(.eatingHistory) }

    public var showsGPNote: Bool { safety.contains { $0.needsGPNote } }

    /// Pregnancy or breastfeeding, or a disordered-eating history, route out of body numbers.
    public var asksForBody: Bool { !calorieFree && !safety.contains(.pregnancy) }

    // MARK: body, training

    /// Returns false for numbers outside the typing-mistake ranges.
    @discardableResult
    public mutating func setBody(heightCm height: Double, weightKg weight: Double) -> Bool {
        guard BodyMeasures.isPlausible(heightCm: height, weightKg: weight) else { return false }
        heightCm = height
        weightKg = weight
        bodySkipped = false
        return true
    }

    /// Typed numbers that stop making sense take the stored ones with them.
    public mutating func clearBody() {
        heightCm = nil
        weightKg = nil
        bodySkipped = false
    }

    public mutating func skipBody() {
        heightCm = nil
        weightKg = nil
        bodySkipped = true
    }

    public mutating func select(experience: Experience) { self.experience = experience }

    public mutating func select(equipment: Equipment) { self.equipment = equipment }

    // MARK: food and energy (SS-0024)

    public mutating func select(activity level: ActivityLevel) { activity = level }

    /// A new goal starts at its own gentle pace.
    public mutating func select(foodGoal goal: FoodGoal) {
        foodGoal = goal
        weeklyKilos = goal.defaultWeeklyKilos
    }

    /// Snaps to 0.05 kg and stays inside the goal's cap, so no slider position can ask for more.
    public mutating func select(weeklyKilos kilos: Double) {
        guard let goal = foodGoal, goal != .hold else { return }
        let snapped = (kilos / FoodGoal.kiloStep).rounded() * FoodGoal.kiloStep
        weeklyKilos = min(max(snapped, FoodGoal.kiloStep), goal.maxWeeklyKilos)
    }

    public mutating func select(foodView view: FoodView) { foodView = view }

    /// A calorie target needs age, height and weight, and never for pregnancy, breastfeeding or an eating-disorder history.
    public var asksForEnergy: Bool {
        asksForBody && !bodySkipped && birthDate != nil && heightCm != nil && weightKg != nil
    }

    /// Calories are the default. She can turn them off on the goal screen (spec section 7: offered in onboarding).
    public var showsCalories: Bool { asksForEnergy && foodView == .calories }

    /// The food and activity screens are skipped when no calorie target is possible.
    public func isAsked(_ step: OnboardingStep) -> Bool {
        switch step {
        case .activity, .goal: asksForEnergy
        default: true
        }
    }

    public func canContinue(from step: OnboardingStep, today: BirthDate = .today()) -> Bool {
        switch step {
        case .welcome, .coach, .building, .plan, .paywall, .invite: true
        case .consent: consented
        case .stage: stage != nil
        case .goals: !goals.isEmpty
        case .birth: isAdult(on: today)
        case .safety: !safety.isEmpty
        case .body: !asksForBody || bodySkipped || weightKg != nil
        case .training: experience != nil && equipment != nil
        case .activity: activity != nil
        case .goal: foodGoal != nil || foodView == .habitsOnly
        case .days: days.count >= Self.minDays
        }
    }
}
