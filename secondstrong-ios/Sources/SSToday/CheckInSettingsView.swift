import SwiftUI
import SSCore
import SSDesign

/// How the coach reaches out: which check-ins, quiet hours and a daily cap. Off or gentle by default (SS-0026).
struct CheckInSettingsView: View {
    let model: TodayModel

    var body: some View {
        @Bindable var model = model
        return ZStack(alignment: .topLeading) {
            PaperBackground()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    MetaLabel("Check-ins")
                    Spacer()
                    Button("Done") { model.showCheckIns = false }.buttonStyle(.plain)
                        .font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ink)
                }
                Text("When \(model.summary.coach.name)").font(SSFont.display(30)).tracking(-1.2).foregroundStyle(Palette.ink).padding(.top, 6)
                Text("writes first.").font(SSFont.hand(37)).foregroundStyle(Palette.ink)
                preview.padding(.top, 18)
                row("Morning plan", "One note when your day starts", $model.settings.morning)
                row("Protein check", "Only if you're a way off, around lunch", $model.settings.midday)
                row("A thread to follow up", "Asks once how something went", $model.settings.followUp)
                row("After your session", "A few words once you finish", $model.settings.afterSession)
                row("Wind down", "A gentle nudge towards sleep", $model.settings.evening)
                HStack {
                    Text("Quiet hours").font(SSFont.display(16, weight: 700))
                    Spacer()
                    Text("\(hour(model.settings.quietFrom)) to \(hour(model.settings.quietTo))").font(SSFont.display(15, weight: 600)).foregroundStyle(Palette.ink2)
                }
                .padding(.vertical, 13)
                HStack {
                    Text("At most").font(SSFont.display(16, weight: 700))
                    Spacer()
                    ForEach(1...3, id: \.self) { n in
                        Button { model.settings.dailyCap = n } label: {
                            Text("\(n)").font(SSFont.display(14, weight: 700))
                                .foregroundStyle(model.settings.dailyCap == n ? Palette.ivory : Palette.ink)
                                .frame(width: 38, height: 34)
                                .background(model.settings.dailyCap == n ? Palette.ink : .clear, in: Capsule())
                                .overlay(Capsule().stroke(Palette.ink.opacity(model.settings.dailyCap == n ? 0 : 0.16), lineWidth: 1.5))
                        }
                        .buttonStyle(.plain)
                    }
                    Text("a day").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
                }
                Text("\(model.summary.coach.name) never nags about weight or calories.").font(SSFont.hand(20)).foregroundStyle(Palette.pen).padding(.top, 10)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24).padding(.top, 62)
        }
        .ignoresSafeArea()
    }

    private func hour(_ h: Int) -> String { "\(h % 12 == 0 ? 12 : h % 12) \(h < 12 ? "am" : "pm")" }

    private var preview: some View {
        HStack(alignment: .top, spacing: 12) {
            CoachAvatar(coach: model.summary.coach, part: model.part, size: 46, animated: model.animateCoach)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(model.summary.coach.name.uppercased()).font(SSFont.display(12, weight: 600)).foregroundStyle(Palette.ink2)
                    Spacer()
                    Text("now").font(SSFont.display(12, weight: 400)).foregroundStyle(Palette.ink2)
                }
                Text("\(model.summary.proteinToGo)g protein to go. Want lunch ideas?").font(SSFont.display(15, weight: 600)).foregroundStyle(Palette.ink)
            }
        }
        .padding(14)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 22))
    }

    private func row(_ title: String, _ detail: String, _ isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(SSFont.display(16, weight: 700)).foregroundStyle(Palette.ink)
                Text(detail).font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
            }
        }
        .toggleStyle(.switch).tint(Palette.ink)
        .padding(.vertical, 11)
        .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink.opacity(0.10)).frame(height: 1) }
    }
}
