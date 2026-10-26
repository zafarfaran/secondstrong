import AVFoundation
import Testing
import SSCore
@testable import SSDesign

@MainActor @Suite(.serialized) struct CoachClipPlayerTests {
    private func wait(_ seconds: Double) async { try? await Task.sleep(for: .seconds(seconds)) }

    @Test func everyCoachHasEveryClip() {
        for coach in Coach.allCases {
            for mood in CoachMood.allCases { #expect(CoachClips.asset(coach, mood) != nil, "\(coach) \(mood)") }
        }
        #expect(CoachClips.manifest?.segments.count == CoachMood.allCases.count)
    }

    @Test func clipsKeepTheirAlpha() async throws {
        let asset = try #require(CoachClips.asset(.miso, .cheer))
        let track = try #require(try await asset.loadTracks(withMediaType: .video).first)
        let reader = try AVAssetReader(asset: asset)
        let out = AVAssetReaderTrackOutput(track: track, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
        reader.add(out)
        reader.startReading()
        let buffer = try #require(out.copyNextSampleBuffer().flatMap(CMSampleBufferGetImageBuffer))
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let corner = CVPixelBufferGetBaseAddress(buffer)!.assumingMemoryBound(to: UInt8.self)[3]
        #expect(corner == 0)
    }

    @Test func theHandOverNeverShowsABlank() async throws {
        let player = CoachClipPlayer(.fern)
        let host = CALayer()
        host.addSublayer(player.root)
        player.setFrame(CGRect(x: 0, y: 0, width: 200, height: 200))
        await wait(0.8)
        for mood in [CoachMood.hello, .idleLook, .cheer, .idle] {
            player.request(mood)
            for _ in 0..<12 {
                await wait(0.04)
                #expect(player.visibleLayerReady, "\(mood)")
            }
        }
        player.stop()
    }

    @Test func theFallLandsAndReturnsToIdle() async throws {
        let player = CoachClipPlayer(.miso)
        let host = CALayer()
        host.addSublayer(player.root)
        player.setFrame(CGRect(x: 0, y: 0, width: 200, height: 200))
        await wait(0.8)
        player.request(.fall)
        #expect(player.currentMood == .fall)
        await wait(0.35)
        player.request(.idle)
        await wait(2.6)
        #expect(player.currentMood == .idle)
        player.stop()
    }

    @Test func anIdleMovePlaysOnceAndGoesBackToIdle() async throws {
        let player = CoachClipPlayer(.otto)
        let host = CALayer()
        host.addSublayer(player.root)
        player.setFrame(CGRect(x: 0, y: 0, width: 200, height: 200))
        await wait(0.8)
        player.request(.idleBounce)
        #expect(player.currentMood == .idleBounce)
        await wait(1.0)
        player.request(.idle)
        #expect(player.currentMood == .idleBounce)
        await wait(1.6)
        #expect(player.currentMood == .idle)
        player.stop()
    }

    @Test func playsAStateAndReturnsToIdle() async throws {
        let player = CoachClipPlayer(.bramble)
        var firstFrame = false
        player.onFirstFrame = { firstFrame = true }
        let host = CALayer()
        host.addSublayer(player.root)
        player.setFrame(CGRect(x: 0, y: 0, width: 200, height: 200))
        await wait(1.0)
        player.request(.hello)
        #expect(player.currentMood == .hello)
        await wait(3.0)
        #expect(player.currentMood == .hello)
        player.request(.idle)
        await wait(3.0)
        #expect(player.currentMood == .idle)
        #expect(firstFrame)
        player.stop()
        #expect(player.currentMood == nil)
    }
}
