import SwiftUI
import SSCore
import SSDesign

/// What she wants from food. A slider sets the pace and the bars show how her daily calories change; the slider is
/// capped and the target never goes below the floor, so no position is unsafe (SS-0024).
struct FoodGoalSection: View {
    let flow: OnboardingFlow

    private var maintenance: Int? { EnergyPlan.maintenance(for: flow.answers) }

    var body: some View {
        SectionFrame(index: OnboardingStep.goal.rawValue, flow: flow) {
            SectionTitle("What do you", emphasis: "want?", index: OnboardingStep.goal.rawValue, size: 30, stacked: true)
            VStack(spacing: 8) {
                ForEach(FoodGoal.allCases) { goal in
                    ChoiceRow(selected: flow.answers.foodGoal == goal, label: goal.title, height: 56, detail: goal.detail,
                              icon: PaperArt.foodGoal(goal)) { flow.pick(foodGoal: goal) }
                        .penAnchor(.foodGoal(goal))
                }
            }
            .padding(.top, 6)
            .opacity(flow.answers.foodView == .habitsOnly ? 0.35 : 1)
            .allowsHitTesting(flow.answers.foodView == .calories)
            if flow.answers.foodView == .habitsOnly {
                Text("Protein and habits only. No calorie numbers.")
                    .font(SSFont.hand(21)).foregroundStyle(Palette.pen).padding(.top, 10)
            } else if let goal = flow.answers.foodGoal, let maintenance {
                CalorieBars(maintenance: maintenance, goal: goal, kilos: flow.answers.weeklyKilos)
                    .padding(.top, 4)
                    .transition(.opacity)
                if goal != .hold { slider(goal) }
            }
            Spacer(minLength: 0)
            Button(flow.answers.foodView == .habitsOnly ? "Show calories again" : "I'd rather not see calories") {
                flow.pick(foodView: flow.answers.foodView == .habitsOnly ? .calories : .habitsOnly)
            }
            .buttonStyle(.plain)
            .font(SSFont.display(14, weight: 600))
            .foregroundStyle(Palette.ink2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
            PillButton("Make my plan", enabled: flow.answers.canContinue(from: .goal)) { flow.next() }
                .penAnchor(.next(OnboardingStep.goal.rawValue))
        }
        .animation(.snappy(duration: 0.25), value: flow.answers.foodGoal)
    }

    private func slider(_ goal: FoodGoal) -> some View {
        VStack(spacing: 2) {
            HStack {
                Text("\(flow.answers.weeklyKilos.formatted()) kg a week").font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ink)
                Spacer()
            }
            Slider(value: Binding(get: { flow.answers.weeklyKilos }, set: { flow.setWeeklyKilos($0) }),
                   in: FoodGoal.kiloStep...goal.maxWeeklyKilos, step: FoodGoal.kiloStep)
                .tint(Palette.pen)
                .accessibilityLabel("Kilos a week")
        }
    }
}

/// Maintenance beside her target, the gap between them, and the safe floor as a dashed line.
private struct CalorieBars: View {
    let maintenance: Int
    let goal: FoodGoal
    let kilos: Double

    private let low = 1_100.0
    private let high = 2_200.0
    private let height = 175.0

    var body: some View {
        let result = EnergyPlan.target(maintenance: maintenance, goal: goal, weeklyKilos: goal == .hold ? 0 : kilos)
        HStack(alignment: .bottom, spacing: 22) {
            bar(maintenance, label: "maintenance", filled: false)
            bar(result.kcal, label: "your target", filled: true)
            VStack(alignment: .leading, spacing: 3) {
                if result.kcal != maintenance {
                    Text(signed(result.kcal - maintenance)).font(SSFont.display(18)).foregroundStyle(Palette.pen)
                }
                if result.clamped {
                    Text("Kept above \(EnergyPlan.floorKcal.formatted())").font(SSFont.display(12, weight: 600)).foregroundStyle(Palette.pen)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 24)
        }
        .frame(height: height + 52, alignment: .bottom)
        .overlay(alignment: .bottom) { floorLine.padding(.bottom, 24 + y(Double(EnergyPlan.floorKcal))) }
        .animation(.snappy(duration: 0.18), value: result.kcal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Maintenance \(maintenance), target \(result.kcal) calories")
    }

    private func y(_ kcal: Double) -> CGFloat { CGFloat(min(max((kcal - low) / (high - low), 0), 1) * height) }

    private func bar(_ kcal: Int, label: String, filled: Bool) -> some View {
        VStack(spacing: 4) {
            Text(kcal.formatted()).font(SSFont.display(17)).foregroundStyle(Palette.ink)
            RoundedRectangle(cornerRadius: 12)
                .fill(filled ? Palette.ink : .clear)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.ink, lineWidth: filled ? 0 : 2))
                .frame(width: 78, height: y(Double(kcal)))
            Text(label).font(SSFont.display(11, weight: 600)).foregroundStyle(Palette.ink2).frame(height: 20)
        }
    }

    private var floorLine: some View {
        Rectangle().stroke(Palette.pen, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            .frame(height: 1.5)
            .overlay(alignment: .topTrailing) {
                Text("safe floor").font(SSFont.display(10.5, weight: 600)).foregroundStyle(Palette.pen).offset(y: -15)
            }
    }

    private func signed(_ n: Int) -> String { (n > 0 ? "+" : "−") + abs(n).formatted() }
}
