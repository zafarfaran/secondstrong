import SwiftUI
import SSCore
import SSDesign

enum CompanionState { case hidden, flying, docked }
enum AuthStage { case choose, email, sent, expired, returning, invited }
enum PaywallTab { case solo, helpers }

/// A line the coach is saying right now, shown in a bubble.
struct Speech: Equatable, Identifiable {
    let id = UUID()
    let text: String
}

/// Who the door greets by name once the backend knows them. Fake data until then.
struct KnownMember: Equatable {
    var firstName: String
    var coach: Coach
    var method: AuthProvider
}
enum AuthProvider { case apple, google }

/// Drives the whole onboarding: answers, the pen, the camera and the living bits.
@MainActor @Observable
final class OnboardingFlow {
    static let lastStep = OnboardingStep.invite.rawValue
    static let companionSize = 110.0
    static let showcaseSize = 210.0

    var answers = OnboardingAnswers()
    var reduceMotion = false
    var frames: [PenAnchor: Rect] = [:]

    private(set) var screen = CGSize(width: 390, height: 844)
    private(set) var safeTop: CGFloat = 0
    private(set) var safeBottom: CGFloat = 0
    private(set) var step = 0
    private(set) var busy = false
    var strokes: [InkStroke] = []
    var cameraY: CGFloat = 0
    private(set) var ended = false
    private(set) var endVisible = false

    var heroVisible = false
    private(set) var heroMood = CoachMood.idle
    private(set) var showMood = CoachMood.idle
    private(set) var companionMood = CoachMood.idle
    var companionState = CompanionState.hidden
    var companionCentre = CGPoint.zero
    var companionScale = 1.0
    private(set) var shakeTicks: [Goal: Int] = [:]
    private(set) var buildStart: Date?
    private(set) var buildMood = CoachMood.idle
    private(set) var buildDone = false

    var authStage = AuthStage.choose
    var authEmail = ""
    private(set) var authBusy = false
    var authCode = ""
    private(set) var member: KnownMember?
    private(set) var signedIn = false
    private(set) var welcomedBack = false

    var proteinLit = false
    var shownDots: Set<Weekday> = []
    var noteText = ""
    var noteProgress = 0.0
    var startReady = false

    var paywallTab = PaywallTab.solo
    var billing = BillingPeriod.yearly
    private(set) var helperCount = 1
    private(set) var purchasing = false
    private(set) var purchased = false
    private(set) var restoreNote = ""
    var inviteName = ""
    var inviteMessage = ""
    private(set) var inviteSent = false
    private(set) var invitedBy: String?

    /// Helpers on the plan being bought: none when solo.
    var plannedHelpers: Int { paywallTab == .solo ? 0 : helperCount }
    var planPrice: Int { Pricing.price(helpers: plannedHelpers, period: billing) }

    enum Bucket { case none, arrive(Int), commit(Int) }
    var planner = PenPlanner(width: 390)
    var bucket = Bucket.none
    var arrivals: [Int: [InkStroke]] = [:]
    var commits: [Int: [InkStroke]] = [:]
    var snapshots: [Int: PenPlanner.Snapshot] = [:]

    private var queued = false
    private var advanceTask: Task<Void, Never>?
    private var moodTasks: [String: Task<Void, Never>] = [:]

    var lastActivity = Date()
    var lastNudge = Date.distantPast
    var variantIndex = 0
    var idleWatch: Task<Void, Never>?
    var companionAway = false
    var speech: Speech?
    var speechTask: Task<Void, Never>?
    var speechShownAt = Date.distantPast
    var lineIndex: [OnboardingStep: Int] = [:]
    static let quietBeforeNudge = 6.0
    static let nudgeGap = 7.0

    var stepValue: OnboardingStep { OnboardingStep(rawValue: step) ?? .plan }
    var plan: FirstWeekPlan { FirstWeekPlan(answers) }

    // MARK: lifecycle

    func start(size: CGSize, safeArea: EdgeInsets) async {
        screen = size
        safeTop = safeArea.top
        safeBottom = safeArea.bottom
        planner = PenPlanner(width: Double(size.width))
        busy = true
        try? await waitForLayout()
        while !signedIn, !Task.isCancelled { try? await Task.sleep(for: .milliseconds(100)) }
        guard !welcomedBack else { return }
        startIdleWatch()
        do { try await arrive(0) } catch { return }
        finishTurn()
    }

    func stop() {
        advanceTask?.cancel()
        idleWatch?.cancel()
        moodTasks.values.forEach { $0.cancel() }
    }

    private func waitForLayout() async throws {
        for _ in 0..<60 where frames[.title(Self.lastStep)] == nil { try await Task.sleep(for: .milliseconds(50)) }
    }

    // MARK: moving between screens

    func next() {
        guard step < Self.lastStep, answers.canContinue(from: stepValue) else { return }
        if busy { queued = true; return }
        advanceTask = Task { await advance() }
    }

