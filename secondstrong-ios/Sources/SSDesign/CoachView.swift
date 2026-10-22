import SwiftUI
import SSCore
#if canImport(UIKit)
import UIKit
typealias PlatformView = UIView
typealias PlatformRepresentable = UIViewRepresentable
#else
import AppKit
typealias PlatformView = NSView
typealias PlatformRepresentable = NSViewRepresentable
#endif

/// A coach, alive: plays the clip for its mood. Frame it as the 200 x 200 mascot grid;
/// the clip is larger than that so raised arms and sparkles have room, and may overflow.
public struct CoachView: View {
    let coach: Coach
    let mood: CoachMood
    let animated: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var player: CoachClipPlayer?
    @State private var playing = false

    public init(_ coach: Coach, mood: CoachMood = .idle, animated: Bool = true) {
        self.coach = coach
        self.mood = mood
        self.animated = animated
    }

    public var body: some View {
        GeometryReader { proxy in
            let k = min(proxy.size.width, proxy.size.height) / 200
            let side = CoachClips.gridWidth * k
            ZStack {
                coach.image.resizable().opacity(playing ? 0 : 1)
                if animated && !reduceMotion, let player {
                    ClipSurface(player: player).opacity(playing ? 1 : 0)
                }
            }
            .frame(width: side, height: side)
            .offset(x: CoachClips.gridOrigin.x * k, y: CoachClips.gridOrigin.y * k)
        }
        .onAppear { start() }
        .onChange(of: mood) { _, new in player?.request(new) }
        .onChange(of: animated) { _, on in if on { start() } else { pause() } }
        .onDisappear { pause() }
        .accessibilityHidden(true)
    }

    /// Off-screen coaches stop decoding; they come back from idle when shown again.
    private func pause() {
        player?.stop()
        player = nil
        playing = false
    }

    private func start() {
        guard animated, !reduceMotion, player == nil else { return }
        let made = CoachClipPlayer(coach)
        made.onFirstFrame = { withAnimation(.easeOut(duration: 0.12)) { playing = true } }
        made.request(mood)
        player = made
    }
}

private struct ClipSurface: PlatformRepresentable {
    let player: CoachClipPlayer

    #if canImport(UIKit)
    func makeUIView(context: Context) -> ClipHost { ClipHost(player) }
    func updateUIView(_ view: ClipHost, context: Context) {}
    #else
    func makeNSView(context: Context) -> ClipHost { ClipHost(player) }
    func updateNSView(_ view: ClipHost, context: Context) {}
    #endif
}

@MainActor private final class ClipHost: PlatformView {
    let player: CoachClipPlayer

    init(_ player: CoachClipPlayer) {
        self.player = player
        super.init(frame: .zero)
        #if canImport(UIKit)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        layer.addSublayer(player.root)
        #else
        wantsLayer = true
        layer?.backgroundColor = nil
        layer?.addSublayer(player.root)
        #endif
    }

    required init?(coder: NSCoder) { fatalError() }

    #if canImport(UIKit)
    override func layoutSubviews() { super.layoutSubviews(); player.setFrame(bounds) }
    #else
    override func layout() { super.layout(); player.setFrame(bounds) }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
    #endif
}
