import SwiftUI
import SSCore
import SSDesign

/// The profile button: a dark disc with her initial, top right on every tab.
struct ProfileButton: View {
    let initial: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(initial).font(SSFont.display(17)).foregroundStyle(Palette.ivory)
                .frame(width: 42, height: 42).background(Palette.ink, in: Circle())
                .overlay(Circle().stroke(Palette.ivory, lineWidth: 3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile and settings")
    }
}

private enum ProfilePage { case home, plan, privacy }

/// Her profile and every setting in one calm list (SS-0027). Editing the numbers and the account actions are not connected yet.
struct ProfileView: View {
    let model: TodayModel
    @State private var page = ProfilePage.home
    @State private var notice: String?

    var body: some View {
        ZStack(alignment: .topLeading) {
            PaperBackground()
            switch page {
            case .home: home.transition(.opacity)
            case .plan: plan.transition(.move(edge: .trailing))
            case .privacy: privacy.transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.28), value: page)
        .alert(notice ?? "", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) { Button("OK") {} }
        .ignoresSafeArea()
    }

    // MARK: home

    private var home: some View {
        @Bindable var model = model
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    MetaLabel("Profile")
                    Spacer()
                    Button("Done") { model.showProfile = false }.buttonStyle(.plain).font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.ink)
                }
                HStack(spacing: 16) {
                    Text(String(model.summary.name.prefix(1))).font(SSFont.display(32)).foregroundStyle(Palette.ivory)
                        .frame(width: 76, height: 76).background(Palette.ink, in: Circle())
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(model.summary.name) Hart").font(SSFont.display(28)).tracking(-1.1).foregroundStyle(Palette.ink)
                        Text(verbatim: "anna.hart@example.com").font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
                        Text("Member since October").font(SSFont.display(12, weight: 400)).foregroundStyle(Palette.ink2)
                    }
                }
                .padding(.top, 14)
                coachRow.padding(.top, 14)
                group("You")
                nav("Your plan and numbers", "Protein, calories, training days") { page = .plan }
                note("Training", "3 days · dumbbells at home")
                note("Health answers", "Stage, safety, goals")
                group("Reminders")
                toggleRow("Check-ins from \(model.summary.coach.name)", "Morning plan, protein check", $model.profile.remind)
                nav("Choose what \(model.summary.coach.name) writes", "Quiet hours and a daily limit") { model.showProfile = false; model.showCheckIns = true }
                group("Family")
                note("Helpers", "Add someone who checks in with you")
                note("Subscription", "Yearly · renews 31 October")
                group("App")
                note("Units", "", model.profile.units)
                note("Appearance", "", model.profile.appearance)
                nav("Privacy and data", "Export, delete, what we keep") { page = .privacy }
                note("Help and support", "Questions, support resources")
                Button("Sign out") { notice = "Signing out is not connected in the prototype." }
                    .buttonStyle(.plain).font(SSFont.display(15, weight: 700)).foregroundStyle(Palette.pen)
                    .frame(maxWidth: .infinity).padding(.vertical, 24)
                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 24).padding(.top, 60)
        }
        .scrollIndicators(.hidden)
    }

    private var coachRow: some View {
        HStack(spacing: 12) {
            CoachAvatar(coach: model.summary.coach, part: model.part, size: 54, animated: model.animateCoach)
            VStack(alignment: .leading, spacing: 1) {
                Text(model.summary.coach.name).font(SSFont.display(16)).foregroundStyle(Palette.ink)
                Text(model.summary.coach.temperament).font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
            }
            Spacer()
            Text("Change").font(SSFont.display(13, weight: 700)).foregroundStyle(Palette.ink)
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 20))
        .onTapGesture { notice = "Changing coach after setup is not connected in the prototype." }
    }

    // MARK: plan

    private var plan: some View {
        @Bindable var model = model
        let s = model.summary
        return page("Your plan", "and numbers.") {
            HStack(alignment: .top) {
                figure("Protein", "\(s.proteinTarget)g")
                Rectangle().fill(Palette.ink.opacity(0.10)).frame(width: 1, height: 60).padding(.horizontal, 18)
                figure(s.calorieTarget == nil ? "Calories" : "Daily target", s.calorieTarget.map { "\($0.formatted()) kcal" } ?? "Off")
            }
            .padding(.top, 14)
            Text(s.calorieTarget == nil ? "Protein and habits only." : "Maintenance about 1,810. An estimate that sharpens as you log.")
                .font(s.calorieTarget == nil ? SSFont.hand(20) : SSFont.display(12.5, weight: 400))
                .foregroundStyle(s.calorieTarget == nil ? Palette.pen : Palette.ink2).padding(.top, 4)
            VStack(spacing: 0) {
                note("Height", "", "165 cm")
                note("Weight", "", "70 kg")
                note("Training days", "", "Mon, Wed, Fri")
                note("Everyday activity", "", "On my feet a bit")
                if s.calorieTarget != nil { note("Goal", "", "Lose fat gently · 0.25 kg a week") }
            }
            .padding(.top, 6)
            toggleRow("Show calories", "Switch to protein and habits only any time",
                      Binding(get: { s.calorieTarget != nil }, set: { model.setShowsCalories($0) }))
            Text(s.calorieTarget != nil ? "Targets never go below a safe minimum. Estimates, not promises. Editing your numbers is coming."
                 : "No calorie numbers anywhere. You can switch them back on at any time.")
                .font(SSFont.display(12, weight: 400)).foregroundStyle(Palette.ink2).padding(.top, 12)
        }
    }

    // MARK: privacy

    private var privacy: some View {
        @Bindable var model = model
        return page("Privacy", "and data.") {
            VStack(spacing: 0) {
                toggleRow("Use my health answers", "To build and adjust your plan, nothing else", $model.profile.useHealthAnswers)
                toggleRow("Help improve Second Strong", "Share anonymous usage. Never your answers", $model.profile.improve)
                toggleRow("Hide numbers on the lock screen", "Your widgets show Miso, not your protein", $model.profile.hideLockScreenNumbers)
            }
            .padding(.top, 8)
            group("Yours to take")
            action("Download my data", "A copy of everything, free", pen: false)
            action("Doctor summary (PDF)", "Symptoms, strength and nutrition for a GP visit", pen: false)
            group("Delete")
            action("Delete my answers", "Keep your account, remove health answers", pen: false)
            action("Delete my account", "Removes everything. Asks you to confirm first.", pen: true)
            group("Support")
            note("Support resources", "If food or your body feels hard right now")
            note("Terms and privacy policy", "")
            Text("Your answers are yours. We never sell them.").font(SSFont.hand(20)).foregroundStyle(Palette.pen).padding(.top, 16)
        }
    }

    // MARK: pieces

    private func page<C: View>(_ lead: String, _ hand: String, @ViewBuilder _ content: () -> C) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Button { page = .home } label: {
                    Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold)).foregroundStyle(Palette.ink)
                        .frame(width: 40, height: 40).overlay(Circle().stroke(Palette.ink.opacity(0.16), lineWidth: 1.5))
                }
                .buttonStyle(.plain).accessibilityLabel("Back")
                Text(lead).font(SSFont.display(30)).tracking(-1.2).foregroundStyle(Palette.ink).padding(.top, 14)
                Text(hand).font(SSFont.hand(37)).foregroundStyle(Palette.ink)
                content()
                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, 24).padding(.top, 60)
        }
        .scrollIndicators(.hidden)
    }

    private func group(_ title: String) -> some View { MetaLabel(title).padding(.top, 22).padding(.bottom, 2) }

    private func figure(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            MetaLabel(label)
            Text(value).font(SSFont.display(34)).tracking(-1.5).foregroundStyle(Palette.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func rowBody(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title).font(SSFont.display(16, weight: 700)).foregroundStyle(Palette.ink)
            if !detail.isEmpty { Text(detail).font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2).multilineTextAlignment(.leading) }
        }
    }

    private func line<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        HStack { content() }
            .padding(.vertical, 12).frame(minHeight: 56)
            .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink.opacity(0.10)).frame(height: 1) }
    }

    private func nav(_ title: String, _ detail: String, _ go: @escaping () -> Void) -> some View {
        Button(action: go) {
            line { rowBody(title, detail); Spacer(); chevron }.contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// A row that only shows a value. No chevron, because it cannot be changed yet.
    private func note(_ title: String, _ detail: String, _ value: String = "") -> some View {
        line {
            rowBody(title, detail)
            Spacer()
            if !value.isEmpty { Text(value).font(SSFont.display(14, weight: 600)).foregroundStyle(Palette.ink2) }
        }
    }

    private func action(_ title: String, _ detail: String, pen: Bool) -> some View {
        Button { notice = "Not connected in the prototype. Nothing is stored or deleted." } label: {
            line {
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(SSFont.display(16, weight: 700)).foregroundStyle(pen ? Palette.pen : Palette.ink)
                    Text(detail).font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(_ title: String, _ detail: String, _ isOn: Binding<Bool>) -> some View {
        line {
            rowBody(title, detail)
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().toggleStyle(.switch).tint(Palette.ink)
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundStyle(Palette.ink2)
    }
}
