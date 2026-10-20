"use client";

import { useRef } from "react";
import { facts } from "@/content/site";
import { useStill } from "@/lib/motion/MotionProvider";
import { clamp01, measurePin, pinAt, span01, useFrame, useLayoutRebuild, type Pin } from "@/lib/motion/frame";
import { factsExitX, factsGx, isPhone, type Pt } from "@/lib/line/geometry";
import { rise, wipe } from "@/lib/motion/reveal";
import { trace } from "@/lib/line/trace";
import { makeSchedule, type ScheduleState } from "@/lib/motion/schedule";

type Marks = Record<"c0" | "mid" | "m1" | "c1" | "u1" | "u2" | "c2" | "pill" | "band" | "end", number>;
interface Built {
  L: number;
  marks: Marks;
  bracketLen: number;
  vw: number;
  mob: boolean;
  pin: Pin;
  /** Point on the line at a drawn length (sampled once, not measured per frame). */
  point: (l: number) => [number, number];
  /** Each column's text lines, revealed in turn. */
  items: Element[][];
  /** Scroll progress → what's drawn, which chart the view is on, how much text is showing. */
  at: (p: number) => ScheduleState;
}

const NS = "http://www.w3.org/2000/svg";
/**
 * "What actually changes": pinned while one line, drawn by scroll, runs through all three
 * charts. What the pen has passed stays drawn. On phones the charts sit in a row three
 * screens wide and the view pans with the pen.
 */
