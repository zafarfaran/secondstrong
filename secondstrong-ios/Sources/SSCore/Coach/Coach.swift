import Foundation

/// The eight coaches a member can pick. Source: design/mascots/README.md.
public enum Coach: String, CaseIterable, Sendable, Identifiable, Codable {
    case pebble, fern, wren, bramble, luna, otto, tilly, miso

    public var id: String { rawValue }

    public var name: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    public var temperament: String {
        switch self {
        case .pebble: "Steady. Plain words, small steps."
        case .fern: "Gentle. Notices the small wins."
        case .wren: "Bright. Keeps things moving."
        case .bramble: "Strong and practical. Big on rest."
        case .luna: "Calm. Good company at 3am."
        case .otto: "Warm and playful. Makes it lighter."
        case .tilly: "Patient. Here for the long run."
        case .miso: "Curious. Quietly keeps you honest."
        }
    }
}
