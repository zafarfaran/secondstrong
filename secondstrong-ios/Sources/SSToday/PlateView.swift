import SwiftUI
import SSCore
import SSDesign

/// A small painted plate standing in for a meal photo until real photos are kept (SS-0032).
struct PlateView: View {
    let kind: PlateKind
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.27).fill(tint)
            Circle().fill(Color.white.opacity(0.94)).frame(width: size * 0.62, height: size * 0.62)
            Circle().stroke(Palette.almond, lineWidth: 1.4).frame(width: size * 0.44, height: size * 0.44)
            detail
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var tint: Color {
        switch kind {
        case .berry: Palette.terracotta
        case .cup: Palette.olive
        case .egg: Palette.apricot
        case .nuts: Palette.plumRose
        case .bowl: Palette.taupe
        }
    }

    @ViewBuilder private var detail: some View {
        let u = size / 56
        switch kind {
        case .berry:
            ZStack {
                dot(Palette.plumRose, 8, -5, -1); dot(Palette.plumRose, 8, 3, -3); dot(Palette.plumRose, 8, -1, 5)
            }.scaleEffect(u)
        case .cup:
            Capsule().fill(Palette.ink.opacity(0.55)).frame(width: 18 * u, height: 12 * u)
        case .egg:
            ZStack { Ellipse().fill(.white).frame(width: 20 * u, height: 15 * u); dot(Palette.honey, 8, 0, 0) }.scaleEffect(u)
        case .nuts:
            ZStack {
                Ellipse().fill(Palette.taupe).frame(width: 7, height: 11).rotationEffect(.degrees(-25)).offset(x: -5, y: 0)
                Ellipse().fill(Palette.roseClay).frame(width: 7, height: 11).rotationEffect(.degrees(20)).offset(x: 3, y: -1)
                Ellipse().fill(Palette.taupe).frame(width: 7, height: 10).offset(x: 0, y: 6)
            }.scaleEffect(u)
        case .bowl:
            ZStack { dot(Palette.olive, 7, -4, -2); dot(Palette.terracotta, 7, 4, -2); Capsule().fill(Palette.honey.opacity(0.7)).frame(width: 20, height: 7).offset(y: 5) }.scaleEffect(u)
        }
    }

    private func dot(_ color: Color, _ d: CGFloat, _ x: CGFloat, _ y: CGFloat) -> some View {
        Circle().fill(color).frame(width: d, height: d).offset(x: x, y: y)
    }
}
