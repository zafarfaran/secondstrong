import SwiftUI
import SSCore
import SSDesign

/// The coach's answer as it is being written. The whole text is laid out from the start, so the bubble is its final size and nothing
/// reflows; the letters appear by the clock and the newest few fade in rather than pop (SS-0029). Reduce Motion shows it at once.
struct WritingBubble: View {
    let writing: Writing
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let fade = 9.0

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            Text(attributed(at: context.date))
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Palette.card, in: UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 6, bottomTrailingRadius: 22, topTrailingRadius: 22))
                .frame(maxWidth: 310, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel(writing.full)
    }

    private func attributed(at date: Date) -> AttributedString {
        var text = AttributedString(writing.full)
        text.font = SSFont.display(15.5, weight: 400)
        text.foregroundColor = Palette.ink.opacity(0)
        let reveal = reduceMotion ? Double(writing.full.count) : TokenStream.revealed(total: writing.full.count, elapsed: date.timeIntervalSince(writing.start), speed: writing.speed)
        let whole = Int(reveal)
        var index = text.startIndex
        for position in 0..<min(writing.full.count, whole + Int(Self.fade)) {
            let next = text.index(index, offsetByCharacters: 1)
            let alpha = position < whole ? 1 : max(0, 1 - (Double(position) - reveal + 1) / Self.fade)
            text[index..<next].foregroundColor = Palette.ink.opacity(alpha)
            index = next
        }
        return text
    }
}
