import AVFoundation
import SwiftUI
import SSCore

enum VoicePhase { case listening, thinking, speaking }

/// Hears her and answers aloud. The prototype's ears are simulated (it "hears" the lines in `TodayLines.voiceScript`); the voice is
/// the system voice, so it really does speak. Real speech recognition needs the microphone permission and consent (SS-0026).
@MainActor @Observable
final class VoiceSession {
    var phase = VoicePhase.listening
    var caption = "I'm listening."
    var muted = false
    private var task: Task<Void, Never>?
    private let speaker = SystemVoice()
    private let onExchange: (String, String) -> Void

    init(autoStart: Bool = true, onExchange: @escaping (String, String) -> Void = { _, _ in }) {
        self.onExchange = onExchange
        if autoStart { start() }
    }

    func start() {
        task = Task { await run() }
    }

    func stop() {
        task?.cancel()
        speaker.stop()
    }

    private func run() async {
        var turn = 0
        while !Task.isCancelled {
            let line = TodayLines.voiceScript[turn % TodayLines.voiceScript.count]
            phase = .listening
            caption = "I'm listening."
            while muted, !Task.isCancelled { try? await Task.sleep(for: .milliseconds(200)) }
            try? await Task.sleep(for: .seconds(3.2))
            guard !Task.isCancelled else { return }
            caption = "\u{201C}\(line.heard)\u{201D}"
            phase = .thinking
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            phase = .speaking
            caption = line.reply
            onExchange(line.heard, line.reply)
            await speaker.say(line.reply)
            try? await Task.sleep(for: .seconds(0.8))
            turn += 1
        }
    }
}

/// The system voice, British English. `say` returns when it has finished speaking.
@MainActor
final class SystemVoice: NSObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    private var finished: CheckedContinuation<Void, Never>?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func say(_ text: String) async {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        await withCheckedContinuation { continuation in
            finished = continuation
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        finish()
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.finish() }
    }

    private func finish() {
        finished?.resume()
        finished = nil
    }
}
