import SwiftUI
import SSDesign

/// The sign-in sky, drawn in the paper style so it can move. Night: a torn-paper crescent that sways, paper stars that
/// twinkle, dark paper clouds drifting, now and then a shooting star, a few fireflies. Day: a paper sun with slow rays,
/// cream clouds drifting. Sits behind the picture of the hills.
struct PaperSky: View {
    let dark: Bool
    let hillsTop: CGFloat
    let reduceMotion: Bool
    var fixedTime: Double?

    private struct Star { let x, y, size, phase, speed: Double; let flash: Bool }

    // x as a fraction of the width, y as a fraction of the sky's height (top of the screen to the hills)
    private let stars = [
        Star(x: 0.90, y: 0.095, size: 0.022, phase: 0.0, speed: 1.1, flash: true),
        Star(x: 0.93, y: 0.215, size: 0.016, phase: 1.3, speed: 0.8, flash: false),
        Star(x: 0.62, y: 0.620, size: 0.020, phase: 2.1, speed: 1.2, flash: true),
        Star(x: 0.80, y: 0.700, size: 0.024, phase: 3.4, speed: 0.9, flash: false),
        Star(x: 0.46, y: 0.800, size: 0.016, phase: 4.0, speed: 1.4, flash: false),
        Star(x: 0.12, y: 0.760, size: 0.020, phase: 4.9, speed: 1.0, flash: true),
        Star(x: 0.88, y: 0.860, size: 0.016, phase: 5.8, speed: 1.3, flash: false),
        Star(x: 0.60, y: 0.900, size: 0.014, phase: 0.7, speed: 1.5, flash: false),
        Star(x: 0.07, y: 0.600, size: 0.014, phase: 2.8, speed: 1.1, flash: false),
        Star(x: 0.72, y: 0.520, size: 0.014, phase: 5.2, speed: 0.7, flash: false),
    ]
    private let specks: [(x: Double, phase: Double)] = [(0.16, 0), (0.34, 1.7), (0.52, 3.2), (0.70, 4.4), (0.86, 5.9), (0.44, 2.4)]

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            Canvas { gc, size in
                let t = fixedTime ?? (reduceMotion ? 1.6 : context.date.timeIntervalSinceReferenceDate)
                dark ? night(&gc, size, t) : day(&gc, size, t)
                motes(&gc, size, t)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: night

    private func night(_ gc: inout GraphicsContext, _ size: CGSize, _ t: Double) {
        let w = size.width
        cloud(&gc, w: w, y: hillsTop * 0.68, scale: 0.9, speed: 0.012, offset: 0.1, t: t, fill: Color(red: 0.17, green: 0.14, blue: 0.12), rim: .white.opacity(0.06))
        cloud(&gc, w: w, y: hillsTop * 0.88, scale: 0.7, speed: 0.008, offset: 0.62, t: t, fill: Color(red: 0.15, green: 0.12, blue: 0.10), rim: .white.opacity(0.05))

        // the moon sways a little on its thread, its glow breathes
        let sway = sin(t * 0.55) * 2.2
        let c = CGPoint(x: w * 0.30, y: hillsTop * 0.72 + sin(t * 0.7) * 3)
        let r = w * 0.115
        let breathe = 0.5 + 0.5 * sin(t * 0.8)
        gc.drawLayer { layer in
            layer.blendMode = .plusLighter
            let g = r * (2.5 + 0.2 * breathe)
            layer.fill(Path(ellipseIn: CGRect(x: c.x - g, y: c.y - g, width: g * 2, height: g * 2)),
                       with: .radialGradient(Gradient(colors: [Color(red: 0.96, green: 0.86, blue: 0.66).opacity(0.09 + 0.08 * breathe), .clear]), center: c, startRadius: r * 0.6, endRadius: g))
        }
        gc.drawLayer { layer in
            layer.translateBy(x: c.x, y: c.y)
            layer.rotate(by: .degrees(sway))
            let outer = tornCircle(r: r, seed: 3)
            let inner = tornCircle(r: r * 0.9, seed: 9).offsetBy(dx: r * 0.42, dy: -r * 0.16)
            layer.drawLayer { cut in
                cut.addFilter(.shadow(color: .black.opacity(0.55), radius: 3, x: 2, y: 4))
                cut.clip(to: inner, options: .inverse)
                cut.fill(outer, with: .linearGradient(Gradient(colors: [Color(red: 0.84, green: 0.76, blue: 0.60), Color(red: 0.70, green: 0.62, blue: 0.47)]),
                                                       startPoint: CGPoint(x: -r, y: -r), endPoint: CGPoint(x: r, y: r)))
                for i in 0..<130 {   // paper fibres
                    let a = hash(i, 1) * .pi * 2, d = sqrt(hash(i, 2)) * r
                    let s = 0.8 + hash(i, 3) * 1.8
                    cut.fill(Path(ellipseIn: CGRect(x: cos(a) * d, y: sin(a) * d, width: s, height: s * 0.7)),
                             with: .color(hash(i, 4) > 0.5 ? .white.opacity(0.22) : .black.opacity(0.16)))
                }
            }
            layer.stroke(outer, with: .color(.white.opacity(0.0)), lineWidth: 0)
        }

        // paper stars twinkle: they rest small and dim, then swell and brighten
        for s in stars {
            let pulse = pow(max(0, sin(t * s.speed + s.phase)), 3)
            let p = CGPoint(x: s.x * w, y: s.y * hillsTop)
            let scale = 0.85 + 0.35 * pulse
            let rad = w * s.size * scale
            gc.drawLayer { layer in
                layer.addFilter(.shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1.5))
                layer.opacity = 0.62 + 0.38 * pulse
                layer.fill(paperStar(at: p, radius: rad, rotation: sin(t * 0.3 + s.phase) * 0.15), with: .color(Color(red: 0.89, green: 0.74, blue: 0.38)))
            }
            if s.flash, pulse > 0.2 {
                gc.drawLayer { layer in
                    layer.blendMode = .plusLighter
                    layer.fill(Path(ellipseIn: CGRect(x: p.x - rad * 2.4, y: p.y - rad * 2.4, width: rad * 4.8, height: rad * 4.8)),
                               with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.9, blue: 0.62).opacity(0.28 * pulse), .clear]), center: p, startRadius: 0, endRadius: rad * 2.4))
                }
            }
        }

        // two lanes on different rhythms, so the sky never goes quiet for long and now and then holds two at once
        meteor(&gc, w, t, period: 4.8, phase: 0.3, lane: 0)
        meteor(&gc, w, t, period: 7.3, phase: 2.6, lane: 1)
    }

    /// A meteor now and then, across the whole sky: it comes in past the right edge, crosses at an even speed and
    /// leaves past the left edge, fading only at the very ends. A white-hot head with a soft glow, a long tapering
    /// tail, a thinner streak beside it and a little dust. Each pass differs a little in height, angle and length.
    private func meteor(_ gc: inout GraphicsContext, _ w: Double, _ t: Double, period: Double, phase: Double, lane: Int) {
        let n = Int(t / period)
        let seed = n + lane * 1000
        let q = (t - Double(n) * period - phase) / 1.6
        guard q > 0, q < 1 else { return }
        let angle = 0.20 + 0.12 * hash(seed, 43)                              // how steeply it falls, in radians
        let length = w * (0.22 + 0.12 * hash(seed, 45))
        let startX = w + 24, endX = -(length + 40)                          // off the right edge, off the left edge
        let head = CGPoint(x: startX + (endX - startX) * q,
                           y: hillsTop * ((lane == 0 ? 0.05 : 0.20) + 0.12 * hash(seed, 42)) + (startX - endX) * q * tan(angle))
        let fade = min(1, q / 0.08, (1 - q) / 0.14)
        let back = CGPoint(x: cos(angle), y: -sin(angle))                    // from the head back along the tail
        let side = CGPoint(x: sin(angle), y: cos(angle))
        func point(_ along: Double, _ across: Double) -> CGPoint {
            CGPoint(x: head.x + back.x * along + side.x * across, y: head.y + back.y * along + side.y * across)
        }
        func tail(_ len: Double, _ halfWidth: Double, _ across: Double, _ alpha: Double) {
            var p = Path()
            p.move(to: point(0, across + halfWidth))
            p.addLine(to: point(len, across))
            p.addLine(to: point(0, across - halfWidth))
            p.closeSubpath()
            gc.drawLayer { layer in
                layer.blendMode = .plusLighter
                layer.fill(p, with: .linearGradient(Gradient(stops: [
                    .init(color: Color(red: 1, green: 0.98, blue: 0.92).opacity(alpha * fade), location: 0),
                    .init(color: Color(red: 1, green: 0.86, blue: 0.58).opacity(0.38 * alpha * fade), location: 0.45),
                    .init(color: .clear, location: 1),
                ]), startPoint: point(0, across), endPoint: point(len, across)))
            }
        }
        tail(length, 2.0, 0, 1)
        tail(length * 0.62, 0.9, 3.4, 0.5)
        for j in 0..<7 {                                                      // dust that drifts off the tail and twinkles out
            let along = length * (Double(j) + 1 + 0.6 * hash(seed * 10 + j, 46)) / 8.5
            let across = (hash(seed * 10 + j, 47) - 0.5) * 9
            let size = 1.0 + 1.4 * hash(seed * 10 + j, 48)
            let alpha = fade * (1 - along / length) * (0.45 + 0.55 * sin(t * 18 + Double(j) * 2))
            let c = point(along, across)
            gc.drawLayer { layer in
                layer.blendMode = .plusLighter
                layer.fill(Path(ellipseIn: CGRect(x: c.x - size, y: c.y - size, width: size * 2, height: size * 2)),
                           with: .color(Color(red: 1, green: 0.92, blue: 0.7).opacity(max(alpha, 0))))
            }
        }
        gc.drawLayer { layer in
            layer.blendMode = .plusLighter
            layer.fill(Path(ellipseIn: CGRect(x: head.x - 12, y: head.y - 12, width: 24, height: 24)),
                       with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.9, blue: 0.68).opacity(0.55 * fade), .clear]),
                                             center: head, startRadius: 0, endRadius: 12))
            layer.fill(Path(ellipseIn: CGRect(x: head.x - 2.4, y: head.y - 2.4, width: 4.8, height: 4.8)),
                       with: .color(Color(red: 1, green: 0.99, blue: 0.95).opacity(fade)))
        }
    }

    // MARK: day

    private func day(_ gc: inout GraphicsContext, _ size: CGSize, _ t: Double) {
        let w = size.width
        let c = CGPoint(x: w * 0.564, y: hillsTop + 14)
        let r = w * 0.20
        let breathe = 0.5 + 0.5 * sin(t * 0.7)
        // slow paper rays
        gc.drawLayer { layer in
            layer.translateBy(x: c.x, y: c.y)
            layer.rotate(by: .radians(t * 0.05))
            for i in 0..<16 {
                let a = Double(i) / 16 * .pi * 2
                var ray = Path()
                ray.move(to: CGPoint(x: cos(a - 0.05) * r * 1.12, y: sin(a - 0.05) * r * 1.12))
                ray.addLine(to: CGPoint(x: cos(a) * r * (1.5 + 0.08 * sin(t * 0.9 + Double(i))), y: sin(a) * r * (1.5 + 0.08 * sin(t * 0.9 + Double(i)))))
                ray.addLine(to: CGPoint(x: cos(a + 0.05) * r * 1.12, y: sin(a + 0.05) * r * 1.12))
                layer.fill(ray, with: .color(Color(red: 0.96, green: 0.78, blue: 0.52).opacity(i % 2 == 0 ? 0.34 : 0.2)))
            }
        }
        gc.drawLayer { layer in
            layer.translateBy(x: c.x, y: c.y)
            layer.scaleBy(x: 1 + 0.015 * breathe, y: 1 + 0.015 * breathe)
            let disc = tornCircle(r: r, seed: 5, wobble: 0.01)
            layer.drawLayer { d in
                d.addFilter(.shadow(color: Color(red: 0.55, green: 0.32, blue: 0.15).opacity(0.28), radius: 4, x: 1, y: 3))
                d.fill(disc, with: .linearGradient(Gradient(colors: [Color(red: 0.98, green: 0.80, blue: 0.52), Color(red: 0.94, green: 0.70, blue: 0.40)]),
                                                    startPoint: CGPoint(x: -r, y: -r), endPoint: CGPoint(x: r, y: r)))
                for i in 0..<160 {
                    let a = hash(i, 11) * .pi * 2, dd = sqrt(hash(i, 12)) * r
                    let s = 0.8 + hash(i, 13) * 1.8
                    d.fill(Path(ellipseIn: CGRect(x: cos(a) * dd, y: sin(a) * dd, width: s, height: s * 0.7)),
                           with: .color(hash(i, 14) > 0.5 ? .white.opacity(0.28) : Color(red: 0.7, green: 0.4, blue: 0.2).opacity(0.14)))
                }
            }
        }
        cloud(&gc, w: w, y: hillsTop * 0.66, scale: 0.9, speed: 0.014, offset: 0.2, t: t, fill: Color(red: 0.96, green: 0.92, blue: 0.85), rim: .white.opacity(0.8), shadow: true)
        cloud(&gc, w: w, y: hillsTop * 0.84, scale: 0.7, speed: 0.009, offset: 0.7, t: t, fill: Color(red: 0.93, green: 0.88, blue: 0.80), rim: .white.opacity(0.7), shadow: true)
    }

    // MARK: shared

    /// Fireflies at night, dust in the sun by day.
    private func motes(_ gc: inout GraphicsContext, _ size: CGSize, _ t: Double) {
        let w = size.width
        for s in specks {
            let rise = (t * 0.03 + s.phase * 0.17).truncatingRemainder(dividingBy: 1)
            let x = (s.x + 0.025 * sin(t * 0.6 + s.phase)) * w
            let y = hillsTop * (1.05 - 0.45 * rise)
            let a = sin(rise * .pi) * (dark ? 0.85 : 0.5) * (0.6 + 0.4 * sin(t * 2 + s.phase))
            let r = w * (dark ? 0.011 : 0.007)
            gc.drawLayer { layer in
                layer.blendMode = dark ? .plusLighter : .normal
                layer.fill(Path(ellipseIn: CGRect(x: x - r * 3, y: y - r * 3, width: r * 6, height: r * 6)),
                           with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.86, blue: 0.56).opacity(a), .clear]), center: CGPoint(x: x, y: y), startRadius: 0, endRadius: r * 3))
            }
        }
    }

    /// A cloud cut from paper: a few round lumps on a flat base, drifting slowly and wrapping round the screen.
    private func cloud(_ gc: inout GraphicsContext, w: Double, y: Double, scale: Double, speed: Double, offset: Double, t: Double, fill: Color, rim: Color, shadow: Bool = false) {
        let width = w * 0.34 * scale
        let x = ((t * speed + offset).truncatingRemainder(dividingBy: 1)) * (w + width * 2) - width
        let h = width * 0.28
        let lumps = [
            Path(ellipseIn: CGRect(x: x, y: y, width: width * 0.5, height: h)),
            Path(ellipseIn: CGRect(x: x + width * 0.22, y: y - h * 0.5, width: width * 0.46, height: h * 1.1)),
            Path(ellipseIn: CGRect(x: x + width * 0.46, y: y - h * 0.1, width: width * 0.54, height: h * 0.95)),
            Path(roundedRect: CGRect(x: x + width * 0.08, y: y + h * 0.45, width: width * 0.84, height: h * 0.55), cornerSize: CGSize(width: h * 0.27, height: h * 0.27)),
        ]
        let p = lumps.dropFirst().reduce(lumps[0]) { $0.union($1) }
        gc.drawLayer { layer in
            if shadow { layer.addFilter(.shadow(color: Color(red: 0.4, green: 0.3, blue: 0.2).opacity(0.18), radius: 3, x: 1, y: 3)) }
            layer.fill(p, with: .color(fill))
            layer.stroke(p, with: .color(rim), lineWidth: 0.6)
        }
    }

    private func hash(_ i: Int, _ k: Int) -> Double {
        let v = sin(Double(i) * 12.9898 + Double(k) * 78.233) * 43758.5453
        return v - floor(v)
    }

    /// A circle with a hand-torn edge.
    private func tornCircle(r: Double, seed: Int, wobble: Double = 0.016) -> Path {
        var p = Path()
        let n = 140
        for i in 0..<n {
            let a = Double(i) / Double(n) * .pi * 2
            let rr = r * (1 + wobble * (hash(i, seed) - 0.5) * 2 + wobble * 0.5 * sin(a * 5 + Double(seed)))
            let pt = CGPoint(x: cos(a) * rr, y: sin(a) * rr)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }

    private func paperStar(at c: CGPoint, radius r: Double, rotation: Double) -> Path {
        var p = Path()
        for i in 0..<10 {
            let a = Double(i) * .pi / 5 - .pi / 2 + rotation
            let rad = (i % 2 == 0 ? r : r * 0.46) * (0.96 + 0.08 * hash(i, 31))
            let pt = CGPoint(x: c.x + cos(a) * rad, y: c.y + sin(a) * rad)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}
