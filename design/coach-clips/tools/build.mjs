// Builds one HyperFrames composition per coach state from the mascot board, plus manifest.json
// describing each clip's in / loop / out segments. Usage: node tools/build.mjs [coach]   (default bramble)
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const project = join(here, "..");
const board = readFileSync(join(project, "..", "mascots", "mascot-board.html"), "utf8");
const src = board.slice(board.indexOf("const EYE"), board.indexOf("/* state chips */"));
const { mascot, CHARS } = new Function(`${src}; return { mascot, CHARS };`)();
const COACH = process.argv[2] || "bramble";
const c = CHARS[COACH];

/* the coach as one SVG, with each ear pulled into its own group so it can lag and flop */
let svg = mascot(COACH)
  .replace('class="m"', 'class="m" id="coach"')
  .replace('viewBox="0 0 200 200"', 'viewBox="-20 -50 240 240"')
  .replace(/data-layer=/g, "data-part=")
  .replace(/<text x="(\d+)" y="(\d+)" font-size="(\d+)">z<\/text>/g, (_, x, y, fs) => {
    const k = +fs * .62, X = +x, Y = +y;
    return `<path class="zz" d="M${X} ${Y - k} h${k} l${-k} ${k} h${k}" fill="none" stroke="var(--terra)" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>`;
  });
const back = svg.match(/<g data-part="back">([\s\S]*?)<\/g>(?=\s*<g data-part="body">)/);
if (back && c.back.length >= 2) {
  const paths = back[1].match(/<path[^>]*\/>/g) || [];
  const rest = back[1].replace(/<path[^>]*\/>/g, "");
  /* ears: [outer L, outer R, inner L, inner R] when four parts, else [L, R] */
  const left = paths.length >= 4 ? paths[0] + paths[2] : paths[0];
  const right = paths.length >= 4 ? paths[1] + paths[3] : paths[1];
  const extra = paths.length > 4 ? paths.slice(4).join("") : (paths.length === 3 ? paths[2] : "");
  svg = svg.replace(back[0], `<g data-part="back"><g id="earL">${left}</g><g id="earR">${right}</g>${extra}${rest}</g>`);
}

/* segment lengths in seconds: in (neutral to state), loop (seamless), out (state to neutral) */
const STATES = {
  idle:       { loop: 4.0 },
  hello:      { in: .5, loop: 1.2, out: .5 },
  listening:  { in: .5, loop: 2.0, out: .5 },
  thinking:   { in: .5, loop: 2.4, out: .5 },
  proud:      { in: .4, loop: 1.2, out: .4 },   // every boundary lands on a whole frame at 30fps
  lifting:    { in: .5, loop: 1.8, out: .5 },
  stretching: { in: .7, loop: 2.0, out: .7 },
  comfort:    { in: .6, loop: 2.4, out: .6 },
  resting:    { in: .8, loop: 3.0, out: .8 }
};

