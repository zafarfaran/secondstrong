import SwiftUI
import SSCore
import SSDesign

/// Sign in or create an account: Apple, Google or email, over the coaches on their hill.
struct AuthDoor: View {
    let flow: OnboardingFlow
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottom) {
            // The sky is drawn and moves; the hills with the coaches on their path sit in front of it.
            let hillsHeight = flow.screen.width * AuthArt.hillsAspect
            PaperSky(dark: scheme == .dark, hillsTop: flow.screen.height - hillsHeight, reduceMotion: reduceMotion)
            AuthArt.hills(dark: scheme == .dark)
                .resizable().scaledToFit()
                .frame(width: flow.screen.width)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                mark
                (Text("Strong, ").font(SSFont.display(37)).tracking(-1.4) + Text("for years.").font(SSFont.hand(44)))
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 20)
                    .accessibilityAddTraits(.isHeader)
                Text("Sign in or create your account. New here? You'll choose a coach right after.")
                    .font(SSFont.display(16, weight: 400))
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 320, alignment: .leading)
                    .padding(.top, 10)
                #if DEBUG
                HStack(spacing: 14) {
                    Button("Prototype: returning member") { flow.previewAuth(.returning) }
                    Button("Prototype: invited") { flow.previewInvite() }
                }
                .buttonStyle(.plain)
                .font(SSFont.display(12, weight: 600))
                .foregroundStyle(Palette.pen)
                .padding(.top, 10)
                #endif
                Spacer(minLength: 0)
            }
            .padding(.top, max(64, flow.safeTop + 14))
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            card
                .padding(.horizontal, 16)
                .padding(.bottom, max(30, flow.safeBottom + 12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// A small "S" with a rose dot, the app's mark.
    private var mark: some View {
        HStack(alignment: .top, spacing: 2) {
            Text("S").font(SSFont.display(30)).tracking(-1.2).foregroundStyle(Palette.ink)
            Circle().fill(Palette.roseClay).frame(width: 9, height: 9).padding(.top, 17)
        }
        .accessibilityHidden(true)
    }

    private var card: some View {
        VStack(spacing: 10) {
            Button { Task { await flow.signIn(with: .apple) } } label: {
                HStack(spacing: 10) {
                    Image(systemName: "apple.logo").font(.system(size: 18, weight: .medium))
                    Text("Continue with Apple").font(SSFont.display(17, weight: 600))
                }
                .foregroundStyle(Palette.ivory)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Palette.ink, in: Capsule())
            }
            .buttonStyle(PressScaleStyle(pressed: 0.97))
            HStack(spacing: 10) {
                outline("Google") { GoogleMark().frame(width: 18, height: 18) } action: { Task { await flow.signIn(with: .google) } }
                outline("Email") { Image(systemName: "envelope").font(.system(size: 17, weight: .regular)) } action: { flow.chooseEmail() }
            }
            Text("By continuing you agree to our Terms and Privacy Policy.")
                .font(SSFont.display(12, weight: 400))
                .foregroundStyle(Palette.ink2)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
        .disabled(flow.authBusy)
        .opacity(flow.authBusy ? 0.5 : 1)
        .padding(16)
        .background(Palette.ivory, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.ink.opacity(0.1), lineWidth: 1))
    }

    private func outline<Icon: View>(_ title: String, @ViewBuilder icon: () -> Icon, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                icon()
                Text(title).font(SSFont.display(16, weight: 600))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity).frame(height: 52)
            .overlay(Capsule().stroke(Palette.ink.opacity(0.28), lineWidth: 1.5))
        }
        .buttonStyle(PressScaleStyle(pressed: 0.97))
        .accessibilityLabel(title)
    }
}
