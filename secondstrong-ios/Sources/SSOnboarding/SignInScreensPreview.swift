import SwiftUI
import SSDesign

/// Every sign-in screen, in light or dark, for the preview app.
public struct SignInScreensPreview: View {
    private enum Screen: String, CaseIterable, Identifiable {
        case door = "Sign in", email = "Email", inbox = "Check your inbox", returning = "Welcome back", expired = "Link expired", invited = "Invited"
        var id: String { rawValue }
        var stage: AuthStage {
            switch self {
            case .door: .choose
            case .email: .email
            case .inbox: .sent
            case .returning: .returning
            case .expired: .expired
            case .invited: .invited
            }
        }
    }

    @State private var screen = Screen.door
    @State private var dark = false

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("Screen", selection: $screen) { ForEach(Screen.allCases) { Text($0.rawValue).tag($0) } }
                    .pickerStyle(.segmented)
                Picker("Appearance", selection: $dark) { Text("Light").tag(false); Text("Dark").tag(true) }
                    .pickerStyle(.segmented)
                    .frame(width: 150)
            }
            .labelsHidden()
            PreviewScreen(stage: screen.stage)
                .id("\(screen.rawValue)-\(dark)")
                .frame(width: 390, height: 844)
                .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        .padding(18)
        .frame(width: 640)
        .background(Palette.ivory.opacity(0.0))
        .preferredColorScheme(dark ? .dark : .light)
    }
}

private struct PreviewScreen: View {
    @State private var flow: OnboardingFlow

    init(stage: AuthStage) {
        let flow = OnboardingFlow()
        flow.previewAuth(stage)
        _flow = State(initialValue: flow)
    }

    var body: some View { AuthGate(flow: flow) }
}