/* the animation, written once and embedded in every clip; build(state, seg) fills a paused timeline */
const RUNTIME = String.raw`
function build(tl, state, S) {
  const I = S.in || 0, L = S.loop, O = S.out || 0, A = I, B = I + L;   // loop runs A..B
  const q = s => document.querySelectorAll("#coach " + s);
  const R = q(".rig"), P = q(".pose"), EL = q("#earL"), ER = q("#earR"), SH = q(".shadow");
  const blink = t => tl.to(q(".blink"), { scaleY: .08, duration: .06, ease: "power1.in", transformOrigin: "50% 50%" }, t)
                       .to(q(".blink"), { scaleY: 1, duration: .1, ease: "power1.out" }, t + .06);
  /* eyes change inside a quick blink: squash the open eye, swap while it's shut, open again */
  const eyes = (to, t) => {
    tl.to(q(".blink"), { scaleY: .08, duration: .06, ease: "power1.in", transformOrigin: "50% 50%" }, t);
    tl.set(q(".e-open"), { opacity: to === "open" ? 1 : 0 }, t + .06);
    tl.set(q(".e-shut"), { opacity: to === "shut" ? 1 : 0 }, t + .06);
    tl.set(q(".e-happy"), { opacity: to === "happy" ? 1 : 0 }, t + .06);
    tl.to(q(".blink"), { scaleY: 1, duration: .1, ease: "power1.out" }, t + .06);
  };
  const mouth = (open, t, d = .16) => { tl.to(q(".mo-open"), { opacity: open ? 1 : 0, duration: d }, t); tl.to(q(".mo-shut"), { opacity: open ? 0 : 1, duration: d }, t); };
  const brows = (l, r, t, d = .3, ease = "back.out(2)") => { tl.to(q(".brow-l"), { ...l, duration: d, ease, transformOrigin: "50% 50%" }, t); tl.to(q(".brow-r"), { ...r, duration: d, ease, transformOrigin: "50% 50%" }, t); };
  const B0 = { x: 0, y: 0, rotation: 0 };
  const ears = (l, r, t, d, ease = "power2.out") => { tl.to(EL, { rotation: l, duration: d, ease, transformOrigin: "70% 90%" }, t); tl.to(ER, { rotation: r, duration: d, ease, transformOrigin: "30% 90%" }, t); };
  const arm = (side, v, t, d, ease = "back.out(1.6)") => tl.to(q(".arm-" + side), { ...v, duration: d, ease, transformOrigin: "50% 0%" }, t);
  const fx = (name, on, t, d = .25) => tl.to(q(".fx-" + name), { opacity: on ? 1 : 0, duration: d }, t);
  const draw = (sel, t, d = .5) => tl.fromTo(q(sel), { strokeDashoffset: 70 }, { strokeDashoffset: 0, duration: d, ease: "power2.out" }, t);
  /* body breathing over [t, t+dur]: an even number of half-cycles so it ends where it began */
  const breathe = (t, dur, cycles, amp, target = R) => tl.to(target, { scaleY: 1 + amp, scaleX: 1 - amp * .6, svgOrigin: "100 178", duration: dur / (cycles * 2), ease: "sine.inOut", yoyo: true, repeat: cycles * 2 - 1 }, t);

  /* neutral pose at t = 0 */
  tl.set(q(".arm"), { rotation: -40, scale: 0, opacity: 0, transformOrigin: "50% 0%" }, 0);
  tl.set([...R, ...P], { svgOrigin: "100 178" }, 0);

  if (state === "idle") {
    breathe(0, L, 2, .03);
    blink(1.3); blink(3.05); blink(3.3);
    tl.to(q(".look"), { x: 2.5, y: -.5, duration: .35, ease: "power2.inOut" }, .6).to(q(".look"), { x: 0, y: 0, duration: .4, ease: "power2.inOut" }, 2.3);
    /* a little ear twitch, with follow-through */
    tl.to(ER, { rotation: 9, duration: .1, ease: "power2.out", transformOrigin: "30% 90%" }, 2.0).to(ER, { rotation: -4, duration: .16, ease: "power1.inOut" }, 2.1).to(ER, { rotation: 0, duration: .3, ease: "elastic.out(1,.5)" }, 2.26);
  }

  if (state === "hello") {
    /* in: a small crouch, a pop up, the arm swings out */
    tl.to(R, { scaleY: .93, scaleX: 1.05, duration: .14, ease: "power2.in" }, 0).to(R, { scaleY: 1.04, scaleX: .97, y: -5, duration: .18, ease: "power2.out" }, .14).to(R, { scaleY: 1, scaleX: 1, y: 0, duration: .18, ease: "power2.inOut" }, .32);
    ears(-10, 10, .14, .15); ears(4, -4, .3, .2, "power1.inOut");
    arm("r", { rotation: -140, scale: 1, opacity: 1 }, .1, .38);
    eyes("happy", .16); mouth(true, .16); brows({ y: -3 }, { y: -3 }, .12);
    tl.to(P, { rotation: -4, duration: .4, ease: "power2.out" }, .1);
    fx("hello", true, .2);
    /* loop: two waves, ears bob in time */
    for (let i = 0; i < 2; i++) { arm("r", { rotation: -103 }, A + i * .6, .3, "sine.inOut"); arm("r", { rotation: -140 }, A + i * .6 + .3, .3, "sine.inOut"); }
    tl.to(EL, { rotation: -3, duration: .3, ease: "sine.inOut", yoyo: true, repeat: 3 }, A);
    tl.to(ER, { rotation: 3, duration: .3, ease: "sine.inOut", yoyo: true, repeat: 3 }, A);
    /* out */
    arm("r", { rotation: -40, scale: 0, opacity: 0 }, B, .35, "power2.in");
    eyes("open", B + .1); mouth(false, B + .1); brows(B0, B0, B, .3, "power2.out"); fx("hello", false, B);
    tl.to(P, { rotation: 0, duration: .4, ease: "power2.inOut" }, B); ears(0, 0, B, .35);
  }

  if (state === "listening") {
    tl.to(P, { rotation: -6, duration: .45, ease: "back.out(1.4)" }, 0);
    tl.to(q(".look"), { x: -2, y: 1, scale: 1.1, duration: .35, ease: "power2.out", transformOrigin: "50% 50%" }, .05);
    brows({ y: -2.5 }, { y: -2.5 }, .05); ears(-12, -5, .05, .3, "back.out(2)");
    /* loop: two slow nods, the sound arcs drawn each time */
    for (let i = 0; i < 2; i++) {
      tl.to(P, { rotation: -9.5, duration: .5, ease: "sine.inOut" }, A + i * 1).to(P, { rotation: -6, duration: .5, ease: "sine.inOut" }, A + i * 1 + .5);
      fx("listen", true, A + i, .15); draw(".fx-listen .draw", A + i, .55); fx("listen", false, A + i + .7, .25);
      tl.to(EL, { rotation: -15, duration: .25, ease: "power2.out" }, A + i + .45).to(EL, { rotation: -12, duration: .3, ease: "elastic.out(1,.5)" }, A + i + .7);
    }
    blink(A + 1.15);
    tl.to(P, { rotation: 0, duration: .45, ease: "power2.inOut" }, B);
    tl.to(q(".look"), { x: 0, y: 0, scale: 1, duration: .35, ease: "power2.inOut" }, B);
    brows(B0, B0, B, .3, "power2.out"); ears(0, 0, B, .35);
  }

  if (state === "thinking") {
    tl.to(q(".look"), { x: 4, y: -5, duration: .35, ease: "power2.inOut" }, 0);
    tl.to(P, { rotation: 3, duration: .45, ease: "power2.out" }, 0);
    brows({ rotation: 6 }, { y: -3.5, rotation: -9 }, .05);
    ears(-3, 8, .1, .3);
    fx("think", true, .25, .2);
    /* loop: the dots pulse in turn, a slow sway */
    const dots = q(".fx-think circle");
    tl.set(dots, { transformOrigin: "50% 50%", scale: .4, opacity: .35 }, 0);
    for (let k = 0; k < 2; k++) dots.forEach((d, i) => { tl.to(d, { scale: 1, opacity: 1, duration: .3, ease: "power2.out" }, A + k * 1.2 + i * .2).to(d, { scale: .4, opacity: .35, duration: .4, ease: "power2.in" }, A + k * 1.2 + i * .2 + .3); });
    tl.to(P, { rotation: 1, duration: .6, ease: "sine.inOut", yoyo: true, repeat: 3 }, A);
    blink(A + 1.6);
    tl.to(q(".look"), { x: 0, y: 0, duration: .35, ease: "power2.inOut" }, B);
    tl.to(P, { rotation: 0, duration: .45, ease: "power2.inOut" }, B);
    brows(B0, B0, B, .3, "power2.out"); ears(0, 0, B, .35); fx("think", false, B, .2);
  }

  if (state === "proud") {
    /* in: anticipation, a deep crouch */
    tl.to(R, { scaleY: .86, scaleX: 1.12, duration: I, ease: "power2.in" }, 0);
    tl.to(SH, { scaleX: 1.08, duration: I, ease: "power2.in", transformOrigin: "50% 50%" }, 0);
    eyes("happy", .05); mouth(true, .1); brows({ y: -3 }, { y: -3 }, 0); ears(6, -6, 0, I);
    fx("proud", true, A, .1);
    /* loop: launch, stretch in the air, ears trail, land with squash, back into the crouch */
    tl.to(R, { y: -30, scaleY: 1.1, scaleX: .93, duration: .36, ease: "power2.out" }, A)
      .to(R, { scaleY: 1, scaleX: 1, duration: .12, ease: "sine.inOut" }, A + .36)
      .to(R, { y: 0, scaleY: 1.06, scaleX: .96, duration: .28, ease: "power2.in" }, A + .48)
      .to(R, { scaleY: .82, scaleX: 1.16, duration: .1, ease: "power2.out" }, A + .76)
      .to(R, { scaleY: .9, scaleX: 1.08, duration: .16, ease: "power1.out" }, A + .86)
      .to(R, { scaleY: .86, scaleX: 1.12, duration: .18, ease: "sine.inOut" }, A + 1.02);
    tl.to(SH, { scaleX: .6, opacity: .5, duration: .4, ease: "power2.out" }, A).to(SH, { scaleX: 1.12, opacity: 1, duration: .36, ease: "power2.in" }, A + .4).to(SH, { scaleX: 1.08, duration: .44, ease: "sine.out" }, A + .76);
    ears(16, -16, A, .2, "power2.out"); ears(-14, 14, A + .3, .3, "sine.inOut"); ears(12, -12, A + .76, .12, "power2.out"); ears(6, -6, A + .9, .3, "elastic.out(1,.45)");
    draw(".fx-proud .draw", A + .25, .45);
    /* the tick fades before the loop ends, so the loop starts and ends on the same frame */
    tl.set(q(".fx-proud .draw"), { opacity: 1 }, A + .24); tl.to(q(".fx-proud .draw"), { opacity: 0, duration: .16, ease: "power1.in" }, A + .98);
    /* out: rise out of the crouch with a small settle */
    tl.to(R, { scaleY: 1.03, scaleX: .98, duration: .22, ease: "power2.out" }, B).to(R, { scaleY: 1, scaleX: 1, duration: .2, ease: "sine.inOut" }, B + .22);
    tl.to(SH, { scaleX: 1, duration: .3 }, B);
    eyes("open", B + .1); mouth(false, B + .1); brows(B0, B0, B, .3, "power2.out"); ears(0, 0, B, .4, "elastic.out(1,.5)"); fx("proud", false, B, .15);
  }

  if (state === "lifting") {
    /* in: arms out with the dumbbells, a determined face, settle into the squat */
    arm("l", { rotation: -80, scale: 1, opacity: 1 }, 0, .4); arm("r", { rotation: -80, scale: 1, opacity: 1 }, .04, .4);
    tl.to(q(".db"), { opacity: 1, duration: .2 }, .15);
    brows({ y: 1.5, rotation: 14 }, { y: 1.5, rotation: -14 }, .05);
    tl.to(R, { scaleY: .95, scaleX: 1.04, duration: .4, ease: "power2.inOut" }, .1);
    /* loop: press up, hold a beat, lower back into the squat */
    ["l", "r"].forEach(s => { arm(s, { rotation: -172 }, A + .05, .6, "power2.inOut"); arm(s, { rotation: -80 }, A + 1.0, .7, "power2.inOut"); });
    tl.to(R, { scaleY: 1.04, scaleX: .97, y: -3, duration: .6, ease: "power2.inOut" }, A + .05).to(R, { scaleY: .95, scaleX: 1.04, y: 0, duration: .7, ease: "power2.inOut" }, A + 1.0);
    ears(-6, 6, A + .1, .4); ears(5, -5, A + .7, .25); ears(0, 0, A + 1.05, .5, "elastic.out(1,.5)");
    fx("lift", true, A + .55, .1); draw(".fx-lift .draw", A + .55, .3); fx("lift", false, A + .95, .2);
    /* out */
    arm("l", { rotation: -40, scale: 0, opacity: 0 }, B, .4, "power2.in"); arm("r", { rotation: -40, scale: 0, opacity: 0 }, B + .04, .4, "power2.in");
    tl.to(q(".db"), { opacity: 0, duration: .15 }, B + .2);
    tl.to(R, { scaleY: 1, scaleX: 1, duration: .45, ease: "back.out(2)" }, B); brows(B0, B0, B, .3, "power2.out");
  }

  if (state === "stretching") {
    /* in: arms rise, the body grows tall, eyes close, a little yawn */
    arm("l", { rotation: -160, scale: 1, opacity: 1 }, 0, .6, "power2.out"); arm("r", { rotation: -160, scale: 1, opacity: 1 }, .05, .6, "power2.out");
    tl.to(R, { scaleY: 1.1, scaleX: .93, duration: .65, ease: "power2.inOut" }, .05);
    eyes("shut", .2); mouth(true, .25); brows({ y: -2 }, { y: -2 }, .2); ears(-8, 8, .1, .5);
    /* loop: reach a little higher and back, twice */
    ["l", "r"].forEach(s => tl.to(q(".arm-" + s), { rotation: -176, duration: .5, ease: "sine.inOut", yoyo: true, repeat: 3 }, A));
    tl.to(R, { scaleY: 1.13, scaleX: .91, duration: .5, ease: "sine.inOut", yoyo: true, repeat: 3 }, A);
    /* out: arms drop, a quick shake-off */
    arm("l", { rotation: -40, scale: 0, opacity: 0 }, B, .45, "power2.in"); arm("r", { rotation: -40, scale: 0, opacity: 0 }, B + .05, .45, "power2.in");
    tl.to(R, { scaleY: .95, scaleX: 1.05, duration: .2, ease: "power2.in" }, B + .1).to(R, { scaleY: 1, scaleX: 1, duration: .35, ease: "elastic.out(1,.4)" }, B + .3);
    eyes("open", B + .25); mouth(false, B + .15); brows(B0, B0, B, .3, "power2.out"); ears(0, 0, B + .1, .5, "elastic.out(1,.5)");
  }

  if (state === "comfort") {
    tl.to(P, { rotation: 7, duration: .55, ease: "power2.inOut" }, 0);
    eyes("shut", .1); brows({ y: -1, rotation: -16 }, { y: -1, rotation: 16 }, .1, .45, "power2.out");
    tl.to(q(".cheek"), { opacity: .9, duration: .4 }, .1); ears(8, 4, .1, .5, "power2.inOut");
    tl.set(q(".fx-comfort path"), { transformOrigin: "50% 50%", scale: .85 }, 0);
    fx("comfort", true, .3, .3);
    /* loop: a slow breath, a gentle heartbeat */
    breathe(A, L, 1, .025);
    const H = q(".fx-comfort path");
    tl.to(H, { scale: 1.08, duration: .15, ease: "power2.out" }, A).to(H, { scale: .95, duration: .15 }, A + .15).to(H, { scale: 1.04, duration: .15 }, A + .3).to(H, { scale: .85, duration: .5, ease: "power2.inOut" }, A + .45);
    /* out */
    tl.to(P, { rotation: 0, duration: .55, ease: "power2.inOut" }, B);
    eyes("open", B + .15); brows(B0, B0, B, .4, "power2.out"); tl.to(q(".cheek"), { opacity: .5, duration: .4 }, B); ears(0, 0, B, .5); fx("comfort", false, B, .3);
  }

  if (state === "resting") {
    /* in: settle down, ears droop, eyes close slowly */
    tl.to(P, { scaleY: .95, scaleX: 1.04, duration: .7, ease: "power2.inOut" }, 0);
    eyes("shut", .2); brows({ y: 2 }, { y: 2 }, .2, .5, "power2.out"); ears(13, -13, .1, .6, "power2.inOut");
    fx("rest", true, A, .05);
    /* loop: one slow breath, three z's drift up and fade */
    breathe(A, L, 1, .025);
    q(".fx-rest .zz").forEach((z, i) => { tl.fromTo(z, { opacity: 0, y: 6 }, { opacity: 1, y: 0, duration: .45, ease: "power1.out" }, A + .2 + i * .7).to(z, { opacity: 0, y: -10, duration: .6, ease: "power1.in" }, A + .2 + i * .7 + .8); });
    /* out: wake up, a slow blink open, ears perk */
    tl.to(P, { scaleY: 1, scaleX: 1, duration: .6, ease: "back.out(1.6)" }, B + .1);
    eyes("open", B + .2); blink(B + .55); brows(B0, B0, B, .4, "power2.out"); ears(-4, 4, B + .15, .3); ears(0, 0, B + .45, .3, "elastic.out(1,.5)"); fx("rest", false, B, .05);
  }
}`;

