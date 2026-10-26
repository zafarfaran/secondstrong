import SwiftUI
import SSCore
import SSDesign

/// What the coach is doing before its words arrive: three pulsing dots and the current stage, and for a photo the steps already
/// done with a tick. Reduce Motion keeps the dots still (SS-0029).
struct StageView: View {
    let progress: ResponseProgress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(progress.done, id: \.self) { stage in
                HStack(spacing: 9) {
                    Image(systemName: "checkmark").font(.system(size: 10, weight: .heavy)).foregroundStyle(Palette.pen).frame(width: 18)
                    Text(stage.label).font(SSFont.display(14, weight: 400)).foregroundStyle(Palette.ink2)
                }
                .transition(.opacity)
            }
            HStack(spacing: 9) {
                dots.frame(width: 18)
                Text(progress.stage.label + "…").font(SSFont.display(14, weight: 600)).foregroundStyle(Palette.ink)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 20))
        .animation(.easeOut(duration: 0.25), value: progress)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(progress.stage.label)
    }

    private var dots: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Palette.pen).frame(width: 4.5, height: 4.5)
                        .opacity(reduceMotion ? 1 : 0.3 + 0.7 * max(0, sin(t * 5 - Double(i) * 0.9)))
                }
            }
        }
    }
}
