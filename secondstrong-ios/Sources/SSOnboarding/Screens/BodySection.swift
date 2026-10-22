import SwiftUI
import SSCore
import SSDesign

/// Height and weight for the protein target, set with sliders. Skippable; not asked when the safety screen says so.
struct BodySection: View {
    let flow: OnboardingFlow
    @State private var imperial = false
    @State private var heightCm: Double?
    @State private var weightKg: Double?

    var body: some View {
        SectionFrame(index: OnboardingStep.body.rawValue, flow: flow, badge: "body") {
            MetaLabel("Private to you")
            SectionTitle("Your", emphasis: "numbers.", index: OnboardingStep.body.rawValue)
            if flow.answers.asksForBody {
                Text("They set your protein target, nothing more.")
                    .font(SSFont.display(16, weight: 400))
                    .foregroundStyle(Palette.ink2)
                units
                VStack(alignment: .leading, spacing: 16) {
                    measure("Height", reading: heightCm.map(heightText), spec: heightSpec, start: heightCm.map(heightDisplay) ?? (imperial ? 65 : 165)) {
                        heightCm = imperial ? $0 * 2.54 : $0
                        store()
                    }
                    measure("Weight", reading: weightKg.map(weightText), spec: weightSpec, start: weightKg.map(weightDisplay) ?? (imperial ? 154 : 70)) {
                        weightKg = imperial ? $0 * 0.453_592_37 : $0
                        store()
                    }
                }
                .padding(.top, 14)
                .penAnchor(.body)
            } else {
                Text("No numbers needed. We'll start with a steady target.")
                    .font(SSFont.hand(24))
                    .foregroundStyle(Palette.pen)
                    .padding(.top, 8)
                    .penAnchor(.body)
            }
            Spacer(minLength: 0)
            if flow.answers.asksForBody {
                Button("Skip for now") {
                    flow.answers.skipBody()
                    flow.next()
                }
                .buttonStyle(.plain)
                .font(SSFont.display(14, weight: 600))
                .foregroundStyle(Palette.ink2)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
            }
            PillButton("Continue", enabled: flow.answers.canContinue(from: .body)) { flow.next() }
                .penAnchor(.next(OnboardingStep.body.rawValue))
        }
    }

    private var heightSpec: RulerPicker.Spec {
        imperial
            ? .init(range: 48...86, step: 1, ticksPerMajor: 12) { "\(Int($0) / 12)\u{2032}" }
            : .init(range: 120...220, step: 1, ticksPerMajor: 10) { String(Int($0)) }
    }

    private var weightSpec: RulerPicker.Spec {
        imperial
            ? .init(range: 80...550, step: 1, ticksPerMajor: 10) { String(Int($0)) }
            : .init(range: 35...250, step: 0.5, ticksPerMajor: 10) { String(Int($0)) }
    }

    private func heightDisplay(_ cm: Double) -> Double { imperial ? (cm / 2.54).rounded() : cm }

    private func weightDisplay(_ kg: Double) -> Double { imperial ? (kg / 0.453_592_37).rounded() : kg }

    private func heightText(_ cm: Double) -> String {
        guard imperial else { return "\(Int(cm.rounded())) cm" }
        let inches = Int((cm / 2.54).rounded())
        return "\(inches / 12)\u{2032} \(inches % 12)\u{2033}"
    }

    private func weightText(_ kg: Double) -> String {
        imperial ? "\(Int((kg / 0.453_592_37).rounded())) lb" : String(format: "%g kg", kg)
    }

    private var units: some View {
        HStack(spacing: 8) {
            unit("cm · kg", on: !imperial) { imperial = false }
            unit("ft · lb", on: imperial) { imperial = true }
        }
        .padding(.top, 4)
    }

    private func unit(_ title: String, on: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(SSFont.display(13, weight: 600))
                .foregroundStyle(on ? Palette.ivory : Palette.ink)
                .padding(.horizontal, 14).frame(height: 32)
                .background(on ? Palette.ink : .clear, in: Capsule())
                .overlay(Capsule().stroke(Palette.ink.opacity(on ? 0 : 0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func measure(_ label: String, reading: String?, spec: RulerPicker.Spec, start: Double, onChange: @escaping (Double) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                MetaLabel(label)
                Spacer()
                Text(reading ?? "Drag to set")
                    .font(reading == nil ? SSFont.hand(20) : SSFont.display(34))
                    .tracking(reading == nil ? 0 : -1.2)
                    .foregroundStyle(reading == nil ? Palette.ink2 : Palette.ink)
                    .contentTransition(.numericText())
                    .animation(.snappy(duration: 0.15), value: reading)
            }
            RulerPicker(spec: spec, start: start, onChange: onChange)
                .padding(.horizontal, -34)
                .id("\(label)\(imperial)")
                .accessibilityLabel(label)
        }
    }

    private func store() {
        guard let heightCm, let weightKg else { return }
        flow.answers.setBody(heightCm: heightCm, weightKg: weightKg)
    }
}
