import Foundation

/// Maintenance and a daily calorie target worked out from her own answers. An estimate with a range, never a promise.
// SS-0024: Mifflin-St Jeor for a woman plus an activity factor and 0.03 per strength session; draft for clinical review.
public struct EnergyPlan: Equatable, Sendable {
    /// Hard floor: no target below this, whatever the pace (spec section 7). The real figure is a clinician's to set.
    public static let floorKcal = 1_400
    public static let kcalPerKilo = 7_700.0
    public static let rangeKcal = 120
    public static let sessionAllowance = 0.03

    public let maintenance: Int
    public let target: Int
    public let goal: FoodGoal
    public let weeklyKilos: Double
    public let clampedByFloor: Bool

    public var range: ClosedRange<Int> { (maintenance - Self.rangeKcal)...(maintenance + Self.rangeKcal) }

    /// Maintenance alone, known as soon as activity is chosen, so the goal screen can chart against it.
    public static func maintenance(for answers: OnboardingAnswers, today: BirthDate = .today()) -> Int? {
        guard answers.asksForEnergy, let birth = answers.birthDate, let height = answers.heightCm, let weight = answers.weightKg,
              let activity = answers.activity else { return nil }
        let basal = 10 * weight + 6.25 * height - 5 * Double(birth.age(on: today)) - 161
        return rounded(basal * (activity.factor + sessionAllowance * Double(answers.days.count)))
    }

    /// The daily target for a goal and pace, never below the floor. `clamped` says the floor stopped it.
    public static func target(maintenance: Int, goal: FoodGoal, weeklyKilos: Double) -> (kcal: Int, clamped: Bool) {
        let daily = weeklyKilos * kcalPerKilo / 7
        let raw = goal == .cut ? Double(maintenance) - daily : goal == .gain ? Double(maintenance) + daily : Double(maintenance)
        let kcal = rounded(raw)
        return (max(floorKcal, kcal), goal == .cut && kcal < floorKcal)
    }

    /// Nil unless the answers allow a calorie target at all.
    public init?(_ answers: OnboardingAnswers, today: BirthDate = .today()) {
        guard let maintenance = Self.maintenance(for: answers, today: today), let goal = answers.foodGoal else { return nil }
        let weekly = goal == .hold ? 0 : answers.weeklyKilos
        let result = Self.target(maintenance: maintenance, goal: goal, weeklyKilos: weekly)
        self.maintenance = maintenance
        self.goal = goal
        weeklyKilos = weekly
        target = result.kcal
        clampedByFloor = result.clamped
    }

    private static func rounded(_ kcal: Double) -> Int { Int((kcal / 10).rounded()) * 10 }
}
