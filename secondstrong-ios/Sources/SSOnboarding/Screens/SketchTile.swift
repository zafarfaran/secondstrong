import SwiftUI
import SSDesign

/// A rounded outline tile. Selecting it stamps the border darker with a small pop.
struct SketchTile<Content: View>: View {
    let selected: Bool
    let label: String
    let action: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        Button(action: action) {
            content
                .padding(.top, 12)
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selected ? Palette.ink : Palette.ink.opacity(0.14), lineWidth: 1.5))
                .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct TileLabel: View {
    let text: String

    var body: some View {
        Text(text).font(SSFont.display(14, weight: 700)).foregroundStyle(Palette.ink)
    }
}

/// A full-width outline row with a dot that fills when chosen. Used for lists of answers.
struct ChoiceRow: View {
    let selected: Bool
    let label: String
    var height: CGFloat = 44
    var detail: String?
    var icon: Image?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(selected ? Palette.ink : Palette.ink.opacity(0.3), lineWidth: 1.5)
                    .background(Circle().fill(selected ? Palette.ink : .clear).padding(4))
                    .frame(width: 20, height: 20)
                    .animation(.spring(duration: 0.3, bounce: 0.4), value: selected)
                if let icon { icon.resizable().scaledToFit().frame(width: 38, height: 38) }
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(SSFont.display(15, weight: 600))
                        .foregroundStyle(Palette.ink)
                        .multilineTextAlignment(.leading)
                    if let detail {
                        Text(detail).font(SSFont.display(12.5, weight: 400)).foregroundStyle(Palette.ink2)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2.2)
                    .stroke(selected ? Palette.ink : Palette.ink.opacity(0.14), lineWidth: 1.5))
            .contentShape(RoundedRectangle(cornerRadius: height / 2.2))
        }
        .buttonStyle(PressScaleStyle(pressed: 0.98))
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
