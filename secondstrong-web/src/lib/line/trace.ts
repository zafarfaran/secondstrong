type Pt = [number, number];

/**
 * Flattens a path into a polyline once, so finding a point on it each frame is a table lookup.
 * This is plain arithmetic on purpose: the browser's getPointAtLength costs about a millisecond
 * a call on phones, which is too slow both per frame and for sampling the path up front.
 * Handles the absolute M/L/C/Q/A commands the pinned sections build their lines from.
 * `total` is the browser's length for the path, so lookups line up with its dash offsets.
 */
export function trace(d: string, total: number, step = 3) {
  const xs: number[] = [], ys: number[] = [], len: number[] = [];
  let cum = 0, cur: Pt = [0, 0];
  const to = (p: Pt) => {
    if (xs.length) cum += Math.hypot(p[0] - cur[0], p[1] - cur[1]);
    xs.push(p[0]); ys.push(p[1]); len.push(cum);
    cur = p;
  };
  /** Samples a curve finely enough that chords are about `step` long. */
  const curve = (at: (t: number) => Pt, rough: number) => {
    const n = Math.max(2, Math.ceil(rough / step));
    for (let k = 1; k <= n; k++) to(at(k / n));
  };

  for (const c of d.match(/[MLCQA][^MLCQA]*/g) ?? []) {
    const v = c.slice(1).trim().split(/[\s,]+/).map(Number);
    const p0 = cur;
    if (c[0] === "M") {
      if (!xs.length) to([v[0], v[1]]);
      else cur = [v[0], v[1]];
    } else if (c[0] === "L") {
      to([v[0], v[1]]);
    } else if (c[0] === "Q") {
      const [x1, y1, x, y] = v;
      curve((t) => {
        const u = 1 - t;
        return [u * u * p0[0] + 2 * u * t * x1 + t * t * x, u * u * p0[1] + 2 * u * t * y1 + t * t * y];
      }, Math.hypot(x1 - p0[0], y1 - p0[1]) + Math.hypot(x - x1, y - y1));
    } else if (c[0] === "C") {
      const [x1, y1, x2, y2, x, y] = v;
      curve((t) => {
        const u = 1 - t, a = u * u * u, b = 3 * u * u * t, e = 3 * u * t * t, f = t * t * t;
        return [a * p0[0] + b * x1 + e * x2 + f * x, a * p0[1] + b * y1 + e * y2 + f * y];
      }, Math.hypot(x1 - p0[0], y1 - p0[1]) + Math.hypot(x2 - x1, y2 - y1) + Math.hypot(x - x2, y - y2));
    } else if (c[0] === "A") {
      arc(p0, v, curve, to);
    }
  }

  const k = cum > 0 ? cum / total : 1; // browser length → our length
  const n = len.length - 1;
  return (l: number): Pt => {
    const s = l * k;
    if (s <= 0 || n < 1) return [xs[0], ys[0]];
    if (s >= len[n]) return [xs[n], ys[n]];
    let lo = 0, hi = n;
    while (hi - lo > 1) {
      const mid = (lo + hi) >> 1;
      if (len[mid] <= s) lo = mid;
      else hi = mid;
    }
    const t = (s - len[lo]) / (len[hi] - len[lo] || 1);
    return [xs[lo] + (xs[hi] - xs[lo]) * t, ys[lo] + (ys[hi] - ys[lo]) * t];
  };
}

/** SVG elliptical arc (endpoint form, no rotation needed here but supported) → centre form, then sampled. */
function arc(p0: Pt, v: number[], curve: (at: (t: number) => Pt, rough: number) => void, to: (p: Pt) => void) {
  let [rx, ry] = v;
  const [, , rot, large, sweep, x, y] = v;
  if (!rx || !ry || (p0[0] === x && p0[1] === y)) return to([x, y]);
  rx = Math.abs(rx); ry = Math.abs(ry);
  const phi = (rot * Math.PI) / 180, cs = Math.cos(phi), sn = Math.sin(phi);
  const dx = (p0[0] - x) / 2, dy = (p0[1] - y) / 2;
  const x1 = cs * dx + sn * dy, y1 = -sn * dx + cs * dy;
  const lam = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry);
  if (lam > 1) { rx *= Math.sqrt(lam); ry *= Math.sqrt(lam); }
  const num = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1;
  const co = (large === sweep ? -1 : 1) * Math.sqrt(Math.max(0, num / (rx * rx * y1 * y1 + ry * ry * x1 * x1)));
  const cxp = (co * rx * y1) / ry, cyp = (-co * ry * x1) / rx;
  const cx = cs * cxp - sn * cyp + (p0[0] + x) / 2, cy = sn * cxp + cs * cyp + (p0[1] + y) / 2;
  const ang = (ux: number, uy: number, vx: number, vy: number) => Math.atan2(ux * vy - uy * vx, ux * vx + uy * vy);
  const t1 = ang(1, 0, (x1 - cxp) / rx, (y1 - cyp) / ry);
  let dt = ang((x1 - cxp) / rx, (y1 - cyp) / ry, (-x1 - cxp) / rx, (-y1 - cyp) / ry);
  if (!sweep && dt > 0) dt -= 2 * Math.PI;
  if (sweep && dt < 0) dt += 2 * Math.PI;
  curve((t) => {
    const a = t1 + dt * t, ex = rx * Math.cos(a), ey = ry * Math.sin(a);
    return [cs * ex - sn * ey + cx, sn * ex + cs * ey + cy];
  }, Math.abs(dt) * Math.max(rx, ry));
}
