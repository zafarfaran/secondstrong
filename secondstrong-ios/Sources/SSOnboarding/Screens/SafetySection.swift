import SwiftUI
import SSCore
import SSDesign

/// Mandatory screening (spec 2.6): neutral wording, never says she was flagged, never blocks.
struct SafetySection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.safety.rawValue, flow: flow, badge: "safety") {
            MetaLabel("Pick any that apply")
            SectionTitle("Anything we", emphasis: "should know?", index: OnboardingStep.safety.rawValue, size: 30, stacked: true)
            VStack(spacing: 8) {
                ForEach(SafetyFlag.allCases) { flag in
                    ChoiceRow(selected: flow.answers.safety.contains(flag), label: flag.title, height: 40) { flow.pick(safety: flag) }
                        .penAnchor(.safety(flag))
                }
            }
            .padding(.top, 4)
            Text(reassurance)
                .font(SSFont.hand(19))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .topLeading)
                .animation(nil, value: flow.answers.safety)
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .safety)) { flow.next() }
                .penAnchor(.next(OnboardingStep.safety.rawValue))
        }
    }

    private var reassurance: String {
        if flow.answers.calorieFree { return "Thank you. No numbers." }
        if flow.answers.safety.contains(.pregnancy) { return "Thank you. We'll go gently." }
        if flow.answers.showsGPNote { return "Check with your GP first." }
        return " "
    }
}
