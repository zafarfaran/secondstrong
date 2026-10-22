import SwiftUI

/// One column of a scrolling wheel. The row under the shared band is the choice. Reports only after
/// the first movement, so the starting row is never mistaken for an answer.
public struct WheelColumn: View {
    public struct Item: Identifiable, Equatable, Sendable {
        public let id: Int
        public let label: String

        public init(_ id: Int, _ label: String) {
            self.id = id
            self.label = label
        }
    }

    public static let rowHeight: CGFloat = 40

    let items: [Item]
    let start: Int
    let height: CGFloat
    let onChange: (Int) -> Void
    @State private var position: Int?
    @State private var ready = false

    public init(items: [Item], start: Int, height: CGFloat, onChange: @escaping (Int) -> Void) {
        self.items = items
        self.start = start
        self.height = height
        self.onChange = onChange
    }

    public var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Text(item.label)
                        .font(SSFont.display(18, weight: item.id == position ? 800 : 600))
                        .foregroundStyle(item.id == position ? Palette.ink : Palette.ink2)
                        .frame(maxWidth: .infinity)
                        .frame(height: Self.rowHeight)
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $position, anchor: .center)
        .contentMargins(.vertical, (height - Self.rowHeight) / 2, for: .scrollContent)
        .frame(height: height)
        .sensoryFeedback(.selection, trigger: position)
        .task {
            try? await Task.sleep(for: .milliseconds(150))
            position = start
            try? await Task.sleep(for: .milliseconds(300))
            ready = true
        }
        .onChange(of: position) { _, new in
            guard ready, let new else { return }
            onChange(new)
        }
    }
}

/// Three columns on a soft card with an ink outline marking the chosen row.
public struct WheelRow<Content: View>: View {
    let height: CGFloat
    @ViewBuilder let content: Content

    public init(height: CGFloat = 200, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) { content }
            .frame(height: height)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Palette.ink, lineWidth: 1.5)
                    .frame(height: WheelColumn.rowHeight)
                    .padding(.horizontal, 10)
                    .allowsHitTesting(false)
            }
            .mask(RoundedRectangle(cornerRadius: 18))
            .overlay {
                LinearGradient(stops: [
                    .init(color: Palette.card, location: 0), .init(color: Palette.card.opacity(0), location: 0.36),
                    .init(color: Palette.card.opacity(0), location: 0.64), .init(color: Palette.card, location: 1),
                ], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
    }
}
