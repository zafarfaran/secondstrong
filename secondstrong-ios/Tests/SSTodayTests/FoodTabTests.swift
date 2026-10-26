import Foundation
import Testing
import SSCore
@testable import SSToday

@MainActor struct FoodTabTests {
    private func model() -> TodayModel {
        let m = TodayModel(hour: 13, widgetStore: WidgetStore(defaults: UserDefaults(suiteName: "test.food.\(UUID().uuidString)")))
        m.pace = 0
        return m
    }

    @Test func aCameraMealLandsInTheDayTheTotalsAndTheWidgets() {
        let m = model()
        let store = WidgetStore(defaults: UserDefaults(suiteName: "test.food2.\(UUID().uuidString)"))
        let tracked = TodayModel(hour: 13, widgetStore: store)
        let before = tracked.summary.proteinGrams, count = tracked.diary.entries.count
        tracked.openCamera()
        tracked.addFromCamera(MealEstimate(name: "Soup", proteinGrams: 12, calories: 200))
        #expect(tracked.camera == nil)
        #expect(tracked.diary.entries.count == count + 1)
        #expect(tracked.summary.proteinGrams == before + 12 && tracked.diary.protein == tracked.summary.proteinGrams)
        #expect(store.load()?.proteinGrams == before + 12)
        #expect(tracked.toast != nil)
        _ = m
    }

    @Test func aMealLoggedInTheChatShowsOnTheFoodTabToo() async throws {
        let m = model()
        m.sendPhoto(Data([1, 2, 3]))
        try await Task.sleep(for: .seconds(0.5))
        let meal = try #require(m.messages.last { $0.meal != nil })
        let count = m.diary.entries.count
        m.log(meal)
        #expect(m.diary.entries.count == count + 1 && m.diary.protein == m.summary.proteinGrams)
    }

    @Test func theCameraReadsThenOffersAResultAndEveryThirdPhotoFails() async throws {
        let flow = CameraFlow(scans: 0, pace: 0)
        flow.capture(nil)
        try await Task.sleep(for: .milliseconds(400))
        #expect(flow.phase == .result && flow.estimate.proteinGrams == 28)
        flow.retake()
        #expect(flow.phase == .viewfinder)
        flow.capture(nil); try await Task.sleep(for: .milliseconds(400)); flow.retake()
        flow.capture(nil); try await Task.sleep(for: .milliseconds(400))
        #expect(flow.phase == .failed, "the third photo is the one that cannot be read")
    }

    @Test func correctionsChangeTheNumbers() async throws {
        let flow = CameraFlow(scans: 0, pace: 0)
        flow.capture(nil)
        try await Task.sleep(for: .milliseconds(400))
        let medium = flow.estimate.proteinGrams
        flow.portion = .large
        #expect(flow.estimate.proteinGrams > medium)
        flow.portion = .medium
        flow.toggle(flow.base.items[0])
        #expect(flow.estimate.proteinGrams < medium)
        flow.toggle(flow.base.items[0])
        #expect(flow.estimate.proteinGrams == medium)
        flow.name = "My lunch"
        #expect(flow.estimate.name == "My lunch")
    }
}
