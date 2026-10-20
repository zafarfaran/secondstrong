"use client";

import { useRef, useSyncExternalStore } from "react";
import { CTA_HREF, CTA_LABEL, hero } from "@/content/site";
import { isLite, useStill } from "@/lib/motion/MotionProvider";
import { HERO_TALL, HERO_WIDE } from "@/lib/motion/boot";
import { pinProgress, useFrame } from "@/lib/motion/frame";
import { useScrubVideo } from "@/lib/motion/scrub";
import { heroIsTall } from "@/lib/line/geometry";

const onResize = (cb: () => void) => {
  addEventListener("resize", cb);
  return () => removeEventListener("resize", cb);
};
const noSubscribe = () => () => {};

/** When each headline line lands, matched to the drawings in the hero film. */
const LANDS = [0.08, 0.36, 0.63, 0.8];

/**
 * The opening screen. It stays pinned while scroll drives a silent line-drawing film
 * (wide cut on desktop, tall cut on phones) and builds the headline over it.
 */
export function Hero() {
  const still = useStill();
  const section = useRef<HTMLElement>(null);
  const video = useRef<HTMLVideoElement>(null);
  const parts = useRef<HTMLElement[]>([]);
  // Phones and tall windows get the tall cut, and switch if a resize crosses over.
  // Read on the client only; null during server render.
  const src = useSyncExternalStore(onResize, () => (heroIsTall() ? HERO_TALL : HERO_WIDE), () => null);
  // Data-saver, 2G and very low-memory devices get the finished frame as a still instead of the film.
  const lite = useSyncExternalStore(noSubscribe, isLite, () => false);
  const animate = !still && !lite;

  const progress = () => (section.current ? pinProgress(section.current) : 0);
  useScrubVideo(video, src, progress, animate);

  const lastP = useRef(-1);
  useFrame(() => {
    const p = progress();
    if (p === lastP.current) return;
    lastP.current = p;
    parts.current.forEach((el) => el.classList.toggle("on", p >= LANDS[Number(el.dataset.s)]));
    section.current?.classList.toggle("moved", p > 0.03);
  }, animate, section);

  const part = (el: HTMLElement | null) => {
    if (el && !parts.current.includes(el)) parts.current.push(el);
  };

  return (
    <section className="hero" id="hero" data-tone="light" ref={section}>
      <div className="stick">
        <video ref={video} muted playsInline preload="auto" aria-label={hero.videoLabel} />
        <div className="wrap copy">
          <div>
            <h1 id="h-hero">
              {hero.lines.map((line, i) => (
                <span key={line} data-s={i} ref={part}>
                  {line}
                </span>
              ))}
              <span data-s={2} ref={part}>
                {hero.last.lead} <span className="em inline">{hero.last.em}</span>
              </span>
            </h1>
          </div>
          <div>
            <p className="lede" data-s={3} ref={part}>
              {hero.lede}
            </p>
            <div className="cta" data-s={3} ref={part}>
              <a className="btn" href={CTA_HREF}>
                {CTA_LABEL}
              </a>
              <span className="mono">{hero.priceNote}</span>
            </div>
          </div>
        </div>
        <div className="cue" aria-hidden="true">
          Scroll<i />
        </div>
      </div>
    </section>
  );
}
