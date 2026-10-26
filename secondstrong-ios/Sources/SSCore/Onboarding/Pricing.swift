import Foundation

public enum BillingPeriod: String, Sendable, CaseIterable { case monthly, yearly }

/// Launch prices in pence, pounds with VAT included. Decisions D11 and D12 in docs/design/family-circle.md:
/// solo 9.99 a month, one helper takes it to 12.99, each helper after the first adds 4.00, yearly is eight months' price.
/// All prices live here so they can change in one edit (and in App Store Connect).
public enum Pricing {
    public static let soloMonthly = 999
    public static let firstHelperExtra = 300
    public static let furtherHelperExtra = 400
    public static let maxHelpers = 4
    public static let yearlyMonths = 8.0
    public static let trialDays = 7

    public static func clampHelpers(_ helpers: Int) -> Int { min(max(helpers, 0), maxHelpers) }

    public static func monthly(helpers: Int) -> Int {
        let h = clampHelpers(helpers)
        guard h > 0 else { return soloMonthly }
        return soloMonthly + firstHelperExtra + (h - 1) * furtherHelperExtra
    }

    /// Eight months' price, rounded to end in .99.
    public static func yearly(helpers: Int) -> Int {
        let pounds = Double(monthly(helpers: helpers)) * yearlyMonths / 100 + 0.07
        return Int(pounds.rounded()) * 100 - 1
    }

    public static func price(helpers: Int, period: BillingPeriod) -> Int {
        period == .monthly ? monthly(helpers: helpers) : yearly(helpers: helpers)
    }

    /// What yearly saves against twelve months, as a whole percent.
    public static func yearlySavingPercent(helpers: Int) -> Int {
        let twelve = Double(monthly(helpers: helpers)) * 12
        return Int((1 - Double(yearly(helpers: helpers)) / twelve) * 100)
    }

    public static func yearlyPerMonth(helpers: Int) -> Int { (yearly(helpers: helpers) + 6) / 12 }

    /// "£12.99"
    public static func text(_ pence: Int) -> String { String(format: "£%d.%02d", pence / 100, pence % 100) }
}
