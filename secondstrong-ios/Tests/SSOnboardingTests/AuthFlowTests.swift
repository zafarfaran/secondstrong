import Testing
@testable import SSOnboarding

@MainActor @Suite struct AuthFlowTests {
    private func make() -> OnboardingFlow {
        let flow = OnboardingFlow()
        flow.reduceMotion = true
        return flow
    }

    @Test func aBadEmailCannotBeSent() async {
        let flow = make()
        flow.chooseEmail()
        flow.authEmail = "sam@"
        #expect(!flow.canSendLink)
        await flow.sendLink()
        #expect(flow.authStage == .email)
    }

    @Test func aGoodEmailMovesToCheckYourInbox() async {
        let flow = make()
        flow.chooseEmail()
        flow.authEmail = " Sam@Example.com "
        #expect(flow.canSendLink)
        await flow.sendLink()
        #expect(flow.authStage == .sent)
        flow.useDifferentEmail()
        #expect(flow.authStage == .email)
        #expect(flow.authCode.isEmpty)
    }

    @Test func aSixDigitCodeSignsIn() async {
        let flow = make()
        await flow.enter(code: "48291")
        #expect(!flow.signedIn)
        await flow.enter(code: "4829-13")
        #expect(flow.authCode == "482913")
        #expect(flow.signedIn)
    }

    @Test func appleAndGoogleSignIn() async {
        let apple = make()
        await apple.signIn(with: .apple)
        #expect(apple.signedIn)
        let google = make()
        await google.signIn(with: .google)
        #expect(google.signedIn)
    }

    @Test func nothingStartsBeforeSignIn() {
        let flow = make()
        #expect(!flow.signedIn)
        #expect(flow.authStage == .choose)
    }
}
