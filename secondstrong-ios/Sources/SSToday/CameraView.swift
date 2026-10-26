import SwiftUI
import PhotosUI
import SSCore
import SSDesign

/// The full-screen camera (design A in `design/app/food-camera.html`): viewfinder with brackets and a hint from the coach,
/// then the coach reading the photo, then the result sheet (SS-0032).
struct CameraView: View {
    let model: TodayModel
    let flow: CameraFlow
    @State private var camera = CameraSession()
    @State private var picked: PhotosPickerItem?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                backdrop(size: proxy.size)
                switch flow.phase {
                case .viewfinder: viewfinder(proxy)
                case .reading(let step): reading(step, proxy)
                case .result: CameraResultSheet(model: model, flow: flow).transition(.move(edge: .bottom).combined(with: .opacity))
                case .failed: failedSheet.transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if flow.phase == .result || flow.phase == .failed { roundButton("chevron.left", "Retake") { flow.retake() }.position(x: 42, y: proxy.safeAreaInsets.top + 34) }
            }
            .animation(.easeOut(duration: 0.35), value: flow.phase)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
        .task { await camera.start() }
        .onDisappear { camera.stop() }
        .onChange(of: picked) { _, item in
            guard let item else { return }
            Task {
                flow.capture(try? await item.loadTransferable(type: Data.self))
                picked = nil
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: flow.photoCount)
        .sensoryFeedback(.success, trigger: flow.phase == .result)
    }

    @ViewBuilder private func backdrop(size: CGSize) -> some View {
        if flow.phase == .viewfinder {
            ViewfinderFeed(camera: camera).frame(width: size.width, height: size.height).clipped()
        } else {
            let frozen = flow.photo.flatMap { Image(photoData: $0) } ?? PaperArt.samplePlate
            frozen.resizable().scaledToFill().frame(width: size.width, height: size.height).clipped()
                .blur(radius: isReading ? 8 : 0).overlay(Color.black.opacity(isReading ? 0.4 : 0.25))
        }
    }

    private var isReading: Bool { if case .reading = flow.phase { true } else { false } }

