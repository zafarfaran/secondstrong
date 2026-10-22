import SwiftUI
import SSCore

/// All six pages stacked into one tall document with the ink laid over it.
/// A vertical offset is the camera; the ending scales the whole page to fit.
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
                page(.building) { BuildingSection(flow: flow) }
                page(.plan) { PlanSection(flow: flow) }
            }
            InkLayer(strokes: flow.strokes, lineWidth: flow.ended ? 3.2 / flow.overviewScale : 2.4)
                .frame(width: size.width, height: total, alignment: .topLeading)
        }
        .frame(width: size.width, height: total, alignment: .topLeading)
        .coordinateSpace(.named(PenSpace.name))
        .onPreferenceChange(PenFrames.self) { frames in
            MainActor.assumeIsolated { flow.frames = frames }
        }
        .scaleEffect(flow.ended ? flow.overviewScale : 1, anchor: .topLeading)
        .offset(
            x: flow.ended ? (size.width - size.width * flow.overviewScale) / 2 : 0,
            y: flow.ended ? 30 : flow.cameraY)
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    /// Pages fade as the camera carries them away, so a move reads as one motion, not a cut.
    private func page(_ step: OnboardingStep, @ViewBuilder _ content: () -> some View) -> some View {
        let index = step.rawValue
        let away = abs(CGFloat(index) * flow.screen.height + flow.cameraY) / flow.screen.height
        return content().opacity(flow.ended ? 1 : 1 - min(away, 1))
    }
}
