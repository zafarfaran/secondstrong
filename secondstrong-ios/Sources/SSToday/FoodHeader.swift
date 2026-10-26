import SwiftUI
import SSCore
import SSDesign

/// A week of days under the title, each ringed by how close she got to her protein; today is a dark pill (SS-0032).
struct WeekStripView: View {
    let days: [WeekDay]
    @State private var shown = false

    var body: some View {
        HStack {
            ForEach(Array(days.enumerated()), id: \.offset) { i, day in
                VStack(spacing: 7) {
                    Text(day.initial).font(SSFont.display(11, weight: 700)).tracking(0.4)
                        .foregroundStyle(day.isToday ? Palette.ink : Palette.ink2)
                    ZStack {
                        if day.isToday {
                            Circle().fill(Palette.ink)
                        } else {
                            Circle().stroke(Palette.ink.opacity(0.08), lineWidth: 3)
                            Circle().trim(from: 0, to: shown ? day.fraction : 0).stroke(Palette.ink2, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                                .animation(.easeOut(duration: 0.8).delay(0.05 * Double(i)), value: shown)
                        }
                        Text("\(day.dayOfMonth)").font(SSFont.display(14.5, weight: 700)).foregroundStyle(day.isToday ? Palette.ivory : Palette.ink)
                    }
                    .frame(width: 40, height: 40)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { shown = true }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("This week")
    }
}

/// One card: the protein ring, what is left in Miso's hand, and calories only when she has them on.
struct FoodSummaryCard: View {
    let protein: Int
    let target: Int
    let meals: Int
    let calories: (eaten: Int, target: Int)?
    @State private var shown = false

    private var fraction: Double { target > 0 ? Double(protein) / Double(target) : 0 }

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle().stroke(Palette.ink.opacity(0.08), lineWidth: 9)
                Circle().trim(from: 0, to: shown ? min(1, fraction) : 0).stroke(Palette.pen, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0), value: shown)
                    .animation(.easeOut(duration: 0.8), value: protein)
                VStack(spacing: 0) {
                    Text("\(protein)").font(SSFont.display(30)).tracking(-1.2).foregroundStyle(Palette.ink)
                        .contentTransition(.numericText()).animation(.easeOut(duration: 0.6), value: protein)
                    Text("of \(target)g").font(SSFont.display(11, weight: 600)).foregroundStyle(Palette.ink2)
                }
            }
            .frame(width: 96, height: 96)
            VStack(alignment: .leading, spacing: 6) {
                Text(protein >= target ? "Goal done" : "\(target - protein)g to go").font(SSFont.hand(26)).foregroundStyle(Palette.pen)
                if let calories {
                    Text("\(calories.eaten) of \(calories.target) kcal").font(SSFont.display(13, weight: 600)).foregroundStyle(Palette.ink2)
                }
                Text("\(meals) \(meals == 1 ? "meal" : "meals") logged").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20).padding(.vertical, 18)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 28))
        .onAppear { shown = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(protein) of \(target) grams of protein")
    }
}
