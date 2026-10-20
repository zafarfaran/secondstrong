"use client";

import { useRef } from "react";
import { useStill } from "@/lib/motion/MotionProvider";
import { useFrame, useLayoutRebuild, view } from "@/lib/motion/frame";
import { setHits } from "@/lib/motion/hits";
import { box, isPhone, pageWidth, PHONE_BREAKPOINT } from "@/lib/line/geometry";
import { buildRoute } from "@/lib/line/route";
import { lengthForY, measure, pointAt, type Chunk, type Measured } from "@/lib/line/measure";

const NS = "http://www.w3.org/2000/svg";

interface Piece extends Chunk {
  ink: SVGPathElement;
  ivory: SVGPathElement;
  /** The browser's own length for this chunk, which its dash offset is measured against. */
  pathLen: number;
  /** Last offset written, so a chunk the pen isn't in is never touched (and never repainted). */
  off: number;
}

interface Built extends Measured {
  pieces: Piece[];
}

/** Seconds for the pen to close ~63% of the gap to the scroll. Phones follow tighter: their scroll already glides. */
const LAG_DESKTOP = 0.11;
const LAG_PHONE = 0.045;

/**
 * The one line that runs the whole page. Ink where the section is light, ivory where it is
 * dark, drawn by scroll with the pen leading at 62% of the viewport.
 *
 * It is drawn as short chunks: each frame only the chunk under the pen changes, so the browser
 * repaints a few hundred pixels instead of a page-tall layer. Light and dark are separated with
 * rectangle clips, which are far cheaper to rasterise than a mask.
 */
export function PageLine() {
  const still = useStill();
  const svg = useRef<SVGSVGElement>(null);
  const inkGroup = useRef<SVGGElement>(null);
  const ivoryGroup = useRef<SVGGElement>(null);
  const nib = useRef<SVGCircleElement>(null);
  const clipDark = useRef<SVGClipPathElement>(null);
  const clipLight = useRef<SVGClipPathElement>(null);
  const built = useRef<Built | null>(null);
  const drawn = useRef(0);
  const painted = useRef(-1);
  const hitCount = useRef(-1);
  const lastT = useRef(0);

  const paint = () => {
    const b = built.current;
    if (!b || !nib.current) return;
    const dr = drawn.current;
    if (Math.abs(dr - painted.current) < 0.25) return; // nothing visible changed
    painted.current = dr;
    for (const pc of b.pieces) {
      const f = dr <= pc.start ? 0 : dr >= pc.end ? 1 : (dr - pc.start) / (pc.end - pc.start || 1);
      const off = Math.round(pc.pathLen * (1 - f) * 10) / 10;
      if (off === pc.off) continue;
      pc.off = off;
      pc.ink.style.strokeDashoffset = `${off}`;
      pc.ivory.style.strokeDashoffset = `${off}`;
    }
    const [x, y] = pointAt(b, dr);
    nib.current.setAttribute("cx", `${x}`);
    nib.current.setAttribute("cy", `${y}`);
    nib.current.style.opacity = dr > 2 && dr < b.total - 2 ? "1" : "0";
    let reached = 0;
    while (reached < b.hits.length && dr >= b.hits[reached].at - 2) reached++;
    if (reached !== hitCount.current) {
      hitCount.current = reached;
      setHits(new Set(b.hits.slice(0, reached).map((h) => h.selector)));
    }
  };

  const build = () => {
    const s = svg.current, gi = inkGroup.current, gv = ivoryGroup.current;
    if (!s || !gi || !gv || !nib.current || !clipDark.current || !clipLight.current) return;
    const page = document.getElementById("page")!;
    const H = page.scrollHeight, W = pageWidth();
    s.setAttribute("viewBox", `0 0 ${W} ${H}`);
    s.style.height = `${H}px`;
    const sw = isPhone() ? 4.5 : 7;
    nib.current.setAttribute("r", `${sw + 2}`);

    // Ivory over dark fields, ink over the light gaps between them.
    const dark = [...document.querySelectorAll<HTMLElement>("#page section[data-tone=dark], #page footer")]
      .map((el) => box(`#${el.id}`))
      .sort((p, q) => p.y - q.y);
    clipDark.current.innerHTML = dark.map((d) => `<rect x="0" y="${d.y}" width="${W}" height="${d.h}"/>`).join("");
    let top = 0, light = "";
    for (const d of dark) {
      if (d.y > top) light += `<rect x="0" y="${top}" width="${W}" height="${d.y - top}"/>`;
      top = Math.max(top, d.y + d.h);
    }
    if (top < H) light += `<rect x="0" y="${top}" width="${W}" height="${H - top}"/>`;
    clipLight.current.innerHTML = light;

    const m = measure(buildRoute(), s);
    gi.replaceChildren();
    gv.replaceChildren();
    const pieces: Piece[] = m.chunks.map((c) => {
      const ink = document.createElementNS(NS, "path");
      const ivory = document.createElementNS(NS, "path");
      for (const p of [ink, ivory]) p.setAttribute("d", c.d);
      ink.setAttribute("stroke", "#3B322C");
      ivory.setAttribute("stroke", "#FBF8F4");
      gi.appendChild(ink);
      gv.appendChild(ivory);
      const pathLen = ink.getTotalLength();
      for (const p of [ink, ivory]) {
        p.setAttribute("stroke-width", `${sw}`);
        p.style.strokeDasharray = `${pathLen} ${pathLen + 10}`;
        p.style.strokeDashoffset = `${pathLen}`;
      }
      return { ...c, ink, ivory, pathLen, off: pathLen };
    });
    built.current = { ...m, pieces };
    if (still) drawn.current = m.total;
    else drawn.current = Math.min(drawn.current, m.total);
    painted.current = -1;
    hitCount.current = -1;
    paint();
  };

  useLayoutRebuild(build, [still]);

  // Scroll sets a target length; the pen eases towards it so fast flicks still read as drawing.
  // The easing runs on elapsed time, so a dropped frame doesn't make the pen fall further behind.
  useFrame(() => {
    const b = built.current;
    const now = performance.now();
    const dt = Math.min(0.1, (now - (lastT.current || now)) / 1000);
    lastT.current = now;
    if (!b) return;
    const atBottom = view.y + view.h >= view.docH - 4;
    const want = atBottom ? b.total : lengthForY(b, view.y + view.h * 0.62);
    if (drawn.current === want) return;
    const k = 1 - Math.exp(-dt / (view.w < PHONE_BREAKPOINT ? LAG_PHONE : LAG_DESKTOP));
    drawn.current += (want - drawn.current) * k;
    if (Math.abs(want - drawn.current) < 0.5) drawn.current = want;
    paint();
  }, !still);

  return (
    <svg id="line" ref={svg} aria-hidden="true">
      <defs>
        <clipPath id="clipDark" ref={clipDark} />
        <clipPath id="clipLight" ref={clipLight} />
      </defs>
      <g ref={inkGroup} clipPath="url(#clipLight)" />
      <g ref={ivoryGroup} clipPath="url(#clipDark)" />
      <circle id="nib" ref={nib} r="7" fill="#C08E82" />
    </svg>
  );
}
