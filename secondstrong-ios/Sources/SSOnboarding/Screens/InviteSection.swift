import SwiftUI
import SSCore
import SSDesign

/// Add someone to your plan: a name, a short message, and a link to send. They set up their own account;
/// nothing about their health is shared by adding them.
struct InviteSection: View {
    @Bindable var flow: OnboardingFlow
    @FocusState private var focused: Bool

    // SS-0013: placeholder link until there is a backend that makes real invites.
    private let link = URL(string: "https://example.com/second-strong/join/prototype")!

    var body: some View {
        SectionFrame(index: OnboardingStep.invite.rawValue, flow: flow, badge: "safety") {
            MetaLabel("Your plan covers \(flow.plannedHelpers + 1)")
            SectionTitle("Add your", emphasis: "helper.", index: OnboardingStep.invite.rawValue)
            Text("They get a link and choose what to share.")
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
            field("Their name", text: $flow.inviteName, prompt: "Sam")
                .padding(.top, 12)
            VStack(alignment: .leading, spacing: 4) {
                MetaLabel("A message, optional")
                TextField("", text: $flow.inviteMessage, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(SSFont.hand(23))
                    .foregroundStyle(Palette.pen)
                    .lineLimit(1...3)
                    .focused($focused)
                    .padding(.bottom, 6)
                    .background(alignment: .leading) {
                        if flow.inviteMessage.isEmpty {
                            Text("Thinking of you. Go gently.").font(SSFont.hand(23)).foregroundStyle(Palette.ink.opacity(0.3))
                        }
                    }
                    .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink).frame(height: 1.5) }
                    .accessibilityLabel("Message")
            }
            if flow.plannedHelpers > 1 {
                Text("More helpers can be added later.")
                    .font(SSFont.display(13, weight: 400)).foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
            ShareLink(item: link, message: Text(shareText)) {
                Text(flow.inviteSent ? "Send it again" : "Send the link")
                    .font(SSFont.display(16.5, weight: 600))
                    .foregroundStyle(Palette.ivory)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Palette.ink, in: Capsule())
                    .opacity(flow.inviteName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
            }
            .buttonStyle(.plain)
            .disabled(flow.inviteName.trimmingCharacters(in: .whitespaces).isEmpty)
            .simultaneousGesture(TapGesture().onEnded { flow.markInviteSent() })
            Button { focused = false; flow.finishOnboarding() } label: {
                Text(flow.inviteSent ? "Done" : "Skip for now")
                    .font(SSFont.display(15, weight: 600))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity).frame(height: 44)
            }
            .buttonStyle(.plain)
        }
    }

    private var shareText: String {
        let name = flow.inviteName.trimmingCharacters(in: .whitespaces)
        let note = flow.inviteMessage.trimmingCharacters(in: .whitespaces)
        return (note.isEmpty ? "" : note + " ") + "I've added you to my Second Strong plan, \(name)."
    }

    private func field(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            MetaLabel(label)
            TextField("", text: text)
                .textFieldStyle(.plain)
                .font(SSFont.display(26))
                .tracking(-0.6)
                .foregroundStyle(Palette.ink)
                .autocorrectionDisabled()
                .focused($focused)
                .padding(.bottom, 6)
                .background(alignment: .leading) {
                    if text.wrappedValue.isEmpty { Text(prompt).font(SSFont.display(26)).tracking(-0.6).foregroundStyle(Palette.ink.opacity(0.25)) }
                }
                .overlay(alignment: .bottom) { Rectangle().fill(Palette.ink).frame(height: 1.5) }
                .accessibilityLabel(label)
        }
    }
}
