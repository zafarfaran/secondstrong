import SwiftUI
import SSCore
import SSDesign

/// The last screen, right after the free trial starts: the coach cheers, a pen tick is drawn, and two short lines
/// say what happens with the money (spec 1.5). SS-0020: nothing is charged in the prototype.
struct AllSetScreen: View {
    let flow: OnboardingFlow
    let onDone: () -> Void
    @Environment(\.colorScheme) private var scheme
    @State private var appeared = Date()

    var body: some View {
        ZStack(alignment: .bottom) {
            PaperBackground()
            if flow.screen.height >= 740 {
                PaperArt.scene(.plan, dark: scheme == .dark)
                    .resizable().scaledToFit()
                    .frame(width: flow.screen.width)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                hero
                title.padding(.top, 6)
                Text(terms.main)
                    .font(SSFont.display(18, weight: 700))
                    .foregroundStyle(Palette.ink)
                    .padding(.top, 14)
                Text(terms.then)
                    .font(SSFont.display(16, weight: 400))
                    .foregroundStyle(Palette.ink2)
                    .padding(.top, 2)
                if !terms.note.isEmpty {
                    Text(terms.note)
                        .font(SSFont.hand(22))
                        .foregroundStyle(Palette.pen)
                        .padding(.top, 8)
                }
                Spacer(minLength: 0)
                Spacer(minLength: 0).frame(maxHeight: 110)
                PillButton("Go to Today", action: onDone)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 26 + flow.safeBottom)
            }
            .padding(.top, max(40, flow.safeTop + 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { appeared = Date() }
    }

    private var hero: some View {
        ZStack {
            Circle().fill(Palette.apricot.opacity(0.35)).frame(width: 190, height: 190)
            CoachView(flow.answers.coach, mood: .cheer)
                .frame(width: 200, height: 200)
            tick.offset(x: 72, y: 62)
        }
        .frame(width: 210, height: 200)
    }

    /// An ink disc with a check the pen draws on, once the coach has landed.
    private var tick: some View {
        TimelineView(.animation(paused: flow.reduceMotion)) { context in
            let t = flow.reduceMotion ? 1 : min(1, max(0, (context.date.timeIntervalSince(appeared) - 0.5) / 0.5))
            ZStack {
                Circle().fill(Palette.ink).frame(width: 46, height: 46)
                    .scaleEffect(0.6 + 0.4 * min(1, t * 2.5)).opacity(min(1, t * 3))
                Check().trim(from: 0, to: t)
                    .stroke(Palette.ivory, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .frame(width: 22, height: 17)
            }
        }
    }

    private var title: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("You're").font(SSFont.display(34)).tracking(-1.2)
            Text("all set.").font(SSFont.hand(41))
        }
        .foregroundStyle(Palette.ink)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// Two short lines. The price and the first-payment date stay readable (spec 1.5).
    private var terms: (main: String, then: String, note: String) {
        if let sponsor = flow.invitedBy, !flow.purchased {
            return ("Covered by \(sponsor)'s plan", "Nothing to pay", "")
        }
        let ends = flow.trialEnds.formatted(Date.FormatStyle().day().month(.wide).locale(Locale(identifier: "en_GB")))
        let period = flow.billing == .yearly ? "year" : "month"
        return ("Free until \(ends)", "then \(Pricing.text(flow.planPrice)) a \(period)", "Cancel any time in Settings.")
    }

    private struct Check: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.minX, y: rect.midY + 1))
            p.addLine(to: CGPoint(x: rect.width * 0.38, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            return p
        }
    }
}
