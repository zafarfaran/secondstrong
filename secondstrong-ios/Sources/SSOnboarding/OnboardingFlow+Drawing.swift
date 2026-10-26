import SwiftUI
import SSCore

/// Grammar: underline the question, ring the committed answer, draw real interface.
extension OnboardingFlow {
    // MARK: strokes

    @discardableResult
    func draw(_ stroke: PenPlanner.Stroke, delay: Double = 0) -> InkStroke {
        let ink = InkStroke(
            path: Path(segments: stroke.segments),
            duration: reduceMotion ? 0.001 : stroke.duration,
            delay: reduceMotion ? 0 : delay)
        strokes.append(ink)
        switch bucket {
        case .arrive(let i): arrivals[i, default: []].append(ink)
        case .commit(let i): commits[i, default: []].append(ink)
        case .none: break
        }
        return ink
    }

    func ink(_ stroke: PenPlanner.Stroke) async throws {
        draw(stroke)
        try await wait(stroke.duration)
    }

    // MARK: arrive: down the margin, curve in, underline the question

    func arrive(_ index: Int) async throws {
        bucket = .arrive(index)
        camera(to: index)
        companionTransition(to: OnboardingStep(rawValue: index))
        guard let title = frames[.title(index)] else { return }
        try await ink(planner.underline(title))
        switch OnboardingStep(rawValue: index) {
        case .welcome: try await drawCoachOutline()
        case .days: try await drawRuler()
        case .plan: try await drawPlan()
        default: break
        }
        snapshots[index] = planner.snapshot
    }

    // MARK: commit: ring what you chose, then back to the margin

    func commit(_ index: Int) async throws {
        bucket = .commit(index)
        planner.leaveRing()
        switch OnboardingStep(rawValue: index) {
        case .coach: try await commitCoach()
        case .stage:
            if let stage = answers.stage { try await ring(.stage(stage), pad: 6) }
        case .goals:
            for goal in Goal.allCases where answers.goals.contains(goal) { try await ring(.goal(goal), pad: 5) }
        case .safety:
            for flag in SafetyFlag.allCases where answers.safety.contains(flag) { try await ring(.safety(flag), pad: 5) }
        case .training:
            if let level = answers.experience { try await ring(.experience(level), pad: 5) }
            if let place = answers.equipment { try await ring(.equipment(place), pad: 5) }
        case .activity:
            if let level = answers.activity { try await ring(.activity(level), pad: 5) }
        case .goal:
            if let goal = answers.foodGoal { try await ring(.foodGoal(goal), pad: 5) }
        case .days:
            for day in answers.days { try await ring(.day(day), pad: 3) }
        default: break
        }
        if let next = frames[.next(index)] { try await ink(planner.toMargin(y: next.y - 18)) }
    }

    private func ring(_ anchor: PenAnchor, pad: Double) async throws {
        guard let rect = frames[anchor] else { return }
        try await ink(planner.ring(around: rect, pad: pad))
    }

    /// Ring the coach, then a U-turn round the right and underline the name, right to left.
    private func commitCoach() async throws {
        try await ring(.coachShow, pad: 4)
        guard let field = frames[.nameField] else { return }
        let width = max(40, min(field.width, Double(answers.name.count) * 15 + 10))
        let y = field.maxY + 5
        try await ink(planner.flow([
            .curve(planner.rightMargin, (planner.position.y + y) / 2, dx: 0, dy: 1),
            .curve(field.x + width + 4, y, dx: -1, dy: 0),
            .line(field.x - 4, y),
        ]))
        planner.leaveRing()
    }

    // MARK: the pen draws real interface

    /// Down the right margin, a scoop under the coach, then its outline. The coach fades in over it.
    private func drawCoachOutline() async throws {
        guard let host = frames[.hero], let sub = frames[.sub] else { return }
        let size = min(host.width, host.height)
        let scale = size / 200
        let origin = Point(host.x + (host.width - size) / 2, host.y)
        let parts = answers.coach.outlinePaths.map { SVGPath.parse($0).map { $0.transformed(scale: scale, offset: origin) } }
        guard let first = parts.first, case .move(let start)? = first.first else { return }
        var heading = Point(0, 1)
        if first.count > 1, case .cubic(let c1, let c2, _) = first[1] {
            heading = ((c1 == start ? c2 : c1) - start).normalized
        }
        try await ink(planner.flow(
            [.curve(planner.rightMargin, sub.maxY + 10, dx: 0, dy: 1),
             .curve(start.x, start.y, dx: heading.x, dy: heading.y, tension: 0.55)],
            end: start, endDirection: heading, pace: .init(maximum: 1.4)))

        var outlines: [InkStroke] = []
        var finish = 0.0
        for (j, segments) in parts.enumerated() {
            let duration = min(1.3, max(0.38, segments.length / 1000))
            outlines.append(draw(.init(segments: segments, duration: duration), delay: Double(j) * 0.12))
            finish = max(finish, duration + Double(j) * 0.12)
        }
        try await wait(finish)
        withAnimation(.easeInOut(duration: 0.5)) { heroVisible = true }
        pulseHero(.hello, for: 3.2)
        withAnimation(.easeInOut(duration: 0.6)) { outlines.forEach { $0.opacity = 0 } }
    }

