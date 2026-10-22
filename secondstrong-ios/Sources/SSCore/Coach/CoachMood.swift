import Foundation

/// What a coach is doing. One case per clip state in design/coach-clips/manifest.json.
public enum CoachMood: String, CaseIterable, Sendable {
    case idle, hello, listening, thinking, proud, lifting, stretching, comfort, resting
    case suggest, cheer, wow, encourage, oops, gotit, breathe
}
