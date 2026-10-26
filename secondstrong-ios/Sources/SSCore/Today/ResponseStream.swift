import Foundation

/// What the coach is doing while it works on an answer, shown as a short plain line (SS-0029).
public enum ResponseStage: String, CaseIterable, Sendable {
    case thinking, reading, spotting, estimating, writing

    public var label: String {
        switch self {
        case .thinking: "Thinking"
        case .reading: "Looking at your photo"
        case .spotting: "Spotting the food"
        case .estimating: "Estimating portions"
        case .writing: "Writing"
        }
    }
}

public enum ResponsePlan {
    /// The stages in order and roughly how long each is shown in the prototype. Writing has no fixed time: it lasts as long as the
    /// text takes to stream. The real durations will come from the real model.
    public static func stages(photo: Bool) -> [(stage: ResponseStage, seconds: Double)] {
        photo ? [(.thinking, 0.8), (.reading, 0.9), (.spotting, 0.9), (.estimating, 1.0), (.writing, 0)]
              : [(.thinking, 1.0), (.writing, 0)]
    }
}

/// How the words of an answer appear: one steady flow of letters by the clock, not word by word, so it reads smoothly (SS-0029).
public enum TokenStream {
    public static let charactersPerSecond = 38.0
    /// The first moment eases in so the writing does not start with a jolt.
    private static let easeIn = 0.35

    /// How many characters are visible after `elapsed` seconds. A fraction is fine: the newest letters fade in.
    public static func revealed(total: Int, elapsed: Double, speed: Double = charactersPerSecond) -> Double {
        guard elapsed > 0, total > 0 else { return 0 }
        let eased = elapsed < easeIn ? elapsed * elapsed / (2 * easeIn) : elapsed - easeIn / 2
        return min(Double(total), eased * speed)
    }

    /// What was written so far, cut back to the last whole word, for an answer that stopped or broke part way.
    public static func wholeWords(_ text: String) -> String {
        guard let space = text.lastIndex(of: " ") else { return "" }
        return String(text[..<space]).trimmingCharacters(in: .whitespaces)
    }

    /// Seconds until all `total` characters are visible.
    public static func duration(total: Int, speed: Double = charactersPerSecond) -> Double {
        total > 0 ? Double(total) / speed + easeIn / 2 : 0
    }
}

/// Why an answer did not finish. Calm, short and no one's fault (SS-0029).
public enum ResponseFailure: String, CaseIterable, Sendable {
    case network, photo

    public var message: String {
        switch self {
        case .network: "Couldn't reach Miso. Nothing was lost."
        case .photo: "I couldn't read that photo. A clearer one might help."
        }
    }

    public var retryLabel: String { "Try again" }
}

public enum ResponseOutcome: Equatable, Sendable {
    case completed, stopped, failed(ResponseFailure)

    /// Whatever words arrived stay on screen.
    public var keepsPartialText: Bool { self != .completed }

    public var note: String? {
        switch self {
        case .completed: nil
        case .stopped: "Stopped"
        case .failed(let failure): failure.message
        }
    }
}
