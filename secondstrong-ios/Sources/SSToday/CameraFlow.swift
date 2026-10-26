import SwiftUI
import SSCore

/// The photo path on the Food tab: viewfinder, Miso reading, a result she can correct, or a photo that could not be read.
/// The prototype "reads" with made-up numbers; the real scanner is not connected, and the photo stays on the phone (SS-0032).
@MainActor @Observable
final class CameraFlow {
    enum Phase: Equatable { case viewfinder, reading(Int), result, failed }

    static let stages: [ResponseStage] = [.reading, .spotting, .estimating]
    /// In the prototype every third photo cannot be read, so the failed state can be seen.
    static let failsEvery = 3

    private(set) var phase = Phase.viewfinder
    private(set) var photo: Data?
    private(set) var base = MealEstimate.prototype(0)
    var portion = Portion.medium
    var name = ""
    var removed: Set<String> = []
    private var scans: Int
    private let pace: Double
    private var task: Task<Void, Never>?

    init(scans: Int = 0, pace: Double = 1) {
        self.scans = scans
        self.pace = pace
    }

    var estimate: MealEstimate { base.adjusted(portion: portion, removing: removed, named: name.isEmpty ? base.name : name) }
    var photoCount: Int { scans }

    func capture(_ data: Data?) {
        photo = data
        scans += 1
        let broken = scans % Self.failsEvery == 0
        let meal = MealEstimate.prototype(scans - 1)
        task?.cancel()
        task = Task {
            for i in Self.stages.indices {
                phase = .reading(i)
                try? await Task.sleep(for: .seconds(0.9 * pace))
                if Task.isCancelled { return }
            }
            phase = .reading(Self.stages.count)
            try? await Task.sleep(for: .seconds(0.4 * pace))
            if Task.isCancelled { return }
            if broken { phase = .failed; return }
            base = meal
            name = meal.name
            portion = .medium
            removed = []
            phase = .result
        }
    }

    func retake() {
        task?.cancel()
        photo = nil
        phase = .viewfinder
    }

    func toggle(_ item: String) {
        if removed.contains(item) { removed.remove(item) } else { removed.insert(item) }
    }
}
