import Testing
@testable import SSCore

@Suite struct SVGPathTests {
    @Test func parsesAbsoluteLines() {
        #expect(SVGPath.parse("M0 0 L10 0 L10 5 Z") == [
            .move(Point(0, 0)), .line(Point(10, 0)), .line(Point(10, 5)), .close,
        ])
    }

    @Test func relativeCommandsOffsetFromCurrentPoint() {
        #expect(SVGPath.parse("M10 10 l5 0 v3 h-2") == [
            .move(Point(10, 10)), .line(Point(15, 10)), .line(Point(15, 13)), .line(Point(13, 13)),
        ])
    }

    @Test func extraPairsAfterMoveBecomeLines() {
        #expect(SVGPath.parse("M0 0 4 4") == [.move(Point(0, 0)), .line(Point(4, 4))])
    }

    @Test func readsGluedAndLeadingDotNumbers() {
        #expect(SVGPath.parse("M5-3 l-.8.5") == [.move(Point(5, -3)), .line(Point(4.2, -2.5))])
    }

    @Test func absoluteCubicKeepsControlPoints() {
        #expect(SVGPath.parse("M0 0 C1 2 3 4 5 6") == [
            .move(Point(0, 0)), .cubic(Point(1, 2), Point(3, 4), Point(5, 6)),
        ])
    }

    @Test func twoArcsMakeAFullCircle() {
        let segments = SVGPath.parse("M20 4 a14 14 0 1 1 0 28 a14 14 0 1 1 0 -28")
        #expect(abs(segments.length - 2 * .pi * 14) < 0.5)
        #expect(segments.last.flatMap { if case .cubic(_, _, let p) = $0 { p } else { nil } } == Point(20, 4))
    }

    @Test func semicircleLength() {
        let segments = SVGPath.parse("M7 26 a13 13 0 0 1 26 0")
        #expect(abs(segments.length - .pi * 13) < 0.3)
    }

    @Test func malformedInputKeepsWhatParsed() {
        #expect(SVGPath.parse("M0 0 L5") == [.move(Point(0, 0))])
        #expect(SVGPath.parse("").isEmpty)
    }
}
