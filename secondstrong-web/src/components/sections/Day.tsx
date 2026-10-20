"use client";

import { useRef } from "react";
import { daySteps } from "@/content/site";
import { Draw } from "@/components/ui/Draw";
import { useStill } from "@/lib/motion/MotionProvider";
import { clamp01, measurePin, pinAt, span01, useFrame, useLayoutRebuild, type Pin } from "@/lib/motion/frame";
import { dayGx, isPhone, type Pt } from "@/lib/line/geometry";
import { slide, wipe } from "@/lib/motion/reveal";
import { trace } from "@/lib/line/trace";
import { makeSchedule, type ScheduleState } from "@/lib/motion/schedule";

interface Built {
  L: number;
  /** For each moment: where the pen reaches its arch, and where the arch comes back down. */
  arrive: number[];
  leave: number[];
  vw: number;
  mob: boolean;
  pin: Pin;
  /** Point on the line at a drawn length (sampled once, not measured per frame). */
  point: (l: number) => [number, number];
  /** Each column's text lines, revealed in turn. */
  items: Element[][];
  /** Scroll progress → what's drawn, which moment the view is on, how much text is showing. */
  at: (p: number) => ScheduleState;
}

const NS = "http://www.w3.org/2000/svg";
const PAD = 14;

/**
 * "A day with Second Strong": pinned while one line, drawn by scroll, runs through the day. It arches over
 * each moment's drawing and runs along a shared baseline between them; drawings and text wipe in as
 * the pen passes and stay. On phones the four moments sit in a row and the view pans with the pen.
 */
