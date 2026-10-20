"use client";

import { useEffect, useRef, type RefObject } from "react";
import { useFrame } from "./frame";
import "./boot";

/**
 * Drives a muted <video>'s currentTime from a 0..1 progress value each frame.
 * The file is fetched whole first so seeking is instant, and the video is played then paused
 * once, because iOS only paints seeked frames after a play.
 */
export function useScrubVideo(
  video: RefObject<HTMLVideoElement | null>,
  src: string | null,
  progress: () => number,
  active: boolean,
) {
  const shown = useRef(0);

  useEffect(() => {
    const v = video.current;
    if (!v || !src || !active) return;
    let url: string | null = null;
    let cancelled = false;
    // Use the download the boot script already started for this film, if there is one.
    const early = window.__ssHero?.url === src ? window.__ssHero.blob : null;
    (early ?? fetch(src).then((r) => r.blob()))
      .then((b) => {
        if (cancelled) return;
        url = URL.createObjectURL(b);
        v.src = url;
      })
      .catch(() => {
        if (!cancelled) v.src = src;
      });
    const prime = () => v.play().then(() => v.pause()).catch(() => {});
    v.addEventListener("loadedmetadata", prime, { once: true });
    return () => {
      cancelled = true;
      v.removeEventListener("loadedmetadata", prime);
      if (url) URL.revokeObjectURL(url);
    };
  }, [video, src, active]);

  useFrame(() => {
    const v = video.current;
    if (!v || !v.duration) return;
    const want = progress() * (v.duration - 0.05);
    shown.current += (want - shown.current) * 0.25;
    seek(v, shown.current);
  }, active, video);
}

/** Seek only when the difference is visible, so idle frames don't thrash the decoder. */
function seek(v: HTMLVideoElement, t: number) {
  if (Math.abs(v.currentTime - t) > 0.02) v.currentTime = t;
}