export function Facts() {
  const still = useStill();
  const section = useRef<HTMLElement>(null);
  const track = useRef<HTMLDivElement>(null);
  const svg = useRef<SVGSVGElement>(null);
  const pen = useRef<SVGPathElement>(null);
  const nib = useRef<SVGCircleElement>(null);
  const dash = useRef<SVGPathElement>(null);
  const bracket = useRef<SVGPathElement>(null);
  const fill0 = useRef<SVGRectElement>(null);
  const fill1 = useRef<SVGRectElement>(null);
  const band = useRef<SVGRectElement>(null);
  const bar = useRef<SVGRectElement>(null);
  const boxes = useRef<(HTMLDivElement | null)[]>([]);
  const axes = useRef<(SVGSVGElement | null)[]>([]);
  const texts = useRef<(HTMLDivElement | null)[]>([]);
  const built = useRef<Built | null>(null);
  const shown = useRef(0); // eased scroll progress
  const paintedAt = useRef(-1); // the progress last painted, so idle frames do nothing

  const build = () => {
    const tr = track.current, s = svg.current, path = pen.current;
    if (!tr || !s || !path || !section.current || boxes.current.some((b) => !b)) return;
    tr.style.transform = "none";
    const T = tr.getBoundingClientRect();
    const vw = section.current.clientWidth, mob = isPhone();
    const W = T.width, H = T.height;
    s.setAttribute("viewBox", `0 0 ${W} ${H}`);
    s.style.width = `${W}px`;
    s.style.height = `${H}px`;

    const cb = boxes.current.map((b) => {
      const r = b!.getBoundingClientRect();
      return { x: r.left - T.left, y: r.top - T.top, w: r.width, h: r.height };
    });
    // Chart artwork is drawn on a 640x440 grid and scaled into each chart box.
    const m = (i: number, x: number, y: number): Pt => [cb[i].x + (x / 640) * cb[i].w, cb[i].y + (y / 440) * cb[i].h];
    const k = cb[0].w / 640;
    const P = (q: Pt) => `${q[0]} ${q[1]}`;
    const gx = mob ? 6 : factsGx() - T.left;
    const exitX = mob ? 3 * vw - 8 : factsExitX() - T.left;

    let d = `M ${gx} -2`;
    let cur: Pt = [gx, -2];
    const marks = {} as Marks;
    const probe = document.createElementNS(NS, "path");
    s.appendChild(probe);
    const add = (seg: string, to: Pt, mark?: keyof Marks) => {
      d += " " + seg;
      cur = to;
      if (mark) {
        probe.setAttribute("d", d);
        marks[mark] = probe.getTotalLength();
      }
    };
    const Cto = (q: Pt, t0: Pt, t1: Pt, kk = 0.5, mark?: keyof Marks) => {
      const len = Math.hypot(q[0] - cur[0], q[1] - cur[1]) * kk;
      add(`C ${cur[0] + t0[0] * len} ${cur[1] + t0[1] * len} ${q[0] - t1[0] * len} ${q[1] - t1[1] * len} ${P(q)}`, q, mark);
    };

    // muscle: in from the top margin, then the curve
    Cto(m(0, 40, 96), [0, 1], [1, 0], 0.5, "c0");
    add(`C ${P(m(0, 180, 108))} ${P(m(0, 260, 126))} ${P(m(0, 320, 150))}`, m(0, 320, 150), "mid");
    add(`C ${P(m(0, 400, 190))} ${P(m(0, 500, 250))} ${P(m(0, 600, 304))}`, m(0, 600, 304), "m1");
    // bone: a full column, then the shorter one
    Cto(m(1, 150, 380), [1, 0.4], [1, 0], 0.5, "c1");
    add(`L ${P(m(1, 150, 112))} Q ${P(m(1, 150, 90))} ${P(m(1, 172, 90))} L ${P(m(1, 258, 90))} Q ${P(m(1, 280, 90))} ${P(m(1, 280, 112))} L ${P(m(1, 280, 380))}`, m(1, 280, 380), "u1");
    add(`L ${P(m(1, 360, 380))} L ${P(m(1, 360, 167))} Q ${P(m(1, 360, 145))} ${P(m(1, 382, 145))} L ${P(m(1, 468, 145))} Q ${P(m(1, 490, 145))} ${P(m(1, 490, 167))} L ${P(m(1, 490, 380))}`, m(1, 490, 380), "u2");
    // protein: round the typical-day bar, then up round the target band
    Cto(m(2, 68, 246), [1, 0], [1, 0], 0.5, "c2");
    const r2 = 28 * k;
    add(`L ${P(m(2, 359, 246))} A ${r2} ${r2} 0 0 0 ${P(m(2, 359, 190))} L ${P(m(2, 68, 190))} A ${r2} ${r2} 0 0 0 ${P(m(2, 68, 246))}`, m(2, 68, 246), "pill");
    Cto(m(2, 432, 310), [1, 0.2], [1, 0], 0.45);
    add(`L ${P(m(2, 432, 118))} Q ${P(m(2, 432, 110))} ${P(m(2, 440, 110))} L ${P(m(2, 502, 110))} Q ${P(m(2, 510, 110))} ${P(m(2, 510, 118))} L ${P(m(2, 510, 310))}`, m(2, 510, 310), "band");
    // and out of the bottom of the screen, where the page line takes over
    Cto([exitX, cb[2].y + cb[2].h + 10], [1, 0], [0, 1], 0.5);
    add(`L ${exitX} ${H + 4}`, [exitX, H + 4], "end");
    probe.remove();

    path.setAttribute("d", d);
    path.style.strokeWidth = mob ? "5" : "7";
    const L = path.getTotalLength();
    path.style.strokeDasharray = `${L} ${L + 10}`;
    dash.current?.setAttribute("d", `M ${P(m(0, 320, 150))} C ${P(m(0, 420, 166))} ${P(m(0, 510, 182))} ${P(m(0, 600, 196))}`);
    const br = bracket.current!;
    br.setAttribute("d", `M ${P(m(1, 504, 90))} L ${P(m(1, 528, 90))} L ${P(m(1, 528, 145))} L ${P(m(1, 504, 145))}`);
    br.style.strokeWidth = mob ? "4" : "5";
    const bracketLen = br.getTotalLength();
    br.style.strokeDasharray = `${bracketLen} ${bracketLen + 4}`;
    const rect = (el: SVGRectElement | null, i: number, x: number, y: number, w: number, h: number, r: number) => {
      if (!el) return;
      const a = m(i, x, y);
      el.setAttribute("x", `${a[0]}`);
      el.setAttribute("y", `${a[1]}`);
      el.setAttribute("width", `${w * k}`);
      el.setAttribute("height", `${h * k}`);
      el.setAttribute("rx", `${r * k}`);
    };
    rect(fill0.current, 1, 164, 104, 102, 276, 10);
    rect(fill1.current, 1, 374, 159, 102, 221, 10);
    rect(band.current, 2, 444, 122, 54, 188, 6);
    rect(bar.current, 2, 52, 202, 323, 32, 16);

    // Phones hold each chart long enough to read its text before the view pans on.
    const at = makeSchedule(
      [{ start: marks.c0, end: marks.m1 }, { start: marks.c1, end: marks.u2 }, { start: marks.c2, end: marks.band }],
      L,
      mob ? { lead: 0.3, hold: 1.4, travel: 0.6, exit: 0.6 } : { lead: 0.3, hold: 0.45, travel: 0.3, exit: 0.6 },
    );
    const items = texts.current.map((t) => (t ? [...t.children] : []));
    built.current = { L, marks, bracketLen, vw, mob, pin: measurePin(section.current), point: trace(d, L), items, at };
    if (still) shown.current = 1;
    paintedAt.current = -1;
    paint();
  };

  const paint = () => {
    const b = built.current, path = pen.current;
    if (!b || !path) return;
    const { L, marks: M, bracketLen, vw, mob } = b;
    const state = b.at(shown.current);
    const dr = state.drawn;
    path.style.strokeDashoffset = `${L - dr}`;
    const [x, y] = b.point(dr);
    nib.current?.setAttribute("cx", `${x}`);
    nib.current?.setAttribute("cy", `${y}`);
    if (nib.current) nib.current.style.opacity = dr > 2 && dr < L - 2 ? "1" : "0";

    // what the pen has passed stays drawn: the training line, the bone fills, the bracket, the bars
    wipe(dash.current, span01(dr, M.mid, M.m1));
    rise(fill0.current, span01(dr, M.u1 - (M.u1 - M.c1) * 0.4, M.u1));
    rise(fill1.current, span01(dr, M.u2 - (M.u2 - M.u1) * 0.4, M.u2));
    if (bracket.current) bracket.current.style.strokeDashoffset = `${bracketLen * (1 - span01(dr, M.u2, M.u2 + (M.c2 - M.u2) * 0.5))}`;
    wipe(bar.current, span01(dr, M.c2 + (M.pill - M.c2) * 0.2, M.pill));
    rise(band.current, span01(dr, M.pill + (M.band - M.pill) * 0.3, M.band));

    // each column's labels and text wipe in as the pen works through its chart
    const cols: [number, number, number][] = [[0, M.c0, M.m1], [M.m1, M.c1, M.u2], [M.u2, M.c2, M.band]];
    cols.forEach(([a, s0, e], i) => {
      wipe(axes.current[i], span01(dr, a, s0 + (e - s0) * 0.4));
      // the figure and its words reveal while the pen holds on the chart, and stay
      b.items[i].forEach((el, j) => wipe(el, span01(state.text[i], j * 0.2, 0.5 + j * 0.25)));
    });

    // phones: the camera follows the pen across the three screens
    if (mob && track.current) track.current.style.transform = `translateX(${-state.view * vw}px)`;
  };

  useLayoutRebuild(build, [still]);

  useFrame(() => {
    const b = built.current;
    if (!b) return;
    const want = clamp01(pinAt(b.pin) / 0.94);
    if (want === shown.current && paintedAt.current === want) return;
    shown.current += (want - shown.current) * 0.2;
    if (Math.abs(want - shown.current) < 0.0005) shown.current = want;
    paint();
    paintedAt.current = shown.current;
  }, !still, section);

  return (
    <section className="facts" id="facts" data-tone="light" aria-label="What actually changes after 40" ref={section}>
      <div className="stick">
        <div className="viewport">
          <div className="track" ref={track}>
            <div className="fhead wrap">
              <h2>
                <span>What actually </span>
                <span className="em">changes.</span>
              </h2>
            </div>
            <div className="fcols wrap">
              {facts.map((f, i) => (
                <div className="fcol" key={f.fig}>
                  <div className="cbox" id={`cb${i}`} ref={(el) => void (boxes.current[i] = el)}>
                    <ChartAxes index={i} ref={(el) => void (axes.current[i] = el)} />
                  </div>
                  <div className="ftxt" ref={(el) => void (texts.current[i] = el)}>
                    <div className="fig">{f.fig}</div>
                    <p>{f.text}</p>
                    <cite>{f.source}</cite>
                  </div>
                </div>
              ))}
            </div>
            <p className="fnote wrap">Illustrative charts. Figures from the sources shown.</p>
            <svg className="fline" ref={svg} aria-hidden="true">
              <rect className="fill" ref={fill0} />
              <rect className="fill" ref={fill1} />
              <rect className="band" ref={band} />
              <rect className="fill" ref={bar} />
              <path className="dash" ref={dash} />
              <path className="pen" ref={bracket} />
              <path className="pen" ref={pen} />
              <circle ref={nib} r="8" fill="#C08E82" />
            </svg>
          </div>
        </div>
      </div>
    </section>
  );
}

