import SwiftUI
import SSCore
import SSDesign

/// The paper sheet over the hero: protein first, calories and steps, the five habits, today's session.
struct TodaySheet: View {
    let model: TodayModel

    private var summary: TodaySummary { model.summary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            protein
            stats.padding(.top, 20)
            Rectangle().fill(Palette.ink.opacity(0.10)).frame(height: 1).padding(.vertical, 16)
            habits
            session.padding(.top, 18)
        }
        .padding(.horizontal, 28)
    }

    private var protein: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(summary.proteinGrams)").font(SSFont.display(60)).tracking(-3.6).foregroundStyle(Palette.ink)
                Text("of \(summary.proteinTarget)g protein").font(SSFont.display(18, weight: 600)).foregroundStyle(Palette.ink2)
            }
            ProgressLine(fraction: summary.proteinFraction)
        }
        .accessibilityElement(children: .combine)
    }

    private var stats: some View {
        HStack(alignment: .top, spacing: 0) {
            if let left = summary.caloriesLeft, let target = summary.calorieTarget {
                stat("Calories left", left.formatted(), "of \(target.formatted())")
                Rectangle().fill(Palette.ink.opacity(0.10)).frame(width: 1, height: 60).padding(.horizontal, 22)
            } else {
                stat("Habits", "\(summary.habitsDone) of 5", "today")
                Rectangle().fill(Palette.ink.opacity(0.10)).frame(width: 1, height: 60).padding(.horizontal, 22)
            }
            stat("Steps", summary.steps.formatted(), "of \(summary.stepTarget.formatted())")
        }
    }

    private func stat(_ label: String, _ value: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            MetaLabel(label)
            Text(value).font(SSFont.display(28)).tracking(-1.1).foregroundStyle(Palette.ink)
            Text(detail).font(SSFont.display(12, weight: 400)).foregroundStyle(Palette.ink2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var habits: some View {
        HStack(spacing: 0) {
            ForEach(Habit.allCases) { habit in
                let on = summary.done.contains(habit)
                Button { model.toggle(habit) } label: {
                    VStack(spacing: 7) {
                        Image(systemName: habit.symbol)
                            .font(.system(size: 19, weight: .regular))
                            .foregroundStyle(on ? Palette.ivory : Palette.ink2)
                            .frame(width: 48, height: 48)
                            .background(on ? Palette.ink : .clear, in: Circle())
                            .overlay(Circle().stroke(on ? Palette.ink : Palette.ink.opacity(0.16), lineWidth: 1.5))
                        Text(habit.title).font(SSFont.display(11, weight: 600)).foregroundStyle(Palette.ink2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(habit.title), \(on ? "done" : "not done")")
                .accessibilityAddTraits(on ? .isSelected : [])
            }
        }
    }

    @ViewBuilder private var session: some View {
        if let session = summary.session {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    MetaLabel("Today · \(session.minutes) min")
                    Text(session.title).font(SSFont.display(22)).tracking(-0.7).foregroundStyle(Palette.ink)
                }
                Spacer()
                Button { model.finishSession() } label: {
                    Text(summary.done.contains(.strength) ? "Done" : "Start").font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ivory)
                        .padding(.horizontal, 26).frame(height: 44)
                        .background(Palette.ink.opacity(summary.done.contains(.strength) ? 0.5 : 1), in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

struct ProgressLine: View {
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Palette.ink.opacity(0.10))
                Capsule().fill(Palette.ink).frame(width: proxy.size.width * fraction)
            }
        }
        .frame(height: 4)
        .animation(.easeOut(duration: 0.6), value: fraction)
    }
}
