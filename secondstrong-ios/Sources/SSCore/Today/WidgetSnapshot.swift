import Foundation

public enum WidgetState: String, Codable, Sendable { case morning, goal, evening }

/// The little summary the app shares with its widgets. Protein only: no weight, no calories, no streaks (SS-0030).
public struct WidgetSnapshot: Codable, Equatable, Sendable {
    public var coach: Coach
    public var proteinGrams: Int
    public var proteinTarget: Int
    public var hour: Int
    public var hideLockScreenNumbers: Bool

    public init(coach: Coach, proteinGrams: Int, proteinTarget: Int, hour: Int, hideLockScreenNumbers: Bool) {
        self.coach = coach
        self.proteinGrams = proteinGrams
        self.proteinTarget = proteinTarget
        self.hour = hour
        self.hideLockScreenNumbers = hideLockScreenNumbers
    }

    public init(summary: TodaySummary, hour: Int, hideLockScreenNumbers: Bool) {
        self.init(coach: summary.coach, proteinGrams: summary.proteinGrams, proteinTarget: summary.proteinTarget,
                  hour: hour, hideLockScreenNumbers: hideLockScreenNumbers)
    }

    public var proteinToGo: Int { max(0, proteinTarget - proteinGrams) }
    public var fraction: Double { proteinTarget > 0 ? min(1, Double(proteinGrams) / Double(proteinTarget)) : 0 }

    /// Evening wins over everything, then reaching the goal, else the plan for the day.
    public var state: WidgetState {
        if hour >= 19 || hour < 5 { return .evening }
        return proteinToGo == 0 ? .goal : .morning
    }

    public var line: [String] {
        switch state {
        case .morning: ["Lift today.", "\(proteinToGo)g to go."]
        case .goal: ["You made it.", "Protein done."]
        case .evening: ["Easy evening.", "Lights out soon."]
        }
    }

    /// The picture for the widget: widgets cannot play video, so each state has a still of the coach.
    public var stillName: String { "still-\(coach.rawValue)-\(state.rawValue)" }

    // MARK: the lock screen can be seen by anyone, so it can hide the numbers

    public var lockScreenRing: Double? { hideLockScreenNumbers ? nil : fraction }
    public var lockScreenProtein: String? { hideLockScreenNumbers ? nil : "\(proteinGrams) of \(proteinTarget)g" }
    public var lockScreenLine: [String] { hideLockScreenNumbers ? [coach.name] : line }

    public struct Figure: Equatable, Sendable {
        public let label: String
        public let value: String
    }

    /// What the home widgets print as numbers: protein only.
    public var homeFigures: [Figure] { [Figure(label: "Protein", value: "\(proteinGrams)")] }
}

/// Where the app leaves the snapshot for the widgets to read. On a phone the defaults are the App Group's.
public struct WidgetStore {
    public static let appGroup = "group.com.secondstrong.app"
    private static let key = "widget.snapshot"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults? = UserDefaults(suiteName: appGroup)) { self.defaults = defaults ?? .standard }

    public func save(_ snapshot: WidgetSnapshot) {
        if let data = try? JSONEncoder().encode(snapshot) { defaults.set(data, forKey: Self.key) }
    }

    public func load() -> WidgetSnapshot? {
        defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode(WidgetSnapshot.self, from: $0) }
    }
}
