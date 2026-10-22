import SwiftUI
import SSCore
import SSDesign

/// A returning member who signed out: their coach greets them and the way they came in last time comes first.
struct AuthReturningScreen: View {
    let flow: OnboardingFlow

    private var member: KnownMember { flow.member ?? KnownMember(firstName: "there", coach: flow.answers.coach, method: .apple) }

    var body: some View {
        AuthFrame(flow: flow, top: max(64, flow.safeTop + 14)) {
            MetaLabel(Date().formatted(Date.FormatStyle().weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_GB"))))
            (Text("\(greeting), ").font(SSFont.display(33)).tracking(-1.2) + Text("\(member.firstName).").font(SSFont.hand(40)))
                .foregroundStyle(Palette.ink)
                .padding(.top, 10)
                .accessibilityAddTraits(.isHeader)
            art
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
            note
            Spacer(minLength: 0)
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 12) {
                    Button { Task { await flow.signIn(with: member.method) } } label: {
                        HStack(spacing: 10) {
                            if member.method == .apple { Image(systemName: "apple.logo").font(.system(size: 18, weight: .medium)) } else { GoogleMark().frame(width: 18, height: 18) }
                            Text(member.method == .apple ? "Continue with Apple" : "Continue with Google").font(SSFont.display(17, weight: 600))
                        }
                        .foregroundStyle(Palette.ivory)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Palette.ink, in: Capsule())
                    }
                    .buttonStyle(PressScaleStyle(pressed: 0.97))
                    Button { flow.authStage = .choose } label: {
                        Text("Use another way")
                            .font(SSFont.display(17, weight: 600))
                            .foregroundStyle(Palette.ink)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .overlay(Capsule().stroke(Palette.ink.opacity(0.28), lineWidth: 1.5))
                    }
                    .buttonStyle(PressScaleStyle(pressed: 0.97))
                    Button { flow.signInAsSomeoneElse() } label: {
                        Text("Not \(member.firstName)? Sign in as someone else")
                            .font(SSFont.display(15, weight: 500))
                            .foregroundStyle(Palette.ink2)
                            .underline()
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                HStack(alignment: .bottom, spacing: 4) {
                    Text("how you came in last time").font(SSFont.hand(19)).rotationEffect(.degrees(-4))
                    Image(systemName: "arrow.turn.right.down").font(.system(size: 18, weight: .medium))
                }
                .foregroundStyle(Palette.pen)
                .offset(x: -2, y: -34)
            }
        }
        .disabled(flow.authBusy)
    }

    private var greeting: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case ..<12: "Morning"
        case ..<17: "Afternoon"
        default: "Evening"
        }
    }

    @ViewBuilder private var art: some View {
        if member.coach == .miso {
            SceneArt(scene: .returning, size: 300)
        } else {
            CoachView(member.coach, mood: .hello).frame(width: 200, height: 200)
        }
    }

    private var note: some View {
        VStack(alignment: .leading, spacing: 6) {
            MetaLabel(member.coach.name)
            // Fake until the plan exists: the real line comes from her next session.
            Text("I kept your place. Thursday's session is still on the plan, and it's a short one.")
                .font(SSFont.display(16, weight: 400))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.ink.opacity(0.1), lineWidth: 1))
    }
}
