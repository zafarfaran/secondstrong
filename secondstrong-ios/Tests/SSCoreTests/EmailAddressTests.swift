import Testing
@testable import SSCore

@Suite struct EmailAddressTests {
    @Test func acceptsOrdinaryAddressesAndTidiesThem() {
        #expect(EmailAddress.normalised("  Sam@Example.com ") == "sam@example.com")
        #expect(EmailAddress.normalised("a.b+c@mail.co.uk") == "a.b+c@mail.co.uk")
    }

    @Test func refusesTheObviouslyWrong() {
        for bad in ["", "sam", "sam@", "@example.com", "sam@example", "sam@.com", "sam@example.", "sa m@example.com", "a@b@c.com"] {
            #expect(EmailAddress.normalised(bad) == nil, "\(bad)")
        }
    }
}
