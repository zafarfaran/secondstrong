import Testing
@testable import SSToday

struct TabSwipeTests {
    @Test func leftMovesAlongTheBarRightMovesBack() {
        #expect(AppTab.today.after(dx: -100, dy: 0, predictedDx: -100) == .coach)
        #expect(AppTab.today.after(dx: 100, dy: 0, predictedDx: 100) == .train)
    }

    @Test func theEndsDoNotWrap() {
        #expect(AppTab.progress.after(dx: -100, dy: 0, predictedDx: -100) == nil)
        #expect(AppTab.food.after(dx: 100, dy: 0, predictedDx: 100) == nil)
    }

    @Test func shortAndSlantedDragsAreIgnored() {
        #expect(AppTab.today.after(dx: -30, dy: 0, predictedDx: -30) == nil)
        #expect(AppTab.today.after(dx: -100, dy: 80, predictedDx: -100) == nil)
    }

    @Test func aQuickFlickCounts() {
        #expect(AppTab.today.after(dx: -40, dy: 0, predictedDx: -220) == .coach)
    }
}
