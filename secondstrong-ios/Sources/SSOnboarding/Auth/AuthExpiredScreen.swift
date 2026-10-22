import SwiftUI
import SSCore
import SSDesign

/// The link only works once, for 15 minutes. One tap for a fresh one: no red, no blame.
struct AuthExpiredScreen: View {
    let flow: OnboardingFlow

    var body: some View {
        AuthFrame(flow: flow, back: { flow.authStage = .email }, top: max(64, flow.safeTop + 14)) {
            SceneArt(scene: .expired, size: 290)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
            MetaLabel("Sign-in link")
            (Text("That link has ").font(SSFont.display(32)).tracking(-1.1) + Text("expired.").font(SSFont.hand(39)))
                .foregroundStyle(Palette.ink)
                .padding(.top, 6)
                .accessibilityAddTraits(.isHeader)
            (Text("Links work once, for 15 minutes, to keep your account safe. A fresh one goes to ")
                + Text(EmailAddress.normalised(flow.authEmail) ?? flow.authEmail).fontWeight(.semibold) + Text("."))
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            Spacer(minLength: 0)
            VStack(spacing: 12) {
                PillButton(flow.authBusy ? "Sending…" : "Send a new link", enabled: !flow.authBusy) { Task { await flow.resendFromExpired() } }
                Button { flow.authStage = .choose } label: {
                    Text("Sign in another way")
                        .font(SSFont.display(16.5, weight: 600))
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .overlay(Capsule().stroke(Palette.ink.opacity(0.28), lineWidth: 1.5))
                }
                .buttonStyle(PressScaleStyle(pressed: 0.97))
            }
        }
    }
}
