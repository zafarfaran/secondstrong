import Foundation

/// The safety screen: neutral wording, one list. Source: spec section 2.6.
public enum SafetyFlag: String, CaseIterable, Sendable, Identifiable {
    case eatingHistory, pregnancy, diabetes, thyroid, heart, kidney, none, noAnswer

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .eatingHistory: "A history of disordered eating"
        case .pregnancy: "Pregnant or breastfeeding"
        case .diabetes: "Diabetes"
        case .thyroid: "A thyroid condition"
        case .heart: "A heart condition"
        case .kidney: "A kidney condition"
        case .none: "None of these"
        case .noAnswer: "I'd rather not say"
        }
    }

    /// "None" and "rather not say" stand alone; they clear every other choice.
    public var isExclusive: Bool { self == .none || self == .noAnswer }

    /// Conditions that get a "check with your GP first" note, never a block.
    public var needsGPNote: Bool {
        switch self {
        case .diabetes, .thyroid, .heart, .kidney: true
        default: false
        }
    }
}

public enum Experience: String, CaseIterable, Sendable, Identifiable {
    case never, tried, onAndOff, regular

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .never: "Never lifted"
        case .tried: "Tried it"
        case .onAndOff: "On and off"
        case .regular: "Regularly"
        }
    }
}

public enum Equipment: String, CaseIterable, Sendable, Identifiable {
    case gym, dumbbells, bands

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .gym: "A gym"
        case .dumbbells: "Dumbbells at home"
        case .bands: "Bands or bodyweight"
        }
    }
}
