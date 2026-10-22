import SwiftUI
import SSCore
import SSDesign

struct WelcomeSection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: 0, flow: flow, scene: .welcome) {
            BrandLogo(markSize: 84, wordSize: 36)
                .penAnchor(.title(0))
                .padding(.top, 4)
            Text("A few questions, then a program that fits you.")
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .penAnchor(.sub)
                .padding(.top, -4)
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .penAnchor(.hero)
                .overlay {
                    CoachView(flow.answers.coach, mood: flow.heroMood, animated: flow.step == 0)
                        .frame(width: 240, height: 240)
                        .opacity(flow.heroVisible ? 1 : 0)
                        .onTapGesture { flow.pulseHero(.hello, for: 2.4) }
                }
            Spacer(minLength: 0)
            PillButton("Begin") { flow.next() }.penAnchor(.next(0))
        }
    }
}