const page = (state, S) => {
  const total = +((S.in || 0) + S.loop + (S.out || 0)).toFixed(3);
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=400, height=400" />
    <title>${c.name} · ${state}</title>
    <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
    <style>
      @font-face { font-family: "Gochi Hand"; src: url("../assets/GochiHand.woff2") format("woff2"); }
      :root { --shadow: rgba(59, 50, 44, 0.22); --terra: #A85A3C; }
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: 400px; height: 400px; overflow: hidden; background: transparent; }
      #root { position: relative; width: 100%; height: 100%; }
      #stage { position: absolute; inset: 0; }
      #coach { display: block; width: 100%; height: 100%; overflow: visible; font-family: "Gochi Hand", cursive; }
      #coach .e-shut, #coach .e-happy, #coach .mo-open, #coach .db { opacity: 0; }
      #coach .fx > g { opacity: 0; }
      #coach .draw { stroke-dasharray: 70; stroke-dashoffset: 70; }
    </style>
  </head>
  <body>
    <div id="root" data-composition-id="${state}" data-start="0" data-duration="${total}" data-width="400" data-height="400" data-fps="30">
      <div id="stage" class="clip" data-start="0" data-duration="${total}" data-track-index="0">
        ${svg}
      </div>
    </div>
    <script>
      ${RUNTIME}
      const tl = gsap.timeline({ paused: true });
      build(tl, ${JSON.stringify(state)}, ${JSON.stringify(S)});
      window.__timelines[${JSON.stringify(state)}] = tl;
      tl.seek(0);
    </script>
  </body>
</html>
`;
};

mkdirSync(join(project, "compositions"), { recursive: true });
const manifest = { coach: COACH, fps: 30, size: 400, states: {} };
for (const [state, S] of Object.entries(STATES)) {
  writeFileSync(join(project, "compositions", `${state}.html`), page(state, S));
  const i = S.in || 0, l = S.loop, o = S.out || 0;
  manifest.states[state] = { in: [0, i], loop: [i, +(i + l).toFixed(3)], out: [+(i + l).toFixed(3), +(i + l + o).toFixed(3)] };
}
writeFileSync(join(project, "manifest.json"), JSON.stringify(manifest, null, 2));
console.log(`built ${Object.keys(STATES).length} ${c.name} clips`);
