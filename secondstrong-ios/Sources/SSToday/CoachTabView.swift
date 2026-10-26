import PhotosUI
import SwiftUI
import SSCore
import SSDesign

/// The Coach tab as a conversation: the coach has already written (it says so), quick replies sit under its questions, and the
/// waveform opens a voice conversation. SS-0026: replies are canned until the real coach is connected.
struct CoachTabView: View {
    let model: TodayModel
    @FocusState private var typing: Bool
    @State private var picked: PhotosPickerItem?

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack(alignment: .topLeading) {
                backPill.padding(.top, proxy.safeAreaInsets.top + 10).padding(.leading, 18)
                header.padding(.top, proxy.safeAreaInsets.top + 60).padding(.leading, 18).padding(.trailing, 74)
                thread(top: proxy.safeAreaInsets.top + 132, height: h)
                VStack(alignment: .leading, spacing: 10) {
                    attachMenu.padding(.leading, 20)
                    composer
                }
                .frame(width: w, height: h - 34, alignment: .bottom)
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
        .ignoresSafeArea()
    }

    private var backPill: some View {
        Button { model.open(.today) } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                Image(systemName: "house").font(.system(size: 15, weight: .regular))
                Text("Today").font(SSFont.display(14, weight: 700))
            }
            .foregroundStyle(Palette.ink)
            .padding(.leading, 10).padding(.trailing, 14).frame(height: 38)
            .background(Palette.card, in: Capsule())
        }
        .buttonStyle(.plain).accessibilityLabel("Back to Today")
    }

    private var header: some View {
        HStack(spacing: 10) {
            CoachAvatar(coach: model.summary.coach, part: model.part, size: 56, animated: model.animateCoach)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.summary.coach.name).font(SSFont.hand(30)).foregroundStyle(Palette.ink)
                HStack(spacing: 5) {
                    Circle().fill(Palette.pen).frame(width: 7, height: 7)
                    Text("Your coach").font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
                }
            }
            Spacer()
            roundButton("bell", label: "Check-ins") { model.showCheckIns = true }
        }
    }

    private func roundButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).font(.system(size: 17, weight: .regular)).foregroundStyle(Palette.ink)
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Palette.ink.opacity(0.16), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func thread(top: CGFloat, height: CGFloat) -> some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    MetaLabel("Today").frame(maxWidth: .infinity)
                    if model.messages.first?.fromCoach == true {
                        Text("\(model.summary.coach.name) started this chat").font(SSFont.display(12, weight: 400))
                            .foregroundStyle(Palette.ink2).frame(maxWidth: .infinity).padding(.top, 4).padding(.bottom, 6)
                    }
                    ForEach(model.messages) { message in
                        if !message.time.isEmpty {
                            Text(message.time).font(SSFont.display(11, weight: 600)).foregroundStyle(Palette.ink2)
                                .padding(.top, 10).padding(.bottom, 6).padding(.leading, 4)
                        }
                        content(message).id(message.id).padding(.bottom, 8)
                        if message.meal != nil { mealCard(message).padding(.bottom, 8) }
                        if message.showsSession, let session = model.summary.session { sessionCard(session).padding(.bottom, 8) }
                        if !message.replies.isEmpty {
                            HStack(spacing: 8) { ForEach(message.replies, id: \.self) { chip($0, message) } }.padding(.bottom, 10)
                        }
                    }
                    Color.clear.frame(height: 130).id("end")
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)
            .onChange(of: model.scrollKey) { _, _ in withAnimation(.easeOut(duration: 0.2)) { reader.scrollTo("end", anchor: .bottom) } }
        }
        .frame(height: height - top)
        .offset(y: top)
    }

    private func bubble(_ message: ChatMessage) -> some View {
        Text(message.text)
            .font(SSFont.display(15.5, weight: 400))
            .foregroundStyle(message.fromCoach ? Palette.ink : Palette.ivory)
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(message.fromCoach ? Palette.card : Palette.ink,
                        in: UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: message.fromCoach ? 6 : 22,
                                                   bottomTrailingRadius: message.fromCoach ? 22 : 6, topTrailingRadius: 22))
            .frame(maxWidth: 310, alignment: message.fromCoach ? .leading : .trailing)
            .frame(maxWidth: .infinity, alignment: message.fromCoach ? .leading : .trailing)
    }

    @ViewBuilder private func content(_ message: ChatMessage) -> some View {
        if let data = message.photo, let image = Image(photoData: data) {
            image.resizable().scaledToFill().frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: .infinity, alignment: .trailing).accessibilityLabel("Your photo")
        } else if let progress = message.progress, progress.stage != .writing, message.writing == nil {
            StageView(progress: progress)
        } else if message.outcome != .completed {
            VStack(alignment: .leading, spacing: 8) {
                if !message.text.isEmpty { bubble(message) }
                outcomeNote(message)
            }
        } else if let writing = message.writing {
            WritingBubble(writing: writing)
        } else {
            bubble(message)
        }
    }

    private func outcomeNote(_ message: ChatMessage) -> some View {
        HStack(spacing: 10) {
            Text(message.outcome.note ?? "").font(SSFont.display(13, weight: 600))
                .foregroundStyle(message.outcome == .stopped ? Palette.ink2 : Palette.pen)
            Button { model.retry(message) } label: {
                Text(message.outcome == .stopped ? "Ask again" : ResponseFailure.network.retryLabel)
                    .font(SSFont.display(13, weight: 700)).foregroundStyle(Palette.ink)
                    .padding(.horizontal, 14).frame(height: 32)
                    .overlay(Capsule().stroke(Palette.ink.opacity(0.18), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 4)
    }

    private func mealCard(_ message: ChatMessage) -> some View {
        let meal = message.meal!
        return VStack(alignment: .leading, spacing: 10) {
            MetaLabel("What I see")
            Text(meal.name).font(SSFont.display(19)).tracking(-0.6).foregroundStyle(Palette.ink)
            Text(meal.summary(showCalories: model.summary.calorieTarget != nil)).font(SSFont.display(15, weight: 600)).foregroundStyle(Palette.ink)
            Text("An estimate. Portions are hard to judge from a photo.").font(SSFont.display(12, weight: 400)).foregroundStyle(Palette.ink2)
            switch message.mealState {
            case .none:
                HStack(spacing: 8) {
                    Button { model.log(message) } label: {
                        Text("Add to today").font(SSFont.display(14, weight: 700)).foregroundStyle(Palette.ivory)
                            .padding(.horizontal, 20).frame(height: 40).background(Palette.ink, in: Capsule())
                    }
                    Button { model.dismiss(message) } label: {
                        Text("Not quite").font(SSFont.display(14, weight: 600)).foregroundStyle(Palette.ink)
                            .padding(.horizontal, 16).frame(height: 40).overlay(Capsule().stroke(Palette.ink.opacity(0.18), lineWidth: 1.5))
                    }
                }
                .buttonStyle(.plain)
            case .added:
                Label("Added to today", systemImage: "checkmark").font(SSFont.display(14, weight: 700)).foregroundStyle(Palette.pen)
            case .dismissed:
                Text("Not added").font(SSFont.display(14, weight: 600)).foregroundStyle(Palette.ink2)
            }
        }
        .padding(16)
        .frame(maxWidth: 310, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 22))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sessionCard(_ session: TrainingSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                MetaLabel("Today · \(session.minutes) min")
                Text(session.title).font(SSFont.display(19)).tracking(-0.6).foregroundStyle(Palette.ink)
            }
            Spacer()
            Button { model.finishSession() } label: {
                Text("Start").font(SSFont.display(14, weight: 700)).foregroundStyle(Palette.ivory)
                    .padding(.horizontal, 22).frame(height: 40).background(Palette.ink, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func chip(_ text: String, _ message: ChatMessage) -> some View {
        Button { model.reply(text, to: message) } label: {
            Text(text).font(SSFont.display(14, weight: 600)).foregroundStyle(Palette.ink)
                .padding(.horizontal, 15).frame(height: 36)
                .overlay(Capsule().stroke(Palette.ink.opacity(0.18), lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    /// One quiet pill: a plain + that opens Photo and Scan a meal, the message, and the waveform (voice) or send.
    private var composer: some View {
        @Bindable var model = model
        return HStack(spacing: 8) {
            Button { withAnimation(.snappy(duration: 0.2)) { model.showAttach.toggle() } } label: {
                Image(systemName: "plus").font(.system(size: 19, weight: .regular)).foregroundStyle(Palette.ink2)
                    .rotationEffect(.degrees(model.showAttach ? 45 : 0)).frame(width: 34, height: 40)
            }
            .buttonStyle(.plain).accessibilityLabel("Add a photo")
            TextField("Message \(model.summary.coach.name)…", text: $model.draft)
                .textFieldStyle(.plain).font(SSFont.display(15, weight: 400)).focused($typing).onSubmit { model.send() }
            Button { model.isResponding ? model.stop() : (model.draft.isEmpty ? model.openVoice() : model.send()) } label: {
                Image(systemName: model.isResponding ? "stop.fill" : (model.draft.isEmpty ? "waveform" : "arrow.up"))
                    .font(.system(size: model.isResponding ? 13 : 16, weight: .semibold))
                    .foregroundStyle(Palette.ivory).frame(width: 40, height: 40).background(Palette.ink, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(model.isResponding ? "Stop" : (model.draft.isEmpty ? "Talk" : "Send"))
        }
        .padding(.leading, 12).padding(.trailing, 8).frame(height: 56)
        .background(Palette.ivory, in: Capsule())
        .overlay(Capsule().stroke(Palette.ink.opacity(0.14), lineWidth: 1.5))
        .padding(.horizontal, 20)
        .onChange(of: picked) { _, item in
            guard let item else { return }
            model.showAttach = false
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) { model.sendPhoto(data) }
                picked = nil
            }
        }
    }

    @ViewBuilder private var attachMenu: some View {
        if model.showAttach {
            VStack(alignment: .leading, spacing: 0) {
                menuRow("Photo", "photo")
                menuRow("Scan a meal", "fork.knife")
            }
            .padding(.vertical, 4).padding(.horizontal, 4).frame(width: 200)
            .background(Palette.ivory, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Palette.ink.opacity(0.10), lineWidth: 1))
            .transition(.scale(scale: 0.9, anchor: .bottomLeading).combined(with: .opacity))
        }
    }

    private func menuRow(_ title: String, _ symbol: String) -> some View {
        PhotosPicker(selection: $picked, matching: .images) {
            HStack(spacing: 12) {
                Image(systemName: symbol).font(.system(size: 16)).foregroundStyle(Palette.pen).frame(width: 22)
                Text(title).font(SSFont.display(15, weight: 600)).foregroundStyle(Palette.ink)
                Spacer()
            }
            .padding(.horizontal, 12).frame(height: 44).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// The coach in a small round window of the scene.
struct CoachAvatar: View {
    let coach: Coach
    let part: DayPart
    let size: CGFloat
    var animated = true
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let scene = PaperArt.todayScene(part, dark: scheme == .dark)
        ZStack {
            scene.image.resizable().frame(width: size * 3.2, height: size * 3.2 / 1.5)
                .offset(x: size * (1.6 - scene.plateau.x * 3.2), y: size * (0.5 - scene.plateau.y * 3.2 / 1.5) + size * 0.1)
            CoachView(coach, mood: .idle, animated: animated).frame(width: size * 0.96, height: size * 0.96).offset(y: size * 0.02)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(Circle().stroke(Palette.ink.opacity(0.12), lineWidth: 1))
        .accessibilityHidden(true)
    }
}
