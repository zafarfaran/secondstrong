import SwiftUI
import SSDesign

/// The "building your program" screen on its own, with a replay button. Used by the preview app.
public struct LoadingScreenPreview: View {
    @State private var run = 0

    public init() {}

    public var body: some View {
        PreviewRun { run += 1 }.id(run)
    }
}

private struct PreviewRun: View {
    let replay: () -> Void
    @State private var flow = OnboardingFlow()

    var body: some View {
        ZStack(alignment: .bottom) {
            PaperBackground()
            BuildingSection(flow: flow)
            Button(action: replay) {
                Text("Replay")
                    .font(SSFont.display(14, weight: 600))
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 18).frame(height: 36)
                    .overlay(Capsule().stroke(Palette.ink.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 26)
        }
        .frame(width: 390, height: 844)
        .task { await flow.previewBuilding(size: CGSize(width: 390, height: 844)) }
    }
}
