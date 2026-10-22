import Foundation

/// Converts SVG endpoint-parameterised arcs into cubic Béziers (SVG 1.1 §F.6.5).
public enum EllipticalArc {
    public static func cubics(
        from p0: Point, to p1: Point, rx rxIn: Double, ry ryIn: Double,
        rotationDegrees: Double, largeArc: Bool, sweep: Bool
    ) -> [PathSegment] {
        if p0 == p1 { return [] }
        var rx = abs(rxIn)
        var ry = abs(ryIn)
        if rx == 0 || ry == 0 { return [.line(p1)] }

        let phi = rotationDegrees * .pi / 180
        let cosPhi = cos(phi)
        let sinPhi = sin(phi)
        let dx = (p0.x - p1.x) / 2
        let dy = (p0.y - p1.y) / 2
        let x1p = cosPhi * dx + sinPhi * dy
        let y1p = -sinPhi * dx + cosPhi * dy

        let lambda = (x1p * x1p) / (rx * rx) + (y1p * y1p) / (ry * ry)
        if lambda > 1 {
            let s = lambda.squareRoot()
            rx *= s
            ry *= s
        }

        let numerator = rx * rx * ry * ry - rx * rx * y1p * y1p - ry * ry * x1p * x1p
        let denominator = rx * rx * y1p * y1p + ry * ry * x1p * x1p
        let sign: Double = largeArc == sweep ? -1 : 1
        let coefficient = sign * max(0, numerator / denominator).squareRoot()
        let cxp = coefficient * rx * y1p / ry
        let cyp = -coefficient * ry * x1p / rx
        let cx = cosPhi * cxp - sinPhi * cyp + (p0.x + p1.x) / 2
        let cy = sinPhi * cxp + cosPhi * cyp + (p0.y + p1.y) / 2

        let u = Point((x1p - cxp) / rx, (y1p - cyp) / ry)
        let v = Point((-x1p - cxp) / rx, (-y1p - cyp) / ry)
        let theta1 = angle(Point(1, 0), u)
        var delta = angle(u, v)
        if !sweep && delta > 0 { delta -= 2 * .pi }
        if sweep && delta < 0 { delta += 2 * .pi }

        let count = max(1, Int((abs(delta) / (.pi / 2)).rounded(.up)))
        let step = delta / Double(count)
        let k = 4.0 / 3.0 * tan(step / 4)

        func point(_ t: Double) -> Point {
            let x = rx * cos(t)
            let y = ry * sin(t)
            return Point(cosPhi * x - sinPhi * y + cx, sinPhi * x + cosPhi * y + cy)
        }
        func tangent(_ t: Double) -> Point {
            let x = -rx * sin(t)
            let y = ry * cos(t)
            return Point(cosPhi * x - sinPhi * y, sinPhi * x + cosPhi * y)
        }

        return (0..<count).map { i in
            let a = theta1 + step * Double(i)
            let b = a + step
            let end = i == count - 1 ? p1 : point(b)
            return .cubic(point(a) + tangent(a) * k, point(b) - tangent(b) * k, end)
        }
    }

    private static func angle(_ a: Point, _ b: Point) -> Double {
        atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
    }
}
