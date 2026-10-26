import SwiftUI
import SSCore
import SSDesign

/// The Food tab: the week, one summary card, then the day down a line with Miso's note and what comes next (SS-0032).
struct FoodView: View {
    let model: TodayModel

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MetaLabel(Date().formatted(Date.FormatStyle().weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_GB"))))
                    Text("Food").font(SSFont.display(34)).tracking(-1.4).foregroundStyle(Palette.ink).padding(.top, 2)
                    WeekStripView(days: WeekStrip.days(today: Date(), todayFraction: fraction)).padding(.top, 30)
                    FoodSummaryCard(protein: model.diary.protein, target: model.summary.proteinTarget, meals: model.diary.entries.count,
                                    calories: model.summary.calorieTarget.map { (model.diary.calories, $0) })
                        .padding(.top, 16)
                    timeline.padding(.top, 22)
                }
                .padding(.horizontal, 22).padding(.top, proxy.safeAreaInsets.top + 14).padding(.bottom, 190)
            }
            .scrollIndicators(.hidden)
            addButton.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding(.trailing, 22).padding(.bottom, max(proxy.safeAreaInsets.bottom - 4, 16) + 78)
        }
        .ignoresSafeArea()
    }

    private var fraction: Double { Double(model.diary.protein) / Double(max(1, model.summary.proteinTarget)) }
    private var showsCalories: Bool { model.summary.calorieTarget != nil }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(model.diary.entries) { entry in
                row(time: FoodDiary.clock(minute: entry.minute), solid: true) {
                    HStack(spacing: 14) {
                        PlateView(kind: entry.plate, size: 56)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.name).font(SSFont.display(15.5, weight: 700)).foregroundStyle(Palette.ink).lineLimit(3).fixedSize(horizontal: false, vertical: true)
                            if showsCalories { Text("\(entry.calories) kcal").font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2) }
                        }
                        Spacer(minLength: 6)
                        Text("\(entry.proteinGrams)g").font(SSFont.display(13.5, weight: 800)).foregroundStyle(Palette.ink)
                            .padding(.horizontal, 11).padding(.vertical, 6).background(Palette.ivory, in: Capsule())
                    }
                    .padding(12).background(Palette.card, in: RoundedRectangle(cornerRadius: 24))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            note.padding(.leading, 60).padding(.top, 6).padding(.bottom, 22).padding(.trailing, 8)
            if let next = FoodDiary.next(afterMinute: model.diary.lastMinute) {
                row(time: String(next.around.split(separator: " ")[0]), solid: false) {
                    Button { model.openCamera() } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus").font(.system(size: 16, weight: .semibold))
                            Text("\(next.title), around \(next.around)").font(SSFont.display(14.5, weight: 700))
                            Spacer()
                        }
                        .foregroundStyle(Palette.ink2).padding(14)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.ink2, style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.spring(duration: 0.4, bounce: 0.25), value: model.diary.entries.count)
    }

    private var note: some View {
        HStack(alignment: .center, spacing: 14) {
            CoachAvatar(coach: model.summary.coach, part: model.part, size: 50, animated: model.animateCoach)
            VStack(alignment: .leading, spacing: 4) {
                Text(model.summary.coach.name).font(SSFont.hand(21)).foregroundStyle(Palette.pen)
                Text(FoodDiary.note(protein: model.diary.protein, target: model.summary.proteinTarget, afterMinute: model.diary.lastMinute))
                    .font(SSFont.display(14.5, weight: 400)).foregroundStyle(Palette.ink).fixedSize(horizontal: false, vertical: true)
            }
        }
        .id(model.diary.protein)
        .transition(.opacity)
    }

    /// A line of the timeline: the time on the left, a dot on the line, the content on the right.
    private func row<Content: View>(time: String, solid: Bool, @ViewBuilder _ content: () -> Content) -> some View {
        HStack(alignment: .top, spacing: 0) {
            Text(time).font(SSFont.display(12, weight: 700)).foregroundStyle(Palette.ink2).frame(width: 36, alignment: .trailing).padding(.top, 24)
            ZStack(alignment: .top) {
                Rectangle().fill(Palette.ink.opacity(0.10)).frame(width: 2)
                Circle().fill(Palette.ivory).overlay(Circle().stroke(solid ? Palette.pen : Palette.ink2, lineWidth: 2.5))
                    .frame(width: 10, height: 10).padding(.top, 25)
            }
            .frame(width: 18)
            content().padding(.leading, 6).padding(.bottom, 12)
        }
    }

    private var addButton: some View {
        Button { model.openCamera() } label: {
            Image(systemName: "plus").font(.system(size: 22, weight: .semibold)).foregroundStyle(Palette.ivory)
                .frame(width: 56, height: 56).background(Palette.ink, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a meal")
    }
}
