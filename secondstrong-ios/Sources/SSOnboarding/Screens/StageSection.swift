import SwiftUI
import SSCore
import SSDesign

struct StageSection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.stage.rawValue, flow: flow) {
            SectionTitle("Where are", emphasis: "you?", index: OnboardingStep.stage.rawValue)
            Color.clear.frame(height: 2)
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow { tile(.peri); tile(.meno) }
                GridRow { tile(.post); tile(.surg) }
                GridRow { wideTile(.unsure).gridCellColumns(2) }
            }
            Text(flow.answers.stage?.acknowledgement ?? " ")
                .font(SSFont.hand(21))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .topLeading)
                .id(flow.answers.stage)
                .transition(.opacity)
                .animation(.easeOut(duration: 0.3), value: flow.answers.stage)
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .stage)) { flow.next() }
                .penAnchor(.next(OnboardingStep.stage.rawValue))
        }
    }

    private func tile(_ stage: Stage) -> some View {
        SketchTile(selected: flow.answers.stage == stage, label: stage.title, action: { flow.pick(stage: stage) }) {
            VStack(spacing: 6) {
                glyph(stage).frame(width: 64, height: 56)
                TileLabel(text: stage.title)
            }
        }
        .penAnchor(.stage(stage))
    }

    private func wideTile(_ stage: Stage) -> some View {
        SketchTile(selected: flow.answers.stage == stage, label: stage.title, action: { flow.pick(stage: stage) }) {
            HStack(spacing: 6) {
                glyph(stage).frame(width: 56, height: 46)
                TileLabel(text: stage.title)
            }
        }
        .penAnchor(.stage(stage))
    }

    private func glyph(_ stage: Stage) -> some View {
        PaperArt.stage(stage).resizable().scaledToFit()
            .opacity(flow.step >= OnboardingStep.stage.rawValue ? 1 : 0)
            .animation(.easeOut(duration: 0.8), value: flow.step)
    }
}