    private func advance() async {
        busy = true
        queued = false
        do {
            try await commit(step)
            if stepValue == .plan, invitedBy != nil {
                finishOnboarding()   // someone else's plan already covers them: no paywall
                return
            }
            if step == OnboardingStep.coach.rawValue {
                try await liftOff()
                step += 1
                try await wait(0.2)
            } else {
                step += 1
                while !answers.isAsked(stepValue) { step += 1 }
            }
            try await arrive(step)
            if stepValue == .building {
                try await runBuilding()
                try await commit(step)
                step += 1
                try await arrive(step)
            }
        } catch { return }
        finishTurn()
    }

    /// A Continue pressed while the pen was still drawing is honoured once it finishes.
    private func finishTurn() {
        busy = false
        let again = queued && step < Self.lastStep && answers.canContinue(from: stepValue)
        queued = false
        if again { next() }
    }

    func back() {
        guard !busy, !purchased, step > 0, step < Self.lastStep else { return }
        busy = true
        // The building screen plays once; going back from the plan skips over it.
        var target = step - 1
        while OnboardingStep(rawValue: target) == .building || !answers.isAsked(OnboardingStep(rawValue: target) ?? .plan) { target -= 1 }
        for page in target + 1...step {
            fade(arrivals[page])
            fade(commits[page - 1])
            arrivals[page] = []
            commits[page - 1] = []
        }
        if target == OnboardingStep.coach.rawValue { companionState = .hidden }
        step = target
        if companionAway, !companionHidesOnPage { Task { await dropCompanionIn() } }
        if let s = snapshots[step] { planner.restore(s) }
        camera(to: step, duration: 0.7)
        advanceTask = Task {
            try? await wait(0.7)
            busy = false
        }
    }

    // MARK: account
    // SS-0021: sign-in is simulated until there is a backend. Nothing is sent anywhere, and any six digits work.

    func chooseEmail() { authStage = .email }

    /// "Not Anna? Sign in as someone else."
    func signInAsSomeoneElse() {
        member = nil
        authStage = .choose
    }

    /// The emailed link works once, for 15 minutes.
    func expireLink() {
        authCode = ""
        authStage = .expired
    }

    func resendFromExpired() async {
        await sendLink()
    }

    /// Prototype hooks: the preview jumps straight to a screen with a made-up member.
    func previewAuth(_ stage: AuthStage) {
        authEmail = "anna.hart@example.com"
        member = KnownMember(firstName: "Anna", coach: .miso, method: .apple)
        if stage == .invited { invitedBy = "Sam" }
        authStage = stage
    }

    func useDifferentEmail() {
        authCode = ""
        authStage = .email
    }

    var canSendLink: Bool { EmailAddress.normalised(authEmail) != nil }

    func sendLink() async {
        guard canSendLink, !authBusy else { return }
        authBusy = true
        try? await wait(0.9)
        authBusy = false
        authCode = ""
        authStage = .sent
    }

    func signIn(with provider: AuthProvider) async {
        guard !authBusy else { return }
        authBusy = true
        try? await wait(1.0)
        authBusy = false
        completeAuth()
    }

    /// The code from the email, for opening it on another device.
    func enter(code: String) async {
        authCode = String(code.filter(\.isNumber).prefix(6))
        guard authCode.count == 6, !authBusy else { return }
        authBusy = true
        try? await wait(0.7)
        authBusy = false
        completeAuth()
    }

    /// Stands in for tapping the emailed link.
    func openEmailLink() { completeAuth() }

    /// A known member goes to the app, not to the questions; the prototype has no app, so it says so.
    private func completeAuth() {
        signedIn = true
        welcomedBack = member != nil
    }

    /// Plays only the loading moment, for the preview window.
    func previewBuilding(size: CGSize) async {
        screen = size
        step = OnboardingStep.building.rawValue
        try? await runBuilding()
    }

    /// The loading moment: the pen climbs; at the end the coach pops in and cheers.
    // SS-0020: about 7 seconds; Reduce Motion shortens it to a blink.
    private func runBuilding() async throws {
        buildMood = .idle
        buildDone = false
        buildStart = Date()
        try await wait(7.4)
        buildMood = .cheer
        buildDone = true
        try await wait(1.7)
    }

    func camera(to index: Int, duration: Double = 0.9) {
        let curve = Animation.timingCurve(0.65, 0, 0.35, 1, duration: reduceMotion ? 0.001 : duration)
        withAnimation(curve) { cameraY = -CGFloat(index) * screen.height }
    }

    private func fade(_ list: [InkStroke]?) {
        guard let list else { return }
        withAnimation(.easeOut(duration: 0.38)) { list.forEach { $0.opacity = 0 } }
        Task {
            try? await Task.sleep(for: .milliseconds(400))
            let gone = Set(list.map(\.id))
            strokes.removeAll { gone.contains($0.id) }
        }
    }

    // MARK: paywall and helpers
    // SS-0020: purchases are simulated until in-app purchase is wired up. Nothing is charged.

    func setHelpers(_ count: Int) { helperCount = min(max(count, 1), Pricing.maxHelpers) }

    func purchase() async {
        guard !purchasing, !purchased else { return }
        purchasing = true
        try? await wait(1.3)
        purchasing = false
        purchased = true
        pulseCompanion(.cheer, for: 2)
        if plannedHelpers > 0 { next() } else { finishOnboarding() }
    }

