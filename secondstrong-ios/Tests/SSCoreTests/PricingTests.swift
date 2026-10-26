import Testing
@testable import SSCore

@Suite struct PricingTests {
    @Test func monthlyFollowsTheLaunchPrices() {
        #expect(Pricing.monthly(helpers: 0) == 999)
        #expect(Pricing.monthly(helpers: 1) == 1299)
        #expect(Pricing.monthly(helpers: 2) == 1699)
        #expect(Pricing.monthly(helpers: 3) == 2099)
        #expect(Pricing.monthly(helpers: 4) == 2499)
    }

    @Test func yearlyIsEightMonthsEndingInNinetyNine() {
        #expect(Pricing.yearly(helpers: 0) == 7999)
        #expect(Pricing.yearly(helpers: 1) == 10399)
        #expect(Pricing.yearly(helpers: 2) == 13599)
        #expect(Pricing.yearly(helpers: 3) == 16799)
        #expect(Pricing.yearly(helpers: 4) == 19999)
    }

    @Test func helpersAreCappedAndNeverNegative() {
        #expect(Pricing.monthly(helpers: 9) == Pricing.monthly(helpers: 4))
        #expect(Pricing.monthly(helpers: -2) == Pricing.soloMonthly)
    }

    @Test func textAndSavings() {
        #expect(Pricing.text(1299) == "£12.99")
        #expect(Pricing.text(7999) == "£79.99")
        #expect(Pricing.yearlySavingPercent(helpers: 0) == 33)
        #expect(Pricing.yearlyPerMonth(helpers: 0) == 667)
        #expect(Pricing.price(helpers: 1, period: .yearly) == 10399)
    }
}
