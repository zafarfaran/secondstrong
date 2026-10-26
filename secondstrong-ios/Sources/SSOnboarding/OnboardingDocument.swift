import SwiftUI
import SSCore

/// All six pages stacked into one tall document with the ink laid over it.
/// A vertical offset is the camera.
struct OnboardingDocument: View {
    let flow: OnboardingFlow

    var body: some View {
        let size = flow.screen
        let total = size.height * CGFloat(OnboardingFlow.lastStep + 1)
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                page(.welcome) { WelcomeSection(flow: flow) }
                page(.consent) { ConsentSection(flow: flow) }
                page(.coach) { CoachSection(flow: flow) }
                page(.stage) { StageSection(flow: flow) }
                page(.goals) { GoalsSection(flow: flow) }
                page(.birth) { BirthSection(flow: flow) }
                page(.safety) { SafetySection(flow: flow) }
                page(.body) { BodySection(flow: flow) }
                page(.training) { TrainingSection(flow: flow) }
                page(.days) { DaysSection(flow: flow) }
                page(.activity) { ActivitySection(flow: flow) }
                page(.goal) { FoodGoalSection(flow: flow) }
                page(.building) { BuildingSection(flow: flow) }
                page(.plan) { PlanSection(flow: flow) }
                page(.paywall) { PaywallSection(flow: flow) }
                page(.invite) { InviteSection(flow: flow) }
            }
            InkLayer(strokes: flow.strokes, lineWidth: 2.4)
                .frame(width: size.width, height: total, alignment: .topLeading)
        }
        .frame(width: size.width, height: total, alignment: .topLeading)
        .coordinateSpace(.named(PenSpace.name))
        .onPreferenceChange(PenFrames.self) { frames in
            MainActor.assumeIsolated { flow.frames = frames }
        }
        // SS-0020: keep this no-op scale; without it the tall ink layer stops drawing the pen line
        .scaleEffect(1, anchor: .topLeading)
        .offset(y: flow.cameraY)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    /// Pages fade as the camera carries them away, so a move reads as one motion, not a cut.
    private func page(_ step: OnboardingStep, @ViewBuilder _ content: () -> some View) -> some View {
        let index = step.rawValue
        let away = abs(CGFloat(index) * flow.screen.height + flow.cameraY) / flow.screen.height
        return content().opacity(1 - min(away, 1))
    }
}
