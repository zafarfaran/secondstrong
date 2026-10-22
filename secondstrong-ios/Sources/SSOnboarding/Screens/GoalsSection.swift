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
            FlowLayout(spacing: 8, lineSpacing: 8) {
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
            .padding(.top, 10)
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
                PaperArt.goal(goal).resizable().scaledToFit().frame(width: 30, height: 30)
                Text(goal.title)
                    .font(SSFont.display(14.5, weight: 600))
                    .foregroundStyle(on ? Palette.ivory : Palette.ink)
            }
            .padding(.leading, 8)
            .padding(.trailing, 14)
            .frame(height: 44)
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

/// Chips that wrap onto new lines.
struct FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews)
        return CGSize(width: proposal.width ?? rows.map(\.width).max() ?? 0, height: rows.reduce(0) { $0 + $1.height } + lineSpacing * CGFloat(max(rows.count - 1, 0)))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + lineSpacing
        }
    }

    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, _ subviews: Subviews) -> [Row] {
        var rows = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let needed = rows[rows.count - 1].indices.isEmpty ? size.width : size.width + spacing
            if rows[rows.count - 1].width + needed > width, !rows[rows.count - 1].indices.isEmpty { rows.append(Row()) }
            let last = rows.count - 1
            rows[last].width += rows[last].indices.isEmpty ? size.width : size.width + spacing
            rows[last].height = max(rows[last].height, size.height)
            rows[last].indices.append(index)
        }
        return rows
    }
}
