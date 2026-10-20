// Records the design prototypes as reference MP4s: plays each one in headless Chrome, captures frames with the
// DevTools screencast, crops to the phone and encodes with ffmpeg.
// Usage: node design/videos/record.mjs [name ...]   (no names = record everything)   Needs Chrome and ffmpeg.
import { spawn, execFileSync } from "node:child_process";
import { writeFileSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const design = join(here, "..");
const CHROME = process.env.CHROME || "C:/Program Files/Google/Chrome/Application/chrome.exe";
const sleep = ms => new Promise(r => setTimeout(r, ms));

/* each clip: page, what to frame, how long, and what to do once it has loaded */
const q = s => `document.querySelector(${JSON.stringify(s)})`;
const CLIPS = [
  { name:"cold-start", page:"onboarding/coldstart.html", frame:"#big", ms:11000, start:"window.__cs.play()" },
  { name:"intro-birds-on-wire-returning", page:"onboarding/intro.html", frame:"#intros .ld:nth-child(3) .frame", ms:8200, start:`document.querySelectorAll("#intros .replay")[2].click()` },
  { name:"intro-birds-on-wire-first-open", page:"onboarding/intro.html", frame:"#intros .ld:nth-child(3) .frame", ms:6500, start:`window.__intro.mode("first")` },
  { name:"intro-all-five", page:"onboarding/intro.html", frame:"#intros", ms:8200, start:`document.querySelectorAll("#intros .replay").forEach(b => b.click())` },
  { name:"peek-loader", page:"onboarding/intro.html", frame:"#trans .ld:nth-child(2) .frame", ms:6500, start:`document.querySelectorAll("#trans .replay")[1].click()` },
  { name:"between-screens", page:"onboarding/intro.html", frame:"#trans", ms:8000, start:`document.querySelectorAll("#trans .replay").forEach((b, i) => i !== 2 && b.click())` },
  { name:"loading-moments", page:"onboarding/loaders.html", frame:"#grid", ms:7500, start:`document.querySelectorAll(".replay").forEach(b => b.click())` },
  { name:"coach-mascot-states", page:"mascots/mascot-board.html", frame:"#cells", ms:24000, start:`(async () => { for (const c of document.querySelectorAll("#states .chip")) { c.click(); await new Promise(r => setTimeout(r, 2600)); } })()` },
  { name:"onboarding-one-line", page:"onboarding/line.html", frame:".phone", ms:34000, script:true }
];

/* the one-line onboarding needs real taps */
async function lineScript(ev, tap){
  const cur = sel => `document.querySelector(${JSON.stringify(".ol-sec:not([inert]) " + sel)})`;
  const next = cur("[data-next]");
  await sleep(4300); await tap(next);
  await sleep(2200); await tap(cur('.thumb[data-c="luna"]')); await sleep(900); await tap(next);
  await sleep(3800); await tap(cur('.tile[data-v="peri"]')); await sleep(700); await tap(next);
  await sleep(3200); await tap(cur('.tile[data-v="strong"]')); await sleep(400); await tap(cur('.tile[data-v="protein"]')); await sleep(600); await tap(next);
  await sleep(4600); for (const d of [0, 2, 4]) { await tap(cur(`.ol-day[data-d="${d}"]`)); await sleep(300); } await sleep(400); await tap(next);
  await sleep(6800); await tap(`document.querySelector("#start")`);
}

async function record(clip){
  const port = 9400 + CLIPS.indexOf(clip);
  const chrome = spawn(CHROME, ["--headless=new", `--remote-debugging-port=${port}`, "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-rec-" + clip.name)}`, "about:blank"]);
  let ws;
  for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, { method:"PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
  await new Promise(r => ws.addEventListener("open", r));
  let id = 0; const pending = new Map(); const frames = [];
  ws.addEventListener("message", e => {
    const m = JSON.parse(e.data);
    if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); }
    if (m.method === "Page.screencastFrame") { frames.push({ data:m.params.data, t:m.params.metadata.timestamp }); ws.send(JSON.stringify({ id:++id, method:"Page.screencastFrameAck", params:{ sessionId:m.params.sessionId } })); }
  });
  const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id:i, method, params })); });
  const run = async expr => (await send("Runtime.evaluate", { expression:expr, returnByValue:true, awaitPromise:false })).result?.value;
  const tap = async js => { const c = await run(`(() => { const n = ${js}; if (!n) return null; const r = n.getBoundingClientRect(); return [r.left + r.width/2, r.top + r.height/2]; })()`); if (!c) return; for (const type of ["mousePressed", "mouseReleased"]) await send("Input.dispatchMouseEvent", { type, x:c[0], y:c[1], button:"left", clickCount:1 }); };

  await send("Page.enable"); await send("Runtime.enable");
  const W = 1240, H = 1700;
  await send("Emulation.setDeviceMetricsOverride", { width:W, height:H, deviceScaleFactor:1, mobile:false });
  await send("Page.navigate", { url:pathToFileURL(join(design, clip.page)).href });
  await sleep(1800);
  const box = await run(`(() => { const el = ${q(clip.frame)}; el.scrollIntoView({block:"center"}); const r = el.getBoundingClientRect(); return [Math.round(r.left), Math.round(r.top), Math.round(r.width), Math.round(r.height)]; })()`);
  await sleep(300);
  await send("Page.startScreencast", { format:"jpeg", quality:92, everyNthFrame:1 });
  await sleep(150);
  const t0 = Date.now();
  if (clip.script) lineScript(null, tap); else if (clip.start) run(clip.start);
  await sleep(clip.ms);
  await send("Page.stopScreencast");
  ws.close(); chrome.kill();

  /* write frames with their real timing, then encode */
  const dir = join(tmpdir(), "ss-frames-" + clip.name); rmSync(dir, { recursive:true, force:true }); mkdirSync(dir, { recursive:true });
  let list = "";
  frames.forEach((f, i) => {
    const file = join(dir, `f${String(i).padStart(5, "0")}.jpg`); writeFileSync(file, Buffer.from(f.data, "base64"));
    const dur = i < frames.length - 1 ? Math.max(0.001, frames[i + 1].t - f.t) : 0.5;
    list += `file '${file.replace(/\\/g, "/")}'\nduration ${dur.toFixed(4)}\n`;
  });
  list += `file '${join(dir, `f${String(frames.length - 1).padStart(5, "0")}.jpg`).replace(/\\/g, "/")}'\n`;
  writeFileSync(join(dir, "list.txt"), list);
  const [x, y, w, h] = box;
  const out = join(here, clip.name + ".mp4");
  execFileSync("ffmpeg", ["-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", join(dir, "list.txt"),
    "-vf", `crop=${w - w % 2}:${h - h % 2}:${x}:${y},fps=30,format=yuv420p`, "-c:v", "libx264", "-crf", "20", "-movflags", "+faststart", out]);
  rmSync(dir, { recursive:true, force:true });
  console.log(`${clip.name}.mp4  ${frames.length} frames over ${((Date.now() - t0) / 1000).toFixed(1)}s, ${w}x${h}`);
}

const wanted = process.argv.slice(2);
for (const clip of CLIPS) if (!wanted.length || wanted.includes(clip.name)) await record(clip);
process.exit(0);
