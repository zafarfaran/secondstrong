import SwiftUI
import SSCore
import SSDesign

/// The first thing anyone sees: one door for new and returning members. Design: design/signin.
/// New members go on to choose a coach; the pen line starts after this.
struct AuthGate: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        ZStack {
            PaperBackground()
            switch flow.authStage {
            case .choose: AuthDoor(flow: flow).transition(.opacity)
            case .email: AuthEmailScreen(flow: flow).transition(.opacity)
            case .sent: AuthInboxScreen(flow: flow).transition(.opacity)
            case .expired: AuthExpiredScreen(flow: flow).transition(.opacity)
            case .returning: AuthReturningScreen(flow: flow).transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flow.authStage)
    }
}

/// Top padding, side padding and back button shared by the sign-in screens.
struct AuthFrame<Content: View>: View {
    let flow: OnboardingFlow
    var back: (() -> Void)?
    var top: CGFloat?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(.top, top ?? max(92, flow.safeTop + 38))
            .padding(.horizontal, 26)
            .padding(.bottom, 24 + flow.safeBottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .overlay(alignment: .topLeading) {
                if let back {
                    Button(action: back) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 12)
                    .padding(.top, flow.safeTop + 6)
                    .accessibilityLabel("Back")
                }
            }
    }
}

/// The illustrations sit on the page colour; a soft edge lets them melt into it.
struct SceneArt: View {
    let scene: AuthArt.Scene
    let size: CGFloat
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        AuthArt.image(scene, dark: scheme == .dark)
            .resizable().scaledToFit()
            .frame(width: size, height: size)
            .mask(RadialGradient(colors: [.black, .black, .clear], center: .center, startRadius: size * 0.34, endRadius: size * 0.5))
            .accessibilityHidden(true)
    }
}
