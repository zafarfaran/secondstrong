import Foundation
import Testing
@testable import SSCore

struct ClipSequencerTests {
    private static let json = """
    {"states":{
      "idle":{"in":[0,0],"loop":[0,4],"out":[4,4]},
      "hello":{"in":[0,0.5],"loop":[0.5,1.7],"out":[1.7,2.2]},
      "cheer":{"in":[0,0.4],"loop":[0.4,1.6],"out":[1.6,2]}}}
    """

    private func make() throws -> ClipSequencer {
        ClipSequencer(manifest: try ClipManifest(json: Data(Self.json.utf8)))
    }

    @Test func parsesTheManifest() throws {
        let manifest = try ClipManifest(json: Data(Self.json.utf8))
        #expect(manifest.segments[.hello]?.loop == 0.5...1.7)
        #expect(manifest.segments.count == 3)
    }

    @Test func idleGivesWayAtOnce() throws {
        var s = try make()
        #expect(s.request(.hello) == .play(.hello))
        #expect(s.mood == .hello)
        #expect(s.phase == .enter)
    }

    @Test func idleLoopsOnItsOwn() throws {
        var s = try make()
        #expect(s.tick(at: 2) == .none)
        #expect(s.tick(at: 4) == .seek(0))
    }

    @Test func aStateRepeatsItsLoopUntilAskedToStop() throws {
        var s = try make()
        _ = s.request(.hello)
        #expect(s.tick(at: 0.5) == .none)
        #expect(s.phase == .loop)
        #expect(s.tick(at: 1.7) == .seek(0.5))
    }

    @Test func aRequestWaitsForTheLoopThenPlaysOutAndHandsOver() throws {
        var s = try make()
        _ = s.request(.hello)
        _ = s.tick(at: 0.5)
        #expect(s.request(.cheer) == .none)
        #expect(s.tick(at: 1.0) == .none)
        #expect(s.tick(at: 1.7) == .none)
        #expect(s.phase == .leave)
        #expect(s.tick(at: 2.2) == .play(.cheer))
        #expect(s.mood == .cheer)
    }

    @Test func goingBackToIdleIsJustAnotherRequest() throws {
        var s = try make()
        _ = s.request(.hello)
        _ = s.tick(at: 0.5)
        _ = s.request(.idle)
        _ = s.tick(at: 1.7)
        #expect(s.tick(at: 2.2) == .play(.idle))
        #expect(s.phase == .loop)
    }

    @Test func onlyTheLatestRequestIsKept() throws {
        var s = try make()
        _ = s.request(.hello)
        _ = s.tick(at: 0.5)
        _ = s.request(.cheer)
        _ = s.request(.idle)
        _ = s.tick(at: 1.7)
        #expect(s.tick(at: 2.2) == .play(.idle))
    }

    @Test func askingForTheCurrentStateCancelsTheHandOver() throws {
        var s = try make()
        _ = s.request(.hello)
        _ = s.tick(at: 0.5)
        _ = s.request(.cheer)
        _ = s.request(.hello)
        #expect(s.tick(at: 1.7) == .seek(0.5))
    }
}
