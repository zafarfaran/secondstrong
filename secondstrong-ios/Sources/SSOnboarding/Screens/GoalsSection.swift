import SwiftUI
import SSCore
import SSDesign

/// A set list of outcomes to tap, then an optional sentence in her own words.
struct GoalsSection: View {
    let flow: OnboardingFlow
    @FocusState private var focused: Bool

    var body: some View {
        SectionFrame(index: OnboardingStep.goals.rawValue, flow: flow) {
            MetaLabel("Up to three")
            SectionTitle("What would you", emphasis: "like to achieve?", index: OnboardingStep.goals.rawValue, size: 30, stacked: true)
            FlowLayout(spacing: 8, lineSpacing: 5) {
                ForEach(Goal.allCases) { chip($0) }
            }
            .padding(.top, 4)
            VStack(alignment: .leading, spacing: 4) {
                MetaLabel("Anything else? Optional")
                TextField("", text: Binding(get: { flow.answers.intention }, set: { flow.answers.write(intention: $0) }), axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(SSFont.hand(23))
                    .foregroundStyle(Palette.pen)
                    .lineLimit(1...2)
                    .focused($focused)
                    .penAnchor(.words)
                    .padding(.bottom, 6)
                    .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink).frame(height: 1.5) }
                    .accessibilityLabel("Anything else, in your own words")
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .goals)) {
                focused = false
                flow.next()
            }
            .penAnchor(.next(OnboardingStep.goals.rawValue))
        }
    }

    private func chip(_ goal: Goal) -> some View {
        let on = flow.answers.goals.contains(goal)
        return Button { flow.toggle(goal: goal) } label: {
            HStack(spacing: 7) {
                PaperArt.goal(goal).resizable().scaledToFit().frame(width: 26, height: 26)
                Text(goal.title)
                    .font(SSFont.display(14.5, weight: 600))
                    .foregroundStyle(on ? Palette.ivory : Palette.ink)
            }
            .padding(.leading, 8)
            .padding(.trailing, 14)
            .frame(height: 38)
                .background(on ? Palette.ink : .clear, in: Capsule())
                .overlay(Capsule().stroke(on ? Palette.ink : Palette.ink.opacity(0.22), lineWidth: 1.5))
                .animation(.spring(duration: 0.3, bounce: 0.35), value: on)
        }
        .buttonStyle(PressScaleStyle(pressed: 0.96))
        .accessibilityLabel(goal.title)
        .accessibilityAddTraits(on ? .isSelected : [])
        .penAnchor(.goal(goal))
        .keyframeAnimator(initialValue: 0.0, trigger: flow.shakeTicks[goal, default: 0]) { view, x in
            view.offset(x: x)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(-4, duration: 0.055)
                LinearKeyframe(4, duration: 0.11)
                LinearKeyframe(0, duration: 0.055)
            }
        }
    }
}