    private func viewfinder(_ proxy: GeometryProxy) -> some View {
        let w = proxy.size.width, h = proxy.size.height, side = min(w - 100, 300)
        return ZStack {
            roundButton("xmark", "Close") { model.closeCamera() }.position(x: 42, y: proxy.safeAreaInsets.top + 34)
            Brackets().stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round)).frame(width: side, height: side).position(x: w / 2, y: h * 0.42)
            hint.position(x: w / 2, y: h * 0.42 + side / 2 + 40)
            HStack {
                PhotosPicker(selection: $picked, matching: .images) {
                    Image(systemName: "photo.on.rectangle").font(.system(size: 20)).foregroundStyle(.white)
                        .frame(width: 48, height: 48).background(.black.opacity(0.4), in: RoundedRectangle(cornerRadius: 13))
                        .overlay(RoundedRectangle(cornerRadius: 13).stroke(.white, lineWidth: 2))
                }
                .accessibilityLabel("Choose a photo")
                Spacer()
                Button { Task { flow.capture(await camera.capture()) } } label: {
                    Circle().fill(.white).frame(width: 60, height: 60).padding(5).overlay(Circle().stroke(.white, lineWidth: 4))
                }
                .buttonStyle(.plain).accessibilityLabel("Take photo")
                Spacer()
                Color.clear.frame(width: 48, height: 48)
            }
            .padding(.horizontal, 32).frame(width: w).position(x: w / 2, y: h - max(proxy.safeAreaInsets.bottom, 20) - 62)
        }
    }

    private var hint: some View {
        HStack(spacing: 8) {
            Text(model.summary.coach.name).font(SSFont.hand(19))
            Text("Get the whole plate in").font(SSFont.display(13.5, weight: 600))
        }
        .foregroundStyle(.white).padding(.horizontal, 16).padding(.vertical, 9).background(.black.opacity(0.45), in: Capsule())
    }

    /// D in `design/app/food-scan.html`: nothing on the photo, a calm card with the coach and three steps that tick off.
    private func reading(_ step: Int, _ proxy: GeometryProxy) -> some View {
        let stages = CameraFlow.stages
        let current = min(step, stages.count - 1)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                CoachAvatar(coach: model.summary.coach, part: model.part, size: 62, animated: model.animateCoach)
                VStack(alignment: .leading, spacing: 1) {
                    Text(model.summary.coach.name).font(SSFont.hand(23)).foregroundStyle(Palette.pen)
                    Text("Reading your meal").font(SSFont.display(17, weight: 700)).foregroundStyle(Palette.ink)
                }
            }
            .padding(.bottom, 14)
            ForEach(Array(stages.enumerated()), id: \.offset) { i, stage in
                if i <= step {
                    HStack(spacing: 12) {
                        if i < step {
                            Image(systemName: "checkmark").font(.system(size: 11, weight: .heavy)).foregroundStyle(.white)
                                .frame(width: 22, height: 22).background(Palette.pen, in: Circle()).transition(.scale.combined(with: .opacity))
                        } else {
                            PulsingDots(still: reduceMotion).frame(width: 22, height: 22)
                        }
                        Text(stage.label).font(SSFont.display(15, weight: i == current && step < stages.count ? 700 : 400))
                            .foregroundStyle(i < step ? Palette.ink2 : Palette.ink)
                    }
                    .padding(.vertical, 8).transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            Capsule().fill(Palette.ink.opacity(0.08)).frame(height: 5)
                .overlay(alignment: .leading) {
                    GeometryReader { bar in
                        Capsule().fill(Palette.pen).frame(width: bar.size.width * Double(min(step + 1, stages.count)) / Double(stages.count), height: 5)
                    }
                }
                .padding(.top, 14)
        }
        .padding(22).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.ivory, in: RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 28)
        .position(x: proxy.size.width / 2, y: proxy.size.height * 0.4)
        .animation(.easeOut(duration: 0.45), value: step)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reading your meal. \(stages[current].label)")
    }

    private var failedSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    CoachAvatar(coach: model.summary.coach, part: model.part, size: 52, animated: model.animateCoach)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("I could not read that one").font(SSFont.display(18, weight: 700)).foregroundStyle(Palette.ink)
                        Text("It was a little dark and blurry. Try again with more light.").font(SSFont.display(14, weight: 400)).foregroundStyle(Palette.ink2)
                    }
                }
                HStack(spacing: 10) {
                    PhotosPicker(selection: $picked, matching: .images) { PillLabel(title: "Choose a photo", filled: false) }.buttonStyle(.plain)
                    Button { flow.retake() } label: { PillLabel(title: "Retake", filled: true) }.buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22).padding(.top, 20).padding(.bottom, 34)
            .frame(maxWidth: .infinity).background(Palette.ivory, in: UnevenRoundedRectangle(topLeadingRadius: 30, topTrailingRadius: 30))
        }
    }

    private func roundButton(_ symbol: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
                .frame(width: 44, height: 44).background(.black.opacity(0.4), in: Circle())
        }
        .buttonStyle(.plain).accessibilityLabel(label)
    }
}

private struct PillLabel: View {
    let title: String
    let filled: Bool

    var body: some View {
        Text(title).font(SSFont.display(15, weight: 700)).foregroundStyle(filled ? Palette.ivory : Palette.ink)
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(filled ? Palette.ink : Color.clear, in: Capsule())
            .overlay(Capsule().stroke(Palette.ink.opacity(filled ? 0 : 0.16), lineWidth: 1.5))
    }
}

private struct Brackets: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let c: CGFloat = 46, k: CGFloat = 20
        for (x, y, dx, dy) in [(r.minX, r.minY, 1.0, 1.0), (r.maxX, r.minY, -1.0, 1.0), (r.minX, r.maxY, 1.0, -1.0), (r.maxX, r.maxY, -1.0, -1.0)] {
            p.move(to: CGPoint(x: x + dx * c, y: y))
            p.addLine(to: CGPoint(x: x + dx * k, y: y))
            p.addQuadCurve(to: CGPoint(x: x, y: y + dy * k), control: CGPoint(x: x, y: y))
            p.addLine(to: CGPoint(x: x, y: y + dy * c))
        }
        return p
    }
}

/// Three small dots pulsing in turn while a step is under way. Still with Reduce Motion.
private struct PulsingDots: View {
    let still: Bool

    var body: some View {
        TimelineView(.animation(paused: still)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    Circle().fill(Palette.pen).frame(width: 4.5, height: 4.5)
                        .opacity(still ? 1 : 0.3 + 0.7 * max(0, sin(t * 5 - Double(i) * 0.9)))
                }
            }
        }
    }
}

struct ViewfinderFeed: View {
    let camera: CameraSession

    var body: some View {
        #if os(iOS)
        if camera.available {
            CameraPreview(session: camera.session)
        } else {
            PaperArt.samplePlate.resizable().scaledToFill()
        }
        #else
        PaperArt.samplePlate.resizable().scaledToFill()
        #endif
    }
}
