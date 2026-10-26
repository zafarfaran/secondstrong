import SwiftUI
import SSCore
import SSDesign

/// A voice conversation: the coach big on the paper scene, listening, thinking and speaking with its own clips, her words
/// written in handwriting under it, and three controls (SS-0026).
struct VoiceView: View {
    let model: TodayModel
    let session: VoiceSession

    private var mood: CoachMood {
        switch session.phase {
        case .listening: .listening
        case .thinking: .thinking
        case .speaking: .suggest
        }
    }

    private var status: String {
        switch session.phase {
        case .listening: session.muted ? "Muted" : "Listening…"
        case .thinking: "Thinking…"
        case .speaking: "Speaking"
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack(alignment: .topLeading) {
                Palette.ivory
                HeroScene(part: model.part, coach: model.summary.coach, mood: mood, width: w, height: h * 0.72,
                          anchor: CGPoint(x: 0.6, y: 0.74), coachSize: min(320, w * 0.8), animated: model.animateCoach)
                    .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.18),
                                                 .init(color: .black, location: 0.5), .init(color: .clear, location: 0.97)],
                                         startPoint: .top, endPoint: .bottom))
                VStack(spacing: 2) {
                    Text(model.summary.coach.name).font(SSFont.hand(34)).foregroundStyle(Palette.ink)
                    Text(status).font(SSFont.display(13, weight: 600)).foregroundStyle(Palette.ink2)
                }
                .frame(maxWidth: .infinity).padding(.top, proxy.safeAreaInsets.top + 16)
                caption.frame(width: w).offset(y: h * 0.66)
                controls.frame(width: w).offset(y: h - proxy.safeAreaInsets.bottom - 130)
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
    }

    private var caption: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(0..<19, id: \.self) { i in
                    Capsule().fill(Palette.ink.opacity(0.8)).frame(width: 4, height: session.phase == .listening && !session.muted ? 8 + abs(sin(Double(i) * 1.3)) * 28 : 6)
                }
            }
            .frame(height: 40)
            .animation(.easeInOut(duration: 0.3), value: session.phase)
            Text(session.caption).font(SSFont.hand(25)).foregroundStyle(Palette.pen)
                .multilineTextAlignment(.center).frame(minHeight: 66, alignment: .top)
                .padding(.horizontal, 36)
        }
    }

    private var controls: some View {
        HStack(spacing: 26) {
            control("Mute", session.muted ? "mic.slash.fill" : "mic.slash", fill: session.muted ? Palette.ink : .clear, tint: session.muted ? Palette.ivory : Palette.ink) {
                session.muted.toggle()
            }
            control("End", "xmark", fill: Palette.pen, tint: .white) { model.closeVoice() }
            control("Type", "keyboard", fill: .clear, tint: Palette.ink) { model.closeVoice() }
        }
    }

    private func control(_ label: String, _ symbol: String, fill: Color, tint: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 7) {
            Button(action: action) {
                Image(systemName: symbol).font(.system(size: 22, weight: .regular)).foregroundStyle(tint)
                    .frame(width: 64, height: 64).background(fill, in: Circle())
                    .overlay(Circle().stroke(Palette.ink.opacity(fill == .clear ? 0.16 : 0), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            Text(label).font(SSFont.display(11.5, weight: 600)).foregroundStyle(Palette.ink2)
        }
    }
}
