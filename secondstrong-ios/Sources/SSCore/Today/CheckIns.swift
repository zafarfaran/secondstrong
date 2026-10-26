import Foundation

public enum CheckIn: String, CaseIterable, Sendable, Identifiable {
    case morning, midday, followUp, afterSession, evening

    public var id: String { rawValue }
}

/// What she has allowed. Defaults are gentle: two a day, quiet from 9 pm to 7 am (SS-0026).
public struct CheckInSettings: Equatable, Sendable {
    public var morning = true
    public var midday = true
    public var followUp = true
    public var afterSession = true
    public var evening = false
    public var dailyCap = 2
    public var quietFrom = 21
    public var quietTo = 7

    public init() {}

    public static let standard = CheckInSettings()

    public func allows(_ kind: CheckIn) -> Bool {
        switch kind {
        case .morning: morning
        case .midday: midday
        case .followUp: followUp
        case .afterSession: afterSession
        case .evening: evening
        }
    }

    /// Quiet hours may wrap past midnight.
    public func isQuiet(minuteOfDay minute: Int) -> Bool {
        let from = quietFrom * 60, to = quietTo * 60
        return from <= to ? (minute >= from && minute < to) : (minute >= from || minute < to)
    }
}

public struct CheckInMessage: Equatable, Sendable, Identifiable {
    public let kind: CheckIn
    public let minuteOfDay: Int
    public let text: String
    public let replies: [String]
    public let showsSession: Bool

    public var id: CheckIn { kind }

    public var time: String {
        let h = minuteOfDay / 60, m = minuteOfDay % 60
        return String(format: "%d:%02d %@", h % 12 == 0 ? 12 : h % 12, m, h < 12 ? "am" : "pm")
    }
}

/// Decides what the coach writes first today. Rules she can see, not guesses; never weight, never calories; backs off when ignored.
// SS-0026: the lines are drafts; the real coach's words need clinical review.
public enum CheckInPlanner {
    private static let schedule: [(CheckIn, Int)] = [(.morning, 8 * 60 + 2), (.followUp, 10 * 60 + 15), (.midday, 12 * 60 + 40), (.evening, 20 * 60 + 30)]
    private static let priority: [CheckIn] = [.midday, .morning, .followUp, .evening]

    public static func due(settings: CheckInSettings, summary: TodaySummary, minuteOfDay now: Int, ignoredInARow: Int = 0) -> [CheckInMessage] {
        let cap = ignoredInARow >= 3 ? 1 : settings.dailyCap
        let ready = schedule.compactMap { kind, minute -> CheckInMessage? in
            guard minute <= now, settings.allows(kind), !settings.isQuiet(minuteOfDay: minute),
                  let message = message(kind, minute: minute, summary: summary) else { return nil }
            return message
        }
        let kept = ready.sorted { priority.firstIndex(of: $0.kind)! < priority.firstIndex(of: $1.kind)! }.prefix(max(0, cap))
        return kept.sorted { $0.minuteOfDay < $1.minuteOfDay }
    }

    /// Written once, when a session is finished.
    public static func afterSession(summary: TodaySummary, minuteOfDay: Int = 0) -> CheckInMessage {
        let title = summary.session?.title ?? "Your session"
        return CheckInMessage(kind: .afterSession, minuteOfDay: minuteOfDay, text: "\(title) is done. Good work. Something with protein soon would help.",
                              replies: [], showsSession: false)
    }

    private static func message(_ kind: CheckIn, minute: Int, summary: TodaySummary) -> CheckInMessage? {
        switch kind {
        case .morning:
            let text = summary.session.map { "Morning, \(summary.name). \($0.title) today, \($0.minutes) minutes. I'll check in after." }
                ?? "Morning, \(summary.name). A rest day today. Easy does it."
            return CheckInMessage(kind: kind, minuteOfDay: minute, text: text, replies: [], showsSession: summary.session != nil)
        case .followUp:
            guard let thread = summary.openThread else { return nil }
            return CheckInMessage(kind: kind, minuteOfDay: minute, text: "Did you get to \(thread)? No pressure either way.",
                                  replies: ["It went well", "Not yet"], showsSession: false)
        case .midday:
            guard summary.proteinToGo >= 20 else { return nil }
            return CheckInMessage(kind: kind, minuteOfDay: minute,
                                  text: "You're \(summary.proteinToGo)g short on protein today. Eggs or yoghurt at lunch would close most of it. Want ideas?",
                                  replies: ["Lunch ideas", "Not now"], showsSession: false)
        case .evening:
            return CheckInMessage(kind: kind, minuteOfDay: minute, text: "Time to wind down. A short stretch, then bed.", replies: [], showsSession: false)
        case .afterSession:
            return nil
        }
    }
}
