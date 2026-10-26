import SwiftUI
import SSDesign

/// A floating pill of five icons. A soft capsule sits under the current one and follows a swipe (SS-0031).
struct FloatingTabBar: View {
    let selected: AppTab
    /// Where the capsule is: the selected tab's index, or between two tabs mid-swipe.
    var position: Double?
    var unread = 0
    let onSelect: (AppTab) -> Void

    private var place: Double { position ?? Double(selected.index) }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button { onSelect(tab) } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 21, weight: .regular))
                            .foregroundStyle(Palette.ink2)
                            .overlay {
                                Image(systemName: tab.symbol).font(.system(size: 21, weight: .semibold))
                                    .foregroundStyle(Palette.ink).opacity(max(0, 1 - abs(Double(tab.index) - place)))
                            }
                            .overlay(alignment: .topTrailing) {
                                if tab == .coach, unread > 0 {
                                    Text("\(unread)").font(SSFont.display(10, weight: 800)).foregroundStyle(.white)
                                        .frame(minWidth: 16, minHeight: 16).background(Palette.pen, in: Capsule())
                                        .offset(x: 9, y: -6)
                                }
                            }
                        Circle().fill(tab.index == Int(place.rounded()) ? Palette.pen : .clear).frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity).frame(height: 64)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(tab == selected ? .isSelected : [])
            }
        }
        .padding(.horizontal, 6)
        .background(alignment: .leading) {
            GeometryReader { proxy in
                let seg = proxy.size.width / CGFloat(AppTab.allCases.count)
                Capsule().fill(Palette.card).frame(width: seg, height: 48)
                    .offset(x: seg * CGFloat(place), y: (proxy.size.height - 48) / 2)
            }
            .padding(.horizontal, 6)
        }
        .background(Palette.ivory, in: Capsule())
        .overlay(Capsule().stroke(Palette.ink.opacity(0.10), lineWidth: 1))
    }
}
