import Foundation

/// Where one state's in, loop and out sit in its clip, in seconds. Source: design/coach-clips/manifest.json.
public struct ClipSegments: Equatable, Sendable {
    public var enter: ClosedRange<Double>
    public var loop: ClosedRange<Double>
    public var leave: ClosedRange<Double>
}

public struct ClipManifest: Sendable {
    public let segments: [CoachMood: ClipSegments]

    public init(json: Data) throws {
        struct Raw: Decodable {
            struct State: Decodable { let `in`: [Double]; let loop: [Double]; let out: [Double] }
            let states: [String: State]
        }
        let raw = try JSONDecoder().decode(Raw.self, from: json)
        var table: [CoachMood: ClipSegments] = [:]
        for (key, s) in raw.states {
            guard let mood = CoachMood(rawValue: key) else { continue }
            table[mood] = ClipSegments(enter: s.in[0]...s.in[1], loop: s.loop[0]...s.loop[1], leave: s.out[0]...s.out[1])
        }
        segments = table
    }
}

/// The clip contract: a state plays its in, repeats its loop until something else is asked for,
/// then plays its out and hands over to the next state. Every clip starts and ends on the same
/// neutral pose, so any state can follow any other. Only the latest request is kept.
public struct ClipSequencer: Sendable {
    public enum Phase: Sendable { case enter, loop, leave }
    public enum Action: Equatable, Sendable {
        case none
        case seek(Double)
        case play(CoachMood)
    }

    public private(set) var mood = CoachMood.idle
    public private(set) var phase = Phase.loop
    public private(set) var pending: CoachMood?
    private let manifest: ClipManifest
    private static let slack = 1.0 / 60

    public init(manifest: ClipManifest) { self.manifest = manifest }

    private func segments(_ mood: CoachMood) -> ClipSegments {
        manifest.segments[mood] ?? ClipSegments(enter: 0...0, loop: 0...1, leave: 1...1)
    }

    /// Idle is only breathing, so it gives way at once; any other state finishes its loop first.
    public mutating func request(_ next: CoachMood) -> Action {
        if next == mood, phase != .leave { pending = nil; return .none }
        pending = next
        guard mood == .idle, phase == .loop else { return .none }
        return begin(next)
    }

    public mutating func tick(at time: Double) -> Action {
        let s = segments(mood)
        switch phase {
        case .enter:
            if time >= s.enter.upperBound - Self.slack { phase = .loop }
        case .loop:
            guard time >= s.loop.upperBound - Self.slack else { return .none }
            if pending == nil { return .seek(s.loop.lowerBound) }
            phase = .leave
        case .leave:
            if time >= s.leave.upperBound - Self.slack { return begin(pending ?? .idle) }
        }
        return .none
    }

    private mutating func begin(_ next: CoachMood) -> Action {
        mood = next
        pending = nil
        phase = next == .idle ? .loop : .enter
        return .play(next)
    }
}
