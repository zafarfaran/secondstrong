import SwiftUI
import SSCore
import SSDesign

/// Everyday movement, not training: it sets how much energy her day uses (SS-0024).
struct ActivitySection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.activity.rawValue, flow: flow, scene: .days) {
            SectionTitle("How active is", emphasis: "your day?", index: OnboardingStep.activity.rawValue, size: 30, stacked: true)
            VStack(spacing: 9) {
                ForEach(ActivityLevel.allCases) { level in
                    ChoiceRow(selected: flow.answers.activity == level, label: level.title, height: 64, detail: level.example, icon: PaperArt.activity(level)) {
                        flow.pick(activity: level)
                    }
                    .penAnchor(.activity(level))
                }
            }
            .padding(.top, 6)
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .activity)) { flow.next() }
                .penAnchor(.next(OnboardingStep.activity.rawValue))
        }
    }
}
