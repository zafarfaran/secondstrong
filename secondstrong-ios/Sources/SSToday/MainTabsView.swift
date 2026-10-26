import SwiftUI
import SSCore
import SSDesign

/// The app after onboarding: five tabs under a floating bar. Today and Coach are built; the others are placeholders (SS-0025).
public struct MainTabsView: View {
    private let summary: TodaySummary

    public init(summary: TodaySummary = .sample) { self.summary = summary }

    public var body: some View { MainTabsContent(model: TodayModel(summary: summary)) }
}

struct MainTabsContent: View {
    @State var model: TodayModel
    @State private var dragX: CGFloat = 0
    @State private var dragIsSideways: Bool?
    @State private var settling = false

    init(model: TodayModel) { _model = State(initialValue: model) }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                PaperBackground()
                pager(width: proxy.size.width)
                ProfileButton(initial: String(model.summary.name.prefix(1))) { model.showProfile = true }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.top, max(proxy.safeAreaInsets.top, 40) + 6).padding(.trailing, 22)
                if model.tab != .coach || dragX != 0 || settling {
                    FloatingTabBar(selected: model.tab, position: barPosition(width: proxy.size.width), unread: model.unread) { model.open($0) }
                        .padding(.horizontal, 34)
                        .padding(.bottom, max(proxy.safeAreaInsets.bottom - 4, 16))
                        .transition(.opacity)
                }
            }
            .simultaneousGesture(swipe(width: proxy.size.width))
        }
        .overlay {
            if let flow = model.camera { CameraView(model: model, flow: flow).transition(.opacity) }
            if let toast = model.toast { ToastView(text: toast) }
            if let voice = model.voice { VoiceView(model: model, session: voice).transition(.opacity) }
            if model.showProfile { ProfileView(model: model).transition(.move(edge: .bottom)) }
            if model.showCheckIns { CheckInSettingsView(model: model).transition(.move(edge: .bottom)) }
        }
        .animation(.easeInOut(duration: 0.3), value: model.camera == nil)
        .animation(.easeInOut(duration: 0.3), value: model.toast)
        .animation(.easeInOut(duration: 0.3), value: model.voice == nil)
        .animation(.easeInOut(duration: 0.3), value: model.showCheckIns)
        .animation(.easeInOut(duration: 0.3), value: model.showProfile)
        .ignoresSafeArea()
    }
}

extension MainTabsContent {
    @ViewBuilder private func pageView(_ tab: AppTab) -> some View {
        switch tab {
        case .today: TodayView(model: model)
        case .coach: CoachTabView(model: model)
        case .food: FoodView(model: model)
        default: ComingSoon(tab: tab)
        }
    }

    /// SS-0031: the page follows the finger and its neighbour slides in beside it.
    private func pager(width: CGFloat) -> some View {
        let step = dragX < 0 ? 1 : -1
        let next = dragX == 0 ? nil : model.tab.neighbour(step)
        return ZStack {
            if let next { pageView(next).offset(x: dragX + CGFloat(-step) * width).id(next) }
            pageView(model.tab).offset(x: dragX).id(model.tab)
        }
    }

    private func barPosition(width: CGFloat) -> Double {
        min(4, max(0, Double(model.tab.index) - Double(dragX / width)))
    }

    private var swipeBlocked: Bool { model.voice != nil || model.showProfile || model.showCheckIns || settling }

    private func swipe(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .global)
            .onChanged { drag in
                guard !swipeBlocked else { return }
                if dragIsSideways == nil, abs(drag.translation.width) + abs(drag.translation.height) > 12 {
                    dragIsSideways = abs(drag.translation.width) > abs(drag.translation.height) * 1.5
                }
                guard dragIsSideways == true else { return }
                let step = drag.translation.width < 0 ? 1 : -1
                let resist: CGFloat = model.tab.neighbour(step) == nil ? 0.25 : 1
                dragX = drag.translation.width * resist
            }
            .onEnded { drag in
                defer { dragIsSideways = nil }
                guard dragIsSideways == true, !settling else { return }
                let target = model.tab.after(dx: drag.translation.width, dy: 0, predictedDx: drag.predictedEndTranslation.width)
                settle(to: target, width: width)
            }
    }

    private func settle(to target: AppTab?, width: CGFloat) {
        settling = true
        let end: CGFloat = target.map { $0.index > model.tab.index ? -width : width } ?? 0
        withAnimation(.easeOut(duration: 0.24)) { dragX = end } completion: {
            var plain = Transaction()
            plain.disablesAnimations = true
            withTransaction(plain) {
                if let target { model.open(target) }
                dragX = 0
            }
            settling = false
        }
    }
}

private struct ComingSoon: View {
    let tab: AppTab

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(tab.title).font(SSFont.display(33)).tracking(-1.3).foregroundStyle(Palette.ink)
            Text("coming soon.").font(SSFont.hand(30)).foregroundStyle(Palette.pen)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 120).padding(.leading, 28)
    }
}

private struct ToastView: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark").font(.system(size: 14, weight: .heavy))
            Text(text).font(SSFont.display(15, weight: 700))
        }
        .foregroundStyle(Palette.ivory).padding(.horizontal, 18).frame(height: 48)
        .background(Palette.ink, in: Capsule())
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top, 62)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityAddTraits(.updatesFrequently)
    }
}
