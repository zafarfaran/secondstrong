import SwiftUI
import SSCore
import SSDesign

/// What someone sees when they open an invite: warm, nothing asked of them, and clear that sharing is their choice.
/// They then sign in and answer their own questions; the plan that added them already covers them.
struct AuthInvitedScreen: View {
    let flow: OnboardingFlow

    var body: some View {
        AuthFrame(flow: flow, top: max(64, flow.safeTop + 14)) {
            Spacer(minLength: 0)
            CoachView(flow.answers.coach, mood: .hello)
                .frame(width: 190, height: 190)
                .frame(maxWidth: .infinity)
            (Text("\(flow.invitedBy ?? "Someone") added you to their ").font(SSFont.display(30)).tracking(-1)
                + Text("plan.").font(SSFont.hand(37)))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .accessibilityAddTraits(.isHeader)
            Text("\u{201C}Thinking of you. Go gently.\u{201D}")
                .font(SSFont.hand(23))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            Text("You're covered, so there's nothing to buy. You choose your coach, your pace, and what you share.")
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
            Spacer(minLength: 0)
            PillButton("Start") { flow.authStage = .choose }
        }
    }
}
