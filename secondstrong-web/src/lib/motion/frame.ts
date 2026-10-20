"use client";

import { useEffect, useEffectEvent, type RefObject } from "react";

/**
 * Scroll and viewport size, read once at the start of each frame before any callback writes to
 * the DOM. Reading scrollY or scrollHeight after a style write forces the browser to lay out the
 * page there and then; with several animations writing in turn, that happened several times a frame.
 */
export const view = { y: 0, w: 0, h: 0, docH: 0 };

// One requestAnimationFrame loop for every animation, so the reads above happen once, up front.
const callbacks = new Set<() => void>();
let raf = 0;
function tick() {
  view.y = scrollY;
  view.w = innerWidth;
  view.h = innerHeight;
  view.docH = document.documentElement.scrollHeight;
  callbacks.forEach((cb) => cb());
  raf = callbacks.size ? requestAnimationFrame(tick) : 0;
}

/**
 * Runs `callback` every animation frame while `active`, always calling the latest version.
 * With `target`, it only runs while that element is on or near the screen, so offscreen
 * sections cost nothing. Callbacks should read scroll and viewport from `view`.
 */
export function useFrame(callback: () => void, active = true, target?: RefObject<Element | null>) {
  const onFrame = useEffectEvent(callback);
  useEffect(() => {
    if (!active) return;
    const cb = () => onFrame();
    const start = () => {
      callbacks.add(cb);
      raf ||= requestAnimationFrame(tick);
    };
    const stop = () => void callbacks.delete(cb);
    const el = target?.current;
    if (!el) {
      start();
      return stop;
    }
    const io = new IntersectionObserver(([e]) => (e.isIntersecting ? start() : stop()), { rootMargin: "50% 0px" });
    io.observe(el);
    return () => {
      io.disconnect();
      stop();
    };
  }, [active, target]);
}

/** How far the viewport has scrolled through a pinned (tall) section, 0 to 1. */
export function pinProgress(el: HTMLElement): number {
  const r = el.getBoundingClientRect();
  const span = r.height - innerHeight;
  return span > 0 ? Math.min(1, Math.max(0, -r.top / span)) : 0;
}

/** Where a pinned section sits in the page. Measured when layout changes, so scroll frames needn't read layout. */
export interface Pin {
  top: number;
  height: number;
}
export function measurePin(el: HTMLElement): Pin {
  const r = el.getBoundingClientRect();
  return { top: r.top + scrollY, height: r.height };
}

/** Same as `pinProgress`, from a measured `Pin` and this frame's `view`: no layout read. */
export function pinAt(pin: Pin): number {
  const span = pin.height - view.h;
  return span > 0 ? Math.min(1, Math.max(0, (view.y - pin.top) / span)) : 0;
}

export const clamp01 = (x: number) => Math.min(1, Math.max(0, x));

/** Where `v` sits between `a` and `b`, clamped to 0..1. */
export const span01 = (v: number, a: number, b: number) => clamp01((v - a) / (b - a || 1));

/**
 * Rebuild geometry after real layout changes: fonts loaded, width changed, page height changed.
 * Height-only window resizes are ignored on touch devices, because phones fire them whenever the
 * address bar shows or hides; the pinned sections use svh so their layout doesn't move then.
 */
export function useLayoutRebuild(build: () => void, deps: unknown[] = []) {
  const onBuild = useEffectEvent(build);
  useEffect(() => {
    let timer = 0;
    let last = { w: -1, h: -1, body: -1 };
    const coarse = matchMedia("(pointer: coarse)");
    const sizes = () => ({ w: innerWidth, h: innerHeight, body: document.body.scrollHeight });
    const rebuild = () => {
      last = sizes();
      onBuild();
    };
    const check = () => {
      const now = sizes();
      const changed = now.w !== last.w || now.body !== last.body || (!coarse.matches && now.h !== last.h);
      if (changed) rebuild();
    };
    const schedule = () => {
      clearTimeout(timer);
      timer = window.setTimeout(check, 150);
    };
    document.fonts.ready.then(rebuild);
    addEventListener("resize", schedule);
    const ro = new ResizeObserver(schedule);
    ro.observe(document.body);
    return () => {
      clearTimeout(timer);
      removeEventListener("resize", schedule);
      ro.disconnect();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}
