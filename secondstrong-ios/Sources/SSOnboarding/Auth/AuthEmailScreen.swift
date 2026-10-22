import SwiftUI
import SSCore
import SSDesign

/// An emailed link instead of a password: nothing to remember. Design: design/signin.
struct AuthEmailScreen: View {
    @Bindable var flow: OnboardingFlow
    @FocusState private var focused: Bool

    var body: some View {
        AuthFrame(flow: flow, back: { flow.authStage = .choose }) {
            MetaLabel("Sign in with email")
            (Text("What's your ").font(SSFont.display(32)).tracking(-1.1) + Text("email?").font(SSFont.hand(39)))
                .foregroundStyle(Palette.ink)
                .padding(.top, 6)
                .accessibilityAddTraits(.isHeader)
            Text("We'll send a link that signs you in, so there's no password to remember.")
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            MetaLabel("Email").padding(.top, 28)
            field.padding(.top, 8)
            HStack(spacing: 6) {
                Image(systemName: "arrow.turn.left.up").font(.system(size: 14, weight: .medium))
                Text("the one you check most").font(SSFont.hand(20))
            }
            .foregroundStyle(Palette.pen)
            .padding(.top, 10)
            Spacer(minLength: 0)
            PillButton(flow.authBusy ? "Sending…" : "Send me a link", enabled: flow.canSendLink && !flow.authBusy) {
                focused = false
                Task { await flow.sendLink() }
            }
        }
        .onAppear { focused = true }
    }

    private var field: some View {
        TextField("", text: $flow.authEmail)
            .textFieldStyle(.plain)
            .font(SSFont.display(18, weight: 500))
            .foregroundStyle(Palette.ink)
            .autocorrectionDisabled()
            #if os(iOS)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            #endif
            .focused($focused)
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(alignment: .leading) {
                if flow.authEmail.isEmpty {
                    Text("you@example.com").font(SSFont.display(18, weight: 500)).foregroundStyle(Palette.ink.opacity(0.3)).padding(.leading, 16)
                }
            }
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Palette.ink.opacity(focused ? 0.7 : 0.25), lineWidth: 1.5))
            .onSubmit { Task { await flow.sendLink() } }
            .accessibilityLabel("Email address")
    }
}
