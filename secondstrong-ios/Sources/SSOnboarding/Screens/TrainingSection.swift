import SwiftUI
import SSCore
import SSDesign

/// What week one holds: how used to lifting she is, and what she has to lift with.
struct TrainingSection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.training.rawValue, flow: flow, badge: "training") {
            SectionTitle("Your", emphasis: "strength.", index: OnboardingStep.training.rawValue)
            MetaLabel("Lifting so far")
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow { level(.never); level(.tried) }
                GridRow { level(.onAndOff); level(.regular) }
            }
            MetaLabel("What you have").padding(.top, 8)
            VStack(spacing: 8) {
                ForEach(Equipment.allCases) { place in
                    ChoiceRow(selected: flow.answers.equipment == place, label: place.title, height: 44) { flow.pick(equipment: place) }
                        .penAnchor(.equipment(place))
                }
            }
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .training)) { flow.next() }
                .penAnchor(.next(OnboardingStep.training.rawValue))
        }
    }

    private func level(_ value: Experience) -> some View {
        ChoiceRow(selected: flow.answers.experience == value, label: value.title, height: 44) { flow.pick(experience: value) }
            .penAnchor(.experience(value))
    }
}
