import SwiftUI
import SSCore
#if canImport(WidgetKit)
import WidgetKit
#endif

enum AppTab: String, CaseIterable, Identifiable {
    /// Today sits in the middle of the bar.
    case food, train, today, coach, progress

    var id: String { rawValue }

    var index: Int { Self.allCases.firstIndex(of: self) ?? 0 }

    /// The tab a swipe leads to: left goes right along the bar. Slanted or short drags lead nowhere, and the ends do not wrap.
    func after(dx: Double, dy: Double, predictedDx: Double) -> AppTab? {
        let travel = abs(predictedDx) > abs(dx) * 2 ? predictedDx : dx
        guard abs(travel) >= 60, abs(dy) < abs(dx) * 0.5 else { return nil }
        return neighbour(travel < 0 ? 1 : -1)
    }

    func neighbour(_ step: Int) -> AppTab? {
        let target = index + step
        return Self.allCases.indices.contains(target) ? Self.allCases[target] : nil
    }

    var symbol: String {
        switch self {
        case .today: "house"
        case .food: "fork.knife"
        case .train: "dumbbell"
        case .coach: "bubble.left"
        case .progress: "chart.bar"
        }
    }

    var title: String { rawValue.capitalized }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    let fromCoach: Bool
    var time = ""
    var replies: [String] = []
    var showsSession = false
    var kind: CheckIn?
    var photo: Data?
    var meal: MealEstimate?
    var mealState = MealState.none
    var progress: ResponseProgress?
    var outcome = ResponseOutcome.completed
    /// While the answer is being written: the whole text, when writing began and how fast letters appear.
    var writing: Writing?
    var retry: Retry?
}

struct Writing: Equatable {
    var full: String
    var start: Date
    var speed: Double

    /// How many characters are showing right now.
    func shown(at date: Date = Date()) -> Int { Int(TokenStream.revealed(total: full.count, elapsed: date.timeIntervalSince(start), speed: speed)) }
}

/// What it takes to ask again after a stop or a failure.
struct Retry: Equatable {
    var question: String
    var answer: String
    var photo: Bool
    var meal: MealEstimate?
}

/// Where the coach is in answering: the stages it will go through, and which one it is on.
struct ResponseProgress: Equatable {
    var stages: [ResponseStage]
    var current = 0

    var stage: ResponseStage { stages[current] }
    var done: [ResponseStage] { Array(stages[..<current]) }
}

enum MealState { case none, added, dismissed }

struct ProfileSettings: Equatable {
    var units = "Metric"
    var appearance = "System"
    var remind = true
    var useHealthAnswers = true
    var improve = false
    /// The lock screen can be seen by anyone, so by default the widgets there show no numbers.
    var hideLockScreenNumbers = true
}


/// The Today and Coach tabs' state. Prototype data only: no network, nothing stored (SS-0025, SS-0026).
@MainActor @Observable
final class TodayModel {
    var summary: TodaySummary { didSet { shareWithWidgets() } }
    var tab = AppTab.today
    var messages: [ChatMessage] = []
    var draft = ""
    var settings = CheckInSettings.standard { didSet { refreshCheckIns() } }
    var unread = 0
    var voice: VoiceSession?
    var showCheckIns = false
    var showProfile = false
    var showAttach = false
    var diary = FoodDiary.sample
    var camera: CameraFlow?
    var toast: String?
    var profile = ProfileSettings() { didSet { shareWithWidgets() } }
    private var scans = 0
    private let widgetStore: WidgetStore
    /// 1 for the real pace; tests use 0 to skip the waiting.
    var pace = 1.0
    private var work: Task<Void, Never>?
    private var failNextPhoto = false

    var isResponding: Bool { messages.contains { $0.progress != nil } }
    /// Tests turn this off so snapshots show the still picture, since offscreen windows do not draw video.
    var animateCoach = true
    let minuteOfDay: Int

    init(summary: TodaySummary = .sample, hour: Int = Calendar.current.component(.hour, from: Date()),
         minute: Int = Calendar.current.component(.minute, from: Date()), widgetStore: WidgetStore = WidgetStore()) {
        self.summary = summary
        self.widgetStore = widgetStore
        // Before 7 am it is still last evening's day, so the thread shows everything she was sent.
        minuteOfDay = hour < 7 ? 24 * 60 : hour * 60 + minute
        refreshCheckIns(initial: true)
        shareWithWidgets()
    }

