import SwiftUI
import SSCore
import SSDesign

/// Health answers are special-category data, so consent comes before the first health question.
/// Tapping the button is the affirmative act; it says plainly what is being agreed.
// SS-0019: placeholder wording. Legal must approve the copy (open question 3).
struct ConsentSection: View {
    let flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.consent.rawValue, flow: flow, badge: "consent") {
            MetaLabel("Your privacy")
            SectionTitle("Before we", emphasis: "begin.", index: OnboardingStep.consent.rawValue)
            VStack(spacing: 0) {
                point("lock", "Yours alone", "Nobody sees your answers unless you share them.")
                divider
                point("wand.and.stars", "Only for your plan", "Used to build your plan, nothing else.")
                divider
                point("hand.raised", "Always your choice", "Change or delete them any time.")
            }
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.ink.opacity(0.08), lineWidth: 1))
            .padding(.top, 6)
            .penAnchor(.agree)
            Spacer(minLength: 0)
            Text("By tapping Agree and continue, you consent to Second Strong using your health answers to build your plan.")
                .font(SSFont.display(12.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
            PillButton("Agree and continue") {
                flow.agree(true)
                flow.next()
            }
            .penAnchor(.next(OnboardingStep.consent.rawValue))
        }
    }

    private var divider: some View {
        Rectangle().fill(Palette.ink.opacity(0.08)).frame(height: 1).padding(.leading, 62)
    }

    private func point(_ symbol: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Palette.ink)
                .frame(width: 36, height: 36)
                .background(Palette.almond, in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(SSFont.display(15.5, weight: 700)).foregroundStyle(Palette.ink)
                Text(detail).font(SSFont.display(14, weight: 400)).foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}
