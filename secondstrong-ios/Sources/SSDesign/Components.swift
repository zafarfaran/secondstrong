import SwiftUI

/// Ivory page with faint ruled lines every 32pt, like a sketchbook.
public struct PaperBackground: View {
    public init() {}

    public var body: some View {
        Canvas { context, size in
            var y: CGFloat = 31
            while y < size.height {
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 1)), with: .color(Palette.ink.opacity(0.04)))
                y += 32
            }
        }
        .background(Palette.ivory)
        .ignoresSafeArea()
    }
}

/// Small monospaced caps label.
public struct MetaLabel: View {
    let text: String

    public init(_ text: String) { self.text = text }

    public var body: some View {
        Text(text.uppercased())
            .font(SSFont.display(11.5, weight: 600))
            .tracking(0.92)
            .foregroundStyle(Palette.ink2)
    }
}

/// The full-width ink pill used for Continue and Begin.
public struct PillButton: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    public init(_ title: String, enabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.enabled = enabled
        self.action = action
    }

    public var body: some View {
        Button(action: { if enabled { action() } }) {
            Text(title)
                .font(SSFont.display(16.5, weight: 600))
                .foregroundStyle(Palette.ivory)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Palette.ink.opacity(enabled ? 1 : 0.3), in: Capsule())
                .background(Palette.ivory, in: Capsule())
        }
        .buttonStyle(PressScaleStyle(pressed: 0.97))
        .accessibilityAddTraits(enabled ? [] : .isStaticText)
    }
}

public struct PressScaleStyle: ButtonStyle {
    let pressed: CGFloat

    public init(pressed: CGFloat = 0.96) { self.pressed = pressed }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressed : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}
