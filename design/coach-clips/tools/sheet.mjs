// Quick visual check without rendering: opens each composition in headless Chrome, seeks its timeline
// to a few moments, and tiles the stills into _shots/sheet-<coach>.png (or one state across coaches).
// Usage: node tools/sheet.mjs [coach ...]            rows = states, columns = in / loop / loop / out
//        node tools/sheet.mjs --state wow [coach ...] one row per coach
import { spawn, execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const M = JSON.parse(readFileSync(join(root, "manifest.json"), "utf8"));
let args = process.argv.slice(2), only = null;
if (args[0] === "--state") { only = args[1]; args = args.slice(2); }
const coaches = args.length ? args : Object.keys(M.coaches);
const states = only ? [only] : Object.keys(M.states);
const out = join(root, "_shots"), tmp = join(out, "_tiles"); mkdirSync(tmp, { recursive: true });

const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9347", "--hide-scrollbars", "--allow-file-access-from-files", `--user-data-dir=${join(tmpdir(), "ss-sheet-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9347/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
await new Promise(r => ws.addEventListener("open", r));
let id = 0; const pending = new Map(), errors = [];
ws.addEventListener("message", e => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result || { error: m.error }); pending.delete(m.id); }
  if (m.method === "Runtime.exceptionThrown") errors.push(m.params.exceptionDetails.exception?.description || m.params.exceptionDetails.text);
  if (m.method === "Runtime.consoleAPICalled" && /warn|error/.test(m.params.type)) errors.push(m.params.args.map(a => a.description || a.value).join(" "));
});
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const run = async expr => { const r = await send("Runtime.evaluate", { expression: expr, returnByValue: true }); if (r.error || r.exceptionDetails) throw new Error(JSON.stringify(r.error || r.exceptionDetails.exception?.description)); return r.result?.value; };
await send("Page.enable"); await send("Runtime.enable");
await send("Page.addScriptToEvaluateOnNewDocument", { source: "window.__timelines = {};" });
await send("Emulation.setDeviceMetricsOverride", { width: 400, height: 400, deviceScaleFactor: .5, mobile: false });
await send("Emulation.setDefaultBackgroundColorOverride", { color: { r: 251, g: 248, b: 244, a: 1 } });

const rows = [];
for (const coach of coaches) for (const state of states) {
  const seg = M.states[state], A = seg.loop[0], B = seg.loop[1];
  const times = [seg.in[1] * .5, A + (B - A) * .25, A + (B - A) * .6, seg.out[0] + (seg.out[1] - seg.out[0]) * .5];
  await send("Page.navigate", { url: pathToFileURL(join(root, "compositions", coach, `${state}.html`)).href });
  await sleep(450);
  const tiles = [];
  for (const [k, t] of times.entries()) {
    await run(`window.__timelines[${JSON.stringify(`${coach}-${state}`)}].seek(${t}); 0`); await sleep(40);
    const s = await send("Page.captureScreenshot", { format: "png" });
    const f = join(tmp, `${coach}-${state}-${k}.png`); writeFileSync(f, Buffer.from(s.data, "base64")); tiles.push(f);
  }
  rows.push(tiles);
}
chrome.kill();

const name = only ? `sheet-${only}.png` : `sheet-${coaches.length === 1 ? coaches[0] : "cast"}.png`;
const inputs = rows.flat().flatMap(f => ["-i", f]);
const cols = 4, layout = rows.flat().map((_, i) => `${(i % cols) * 200}_${Math.floor(i / cols) * 200}`).join("|");
execFileSync("ffmpeg", ["-y", "-loglevel", "error", ...inputs, "-filter_complex", `xstack=inputs=${rows.flat().length}:layout=${layout}:fill=0xFBF8F4`, join(out, name)]);
rmSync(tmp, { recursive: true, force: true });
console.log(`wrote _shots/${name}` + (errors.length ? `\nconsole:\n${[...new Set(errors)].join("\n")}` : "\nno console warnings"));
process.exit(0);