    /// A round U-turn into the ruler, then a soft bump under each day, right to left.
    private func drawRuler() async throws {
        guard let week = frames[.week] else { return }
        let y = week.maxY + 12
        let centres = Weekday.allCases.map { frames[.day($0)]?.midX ?? week.midX }
        var bumps = ""
        for i in stride(from: 6, through: 0, by: -1) {
            let x = centres[i]
            bumps += " L\(f(x + 14)) \(f(y)) C\(f(x + 7)) \(f(y)) \(f(x + 7)) \(f(y - 9)) \(f(x)) \(f(y - 9))"
            bumps += " C\(f(x - 7)) \(f(y - 9)) \(f(x - 7)) \(f(y)) \(f(x - 14)) \(f(y))"
        }
        try await ink(planner.flow(
            [.curve(planner.rightMargin - 6, y, dx: -1, dy: 0, tension: 0.6)],
            extra: bumps, end: Point(centres[0] - 14, y), endDirection: Point(-1, 0), pace: .init(maximum: 2.2)))
    }

    /// Protein line, the week with a dot where you train, the coach's note, then a pill round the button.
    private func drawPlan() async throws {
        guard let number = frames[.pnum], let bar = frames[.bar], let week = frames[.wk2], let button = frames[.start] else { return }
        pulseCompanion(.thinking, for: 12)
        let right = planner.rightMargin - 8
        let barY = bar.y + 6
        try await ink(planner.flow([.curve(right, barY, dx: -1, dy: 0, tension: 0.6), .line(number.x - 2, barY)]))
        withAnimation(.easeInOut(duration: 0.5)) { proteinLit = true }

        let weekY = week.maxY + 8
        let row = planner.flow([.curve(week.x + 4, weekY, dx: 1, dy: 0, tension: 0.7), .line(right, weekY)], pace: .init(maximum: 2))
        draw(row)
        for day in answers.days {
            guard let dot = frames[.dot(day)] else { continue }
            let at = 0.35 + 0.65 * (dot.midX - week.x) / (right - week.x)
            Task {
                try? await wait(row.duration * min(1, at))
                withAnimation(.spring(duration: 0.38, bounce: 0.4)) { _ = shownDots.insert(day) }
            }
        }
        try await wait(row.duration)

        noteText = plan.coachNote
        withAnimation(.linear(duration: reduceMotion ? 0.001 : 1.1)) { noteProgress = 1 }
        try await wait(0.3)
        if let note = frames[.note] {
            let y = note.maxY + 6
            try await ink(planner.flow([.curve(min(right, note.maxX + 6), y, dx: -1, dy: 0, tension: 0.7), .line(note.x - 4, y)]))
        }
        try await drawPill(around: button)
        withAnimation(.easeInOut(duration: 0.4)) { startReady = true }
        pulseCompanion(.proud, for: 2)
    }

    /// A curve down into the button, drawn round. It then becomes the real button.
    private func drawPill(around b: Rect) async throws {
        let r = b.height / 2
        let bottom = b.maxY
        let pill = " L\(f(b.maxX - r)) \(f(bottom)) A\(f(r)) \(f(r)) 0 0 0 \(f(b.maxX)) \(f(b.y + r))"
            + " A\(f(r)) \(f(r)) 0 0 0 \(f(b.maxX - r)) \(f(b.y)) L\(f(b.x + r)) \(f(b.y))"
            + " A\(f(r)) \(f(r)) 0 0 0 \(f(b.x)) \(f(b.y + r)) A\(f(r)) \(f(r)) 0 0 0 \(f(b.x + r)) \(f(bottom))"
        try await ink(planner.flow(
            [.curve(b.x + r, bottom, dx: 1, dy: 0, tension: 0.6)],
            extra: pill, end: Point(b.x + r, bottom), endDirection: Point(1, 0), pace: .init(maximum: 2.4)))
    }

    private func f(_ v: Double) -> String { String(format: "%.1f", v) }
}
