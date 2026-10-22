import SwiftUI
import SSCore
import SSDesign

/// Link sent: open Mail, or type the six-digit code when the email is open on another device.
struct AuthInboxScreen: View {
    @Bindable var flow: OnboardingFlow
    @Environment(\.openURL) private var openURL
    @FocusState private var codeFocused: Bool

    var body: some View {
        AuthFrame(flow: flow, back: { flow.useDifferentEmail() }) {
            SceneArt(scene: .inbox, size: 220)
                .frame(maxWidth: .infinity)
                .padding(.top, -34)
            MetaLabel("Link sent").padding(.top, 8)
            (Text("Check your ").font(SSFont.display(32)).tracking(-1.1) + Text("inbox.").font(SSFont.hand(39)))
                .foregroundStyle(Palette.ink)
                .padding(.top, 6)
                .accessibilityAddTraits(.isHeader)
            (Text("We sent a sign-in link to ") + Text(EmailAddress.normalised(flow.authEmail) ?? flow.authEmail).fontWeight(.bold)
                + Text(". Open it on this phone and you're in."))
                .font(SSFont.display(15.5, weight: 400))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
            codeCard.padding(.top, 18)
            Spacer(minLength: 0)
            PillButton("Open Mail") {
                // The prototype has no inbox, so debug builds stand in for tapping the link.
                #if DEBUG
                flow.openEmailLink()
                #else
                if let url = URL(string: "message://") { openURL(url) }
                #endif
            }
            HStack {
                link("Send another link") { Task { await flow.sendLink() } }
                Spacer()
                link("Change email") { flow.useDifferentEmail() }
            }
            .padding(.top, 16)
            #if DEBUG
            link("Prototype only: let the link expire") { flow.expireLink() }
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
            #endif
        }
    }

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            MetaLabel("On another device? Type the code")
            HStack(spacing: 8) {
                ForEach(0..<6, id: \.self) { i in
                    let digits = Array(flow.authCode)
                    Text(i < digits.count ? String(digits[i]) : "")
                        .font(SSFont.display(22))
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Palette.ivory, in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Palette.ink.opacity(i == digits.count && codeFocused ? 0.8 : 0.3), lineWidth: 1.5))
                }
            }
            .overlay {
                TextField("", text: Binding(get: { flow.authCode }, set: { code in Task { await flow.enter(code: code) } }))
                    .focused($codeFocused)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.clear)
                    .tint(.clear)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    #endif
                    .accessibilityLabel("Six-digit code")
            }
            .contentShape(Rectangle())
            .onTapGesture { codeFocused = true }
        }
        .padding(14)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Palette.ink.opacity(0.08), lineWidth: 1))
    }

    private func link(_ title: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(SSFont.display(14, weight: 600))
                .foregroundStyle(Palette.ink)
                .underline()
        }
        .buttonStyle(.plain)
    }
}
