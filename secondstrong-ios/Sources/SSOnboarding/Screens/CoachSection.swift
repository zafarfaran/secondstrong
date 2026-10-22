import SwiftUI
import SSCore
import SSDesign

struct CoachSection: View {
    let flow: OnboardingFlow
    @FocusState private var nameFocused: Bool
    @State private var scrolled: Coach?
    @State private var written = 1.0

    private let itemSize: CGFloat = 210
    private let itemHeight: CGFloat = 292

    var body: some View {
        SectionFrame(index: OnboardingStep.coach.rawValue, flow: flow) {
            SectionTitle("Pick your", emphasis: "coach.", index: OnboardingStep.coach.rawValue)
            carousel
            dots
            introduction
            nameField
            Spacer(minLength: 0)
            PillButton("Continue") { flow.next() }.penAnchor(.next(OnboardingStep.coach.rawValue))
        }
    }

    /// The coach says hello and its temperament writes itself out in handwriting, left to right.
    private var introduction: some View {
        Text(flow.answers.coach.temperament)
            .font(SSFont.hand(21))
            .foregroundStyle(Palette.pen)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .mask(alignment: .leading) { Rectangle().scaleEffect(x: max(written, 0.001), anchor: .leading) }
            .onChange(of: flow.answers.coach) { _, _ in write() }
            .accessibilityLabel(flow.answers.coach.temperament)
    }

    private func write() {
        written = 0
        guard !flow.reduceMotion else { written = 1; return }
        withAnimation(.linear(duration: 1.3).delay(0.3)) { written = 1 }
    }

    /// Coaches in a row you swipe through. The one in the middle is the choice; its neighbours
    /// peek in at the sides and shrink away. Tap a neighbour to bring it in.
    private var carousel: some View {
        let edge = (flow.screen.width - itemSize) / 2
        return ScrollView(.horizontal) {
            HStack(spacing: -44) {
                ForEach(Coach.allCases) { coach in
                    item(coach)
                        .frame(width: itemSize, height: itemHeight, alignment: .bottom)
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - min(abs(phase.value), 1.4) * 0.3, anchor: .bottom)
                                .opacity(1 - min(abs(phase.value), 1.4) * 0.5)
                                .offset(y: min(abs(phase.value), 1.4) * 8)
                        }
                        .id(coach)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolled, anchor: .center)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .contentMargins(.horizontal, edge, for: .scrollContent)
        .frame(width: flow.screen.width, height: itemHeight + 8)
        .background(alignment: .bottom) {
            // One platform for everyone: the coaches slide across it, it never moves.
            PaperArt.plinth.resizable().scaledToFit()
                .frame(width: itemSize * 0.96)
                .padding(.bottom, 4)
                .opacity(flow.companionState != .hidden ? 0 : 1)
                .animation(.easeOut(duration: 0.4), value: flow.companionState)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .top) { Color.clear.frame(width: itemSize, height: itemSize).penAnchor(.coachShow).allowsHitTesting(false) }
        .padding(.leading, -34)
        .padding(.trailing, -22)
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            scrolled = flow.answers.coach
        }
        .onChange(of: scrolled) { _, coach in
            if let coach, coach != flow.answers.coach { flow.pick(coach: coach) }
        }
        .onChange(of: flow.answers.coach) { _, coach in
            if scrolled != coach { withAnimation(.snappy) { scrolled = coach } }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Coach: \(flow.answers.coach.name)")
        .accessibilityAdjustableAction { direction in
            let all = Coach.allCases
            let i = all.firstIndex(of: flow.answers.coach) ?? 0
            let next = direction == .increment ? min(i + 1, all.count - 1) : max(i - 1, 0)
            flow.pick(coach: all[next])
        }
    }

    /// Every coach is drawn the same way. The chosen one stands on the platform and comes alive:
    /// choosing swaps nothing, it only starts the clip and gives the coach a small hop onto it.
    @ViewBuilder private func item(_ coach: Coach) -> some View {
        let selected = coach == flow.answers.coach
        let hidden = selected && flow.companionState != .hidden
        ZStack(alignment: .bottom) {
            CoachView(coach, mood: selected ? flow.showMood : .idle,
                      animated: selected && flow.companionState == .hidden && flow.step <= OnboardingStep.coach.rawValue)
                .id(coach)
                .frame(width: itemSize, height: itemSize)
                .scaleEffect(selected ? 1 : 0.94, anchor: .bottom)
                .offset(y: selected ? 0 : 6)
                .animation(.spring(duration: 0.55, bounce: 0.45), value: selected)
                .frame(maxHeight: .infinity, alignment: .top)
                .opacity(hidden ? 0 : 1)
        }
        .frame(width: itemSize, height: itemHeight, alignment: .bottom)
        .contentShape(Rectangle())
        .onTapGesture {
            if selected { flow.poke() } else { withAnimation(.snappy(duration: 0.45)) { scrolled = coach } }
        }
    }

    private var dots: some View {
        HStack(spacing: 7) {
            ForEach(Coach.allCases) { coach in
                Capsule()
                    .fill(coach == flow.answers.coach ? Palette.ink : Palette.ink.opacity(0.2))
                    .frame(width: coach == flow.answers.coach ? 20 : 7, height: 7)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(duration: 0.4, bounce: 0.3), value: flow.answers.coach)
        .accessibilityHidden(true)
    }

    private var nameField: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("NAME").font(SSFont.display(11, weight: 600)).tracking(0.88).foregroundStyle(Palette.ink2)
            TextField("", text: Binding(get: { flow.answers.name }, set: { flow.answers.rename($0) }))
                .textFieldStyle(.plain)
                .font(SSFont.display(24))
                .tracking(-0.48)
                .foregroundStyle(Palette.ink)
                .autocorrectionDisabled()
                .focused($nameFocused)
                .penAnchor(.nameField)
                .accessibilityLabel("Coach name")
        }
        .padding(.top, 4)
        .padding(.bottom, 6)
        .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink).frame(height: 1.5) }
        .onChange(of: nameFocused) { _, focused in
            if focused { flow.pulseShow(.listening, for: 30) } else { flow.pulseShow(.idle, for: 0) }
        }
    }
}
