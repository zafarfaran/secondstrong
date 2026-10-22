import SwiftUI
import SSCore
import SSDesign

struct DaysSection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.days.rawValue, flow: flow, scene: .days) {
            MetaLabel("Two to four")
            SectionTitle("Your", emphasis: "days.", index: OnboardingStep.days.rawValue)
            HStack(spacing: 6) { ForEach(Weekday.allCases) { day($0) } }
                .penAnchor(.week)
                .padding(.top, 12)
            Text(FirstWeekPlan.summary(dayCount: flow.answers.days.count))
                .font(SSFont.hand(21))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .animation(nil, value: flow.answers.days)
            Spacer(minLength: 0)
            PillButton("Make my plan", enabled: flow.answers.canContinue(from: .days)) { flow.next() }
                .penAnchor(.next(OnboardingStep.days.rawValue))
        }
    }

    private func day(_ day: Weekday) -> some View {
        let selected = flow.answers.days.contains(day)
        return Button { flow.toggle(day: day) } label: {
            Text(day.initial)
                .font(SSFont.display(18))
                .foregroundStyle(selected ? Palette.ivory : Palette.ink2)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background { if selected { Ellipse().fill(Palette.ink) } }
                .animation(.spring(duration: 0.38, bounce: 0.4), value: selected)
        }
        .buttonStyle(PressScaleStyle(pressed: 0.92))
        .accessibilityLabel(day.short)
        .accessibilityAddTraits(selected ? .isSelected : [])
        .penAnchor(.day(day))
    }
}
