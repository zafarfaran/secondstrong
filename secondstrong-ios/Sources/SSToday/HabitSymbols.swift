import SSCore

extension Habit {
    /// The line icon for each habit on Today.
    var symbol: String {
        switch self {
        case .protein: "fork.knife"
        case .strength: "dumbbell"
        case .movement: "figure.walk"
        case .fibre: "leaf"
        case .sleep: "moon.stars"
        }
    }
}
