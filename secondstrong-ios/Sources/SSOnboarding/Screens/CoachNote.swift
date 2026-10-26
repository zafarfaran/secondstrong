import SwiftUI
import SSDesign

/// What the coach says, written in the margin like a note: a few words of handwriting low on the left, a pen
/// underline drawn beneath them. It sits beside the coach, clear of Continue and any skip link, and takes no
/// touches, so the page underneath stays usable.
struct CoachNote: View {
    let text: String
    let screen: CGSize
    let safeBottom: CGFloat
    /// Extra room above the Continue button, for pages that keep a skip link just above it.
    var lift: CGFloat = 0
    let reduceMotion: Bool
    @State private var appeared = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            typed
                .overlay(alignment: .bottomLeading) { underline.offset(y: 9) }
        }
        .padding(.vertical, 6).padding(.horizontal, 8)
        .rotationEffect(.degrees(-1.5), anchor: .bottomLeading)
        .frame(maxWidth: screen.width - 34 - 14 - OnboardingFlow.companionSize - 8, alignment: .leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 26)
        .padding(.bottom, 26 + safeBottom + 54 + 14 + lift)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { appeared = Date() }
    }

    private var duration: Double { min(1.5, 0.045 * Double(text.count)) }

    /// The words appear letter by letter. The whole line is laid out from the start (the unwritten part is clear),
    /// so nothing jumps to a new line while it is written.
    private var typed: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let progress = reduceMotion ? 1 : min(1, max(0, (context.date.timeIntervalSince(appeared) - 0.15) / duration))
            var attributed = AttributedString(text)
            attributed.font = SSFont.hand(23)
            attributed.foregroundColor = Palette.pen.opacity(0)
            let written = attributed.index(attributed.startIndex, offsetByCharacters: Int(Double(text.count) * progress))
            attributed[attributed.startIndex..<written].foregroundColor = Palette.pen
            return Text(attributed).fixedSize(horizontal: false, vertical: true)
        }
    }

    /// A loose pen line under the words, drawn once they have been written.
    private var underline: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = reduceMotion ? 1 : min(1, max(0, (context.date.timeIntervalSince(appeared) - 0.15 - duration) / 0.5))
            Wave().trim(from: 0, to: t)
                .stroke(Palette.pen, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                .frame(height: 8)
        }
    }

    private struct Wave: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY + 1))
            p.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY - 1),
                       control1: CGPoint(x: rect.width * 0.3, y: rect.maxY),
                       control2: CGPoint(x: rect.width * 0.7, y: rect.minY))
            return p
        }
    }
}