    func restorePurchases() async {
        restoreNote = "Looking…"
        try? await wait(0.9)
        restoreNote = "No earlier purchase found on this Apple ID."
    }

    /// The link and message are made up in the prototype; sharing is the system share sheet.
    func markInviteSent() { inviteSent = true }

    func previewInvite() {
        invitedBy = "Sam"
        authStage = .invited
    }

    /// The trial runs from today; the first payment is when it ends.
    var trialEnds: Date { Calendar.current.date(byAdding: .day, value: Pricing.trialDays, to: Date()) ?? Date() }

    /// The page gives way to the "all set" screen.
    func finishOnboarding() {
        guard !ended else { return }
        hideSpeech()
        busy = true
        pulseCompanion(.cheer, for: 2)
        withAnimation(.easeInOut(duration: reduceMotion ? 0.001 : 0.5)) { ended = true }
        advanceTask = Task {
            try? await wait(0.35)
            withAnimation(.easeOut(duration: 0.5)) { endVisible = true }
        }
    }

    // MARK: answers and the small reactions to them

    func pick(coach: Coach) {
        answers.select(coach: coach)
        pulseShow(.hello, for: 2.0)
    }

    func pick(safety flag: SafetyFlag) {
        answers.toggle(safety: flag)
        pulseCompanion(flag == .eatingHistory ? .comfort : .gotit, for: 1.8)
    }

    func pick(experience: Experience) {
        answers.select(experience: experience)
        pulseCompanion(.encourage, for: 1.6)
    }

    func pick(activity: ActivityLevel) {
        answers.select(activity: activity)
        pulseCompanion(.gotit, for: 1.4)
    }

    func pick(foodGoal: FoodGoal) {
        answers.select(foodGoal: foodGoal)
        pulseCompanion(.encourage, for: 1.6)
    }

    func setWeeklyKilos(_ kilos: Double) { answers.select(weeklyKilos: kilos) }

    func pick(foodView: FoodView) {
        withAnimation(.snappy(duration: 0.25)) { answers.select(foodView: foodView) }
        pulseCompanion(foodView == .habitsOnly ? .comfort : .gotit, for: 1.6)
    }

    func pick(equipment: Equipment) {
        answers.select(equipment: equipment)
        pulseCompanion(.lifting, for: 1.6)
    }

    func agree(_ value: Bool) {
        answers.consent(value)
        if value { pulseCompanion(.gotit, for: 1.4) }
    }

    func pick(stage: Stage) {
        answers.select(stage: stage)
        pulseCompanion(stage == .surg ? .comfort : .gotit, for: stage == .surg ? 3 : 1.6)
    }

    /// Each goal makes the coach act out its theme: strength lifts, sleep dozes, energy stretches.
    func toggle(goal: Goal) {
        let on = !answers.goals.contains(goal)
        if !answers.toggle(goal: goal) {
            shakeTicks[goal, default: 0] += 1
        } else if on {
            switch goal.theme {
            case .strength: pulseCompanion(.lifting, for: 2.4)
            case .habits: pulseCompanion(.proud, for: 1.8)
            case .energy: pulseCompanion(.stretching, for: 2.6)
            case .sleep: pulseCompanion(.resting, for: 2.4)
            }
        }
    }

    /// Tapping a coach makes it react. The docked coach says the next line for the screen it is on.
    func poke() {
        guard companionState == .docked, !companionAway else {
            if companionState != .docked { pulseShow(.proud, for: 1.8) }
            return
        }
        let lines = CoachLines.lines(for: stepValue, coachName: answers.displayName)
        guard !lines.isEmpty else { pulseCompanion(.hello, for: 1.8); return }
        let next = ((lineIndex[stepValue] ?? -1) + 1) % lines.count
        lineIndex[stepValue] = next
        say(lines[next])
    }

    func pulseHero(_ mood: CoachMood, for seconds: Double) {
        heroMood = mood
        schedule("hero", seconds) { $0.heroMood = .idle }
    }

    func toggle(day: Weekday) {
        if answers.toggle(day: day), answers.days.contains(day) { pulseCompanion(.lifting, for: 1.1) }
    }

    func pulseShow(_ mood: CoachMood, for seconds: Double) {
        showMood = mood
        schedule("show", seconds) { $0.showMood = .idle }
    }

    func pulseCompanion(_ mood: CoachMood, for seconds: Double) {
        guard companionState == .docked || companionState == .flying else { return }
        companionMood = mood
        schedule("companion", seconds) { $0.companionMood = .idle }
    }

    private func schedule(_ key: String, _ seconds: Double, _ reset: @escaping @MainActor (OnboardingFlow) -> Void) {
        moodTasks[key]?.cancel()
        moodTasks[key] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(seconds))
            guard !Task.isCancelled, let self else { return }
            reset(self)
        }
    }

    // MARK: timing

    func wait(_ seconds: Double) async throws {
        try await Task.sleep(for: .seconds(reduceMotion ? min(seconds, 0.03) : seconds))
    }
}
