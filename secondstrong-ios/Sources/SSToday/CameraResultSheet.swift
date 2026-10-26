import SwiftUI
import SSCore
import SSDesign

/// What the coach read from the photo, all of it changeable: the name, what was spotted, the portion. An estimate, never a verdict (SS-0032).
struct CameraResultSheet: View {
    let model: TodayModel
    @Bindable var flow: CameraFlow

    private var minute: Int { min(model.minuteOfDay, 24 * 60 - 1) }
    private var slot: String { FoodDiary.slotName(minute: minute) }
    private var showsCalories: Bool { model.summary.calorieTarget != nil }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 110)
            VStack(alignment: .leading, spacing: 14) {
                Capsule().fill(Palette.ink.opacity(0.12)).frame(width: 40, height: 5).frame(maxWidth: .infinity)
                MetaLabel("\(slot) · \(FoodDiary.clock(minute: minute))")
                TextField("What was it?", text: $flow.name, axis: .vertical).textFieldStyle(.plain).font(SSFont.display(23)).tracking(-0.7).foregroundStyle(Palette.ink)
                    .lineLimit(1...2)
                coachNote
                WrapLayout(spacing: 6) {
                    ForEach(flow.base.items, id: \.self) { item in
                        let off = flow.removed.contains(item)
                        Button { flow.toggle(item) } label: {
                            HStack(spacing: 6) {
                                Text(item).strikethrough(off)
                                Image(systemName: off ? "plus" : "xmark").font(.system(size: 9, weight: .heavy)).foregroundStyle(Palette.ink2)
                            }
                            .font(SSFont.display(13, weight: 700)).foregroundStyle(off ? Palette.ink2 : Palette.ink)
                            .padding(.horizontal, 12).padding(.vertical, 7).background(Palette.card, in: Capsule())
                        }
                        .buttonStyle(.plain).accessibilityLabel(off ? "Put \(item) back" : "Take \(item) off")
                    }
                }
                portion
                numbers
                Button { model.addFromCamera(flow.estimate) } label: {
                    Text("Add to \(slot)").font(SSFont.display(16, weight: 700)).foregroundStyle(Palette.ivory)
                        .frame(maxWidth: .infinity).frame(height: 54).background(Palette.ink, in: Capsule())
                }
                .buttonStyle(.plain)
                Text("An estimate, not exact. Change anything that looks off.").font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 22).padding(.top, 12).padding(.bottom, 30)
            .background(Palette.ivory, in: UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
        }
    }

    private var coachNote: some View {
        HStack(spacing: 12) {
            CoachAvatar(coach: model.summary.coach, part: model.part, size: 44, animated: model.animateCoach)
            VStack(alignment: .leading, spacing: 1) {
                Text(model.summary.coach.name).font(SSFont.hand(21)).foregroundStyle(Palette.pen)
                Text("Here is what I can see. Take off anything that is not there.").font(SSFont.display(14, weight: 400)).foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var portion: some View {
        HStack {
            Text("Portion").font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ink)
            Spacer()
            HStack(spacing: 4) {
                ForEach(Portion.allCases, id: \.self) { p in
                    Button { withAnimation(.snappy(duration: 0.2)) { flow.portion = p } } label: {
                        Text(p.title).font(SSFont.display(14, weight: 700)).foregroundStyle(flow.portion == p ? Palette.ivory : Palette.ink2)
                            .padding(.horizontal, 14).padding(.vertical, 9).background(flow.portion == p ? Palette.ink : Color.clear, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4).background(Palette.card, in: Capsule())
        }
    }

    private var numbers: some View {
        HStack(spacing: 10) {
            box("Protein", "\(flow.estimate.proteinGrams)g")
            if showsCalories { box("Calories", "\(flow.estimate.calories)") }
        }
    }

    private func box(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            MetaLabel(title)
            Text(value).font(SSFont.display(28)).tracking(-1).foregroundStyle(Palette.ink).contentTransition(.numericText())
        }
        .animation(.easeOut(duration: 0.25), value: value)
        .padding(.horizontal, 14).padding(.vertical, 12).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// Chips that wrap onto new lines.
struct WrapLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? 320).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(subviews, width: bounds.width)
        for (i, origin) in result.origins.enumerated() { subviews[i].place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified) }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> (size: CGSize, origins: [CGPoint]) {
        var x: CGFloat = 0, y: CGFloat = 0, row: CGFloat = 0
        var origins: [CGPoint] = []
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += row + spacing; row = 0 }
            origins.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            row = max(row, size.height)
        }
        return (CGSize(width: width, height: y + row), origins)
    }
}