export function Day() {
  const still = useStill();
  const section = useRef<HTMLElement>(null);
  const track = useRef<HTMLDivElement>(null);
  const svg = useRef<SVGSVGElement>(null);
  const pen = useRef<SVGPathElement>(null);
  const nib = useRef<SVGCircleElement>(null);
  const pics = useRef<(HTMLDivElement | null)[]>([]);
  const reveals = useRef<(HTMLDivElement | null)[]>([]);
  const texts = useRef<(HTMLDivElement | null)[]>([]);
  const built = useRef<Built | null>(null);
  const shown = useRef(0); // eased scroll progress
  const paintedAt = useRef(-1); // the progress last painted, so idle frames do nothing

  const build = () => {
    const tr = track.current, s = svg.current, path = pen.current;
    if (!tr || !s || !path || !section.current || pics.current.some((p) => !p)) return;
    tr.style.transform = "none";
    const T = tr.getBoundingClientRect();
    const vw = section.current.clientWidth, mob = isPhone();
    const W = T.width, H = T.height;
    s.setAttribute("viewBox", `0 0 ${W} ${H}`);
    s.style.width = `${W}px`;
    s.style.height = `${H}px`;

    const rel = (el: Element) => {
      const r = el.getBoundingClientRect();
      return { x: r.left - T.left, y: r.top - T.top, w: r.width, h: r.height };
    };
    const boxes = pics.current.map((p) => rel(p!));
    const lowest = Math.max(...texts.current.map((t) => (t ? rel(t).y + rel(t).h : 0)));
    const base = boxes[0].y + boxes[0].h + PAD; // the day's baseline, just under the drawings
    const r = Math.min(26, boxes[0].w * 0.12);
    const gx = mob ? 6 : dayGx() - T.left;

    let d = `M ${gx} -2`;
    let cur: Pt = [gx, -2];
    const probe = document.createElementNS(NS, "path");
    s.appendChild(probe);
    const len = () => {
      probe.setAttribute("d", d);
      return probe.getTotalLength();
    };
    const Cto = (q: Pt, t0: Pt, t1: Pt, k = 0.5) => {
      const l = Math.hypot(q[0] - cur[0], q[1] - cur[1]) * k;
      d += ` C ${cur[0] + t0[0] * l} ${cur[1] + t0[1] * l} ${q[0] - t1[0] * l} ${q[1] - t1[1] * l} ${q[0]} ${q[1]}`;
      cur = q;
    };

    const arrive: number[] = [], leave: number[] = [];
    boxes.forEach((b, i) => {
      const x0 = b.x - PAD, x1 = b.x + b.w + PAD, y0 = b.y - PAD;
      if (i === 0) Cto([x0, base], [0, 1], [1, 0]);
      else d += ` L ${x0} ${base}`;
      cur = [x0, base];
      arrive.push(len());
      // up, over and down: an arch round the moment's drawing
      d += ` L ${x0} ${y0 + r} Q ${x0} ${y0} ${x0 + r} ${y0} L ${x1 - r} ${y0} Q ${x1} ${y0} ${x1} ${y0 + r} L ${x1} ${base}`;
      cur = [x1, base];
      leave.push(len());
    });

    // Home: back along under the text and out of the bottom of the screen at the left margin,
    // where the page line carries on. On phones the last screen is the fourth one.
    const runY = Math.min(lowest + 34, H - 26); // under the text, clear of the screen's bottom edge
    const ex = mob ? 3 * vw + 6 : gx;
    Cto([ex + 40, runY], [0.2, 1], [-1, 0]);
    Cto([ex, H + 4], [-1, 0], [0, 1], 0.5);
    probe.remove();

    path.setAttribute("d", d);
    path.style.strokeWidth = mob ? "5" : "7";
    const L = path.getTotalLength();
    path.style.strokeDasharray = `${L} ${L + 10}`;
    // Phones hold each moment long enough to read it before the view pans on.
    const at = makeSchedule(
      arrive.map((a, i) => ({ start: a, end: leave[i] })),
      L,
      mob ? { lead: 0.3, hold: 1.4, travel: 0.6, exit: 0.6 } : { lead: 0.3, hold: 0.45, travel: 0.25, exit: 0.6 },
    );
    const items = texts.current.map((t) => (t ? [...t.children] : []));
    built.current = { L, arrive, leave, vw, mob, pin: measurePin(section.current), point: trace(d, L), items, at };
    if (still) shown.current = 1;
    paintedAt.current = -1;
    paint();
  };

  const paint = () => {
    const b = built.current, path = pen.current;
    if (!b || !path) return;
    const { L, arrive, leave, vw, mob } = b;
    const state = b.at(shown.current);
    const dr = state.drawn;
    path.style.strokeDashoffset = `${L - dr}`;
    const [x, y] = b.point(dr);
    nib.current?.setAttribute("cx", `${x}`);
    nib.current?.setAttribute("cy", `${y}`);
    if (nib.current) nib.current.style.opacity = dr > 2 && dr < L - 2 ? "1" : "0";

    arrive.forEach((a, i) => {
      // the drawing appears as the arch goes over it; its words reveal while the pen holds, and stay
      slide(reveals.current[i], span01(dr, a, leave[i]));
      b.items[i].forEach((el, j) => wipe(el, span01(state.text[i], j * 0.2, 0.5 + j * 0.25)));
    });

    // phones: one moment per screen; the view moves on only after the hold
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
    <section className="day f-honey" id="day" data-tone="light" aria-label="A day with Second Strong" ref={section}>
      <div className="stick">
        <div className="viewport">
          <div className="track" ref={track}>
            <div className="dhead wrap">
              <span className="eyebrow">A day with Second Strong</span>
              <h2>
                <span>Small things, </span>
                <span className="em">all day.</span>
              </h2>
            </div>
            <div className="dcols wrap">
              {daySteps.map((s, i) => (
                <div className="dcol" key={s.time}>
                  <div className="dpic" ref={(el) => void (pics.current[i] = el)}>
                    <div className="rv" ref={(el) => void (reveals.current[i] = el)}>
                      <Draw name={s.draw} label={`Line drawing: ${s.title}`} />
                    </div>
                  </div>
                  <div className="dtxt" ref={(el) => void (texts.current[i] = el)}>
                    <span className="t">{s.time}</span>
                    <b>{s.title}</b>
                    <p>{s.text}</p>
                  </div>
                </div>
              ))}
            </div>
            <svg className="fline" ref={svg} aria-hidden="true">
              <path className="pen" ref={pen} />
              <circle ref={nib} r="8" fill="#C08E82" />
            </svg>
          </div>
        </div>
      </div>
    </section>
  );
}
