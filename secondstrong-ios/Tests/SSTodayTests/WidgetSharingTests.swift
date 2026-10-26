import Foundation
import Testing
import SSCore
@testable import SSToday

@MainActor @Suite struct WidgetSharingTests {
    private func store() -> WidgetStore { WidgetStore(defaults: UserDefaults(suiteName: "test.share.\(UUID().uuidString)")) }

    @Test func theAppSharesTheSnapshotAtStartAndWhenProteinChanges() {
        let store = store()
        let model = TodayModel(hour: 9, widgetStore: store)
        #expect(store.load()?.proteinGrams == 62 && store.load()?.coach == .miso)
        model.summary.log(MealEstimate(name: "Eggs", proteinGrams: 28, calories: 410))
        #expect(store.load()?.proteinGrams == 90)
    }

    @Test func theLockScreenHidesNumbersUntilSheChoosesOtherwise() {
        let store = store()
        let model = TodayModel(hour: 9, widgetStore: store)
        #expect(store.load()?.hideLockScreenNumbers == true && store.load()?.lockScreenProtein == nil)
        model.profile.hideLockScreenNumbers = false
        #expect(store.load()?.lockScreenProtein == "62 of 85g")
    }

    @Test func thePhotoLogsIntoTheWidgetToo() async throws {
        let store = store()
        let model = TodayModel(hour: 9, widgetStore: store)
        model.pace = 0
        let sample = try #require(model.messages.first)
        _ = sample
        model.sendPhoto(Data([1, 2, 3]))
        try await Task.sleep(for: .seconds(0.5))
        let meal = try #require(model.messages.last { $0.meal != nil })
        model.log(meal)
        #expect(store.load()?.proteinGrams == 90)
    }
}
