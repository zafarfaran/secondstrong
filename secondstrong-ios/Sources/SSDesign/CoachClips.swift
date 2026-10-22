import AVFoundation
import SSCore

/// The coach clips in the module bundle: HEVC with alpha, one file per coach and state,
/// 400 x 400 px covering the mascot grid from (-20, -50) to (220, 190).
enum CoachClips {
    /// Clip pixels per mascot-grid unit, and where the clip's corner sits on the grid.
    static let gridWidth = 240.0
    static let gridOrigin = (x: -20.0, y: -50.0)

    static let manifest: ClipManifest? = {
        guard let url = Bundle.module.url(forResource: "manifest", withExtension: "json", subdirectory: "Clips"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? ClipManifest(json: data)
    }()

    @MainActor private static var assets: [String: AVURLAsset] = [:]

    @MainActor static func asset(_ coach: Coach, _ mood: CoachMood) -> AVURLAsset? {
        let key = "\(coach.rawValue)/\(mood.rawValue)"
        if let hit = assets[key] { return hit }
        guard let url = Bundle.module.url(forResource: mood.rawValue, withExtension: "mov", subdirectory: "Clips/\(coach.rawValue)")
        else { return nil }
        let asset = AVURLAsset(url: url)
        assets[key] = asset
        return asset
    }

    /// Loads every state in the background so a mood change never waits on the disk.
    @MainActor static func warm(_ coach: Coach) {
        let all = CoachMood.allCases.compactMap { asset(coach, $0) }
        Task.detached(priority: .utility) {
            for asset in all { _ = try? await asset.load(.tracks) }
        }
    }
}
