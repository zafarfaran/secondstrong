import Foundation

/// Parses SVG path data (`d` attributes) into absolute move/line/cubic/close segments.
public enum SVGPath {
    /// Never throws: parsing stops at the first malformed token and keeps what it has.
    public static func parse(_ data: String) -> [PathSegment] {
        var reader = Reader(Array(data))
        var segments: [PathSegment] = []
        var current = Point(0, 0)
        var subpathStart = Point(0, 0)
        var lastCubicControl: Point?
        var lastQuadControl: Point?

        while let command = reader.command() {
            var cmd = command
            repeat {
                let relative = cmd.isLowercase
                let origin = relative ? current : Point(0, 0)
                var nextCubic: Point?
                var nextQuad: Point?

                switch cmd.uppercased() {
                case "M", "L":
                    guard let p = reader.point(origin) else { return segments }
                    if cmd.uppercased() == "M" {
                        segments.append(.move(p))
                        subpathStart = p
                        cmd = relative ? "l" : "L"
                    } else {
                        segments.append(.line(p))
                    }
                    current = p
                case "H":
                    guard let x = reader.number() else { return segments }
                    current = Point(relative ? current.x + x : x, current.y)
                    segments.append(.line(current))
                case "V":
                    guard let y = reader.number() else { return segments }
                    current = Point(current.x, relative ? current.y + y : y)
                    segments.append(.line(current))
                case "C":
                    guard let c1 = reader.point(origin), let c2 = reader.point(origin),
                          let p = reader.point(origin) else { return segments }
                    segments.append(.cubic(c1, c2, p))
                    nextCubic = c2
                    current = p
                case "S":
                    guard let c2 = reader.point(origin), let p = reader.point(origin) else { return segments }
                    let c1 = lastCubicControl.map { current * 2 - $0 } ?? current
                    segments.append(.cubic(c1, c2, p))
                    nextCubic = c2
                    current = p
                case "Q", "T":
                    var control = lastQuadControl.map { current * 2 - $0 } ?? current
                    if cmd.uppercased() == "Q" {
                        guard let q = reader.point(origin) else { return segments }
                        control = q
                    }
                    guard let p = reader.point(origin) else { return segments }
                    segments.append(.cubic(current + (control - current) * (2.0 / 3), p + (control - p) * (2.0 / 3), p))
                    nextQuad = control
                    current = p
                case "A":
                    guard let rx = reader.number(), let ry = reader.number(), let rotation = reader.number(),
                          let large = reader.flag(), let sweep = reader.flag(),
                          let p = reader.point(origin) else { return segments }
                    segments += EllipticalArc.cubics(
                        from: current, to: p, rx: rx, ry: ry,
                        rotationDegrees: rotation, largeArc: large, sweep: sweep)
                    current = p
                case "Z":
                    segments.append(.close)
                    current = subpathStart
                default:
                    return segments
                }
                lastCubicControl = nextCubic
                lastQuadControl = nextQuad
                if cmd.uppercased() == "Z" { break }
            } while reader.hasNumber
        }
        return segments
    }
}

private struct Reader {
    private let chars: [Character]
    private var index = 0

    init(_ chars: [Character]) { self.chars = chars }

    private mutating func skipSeparators() {
        while index < chars.count, chars[index] == " " || chars[index] == "," || chars[index].isNewline || chars[index] == "\t" {
            index += 1
        }
    }

    mutating func command() -> Character? {
        skipSeparators()
        guard index < chars.count, chars[index].isLetter else { return nil }
        defer { index += 1 }
        return chars[index]
    }

    var hasNumber: Bool {
        mutating get {
            skipSeparators()
            guard index < chars.count else { return false }
            let c = chars[index]
            return c.isNumber || c == "-" || c == "+" || c == "."
        }
    }

    mutating func number() -> Double? {
        skipSeparators()
        let start = index
        if index < chars.count, chars[index] == "-" || chars[index] == "+" { index += 1 }
        while index < chars.count, chars[index].isNumber { index += 1 }
        if index < chars.count, chars[index] == "." {
            index += 1
            while index < chars.count, chars[index].isNumber { index += 1 }
        }
        if index < chars.count, chars[index] == "e" || chars[index] == "E" {
            index += 1
            if index < chars.count, chars[index] == "-" || chars[index] == "+" { index += 1 }
            while index < chars.count, chars[index].isNumber { index += 1 }
        }
        guard index > start else { return nil }
        return Double(String(chars[start..<index]))
    }

    mutating func point(_ origin: Point) -> Point? {
        guard let x = number(), let y = number() else { return nil }
        return Point(origin.x + x, origin.y + y)
    }

    mutating func flag() -> Bool? {
        skipSeparators()
        guard index < chars.count, chars[index] == "0" || chars[index] == "1" else { return nil }
        defer { index += 1 }
        return chars[index] == "1"
    }
}
