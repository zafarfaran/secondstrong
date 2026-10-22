import SwiftUI
import SSDesign

/// The onboarding flow: one continuous pen line from welcome to the first-week plan.
public struct OnboardingView: View {
    @State private var run = 0

    public init() {}

    public var body: some View {
        OnboardingRun { run += 1 }.id(run)
    }
}

struct OnboardingRun: View {
    let onRestart: () -> Void
    @State private var flow: OnboardingFlow
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(flow: OnboardingFlow = OnboardingFlow(), onRestart: @escaping () -> Void) {
        _flow = State(initialValue: flow)
        self.onRestart = onRestart
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                PaperBackground()
                OnboardingDocument(flow: flow)
                topBar(safeTop: proxy.safeAreaInsets.top)
                companion
                ending
                gate
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .clipped()
            .task {
                flow.reduceMotion = reduceMotion
                await flow.start(size: proxy.size, safeArea: proxy.safeAreaInsets)
            }
            .onDisappear { flow.stop() }
            .animation(.easeInOut(duration: 0.5), value: flow.signedIn)
            .sensoryFeedback(.selection, trigger: flow.answers.coach)
            .sensoryFeedback(.selection, trigger: flow.answers.stage)
            .sensoryFeedback(.selection, trigger: flow.answers.goals)
            .sensoryFeedback(.selection, trigger: flow.answers.days)
            .sensoryFeedback(.warning, trigger: flow.shakeTicks)
            .sensoryFeedback(.impact(weight: .light), trigger: flow.step)
            .sensoryFeedback(.success, trigger: flow.startReady)
        }
        .ignoresSafeArea()
    }

    private func topBar(safeTop: CGFloat) -> some View {
        let visible = flow.step > 0 && flow.step < OnboardingFlow.lastStep && flow.stepValue != .building && !flow.ended
        return HStack {
            Button { flow.back() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")
            .opacity(visible ? 1 : 0)
            .allowsHitTesting(visible)
            Spacer()
        }
        .padding(.leading, 12)
        .padding(.top, safeTop + 6)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(alignment: .top) {
            LinearGradient(colors: [Palette.ivory, Palette.ivory.opacity(0)], startPoint: UnitPoint(x: 0.5, y: 0.6), endPoint: .bottom)
                .frame(height: safeTop + 60)
                .allowsHitTesting(false)
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder private var companion: some View {
        if flow.companionState != .hidden {
            CoachView(flow.answers.coach, mood: flow.companionMood)
                .frame(width: OnboardingFlow.showcaseSize, height: OnboardingFlow.showcaseSize)
                .scaleEffect(flow.companionScale)
                .position(flow.companionCentre)
                .opacity(flow.ended || flow.stepValue == .building ? 0 : 1)
                .animation(.easeOut(duration: 0.38), value: flow.ended)
                .animation(.easeInOut(duration: 0.5), value: flow.stepValue == .building)
                .allowsHitTesting(!flow.ended)
                .onTapGesture { flow.poke() }
        }
    }

    @ViewBuilder private var gate: some View {
        if !flow.signedIn {
            AuthGate(flow: flow).transition(.opacity)
        }
        if flow.welcomedBack {
            VStack(spacing: 14) {
                Text("Welcome back.").font(SSFont.hand(36)).foregroundStyle(Palette.ink)
                Text("This is where the app would open.").font(SSFont.display(15, weight: 400)).foregroundStyle(Palette.ink2)
                Button("Start again", action: onRestart)
                    .buttonStyle(.plain)
                    .font(SSFont.display(15, weight: 600))
                    .foregroundStyle(Palette.ivory)
                    .padding(.horizontal, 20).frame(height: 44)
                    .background(Palette.ink, in: Capsule())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PaperBackground())
            .transition(.opacity)
        }
    }

    @ViewBuilder private var ending: some View {
        if flow.endVisible {
            VStack(spacing: 10) {
                Text("Your first week, on one line.")
                    .font(SSFont.hand(22))
                    .foregroundStyle(Palette.pen)
                Button(action: onRestart) {
                    Text("Play again")
                        .font(SSFont.display(15, weight: 600))
                        .foregroundStyle(Palette.ivory)
                        .padding(.horizontal, 20)
                        .frame(height: 44)
                        .background(Palette.ink, in: Capsule())
                }
                .buttonStyle(PressScaleStyle(pressed: 0.97))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 22 + flow.safeBottom)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}
