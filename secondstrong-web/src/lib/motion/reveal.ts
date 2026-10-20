// Scroll frames call these with the same values over and over; only touch the DOM when the value changes.
const last = new WeakMap<Element, string>();
function set(el: Element | null | undefined, prop: "clipPath" | "transform", v: string) {
  if (!el || last.get(el) === v) return;
  last.set(el, v);
  (el as HTMLElement).style[prop] = v;
}

/** Reveal an element left to right as `t` goes 0 → 1 (scroll-driven, so it reverses too). */
export function wipe(el: Element | null | undefined, t: number) {
  set(el, "clipPath", t >= 1 ? "none" : `inset(-10% ${(100 - t * 100).toFixed(1)}% -10% -10%)`);
}

/** Reveal an element bottom to top as `t` goes 0 → 1. */
export function rise(el: Element | null | undefined, t: number) {
  set(el, "clipPath", `inset(${(100 - t * 100).toFixed(1)}% 0 0 0)`);
}

/**
 * Reveal left to right with transforms only, so the content is never repainted (a clip-path
 * wipe repaints it every frame, which is slow for masked drawings on phones). `el` clips
 * (overflow: hidden) and slides in from the left while its only child slides the other way,
 * so the child stays still and the clip's right edge moves across it.
 */
export function slide(el: Element | null | undefined, t: number) {
  const x = ((1 - Math.min(1, Math.max(0, t))) * 100).toFixed(2);
  set(el, "transform", `translate3d(-${x}%, 0, 0)`);
  set(el?.firstElementChild, "transform", `translate3d(${x}%, 0, 0)`);
}
