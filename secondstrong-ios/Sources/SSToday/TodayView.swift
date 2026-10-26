import SwiftUI
import SSCore
import SSDesign

/// The Today tab: the paper scene runs edge to edge with the coach on its hill and a line from it, and the day sits on a
/// sheet that slides over the scene. Tapping the coach or its line opens the Coach tab (SS-0025).
struct TodayView: View {
    let model: TodayModel
    @State private var mood = CoachMood.hello

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            let heroHeight = max(400, h * 0.5)
            let top = proxy.safeAreaInsets.top
            ZStack(alignment: .topLeading) {
                HeroScene(part: model.part, coach: model.summary.coach, mood: mood, width: w, height: heroHeight,
                          anchor: CGPoint(x: 0.71, y: 0.80), coachSize: min(200, w * 0.5), animated: model.animateCoach)
                Color.clear.frame(width: w * 0.46, height: heroHeight * 0.5)
                    .contentShape(Rectangle())
                    .offset(x: w * 0.48, y: heroHeight * 0.34)
                    .onTapGesture { model.open(.coach) }
                    .accessibilityHidden(true)
                greeting.padding(.top, top + 16).padding(.leading, 28)
                coachLine.padding(.leading, 28).offset(y: heroHeight * 0.46)
                sheet(width: w, top: heroHeight - 50, height: h)
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(for: .seconds(2.6))
            mood = .idle
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            MetaLabel(Date().formatted(Date.FormatStyle().weekday(.wide).day().month(.wide).locale(Locale(identifier: "en_GB"))))
            Text(model.part.greeting.replacingOccurrences(of: "Good ", with: "").capitalized + ",")
                .font(SSFont.display(33)).tracking(-1.3).foregroundStyle(Palette.ink)
            Text(model.summary.name + ".").font(SSFont.hand(40)).foregroundStyle(Palette.ink)
        }
        .accessibilityElement(children: .combine)
    }

    private var coachLine: some View {
        Button { model.open(.coach) } label: {
            VStack(alignment: .leading, spacing: 9) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(model.coachLines, id: \.self) { Text($0).font(SSFont.hand(22)).foregroundStyle(Palette.pen) }
                }
                HStack(spacing: 5) {
                    Text("Ask \(model.summary.coach.name)").font(SSFont.display(12, weight: 700))
                    Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold)).foregroundStyle(Palette.pen)
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 12).frame(height: 27)
                .background(Palette.ivory, in: Capsule())
                .overlay(Capsule().stroke(Palette.ink.opacity(0.10), lineWidth: 1))
            }
            .frame(maxWidth: 170, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(model.coachLines.joined(separator: " ")) Ask \(model.summary.coach.name)")
    }

    private func sheet(width: CGFloat, top: CGFloat, height: CGFloat) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                Capsule().fill(Palette.ink.opacity(0.12)).frame(width: 38, height: 4).padding(.top, 10).padding(.bottom, 18)
                TodaySheet(model: model)
                Color.clear.frame(height: 130)
            }
        }
        .scrollIndicators(.hidden)
        .frame(width: width, height: height - top)
        .background(Palette.ivory, in: UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32))
        .overlay(alignment: .top) { UnevenRoundedRectangle(topLeadingRadius: 32, topTrailingRadius: 32).stroke(Palette.ink.opacity(0.10), lineWidth: 1) }
        .offset(y: top)
    }
}
