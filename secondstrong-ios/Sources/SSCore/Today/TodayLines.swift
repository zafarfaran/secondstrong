import Foundation

/// The coach's few words on Today, and the first thing it says when opened. UK English, no exclamation marks.
// SS-0025: draft copy; the coach's real lines come from the coach itself and need clinical review.
public enum TodayLines {
    public static func coach(for summary: TodaySummary, hour: Int) -> [String] {
        let gap = summary.proteinToGo
        let session = summary.session != nil
        if gap >= 20 && session { return ["Lift today.", "\(gap)g protein to go."] }
        if gap >= 20 { return ["\(gap)g protein to go.", "A small meal will do it."] }
        if session { return ["Your session is ready.", "Easy does it."] }
        return ["All set today.", "Rest well."]
    }

    public static func opening(for summary: TodaySummary, hour: Int) -> String {
        let hello = "\(DayPart.at(hour: hour).greeting), \(summary.name)."
        let gap = summary.proteinToGo
        guard gap >= 20 else { return hello + " You are on track with protein today." }
        return hello + " You're \(gap)g short on protein today. A protein-rich meal would close most of the gap."
    }

    /// SS-0025: canned answers so the prototype can reply; the real coach replaces them.
    public static func reply(to text: String) -> String {
        switch text {
        case "Lunch ideas": "Try eggs on toast with cottage cheese. About 28g, ten minutes."
        case "Not now": "Of course. I'm here when you want me."
        case "It went well": "Lovely. Keep it going."
        case "Not yet": "That's fine. Maybe tomorrow."
        default: "Tell me more."
        }
    }

    /// What the prototype's voice conversation says, in turn: what she is heard to say, and Miso's answer.
    public static let voiceScript: [(heard: String, reply: String)] = [
        ("What should I eat for lunch?", "Aim for about thirty grams of protein. Eggs, yoghurt, fish or beans all work."),
        ("I'm a bit tired today.", "Then keep it light. Ten minutes still counts."),
        ("Can we make today's session shorter?", "Of course. Let's do ten minutes and see how you feel."),
    ]
}
