import Foundation

public struct Point: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(_ x: Double, _ y: Double) {
        self.x = x
        self.y = y
    }

    public static func + (a: Point, b: Point) -> Point { Point(a.x + b.x, a.y + b.y) }
    public static func - (a: Point, b: Point) -> Point { Point(a.x - b.x, a.y - b.y) }
    public static func * (a: Point, k: Double) -> Point { Point(a.x * k, a.y * k) }

    public var length: Double { (x * x + y * y).squareRoot() }

    /// Unit vector, or (0, 0) for the zero vector.
    public var normalized: Point {
        let l = length
        return l == 0 ? Point(0, 0) : Point(x / l, y / l)
    }
}

/// A path reduced to the four operations every renderer understands.
public enum PathSegment: Equatable, Sendable {
    case move(Point)
    case line(Point)
    case cubic(Point, Point, Point)
    case close
}

extension Array where Element == PathSegment {
    /// Approximate arc length. Curves are flattened into short chords.
    public var length: Double {
        var total = 0.0
        var current = Point(0, 0)
        var start = Point(0, 0)
        for segment in self {
            switch segment {
            case .move(let p):
                current = p
                start = p
            case .line(let p):
                total += (p - current).length
                current = p
            case .cubic(let c1, let c2, let p):
                total += Self.cubicLength(current, c1, c2, p)
                current = p
            case .close:
                total += (start - current).length
                current = start
            }
        }
        return total
    }

    private static func cubicLength(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Double {
        let steps = 24
        var previous = p0
        var total = 0.0
        for i in 1...steps {
            let t = Double(i) / Double(steps)
            let u = 1 - t
            let point = p0 * (u * u * u) + p1 * (3 * u * u * t) + p2 * (3 * u * t * t) + p3 * (t * t * t)
            total += (point - previous).length
            previous = point
        }
        return total
    }
}

public struct Rect: Equatable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var maxX: Double { x + width }
    public var maxY: Double { y + height }
    public var midX: Double { x + width / 2 }
    public var midY: Double { y + height / 2 }
}

extension PathSegment {
    /// Scales about the origin, then moves by `offset`.
    public func transformed(scale: Double, offset: Point) -> PathSegment {
        func map(_ p: Point) -> Point { p * scale + offset }
        switch self {
        case .move(let p): return .move(map(p))
        case .line(let p): return .line(map(p))
        case .cubic(let c1, let c2, let p): return .cubic(map(c1), map(c2), map(p))
        case .close: return .close
        }
    }
}
