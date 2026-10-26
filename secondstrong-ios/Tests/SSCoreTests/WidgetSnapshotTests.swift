import Foundation
import Testing
@testable import SSCore

@Suite struct WidgetSnapshotTests {
    private func snapshot(protein: Int = 62, hour: Int = 9, hideLock: Bool = false, calories: Bool = true) -> WidgetSnapshot {
        var s = TodaySummary.sample
        s.proteinGrams = protein
        if !calories { s.calorieTarget = nil }
        return WidgetSnapshot(summary: s, hour: hour, hideLockScreenNumbers: hideLock)
    }

    @Test func theStateFollowsTheDayAndTheGoal() {
        #expect(snapshot(protein: 62, hour: 9).state == .morning)
        #expect(snapshot(protein: 62, hour: 14).state == .morning)
        #expect(snapshot(protein: 88, hour: 14).state == .goal)
        #expect(snapshot(protein: 62, hour: 20).state == .evening)
        #expect(snapshot(protein: 88, hour: 20).state == .evening)
        #expect(snapshot(protein: 62, hour: 2).state == .evening)
    }

    @Test func eachStateHasItsOwnPlainLine() {
        #expect(snapshot().line == ["Lift today.", "23g to go."])
        #expect(snapshot(protein: 88, hour: 14).line == ["You made it.", "Protein done."])
        #expect(snapshot(protein: 62, hour: 20).line == ["Easy evening.", "Lights out soon."])
    }

    @Test func linesFitTheLockScreenAndNeverNagAboutWeight() {
        for protein in [0, 62, 88] { for hour in [9, 14, 20] {
            for line in snapshot(protein: protein, hour: hour).line {
                #expect(line.count <= 18 && !line.contains("!"), "\(line)")
                #expect(!line.lowercased().contains("weight") && !line.lowercased().contains("kcal"))
            }
        } }
    }

    @Test func theLockScreenCanHideEveryNumber() {
        let open = snapshot(), hidden = snapshot(hideLock: true)
        #expect(open.lockScreenRing == 62.0 / 85.0 && open.lockScreenProtein == "62 of 85g")
        #expect(hidden.lockScreenRing == nil && hidden.lockScreenProtein == nil)
        #expect(hidden.lockScreenLine == ["Miso"])
    }

    @Test func caloriesAreNeverOnAWidget() {
        #expect(snapshot(calories: true).homeFigures.map(\.label) == ["Protein"])
        #expect(snapshot(calories: false).homeFigures.map(\.label) == ["Protein"])
    }

    @Test func thePictureNameMatchesTheStateAndCoach() {
        #expect(snapshot().stillName == "still-miso-morning")
        #expect(snapshot(protein: 88, hour: 14).stillName == "still-miso-goal")
    }

    @Test func itSurvivesTheRoundTripThroughSharedStorage() throws {
        let original = snapshot()
        let data = try JSONEncoder().encode(original)
        #expect(try JSONDecoder().decode(WidgetSnapshot.self, from: data) == original)
    }

    @Test func theStoreKeepsOneSnapshot() throws {
        let suite = UserDefaults(suiteName: "test.widgets.\(UUID().uuidString)")!
        let store = WidgetStore(defaults: suite)
        #expect(store.load() == nil)
        store.save(snapshot())
        #expect(store.load() == snapshot())
        store.save(snapshot(protein: 70))
        #expect(store.load()?.proteinGrams == 70)
    }
}
