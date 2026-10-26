import SwiftUI
import SSCore
import SSDesign

struct PlanSection: View {
    let flow: OnboardingFlow

    private var today: String {
        Date().formatted(Date.FormatStyle().weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_GB")))
    }

    var body: some View {
        SectionFrame(index: OnboardingStep.plan.rawValue, flow: flow, scene: .plan) {
            MetaLabel(today)
            SectionTitle("Begin your", emphasis: "program.", index: OnboardingStep.plan.rawValue, size: 32)
            hero.padding(.top, 8)
            Color.clear.frame(height: 14).penAnchor(.bar)
            weekRow
            if flow.plan.showsGPNote {
                Text("Check with your GP first.").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
                    .padding(.top, 6)
            }
            note.padding(.top, 8)
            Spacer(minLength: 0)
            startButton
        }
    }

    /// The calorie ring with protein beside it. Without calories (her choice, or the safety branch) protein stands alone.
    private var hero: some View {
        HStack(alignment: .center, spacing: 20) {
            if let energy = flow.plan.energy { ring(energy) }
            VStack(alignment: .leading, spacing: 2) {
                (Text("\(flow.plan.proteinGrams)").font(SSFont.display(flow.plan.energy == nil ? 64 : 50)).tracking(-2.4)
                    + Text("g").font(SSFont.display(20)).tracking(-1))
                    .foregroundStyle(Palette.ink)
                    .penAnchor(.pnum)
                MetaLabel("protein")
            }
            .opacity(flow.proteinLit ? 1 : 0.18)
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func ring(_ energy: EnergyPlan) -> some View {
        ZStack {
            Circle().stroke(Palette.ink.opacity(0.12), lineWidth: 13)
            Circle().trim(from: 0, to: flow.proteinLit ? 1 : 0)
                .stroke(Palette.ink, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.1), value: flow.proteinLit)
            VStack(spacing: 0) {
                Text(energy.target.formatted()).font(SSFont.display(30)).tracking(-1.2).foregroundStyle(Palette.ink)
                MetaLabel("kcal a day")
            }
        }
        .frame(width: 148, height: 148)
        .accessibilityElement(children: .combine)
    }

    private var weekRow: some View {
        HStack(spacing: 0) {
            ForEach(Weekday.allCases) { day in
                let on = flow.answers.days.contains(day)
                VStack(spacing: 10) {
                    Text(day.initial)
                        .font(SSFont.display(11, weight: 600))
                        .foregroundStyle(on ? Palette.ink : Palette.ink2)
                    Circle()
                        .fill(on ? Palette.ink : .clear)
                        .frame(width: 14, height: 14)
                        .penAnchor(.dot(day))
                        .scaleEffect(flow.shownDots.contains(day) ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(on ? "\(day.short), training day" : day.short)
            }
        }
        .penAnchor(.wk2)
    }

    /// The note takes at most 88% of the line, like the prototype, and wraps inside that.
    private var note: some View {
        HStack(spacing: 0) {
            Text(flow.noteText)
                .font(SSFont.hand(22))
                .foregroundStyle(Palette.pen)
                .fixedSize(horizontal: false, vertical: true)
                .penAnchor(.note)
                .mask(alignment: .leading) {
                    Rectangle().scaleEffect(x: max(flow.noteProgress, 0.001), anchor: .leading)
                }
            Spacer(minLength: (flow.screen.width - 56) * 0.12)
        }
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .topLeading)
    }

    private var startButton: some View {
        Button { flow.next() } label: {
            Text("Begin")
                .font(SSFont.display(16.5, weight: 600))
                .foregroundStyle(flow.startReady ? Palette.ivory : Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(flow.startReady ? Palette.ink : .clear, in: Capsule())
                .opacity(flow.startReady ? 1 : 0.3)
        }
        .buttonStyle(PressScaleStyle(pressed: 0.97))
        .disabled(!flow.startReady)
        .penAnchor(.start)
            .penAnchor(.next(OnboardingStep.plan.rawValue))
    }
}
