import SwiftUI
import SSDesign

/// One drawn piece of the line. The pen animates along it when it appears.
@MainActor @Observable
final class InkStroke: Identifiable {
    let id = UUID()
    let path: Path
    let duration: Double
    let delay: Double
    var opacity = 1.0

    init(path: Path, duration: Double, delay: Double = 0) {
        self.path = path
        self.duration = duration
        self.delay = delay
    }
}

private struct StrokeView: View {
    let stroke: InkStroke
    let lineWidth: Double
    @State private var drawn = false

    var body: some View {
        stroke.path
            .trim(from: 0, to: drawn ? 1 : 0)
            .stroke(Palette.pen, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .opacity(stroke.opacity)
            .onAppear {
                withAnimation(.timingCurve(0.4, 0.05, 0.35, 1, duration: stroke.duration).delay(stroke.delay)) {
                    drawn = true
                }
            }
    }
}

struct InkLayer: View {
    let strokes: [InkStroke]
    let lineWidth: Double
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            ForEach(strokes) { StrokeView(stroke: $0, lineWidth: lineWidth) }
        }
        // Ink darkens what it crosses on paper; multiplying on a dark page would make it vanish.
        .blendMode(scheme == .dark ? .normal : .multiply)
        .allowsHitTesting(false)
    }
}
