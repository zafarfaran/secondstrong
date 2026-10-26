import SwiftUI
import SSCore
import SSDesign

/// The paywall: hard, no skip (spec 1.3, 2.7). Solo, or you plus helpers, monthly or yearly, seven days free.
/// Renewal price and terms are in readable type (spec 1.5). Purchases are simulated.
struct PaywallSection: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        SectionFrame(index: OnboardingStep.paywall.rawValue, flow: flow) {
            SectionTitle("Choose your", emphasis: "plan.", index: OnboardingStep.paywall.rawValue, size: 32)
            Text("Your \(flow.plan.proteinGrams)g protein target starts today.")
                .font(SSFont.display(15, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
            tabs.padding(.top, 6)
            if flow.paywallTab == .helpers { helpers }
            billing.padding(.top, 4)
            Text(flow.paywallTab == .helpers ? "You and \(flow.helperCount) helper\(flow.helperCount > 1 ? "s" : "") on one bill" : " ")
                .font(SSFont.hand(20))
                .foregroundStyle(Palette.pen)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
            Text(terms)
                .font(SSFont.display(13.5, weight: 400))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
            PillButton(flow.purchasing ? "Starting…" : "Start \(Pricing.trialDays)-day free trial", enabled: !flow.purchasing) {
                Task { await flow.purchase() }
            }
            .penAnchor(.next(OnboardingStep.paywall.rawValue))
            HStack {
                Button("Restore purchases") { Task { await flow.restorePurchases() } }
                    .buttonStyle(.plain)
                Spacer()
                Text(flow.restoreNote.isEmpty ? "Add helpers any time" : flow.restoreNote)
            }
            .font(SSFont.display(13, weight: 600))
            .foregroundStyle(Palette.ink2)
        }
    }

    private var terms: String {
        let period = flow.billing == .yearly ? "year" : "month"
        let who = flow.plannedHelpers > 0 ? " for you and \(flow.plannedHelpers) helper\(flow.plannedHelpers > 1 ? "s" : "")" : ""
        return "\(Pricing.trialDays) days free, then \(Pricing.text(flow.planPrice)) a \(period)\(who). Renews automatically. Cancel any time in Settings."
    }

    private var tabs: some View {
        HStack(spacing: 0) {
            tab("Just me", .solo)
            tab("Me and a helper", .helpers)
        }
        .padding(4)
        .background(Palette.card, in: Capsule())
    }

    private func tab(_ title: String, _ value: PaywallTab) -> some View {
        let on = flow.paywallTab == value
        return Button { withAnimation(.snappy(duration: 0.25)) { flow.paywallTab = value } } label: {
            Text(title)
                .font(SSFont.display(14.5, weight: 600))
                .foregroundStyle(on ? Palette.ivory : Palette.ink2)
                .frame(maxWidth: .infinity).frame(height: 38)
                .background(on ? Palette.ink : .clear, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    private var helpers: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Helpers").font(SSFont.display(15.5, weight: 700)).foregroundStyle(Palette.ink)
                Text("A son or daughter who checks in with you").font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
            }
            Spacer()
            HStack(spacing: 12) {
                stepper("minus") { flow.setHelpers(flow.helperCount - 1) }
                Text("\(flow.helperCount)").font(SSFont.display(20)).foregroundStyle(Palette.ink).frame(minWidth: 18)
                stepper("plus") { flow.setHelpers(flow.helperCount + 1) }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.ink.opacity(0.15), lineWidth: 1.5))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func stepper(_ symbol: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 14, weight: .semibold)).foregroundStyle(Palette.ink)
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(Palette.ink, lineWidth: 1.5))
        }
        .buttonStyle(PressScaleStyle(pressed: 0.9))
        .accessibilityLabel(symbol == "plus" ? "More helpers" : "Fewer helpers")
    }

    private var billing: some View {
        HStack(spacing: 10) {
            card(.monthly)
            card(.yearly)
        }
    }

    private func card(_ period: BillingPeriod) -> some View {
        let h = flow.plannedHelpers
        let on = flow.billing == period
        return Button { withAnimation(.snappy(duration: 0.25)) { flow.billing = period } } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(period == .yearly ? "Yearly" : "Monthly").font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ink)
                Text(Pricing.text(Pricing.price(helpers: h, period: period)))
                    .font(SSFont.display(24)).tracking(-0.8).foregroundStyle(Palette.ink)
                    .contentTransition(.numericText())
                Text(period == .yearly ? "\(Pricing.text(Pricing.yearlyPerMonth(helpers: h))) a month" : "Billed every month")
                    .font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(on ? Palette.card : .clear, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(on ? Palette.ink : Palette.ink.opacity(0.15), lineWidth: 1.5))
            .overlay(alignment: .topLeading) {
                if period == .yearly {
                    Text("SAVE \(Pricing.yearlySavingPercent(helpers: h))%")
                        .font(SSFont.display(10.5, weight: 700)).tracking(0.4)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Color(red: 0.66, green: 0.35, blue: 0.24), in: Capsule())
                        .offset(x: 12, y: -9)
                }
            }
        }
        .buttonStyle(PressScaleStyle(pressed: 0.98))
        .accessibilityLabel("\(period == .yearly ? "Yearly" : "Monthly"), \(Pricing.text(Pricing.price(helpers: h, period: period)))")
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}
