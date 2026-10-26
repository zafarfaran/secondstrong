import Testing
import SSCore
@testable import SSOnboarding

@MainActor @Suite struct PaywallFlowTests {
    private func make() -> OnboardingFlow {
        let flow = OnboardingFlow()
        flow.reduceMotion = true
        return flow
    }

    @Test func helpersStayBetweenOneAndTheCap() {
        let flow = make()
        flow.setHelpers(0)
        #expect(flow.helperCount == 1)
        flow.setHelpers(9)
        #expect(flow.helperCount == Pricing.maxHelpers)
    }

    @Test func theChosenPlanDrivesThePrice() {
        let flow = make()
        flow.billing = .monthly
        #expect(flow.plannedHelpers == 0)
        #expect(flow.planPrice == 999)
        flow.paywallTab = .helpers
        flow.setHelpers(2)
        #expect(flow.plannedHelpers == 2)
        #expect(flow.planPrice == 1699)
        flow.billing = .yearly
        #expect(flow.planPrice == 13599)
    }

    @Test func aSoloPurchaseFinishesTheOnboarding() async {
        let flow = make()
        await flow.purchase()
        #expect(flow.purchased)
        #expect(flow.ended)
    }

    @Test func aPurchaseHappensOnlyOnce() async {
        let flow = make()
        await flow.purchase()
        await flow.purchase()
        #expect(flow.purchased)
    }

    @Test func anInviteMarksItselfSent() {
        let flow = make()
        #expect(!flow.inviteSent)
        flow.markInviteSent()
        #expect(flow.inviteSent)
    }

    @Test func anInvitedMemberIsRemembered() {
        let flow = make()
        flow.previewInvite()
        #expect(flow.invitedBy == "Sam")
        #expect(flow.authStage == .invited)
    }
}