/** Axes, ticks and labels for each chart (the line itself is drawn over them). */
function ChartAxes({ index, ref }: { index: number; ref: (el: SVGSVGElement | null) => void }) {
  return (
    <svg className="axes" viewBox="0 0 640 440" aria-hidden="true" ref={ref}>
      {index === 0 && (
        <>
          <path className="ax" d="M 40 380 L 600 380" />
          <path className="ax" d="M 320 70 L 320 380" style={{ strokeDasharray: "4 10" }} />
          {[30, 40, 50, 60, 70].map((age, i) => (
            <text key={age} x={40 + i * 140} y="412" textAnchor="middle">{age}</text>
          ))}
          <text className="big" x="40" y="50">Muscle</text>
          <text x="332" y="62">around menopause</text>
          <text x="600" y="146" textAnchor="end">with strength training</text>
          <text x="600" y="340" textAnchor="end">without</text>
        </>
      )}
      {index === 1 && (
        <>
          <path className="ax" d="M 40 380 L 600 380" />
          <path className="ghost" d="M 360 145 L 360 112 Q 360 90 382 90 L 468 90 Q 490 90 490 112 L 490 145" />
          <text className="big" x="40" y="50">Bone density</text>
          <text x="215" y="412" textAnchor="middle">at menopause</text>
          <text x="425" y="412" textAnchor="middle">5–7 years on</text>
          <text className="big" x="546" y="124">up to</text>
          <text className="big" x="546" y="148">20%</text>
        </>
      )}
      {index === 2 && (
        <>
          <path className="ax" d="M 40 330 L 600 330" />
          {["0g", "25g", "50g", "75g", "100g"].map((g, i) => (
            <text key={g} x={40 + i * 140} y="362" textAnchor="middle">{g}</text>
          ))}
          <text className="big" x="40" y="50">Protein a day, 70 kg woman</text>
          <text x="471" y="96" textAnchor="middle">target 70–84g</text>
          <text className="big" x="40" y="176">typical day · 62g</text>
        </>
      )}
    </svg>
  );
}
