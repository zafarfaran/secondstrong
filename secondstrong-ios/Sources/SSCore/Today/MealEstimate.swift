import Foundation

/// What the coach reads from a photo of food: a name and rough numbers. Always an estimate, never exact (SS-0028).
public struct MealEstimate: Equatable, Sendable {
    public let name: String
    public let proteinGrams: Int
    public let calories: Int
    /// What was spotted on the plate, so she can take one off.
    public let items: [String]

    public init(name: String, proteinGrams: Int, calories: Int, items: [String] = []) {
        self.items = items
        self.name = name
        self.proteinGrams = proteinGrams
        self.calories = calories
    }

    /// "28g protein · about 410 kcal"; calories are left out in calorie-free mode (spec section 7).
    public func summary(showCalories: Bool) -> String {
        showCalories ? "\(proteinGrams)g protein · about \(calories) kcal" : "\(proteinGrams)g protein"
    }

    /// Made-up results standing in for the real vision model, which is not connected. Prototype only.
    public static let samples = [
        MealEstimate(name: "Eggs on toast with cottage cheese", proteinGrams: 28, calories: 410, items: ["Egg ×2", "Toast ×2", "Cottage cheese", "Greens"]),
        MealEstimate(name: "Chicken and quinoa bowl", proteinGrams: 34, calories: 520, items: ["Chicken", "Quinoa", "Greens"]),
        MealEstimate(name: "Greek yoghurt, berries and oats", proteinGrams: 22, calories: 330, items: ["Greek yoghurt", "Berries", "Oats"]),
    ]

    public static func prototype(_ index: Int) -> MealEstimate { samples[index % samples.count] }
}

extension TodaySummary {
    public mutating func log(_ meal: MealEstimate) {
        proteinGrams += meal.proteinGrams
        caloriesEaten += meal.calories
    }

    /// Hiding calories only hides them; the target comes back when she turns them on (it is recalculated elsewhere).
    public mutating func setShowsCalories(_ on: Bool, target: Int = 1540) {
        calorieTarget = on ? target : nil
    }
}

extension TodayLines {
    public static func mealReply(_ meal: MealEstimate, summary: TodaySummary) -> String {
        let after = summary.proteinGrams + meal.proteinGrams
        let gap = max(0, summary.proteinTarget - after)
        let tail = gap == 0 ? "That gets you to your protein today." : "That leaves \(gap)g to go."
        return "That looks like \(meal.name.lowercased()), about \(meal.proteinGrams)g of protein. \(tail)"
    }
}
