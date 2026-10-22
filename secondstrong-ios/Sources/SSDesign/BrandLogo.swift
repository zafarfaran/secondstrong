import SwiftUI

/// The Second Strong logo: the "S" with its rose dot, over the wordmark. Placeholder drawn in the app's own type
/// until a final logo exists (the Keel files in assets/ are the old name and are not cleared for use).
public struct BrandLogo: View {
    let markSize: CGFloat
    let wordSize: CGFloat

    public init(markSize: CGFloat = 78, wordSize: CGFloat = 30) {
        self.markSize = markSize
        self.wordSize = wordSize
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: wordSize * 0.1) {
            HStack(alignment: .top, spacing: markSize * 0.04) {
                Text("S").font(SSFont.display(markSize)).tracking(-markSize * 0.04).foregroundStyle(Palette.ink)
                Circle().fill(Palette.roseClay).frame(width: markSize * 0.3, height: markSize * 0.3).padding(.top, markSize * 0.56)
            }
            .frame(height: markSize * 0.82, alignment: .top)
            (Text("Second ").font(SSFont.display(wordSize)).tracking(-wordSize * 0.035)
                + Text("Strong").font(SSFont.hand(wordSize * 1.2)))
                .foregroundStyle(Palette.ink)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Second Strong")
    }
}
