import Foundation

/// A calendar date of birth, kept free of time zones so the adult check is exact.
public struct BirthDate: Equatable, Sendable, Comparable {
    public let year: Int
    public let month: Int
    public let day: Int

    /// Nil for dates that do not exist, like 31 February.
    public init?(year: Int, month: Int, day: Int) {
        guard (1...12).contains(month), day >= 1, day <= Self.daysIn(month: month, year: year) else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    public static func today(calendar: Calendar = .current, now: Date = Date()) -> BirthDate {
        let c = calendar.dateComponents([.year, .month, .day], from: now)
        return BirthDate(year: c.year!, month: c.month!, day: c.day!)!
    }

    public static func < (a: BirthDate, b: BirthDate) -> Bool { (a.year, a.month, a.day) < (b.year, b.month, b.day) }

    /// Whole years completed on `date`.
    public func age(on date: BirthDate) -> Int {
        let had = (date.month, date.day) >= (month, day)
        return date.year - year - (had ? 0 : 1)
    }

    private static func daysIn(month: Int, year: Int) -> Int {
        switch month {
        case 2: (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28
        case 4, 6, 9, 11: 30
        default: 31
        }
    }
}
