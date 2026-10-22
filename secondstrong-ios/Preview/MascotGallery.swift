import SwiftUI
import SSCore
import SSDesign

/// Pick a coach and a state to watch its clips play.
struct MascotGallery: View {
    @State private var coach = Coach.bramble
    @State private var mood = CoachMood.hello
    @State private var cycling = false
    private let timer = Timer.publish(every: 3.2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                ForEach(Coach.allCases) { c in
                    Button { coach = c } label: {
                        c.image.resizable().scaledToFit().padding(3).frame(width: 52, height: 52)
                            .background(Palette.card, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(c == coach ? Palette.ink : Palette.edge, lineWidth: c == coach ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            CoachView(coach, mood: mood)
                .id(coach)
                .frame(width: 300, height: 300)
            VStack(spacing: 4) {
                Text(coach.name).font(SSFont.display(26)).foregroundStyle(Palette.ink)
                Text(coach.temperament).font(SSFont.display(14, weight: 400)).foregroundStyle(Palette.ink2)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(CoachMood.allCases, id: \.self) { m in
                    Button { mood = m; cycling = false } label: {
                        Text(m.rawValue)
                            .font(SSFont.display(14, weight: 600))
                            .foregroundStyle(m == mood ? Palette.ivory : Palette.ink)
                            .frame(maxWidth: .infinity).frame(height: 38)
                            .background(m == mood ? Palette.ink : .clear, in: Capsule())
                            .overlay(Capsule().stroke(Palette.ink.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            Toggle("Cycle through the moods", isOn: $cycling).toggleStyle(.switch).font(SSFont.display(14, weight: 400))
        }
        .padding(24)
        .frame(width: 460, height: 780)
        .background(PaperBackground())
        .onReceive(timer) { _ in
            guard cycling else { return }
            let all = CoachMood.allCases
            mood = all[((all.firstIndex(of: mood) ?? 0) + 1) % all.count]
        }
    }
}