    /// Leaves the protein summary where the widgets can read it and asks them to redraw (SS-0030).
    private func shareWithWidgets() {
        widgetStore.save(WidgetSnapshot(summary: summary, hour: Calendar.current.component(.hour, from: Date()),
                                        hideLockScreenNumbers: profile.hideLockScreenNumbers))
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    /// Changes whenever the thread grows, including while an answer streams in, so the view can keep the end in sight.
    var scrollKey: String { "\(messages.count)-\(messages.last?.text.count ?? 0)-\(messages.last?.progress?.current ?? -1)" }

    var hour: Int { min(23, minuteOfDay / 60) }
    var part: DayPart { DayPart.at(hour: hour) }
    var coachLines: [String] { TodayLines.coach(for: summary, hour: hour) }

    func open(_ tab: AppTab) {
        withAnimation(.easeInOut(duration: 0.28)) { self.tab = tab }
        if tab == .coach { unread = 0 }
    }

    func toggle(_ habit: Habit) {
        withAnimation(.spring(duration: 0.3, bounce: 0.35)) { summary.toggle(habit) }
    }

    func reply(_ text: String, to message: ChatMessage) {
        if let i = messages.firstIndex(of: message) { messages[i].replies = [] }
        ask(text)
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        // Prototype switches for showing the failed states: /fail breaks the next text answer, /failphoto the next photo.
        if text == "/failphoto" { failNextPhoto = true; return }
        ask(text, failing: text == "/fail")
    }

    /// Starting the session is simulated as finishing it, so the coach can write once afterwards (SS-0026).
    func finishSession() {
        guard summary.session != nil, !summary.done.contains(.strength) else { return }
        toggle(.strength)
        guard settings.afterSession else { return }
        let message = CheckInPlanner.afterSession(summary: summary, minuteOfDay: minuteOfDay)
        coachWrites(ChatMessage(text: message.text, fromCoach: true, time: message.time, kind: .afterSession))
    }

    /// A photo sent to the coach. The prototype "reads" it with made-up numbers; the real scanner is not connected, and the
    /// photo stays on the phone (SS-0028).
    func sendPhoto(_ data: Data) {
        for i in messages.indices { messages[i].replies = [] }
        var photo = ChatMessage(text: "", fromCoach: false)
        photo.photo = data
        messages.append(photo)
        let meal = MealEstimate.prototype(scans)
        scans += 1
        let broken = failNextPhoto
        failNextPhoto = false
        respond(TodayLines.mealReply(meal, summary: summary), question: "", photo: true, meal: meal, failure: broken ? .photo : nil)
    }

    private func ask(_ text: String, failing: Bool = false) {
        messages.append(ChatMessage(text: text, fromCoach: false))
        respond(failing ? "Let me think about that for a moment and come back to you." : TodayLines.reply(to: text), question: text, photo: false,
                failure: failing ? .network : nil)
    }

    /// Stops the answer where it is. What has arrived stays, marked as stopped.
    func stop() {
        work?.cancel()
        guard let i = messages.lastIndex(where: { $0.progress != nil }) else { return }
        if let writing = messages[i].writing { messages[i].text = TokenStream.wholeWords(String(writing.full.prefix(writing.shown()))) }
        messages[i].writing = nil
        messages[i].progress = nil
        messages[i].outcome = .stopped
        work = nil
    }

    /// Asks again after a stop or a failure: the old answer is dropped and a new one is made.
    func retry(_ message: ChatMessage) {
        guard let retry = message.retry, let i = messages.firstIndex(where: { $0.id == message.id }), !isResponding else { return }
        messages.remove(at: i)
        respond(retry.answer, question: retry.question, photo: retry.photo, meal: retry.meal)
    }

    /// The coach answers in stages (thinking, looking, estimating) and then the words arrive a piece at a time (SS-0029).
    private func respond(_ answer: String, question: String, photo: Bool, meal: MealEstimate? = nil, failure: ResponseFailure? = nil) {
        let plan = ResponsePlan.stages(photo: photo)
        var reply = ChatMessage(text: "", fromCoach: true)
        reply.progress = ResponseProgress(stages: plan.map(\.stage))
        reply.retry = Retry(question: question, answer: answer, photo: photo, meal: meal)
        let id = reply.id
        messages.append(reply)
        func update(_ change: (inout ChatMessage) -> Void) {
            guard let i = messages.firstIndex(where: { $0.id == id }) else { return }
            change(&messages[i])
        }
        work = Task {
            for (index, step) in plan.enumerated() {
                update { $0.progress?.current = index }
                if step.stage == .writing { break }
                if failure == .photo, step.stage == .estimating {
                    try? await Task.sleep(for: .seconds(step.seconds * pace))
                    guard !Task.isCancelled else { return }
                    update { $0.progress = nil; $0.text = ""; $0.outcome = .failed(.photo) }
                    return
                }
                try? await Task.sleep(for: .seconds(step.seconds * pace))
                guard !Task.isCancelled else { return }
            }
            let speed = pace > 0 ? TokenStream.charactersPerSecond / pace : 1e9
            update { $0.writing = Writing(full: answer, start: Date(), speed: speed) }
            let total = TokenStream.duration(total: answer.count, speed: speed)
            if failure == .network {
                try? await Task.sleep(for: .seconds(total * 0.4))
                guard !Task.isCancelled else { return }
                update { message in
                    message.text = TokenStream.wholeWords(String(answer.prefix(message.writing?.shown() ?? 0)))
                    message.writing = nil
                    message.progress = nil
                    message.outcome = .failed(.network)
                }
                return
            }
            try? await Task.sleep(for: .seconds(total))
            guard !Task.isCancelled else { return }
            update {
                $0.text = answer
                $0.writing = nil
                $0.progress = nil
                $0.meal = meal
            }
            if tab != .coach { unread += 1 }
        }
    }

    func openCamera() {
        camera = CameraFlow(scans: scans, pace: pace)
    }

    func closeCamera() {
        scans = camera?.photoCount ?? scans
        camera = nil
    }

    /// Adds what the camera read to the day, the totals and the widgets, then shows a short confirmation.
    func addFromCamera(_ estimate: MealEstimate) {
        let slot = min(minuteOfDay, 24 * 60 - 1)
        closeCamera()
        withAnimation(.spring(duration: 0.4, bounce: 0.25)) {
            diary.add(estimate, minute: slot)
            summary.log(estimate)
        }
        toast = "Added · \(estimate.proteinGrams)g protein"
        Task {
            try? await Task.sleep(for: .seconds(2.4 * pace))
            toast = nil
        }
    }

    func log(_ meal: ChatMessage) {
        guard let estimate = meal.meal, let i = messages.firstIndex(where: { $0.id == meal.id }), messages[i].mealState == .none else { return }
        withAnimation(.spring(duration: 0.3, bounce: 0.3)) {
            diary.add(estimate, minute: min(minuteOfDay, 24 * 60 - 1))
            summary.log(estimate)
            messages[i].mealState = .added
        }
        messages.append(ChatMessage(text: summary.proteinToGo == 0 ? "Added. You've reached your protein today." : "Added. \(summary.proteinToGo)g protein to go.", fromCoach: true))
    }

    func dismiss(_ meal: ChatMessage) {
        guard let i = messages.firstIndex(where: { $0.id == meal.id }) else { return }
        messages[i].mealState = .dismissed
        messages.append(ChatMessage(text: "No problem. Tell me what it was and I'll note it.", fromCoach: true))
    }

    func setShowsCalories(_ on: Bool) {
        withAnimation(.snappy(duration: 0.25)) { summary.setShowsCalories(on) }
    }

    func openVoice() {
        voice = VoiceSession { [weak self] heard, reply in self?.recordVoice(heard, reply) }
    }

    func closeVoice() {
        voice?.stop()
        voice = nil
    }

    private func recordVoice(_ heard: String, _ reply: String) {
        messages.append(ChatMessage(text: heard, fromCoach: false))
        messages.append(ChatMessage(text: reply, fromCoach: true))
    }

    private func coachWrites(_ message: ChatMessage) {
        messages.append(message)
        if tab != .coach { unread += 1 }
    }

    /// The thread is what the coach has written so far today under her settings; turning a check-in off takes it out again.
    private func refreshCheckIns(initial: Bool = false) {
        let due = CheckInPlanner.due(settings: settings, summary: summary, minuteOfDay: minuteOfDay)
        let kinds = Set(due.map(\.kind))
        messages.removeAll { message in message.kind.map { $0 != .afterSession && !kinds.contains($0) } ?? false }
        let have = Set(messages.compactMap(\.kind))
        var added: [ChatMessage] = []
        for item in due where !have.contains(item.kind) {
            added.append(ChatMessage(text: item.text, fromCoach: true, time: item.time, replies: item.replies, showsSession: item.showsSession, kind: item.kind))
        }
        messages.insert(contentsOf: added, at: messages.firstIndex { $0.kind == nil } ?? messages.endIndex)
        if tab != .coach { unread += added.count }
    }
}
