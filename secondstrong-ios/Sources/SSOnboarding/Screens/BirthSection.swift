import SwiftUI
import SSCore
import SSDesign

/// Full date of birth on three wheels: drives the protein target and is the adult gate.
/// Nothing counts until a wheel is moved; then all three shown values do.
struct BirthSection: View {
    let flow: OnboardingFlow
    @State private var day = 1
    @State private var month = 1
    @State private var year = 1975
    @State private var touched = false

    private let thisYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        SectionFrame(index: OnboardingStep.birth.rawValue, flow: flow, badge: "birth") {
            MetaLabel("About you")
            SectionTitle("Your", emphasis: "birthday.", index: OnboardingStep.birth.rawValue)
            Text(readout)
                .font(SSFont.display(touched ? 28 : 18, weight: touched ? 800 : 400))
                .foregroundStyle(touched ? Palette.ink : Palette.ink2)
                .frame(maxWidth: .infinity, minHeight: 40)
                .padding(.top, 6)
            WheelRow(height: 200) {
                WheelColumn(items: (1...31).map { .init($0, String($0)) }, start: day, height: 200) { day = $0; commit() }
                    .frame(width: 80)
                WheelColumn(items: Calendar.current.monthSymbols.enumerated().map { .init($0.offset + 1, $0.element) }, start: month, height: 200) { month = $0; commit() }
                WheelColumn(items: (1900...thisYear).reversed().map { .init($0, String($0)) }, start: year, height: 200) { year = $0; commit() }
                    .frame(width: 104)
            }
            .penAnchor(.birth)
            Text(message)
                .font(SSFont.hand(21))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity, minHeight: 30)
            Spacer(minLength: 0)
            PillButton("Continue", enabled: flow.answers.canContinue(from: .birth)) { flow.next() }
                .penAnchor(.next(OnboardingStep.birth.rawValue))
        }
    }

    private var date: BirthDate? { BirthDate(year: year, month: month, day: day) }

    private var readout: String {
        guard touched else { return "Scroll to your date of birth" }
        guard let date, let d = Calendar.current.date(from: DateComponents(year: date.year, month: date.month, day: date.day, hour: 12)) else {
            return "\(day) \(Calendar.current.monthSymbols[month - 1]) \(year)"
        }
        return d.formatted(.dateTime.day().month(.wide).year().locale(Locale(identifier: "en_GB")))
    }

    private var message: String {
        guard touched else { return " " }
        if date == nil { return "That date doesn't exist." }
        return flow.answers.isAdult() ? " " : "Second Strong is for adults, 18 and over."
    }

    private func commit() {
        touched = true
        flow.answers.select(birthDate: date)
    }
}
