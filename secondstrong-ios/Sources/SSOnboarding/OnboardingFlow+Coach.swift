import SwiftUI
import SSCore
import SSDesign

/// The coach once it is docked: where it rests, how it falls and hops, when it speaks, and its idle moves.
extension OnboardingFlow {
    /// Where the docked coach rests: bottom right, just above the Continue button. The top right is where the paper
    /// badges sit.
    var restPoint: CGPoint {
        let size = Self.companionSize
        let buttonTop = screen.height - 26 - safeBottom - 54
        return CGPoint(x: screen.width - 14 - size / 2, y: buttonTop - 8 - size / 2)
    }

    /// The coach falls to its corner. The clip (design/coach-clips, state `fall`) does the body: a squat, a stretch in
    /// the air, then a squash, a hop and a settle on landing. The screen movement accelerates like a fall and
    /// arrives exactly when the clip's landing begins (0.7 s in).
    func fall(to target: CGPoint, scale: Double) async {
        let d = reduceMotion ? 0.001 : 0.7
        pulseCompanion(.fall, for: 0.35)
        withAnimation(.timingCurve(0.45, 0, 0.9, 0.5, duration: d)) { companionCentre.y = target.y }
        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1, duration: d)) { companionCentre.x = target.x }
        withAnimation(.timingCurve(0.45, 0, 0.9, 0.5, duration: d)) { companionScale = scale }
        try? await wait(0.75)
    }

    /// The coach lifts off the page and falls to the bottom-right corner while the page scrolls away underneath.
    func liftOff() async throws {
        guard let from = frames[.coachShow] else { return }
        companionCentre = CGPoint(x: from.midX, y: from.midY + cameraY)
        companionScale = from.width / Self.showcaseSize
        companionState = .flying
        try await wait(0.06)
        let scale = Self.companionSize / Self.showcaseSize
        Task {
            await fall(to: restPoint, scale: scale)
            if companionState == .flying { companionState = .docked }
        }
    }

    /// Pages with a skip link just above Continue, which the coach's note must not sit on.
    var hasSkipLink: Bool { stepValue == .body || stepValue == .invite || stepValue == .goal }

    /// Pages where the coach stays out of the way: the loading screen and the paywall (its terms must stay readable).
    var companionHidesOnPage: Bool { stepValue == .building || stepValue == .paywall }

    /// Every time the page moves on, the docked coach stays on screen and plays its fall in place. It never leaps up or vanishes.
    func companionTransition(to step: OnboardingStep?) {
        noteActivity()
        speakOnArrival(step)
        guard companionState == .docked, !reduceMotion, let step else { return }
        if step == .building || step == .paywall {
            Task { await hopOut() }
        } else if companionAway {
            Task { await dropCompanionIn() }
        } else {
            Task { await hopToNextPage() }
        }
    }

    /// Leaving for the loading screen or paywall, the coach drops down out of the bottom. It never goes up.
    func hopOut() async {
        pulseCompanion(.fall, for: 0.45)
        companionAway = true
        withAnimation(.timingCurve(0.45, 0, 0.9, 0.5, duration: 0.5)) { companionCentre.y = screen.height + 120 }
        try? await wait(0.55)
    }

    /// The coach never leaves the screen between pages: the fall clip plays where it stands, so it reads as one body.
    func hopToNextPage() async {
        pulseCompanion(.fall, for: 0.85)
        try? await wait(0.9)
    }

    /// Back from a page it was hidden on, the coach falls in from above the screen.
    func dropCompanionIn() async {
        guard companionState == .docked else { return }
        companionAway = false
        pulseCompanion(.fall, for: 0.35)
        try? await wait(0.25)
        withAnimation(.timingCurve(0.45, 0, 0.9, 0.5, duration: 0.7)) { companionCentre.y = restPoint.y }
        try? await wait(0.75)
    }

    // MARK: quiet moments

    /// Any touch or answer counts. A bubble that has been up a couple of seconds clears away once the person gets on with it.
    func noteActivity() {
        lastActivity = Date()
        if speech != nil, Date().timeIntervalSince(speechShownAt) > 4 {
            withAnimation(.easeOut(duration: 0.25)) { hideSpeech() }
        }
    }

    func startIdleWatch() {
        idleWatch?.cancel()
        guard !reduceMotion else { return }
        idleWatch = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.nudgeIfQuiet()
            }
        }
    }

    /// When nobody has touched anything for a few seconds, the coach on screen does a small idle move, then another
    /// every few seconds for as long as it stays quiet. Any touch or answer starts the wait again.
    func nudgeIfQuiet(now: Date = Date()) {
        guard !busy, !ended, !purchasing, speech == nil,
              now.timeIntervalSince(lastActivity) >= Self.quietBeforeNudge,
              now.timeIntervalSince(lastNudge) >= Self.nudgeGap else { return }
        let variant = CoachMood.idleVariants[variantIndex % CoachMood.idleVariants.count]
        guard playIdle(variant) else { return }
        lastNudge = now
        variantIndex += 1
    }

    /// The coach that is on screen right now does the move. False when no coach is showing.
    func playIdle(_ variant: CoachMood) -> Bool {
        let seconds = variant.idleVariantSeconds
        switch stepValue {
        case .welcome where heroVisible: pulseHero(variant, for: seconds)
        case .coach where companionState == .hidden: pulseShow(variant, for: seconds)
        case .building, .paywall: return false
        default:
            guard companionState == .docked, !companionAway else { return false }
            pulseCompanion(variant, for: seconds)
        }
        return true
    }


    // MARK: speech

    func hideSpeech() {
        speechTask?.cancel()
        speech = nil
    }

    /// The coach listens while its line is written in the margin; both go when the line has been up long enough.
    func say(_ line: String) {
        speechTask?.cancel()
        speechShownAt = Date()
        let seconds = CoachLines.seconds(for: line)
        withAnimation(.spring(duration: 0.4, bounce: 0.35)) { speech = Speech(text: line) }
        pulseCompanion(.listening, for: seconds)
        AccessibilityNotification.Announcement(line).post()
        speechTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.25)) { self?.speech = nil }
        }
    }

    /// On each screen after the coach pick, the coach says its first line once it has landed.
    func speakOnArrival(_ step: OnboardingStep?) {
        hideSpeech()
        guard let step else { return }
        let lines = CoachLines.lines(for: step, coachName: answers.displayName)
        guard !lines.isEmpty else { return }
        lineIndex[step] = 0
        speechTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(self?.reduceMotion == true ? 0.4 : 1.6))
            guard !Task.isCancelled, let self, self.stepValue == step, self.companionState == .docked, !self.companionAway else { return }
            self.say(lines[0])
        }
    }
}
