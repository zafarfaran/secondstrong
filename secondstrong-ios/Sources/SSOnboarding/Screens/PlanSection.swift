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
            SectionTitle("Your first", emphasis: "week.", index: OnboardingStep.plan.rawValue)
            protein
            Color.clear.frame(height: 14).penAnchor(.bar)
            weekRow
            Color.clear.frame(height: 8)
            reminders
            note
            Spacer(minLength: 0)
            startButton
        }
    }

    /// Her own words, then anything the safety screen asked us to say. Kept short to fit above the note.
    private var reminders: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let words = flow.plan.intention {
                Text("You said: \u{201C}\(words)\u{201D}")
                    .font(SSFont.hand(19))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(2)
            }
            if flow.plan.calorieFree {
                Text("No calorie counting. Just protein and habits.").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
            }
            if flow.plan.showsGPNote {
                Text("Check with your GP before you start.").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
            }
            Text(flow.plan.trainingLine).font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(flow.proteinLit ? 1 : 0.18)
    }

    private var protein: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            (Text("\(flow.plan.proteinGrams)").font(SSFont.display(64)).tracking(-3.2)
                + Text("g").font(SSFont.display(24)).tracking(-1.2))
                .foregroundStyle(Palette.ink)
                .frame(height: 64 * 0.9)
                .penAnchor(.pnum)
            MetaLabel("protein a day")
        }
        .opacity(flow.proteinLit ? 1 : 0.18)
        .padding(.top, 6)
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
        Button { flow.finish() } label: {
            Text("Start my week")
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
    }
}
