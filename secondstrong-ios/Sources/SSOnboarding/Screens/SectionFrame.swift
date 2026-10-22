import SwiftUI
import SSDesign

/// One full-screen page of the document. Lit once the pen has reached it.
struct SectionFrame<Content: View>: View {
    let index: Int
    let flow: OnboardingFlow
    var badge: String?
    var scene: PaperArt.Scene?
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(.top, max(92, flow.safeTop + 38))
            .padding(.leading, 34)
            .padding(.trailing, 22)
            .padding(.bottom, 26 + flow.safeBottom)
            .frame(width: flow.screen.width, height: flow.screen.height, alignment: .topLeading)
            .background(alignment: .bottom) {
                if let scene {
                    PaperArt.scene(scene, dark: colorScheme == .dark)
                        .resizable().scaledToFit()
                        .frame(width: flow.screen.width)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .overlay(alignment: .topTrailing) {
                if let badge {
                    PaperArt.badge(badge)
                        .resizable().scaledToFit()
                        .frame(width: 74, height: 74)
                        .padding(.top, max(76, flow.safeTop + 22))
                        .padding(.trailing, 18)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .opacity(flow.ended ? 0.3 : (index <= flow.step ? 1 : 0))
            .animation(.easeOut(duration: 0.5), value: flow.step)
            .allowsHitTesting(index == flow.step && !flow.ended)
    }
}

/// A headline in the bold face with one emphasised phrase in handwriting. The pen underlines the phrase.
struct SectionTitle: View {
    let lead: String
    let emphasis: String
    let index: Int
    let size: CGFloat
    let stacked: Bool

    init(_ lead: String, emphasis: String, index: Int, size: CGFloat = 34, stacked: Bool = false) {
        self.lead = lead
        self.emphasis = emphasis
        self.index = index
        self.size = size
        self.stacked = stacked
    }

    var body: some View {
        let leadText = Text(lead).font(SSFont.display(size)).tracking(-size * 0.035)
        let emText = Text(emphasis).font(SSFont.hand(size * 1.2))
        Group {
            if stacked {
                VStack(alignment: .leading, spacing: -size * 0.2) { line(leadText); line(emText).penAnchor(.title(index)) }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: size * 0.2) { line(leadText); line(emText).penAnchor(.title(index)) }
            }
        }
        .foregroundStyle(Palette.ink)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lead + emphasis)
        .accessibilityAddTraits(.isHeader)
    }

    private func line(_ text: Text) -> some View {
        text.fixedSize()
    }
}
