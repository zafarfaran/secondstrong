import Foundation

/// The plan shown at the end of onboarding.
public struct FirstWeekPlan: Equatable, Sendable {
    public static let sessionMinutes = 20

    // SS-0019: 1.2 g per kg, kept inside 60 to 140 and rounded to 5. Needs clinician sign-off.
    public static let gramsPerKilo = 1.2
    public static let proteinRange: ClosedRange<Double> = 60...140
    public static let defaultProteinGrams = 100

    public let proteinGrams: Int
    public let trainingDays: [Weekday]
    public let coachName: String
    public let intention: String?
    public let calorieFree: Bool
    public let hidesCalories: Bool
    /// Maintenance and target, only when a calorie target is possible and she chose to see calories.
    public let energy: EnergyPlan?
    public let showsGPNote: Bool
    public let trainingLine: String

    public init(_ answers: OnboardingAnswers) {
        proteinGrams = Self.protein(forWeightKg: answers.weightKg)
        trainingDays = answers.days
        coachName = answers.displayName
        calorieFree = answers.calorieFree
        hidesCalories = answers.calorieFree || answers.foodView == .habitsOnly
        energy = answers.showsCalories ? EnergyPlan(answers) : nil
        showsGPNote = answers.showsGPNote
        let words = answers.intention.trimmingCharacters(in: .whitespacesAndNewlines)
        intention = words.isEmpty || answers.calorieFree ? nil : words
        trainingLine = Self.summary(dayCount: answers.days.count) + (answers.equipment.map { " · " + $0.title.lowercased() } ?? "")
    }

    public static func protein(forWeightKg weight: Double?) -> Int {
        guard let weight else { return defaultProteinGrams }
        let grams = min(max(weight * gramsPerKilo, proteinRange.lowerBound), proteinRange.upperBound)
        return Int((grams / 5).rounded()) * 5
    }

    /// "3 × 20 minutes", or a prompt while no day is chosen.
    public static func summary(dayCount: Int) -> String {
        dayCount == 0 ? "tap the days that usually work" : "\(dayCount) × \(sessionMinutes) minutes"
    }

    public var coachNote: String {
        let first = trainingDays.first?.short ?? "Monday"
        return "\(first) first. Easy does it. — \(coachName)"
    }
}
