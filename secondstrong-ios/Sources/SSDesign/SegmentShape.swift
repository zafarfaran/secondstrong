import SwiftUI
import SSCore

extension Path {
    public init(segments: [PathSegment]) {
        self.init()
        for segment in segments {
            switch segment {
            case .move(let p): move(to: CGPoint(x: p.x, y: p.y))
            case .line(let p): addLine(to: CGPoint(x: p.x, y: p.y))
            case .cubic(let c1, let c2, let p):
                addCurve(to: CGPoint(x: p.x, y: p.y),
                         control1: CGPoint(x: c1.x, y: c1.y),
                         control2: CGPoint(x: c2.x, y: c2.y))
            case .close: closeSubpath()
            }
        }
    }
}

/// Draws SVG path data scaled to fit its frame (like preserveAspectRatio="meet").
public struct SVGShape: Shape {
    let segments: [PathSegment]
    let viewBox: CGSize

    public init(_ data: String, viewBox: CGSize) {
        segments = SVGPath.parse(data)
        self.viewBox = viewBox
    }

    public func path(in rect: CGRect) -> Path {
        let scale = min(rect.width / viewBox.width, rect.height / viewBox.height)
        let dx = rect.minX + (rect.width - viewBox.width * scale) / 2
        let dy = rect.minY + (rect.height - viewBox.height * scale) / 2
        return Path(segments: segments)
            .applying(CGAffineTransform(scaleX: scale, y: scale).concatenating(CGAffineTransform(translationX: dx, y: dy)))
    }
}
