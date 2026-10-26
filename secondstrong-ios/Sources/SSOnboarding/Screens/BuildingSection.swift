import SwiftUI
import SSCore
import SSDesign

/// "Building your program": a pen line climbs across the page, one milestone per step,
/// Ends on her protein target, and the coach pops in to cheer.
struct BuildingSection: View {
    let flow: OnboardingFlow

    private static let curveDuration = 6.2
    private static let stepStart = 0.3
    private static let stepGap = 1.25

    private var steps: [String] {
        let days = flow.answers.days.count
        return ["Reading your answers", "Working out your numbers", "Picking where to start",
                "Fitting your \(days) days", "Drafting your week"]
    }

    var body: some View {
        SectionFrame(index: OnboardingStep.building.rawValue, flow: flow, scene: .plan) {
            MetaLabel("A moment")
            SectionTitle("Building your", emphasis: "program.", index: OnboardingStep.building.rawValue, size: 30)
            TimelineView(.animation(paused: paused)) { context in
                let elapsed = self.elapsed(context.date)
                VStack(alignment: .leading, spacing: 14) {
                    statusList(elapsed)
                    result(elapsed)
                }
            }
            Spacer(minLength: 0)
            Color.clear.frame(height: 1).penAnchor(.next(OnboardingStep.building.rawValue))
        }
        .overlay {
            TimelineView(.animation(paused: paused)) { context in
                climb(elapsed(context.date))
            }
        }
    }

    private var paused: Bool { flow.buildStart == nil || flow.buildDone || flow.reduceMotion }

    private func elapsed(_ date: Date) -> Double {
        flow.reduceMotion ? 99 : flow.buildStart.map { date.timeIntervalSince($0) } ?? 0
    }

    // MARK: status lines

    private func statusList(_ elapsed: Double) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(Array(steps.enumerated()), id: \.offset) { i, text in
                let on = elapsed >= Self.stepStart + Double(i) * Self.stepGap
                let done = elapsed >= Self.stepStart + Double(i) * Self.stepGap + Self.stepGap * 0.8
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(done ? Palette.ivory : .clear)
                        .frame(width: 18, height: 18)
                        .background(Circle().fill(done ? Palette.ink : .clear))
                        .overlay(Circle().stroke(done ? Palette.ink : Palette.ink.opacity(0.33), lineWidth: 1.5))
                    Text(text)
                        .font(SSFont.display(15, weight: 400))
                        .foregroundStyle(done ? Palette.ink : Palette.ink2)
                }
                .opacity(on ? 1 : 0)
                .offset(y: on ? 0 : 6)
                .animation(.easeOut(duration: 0.4), value: on)
                .animation(.easeOut(duration: 0.3), value: done)
            }
        }
        .padding(.top, 6)
        .accessibilityElement(children: .combine)
    }

    // MARK: the climbing line, over the paper hills
    // The route and flag are fitted by eye to design/onboarding/paper plan art (fractions of the picture).

    private func route(in size: CGSize) -> (path: Path, flag: CGPoint, marks: [CGPoint]) {
        let w = size.width, h = w * PaperArt.Scene.plan.aspect, top = size.height - h
        func p(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: x * w, y: top + y * h) }
        var path = Path()
        path.move(to: p(0.0, 1.0))
        path.addCurve(to: p(0.42, 0.70), control1: p(0.18, 0.97), control2: p(0.30, 0.80))
        path.addCurve(to: p(0.78, 0.43), control1: p(0.55, 0.60), control2: p(0.68, 0.52))
        path.addCurve(to: p(0.80, 0.36), control1: p(0.79, 0.41), control2: p(0.80, 0.39))
        return (path, p(0.80, 0.36), [p(0.42, 0.70), p(0.78, 0.43)])
    }

    private func climb(_ elapsed: Double) -> some View {
        let t = easeInOut(min(elapsed / Self.curveDuration, 1))
        return GeometryReader { proxy in
            let r = route(in: proxy.size)
            ZStack(alignment: .topLeading) {
                r.path.trimmedPath(from: 0, to: t)
                    .stroke(Palette.pen, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                milestone("protein", at: r.marks[0], lit: stepDone(1, elapsed))
                milestone("training", at: r.marks[1], lit: stepDone(3, elapsed))
                CoachView(flow.answers.coach, mood: flow.buildMood, animated: flow.stepValue == .building)
                    .frame(width: 130, height: 130)
                    .scaleEffect(flow.buildDone ? 1 : 0.2, anchor: .bottom)
                    .opacity(flow.buildDone ? 1 : 0)
                    .animation(.spring(duration: 0.6, bounce: 0.45), value: flow.buildDone)
                    .position(x: min(r.flag.x, proxy.size.width - 62), y: r.flag.y - 40)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func stepDone(_ i: Int, _ elapsed: Double) -> Bool {
        elapsed >= Self.stepStart + Double(i) * Self.stepGap + Self.stepGap * 0.8
    }

    private func milestone(_ label: String, at point: CGPoint, lit: Bool) -> some View {
        ZStack {
            Circle().fill(lit ? Palette.ink : Palette.ivory).frame(width: 16, height: 16)
                .overlay(Circle().stroke(Palette.ivory, lineWidth: 2))
                .scaleEffect(lit ? 1 : 0.6)
                .opacity(lit ? 1 : 0)
            Text(label).font(SSFont.hand(18)).foregroundStyle(Palette.ink)
                .offset(x: -6, y: -24)
                .opacity(lit ? 1 : 0)
        }
        .position(point)
        .animation(.spring(duration: 0.4, bounce: 0.4), value: lit)
    }

    private func easeInOut(_ x: Double) -> Double { x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2 }

    // MARK: the result

    private func result(_ elapsed: Double) -> some View {
        let show = elapsed >= Self.curveDuration + 0.3
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                (Text("\(flow.plan.proteinGrams)").font(SSFont.display(56)).tracking(-2.8)
                    + Text("g").font(SSFont.display(22)).tracking(-1))
                    .foregroundStyle(Palette.ink)
                MetaLabel("protein a day")
            }
            if let energy = flow.plan.energy {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    (Text(energy.target.formatted()).font(SSFont.display(34)).tracking(-1.4)
                        + Text(" kcal").font(SSFont.display(16)).tracking(-0.4))
                        .foregroundStyle(Palette.ink)
                    MetaLabel("a day")
                }
            }
        }
        .opacity(show ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: show)
        .accessibilityElement(children: .combine)
    }
}
