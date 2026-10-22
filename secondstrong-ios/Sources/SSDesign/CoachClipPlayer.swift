import AVFoundation
import QuartzCore
import SSCore

/// Plays one coach's clips following the in / loop / out contract. Two players take turns:
/// the next clip is cued on the idle one, so the hand-over shows no blank frame.
@MainActor
final class CoachClipPlayer {
    private final class Slot {
        let player = AVPlayer()
        let layer = AVPlayerLayer()
        var mood: CoachMood?
        var observer: Any?
        var ready: NSKeyValueObservation?

        init() {
            player.automaticallyWaitsToMinimizeStalling = false
            player.isMuted = true
            layer.player = player
            layer.videoGravity = .resizeAspect
            layer.backgroundColor = nil
            layer.isOpaque = false
        }
    }

    let coach: Coach
    let root = CALayer()
    var onFirstFrame: (() -> Void)?
    private var sequencer: ClipSequencer?
    private let slots = [Slot(), Slot()]
    private var live = 0

    init(_ coach: Coach) {
        self.coach = coach
        root.isOpaque = false
        guard let manifest = CoachClips.manifest else { return }
        sequencer = ClipSequencer(manifest: manifest)
        CoachClips.warm(coach)
        for (i, slot) in slots.enumerated() {
            root.addSublayer(slot.layer)
            slot.layer.opacity = i == live ? 1 : 0
            slot.observer = slot.player.addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 30), queue: .main
            ) { [weak self] time in
                MainActor.assumeIsolated { self?.tick(slot: i, time: time.seconds) }
            }
        }
        cue(.idle, in: slots[live])
        slots[live].player.play()
        slots[live].ready = slots[live].layer.observe(\.isReadyForDisplay, options: [.new]) { [weak self] layer, _ in
            guard layer.isReadyForDisplay else { return }
            DispatchQueue.main.async { MainActor.assumeIsolated { self?.onFirstFrame?() } }
        }
    }

    var currentMood: CoachMood? { sequencer?.mood }

    func setFrame(_ frame: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        root.frame = frame
        slots.forEach { $0.layer.frame = CGRect(origin: .zero, size: frame.size) }
        CATransaction.commit()
    }

    func request(_ mood: CoachMood) {
        guard var sequencer else { return }
        let action = sequencer.request(mood)
        self.sequencer = sequencer
        apply(action)
        cuePending()
    }

    /// Releases the decoders; the player is not used again after this.
    func stop() {
        for slot in slots {
            slot.player.pause()
            if let observer = slot.observer { slot.player.removeTimeObserver(observer) }
            slot.observer = nil
            slot.ready = nil
            slot.player.replaceCurrentItem(with: nil)
        }
        sequencer = nil
        root.removeFromSuperlayer()
    }

    private func tick(slot index: Int, time: Double) {
        guard index == live, var sequencer else { return }
        let action = sequencer.tick(at: time)
        self.sequencer = sequencer
        apply(action)
        cuePending()
    }

    private func apply(_ action: ClipSequencer.Action) {
        switch action {
        case .none: break
        case .seek(let t):
            slots[live].player.seek(to: CMTime(seconds: t, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
        case .play(let mood):
            let next = 1 - live
            if slots[next].mood != mood { cue(mood, in: slots[next]) }
            slots[next].player.play()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            slots[next].layer.opacity = 1
            slots[live].layer.opacity = 0
            CATransaction.commit()
            slots[live].player.pause()
            slots[live].mood = nil
            live = next
        }
    }

    /// While a clip is leaving, the next one is already waiting on the spare player.
    private func cuePending() {
        guard let sequencer, sequencer.phase != .enter else { return }
        let target = sequencer.pending ?? (sequencer.phase == .leave ? .idle : nil)
        guard let target, slots[1 - live].mood != target else { return }
        cue(target, in: slots[1 - live])
    }

    private func cue(_ mood: CoachMood, in slot: Slot) {
        slot.player.pause()
        slot.mood = mood
        guard let asset = CoachClips.asset(coach, mood) else { return }
        slot.player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        slot.player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
