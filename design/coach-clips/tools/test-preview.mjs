// Drives preview.html in headless Chrome: logs the state player's segment changes through a run of
// events, and screenshots the phone and the clip grid. Usage: node tools/test-preview.mjs (from coach-clips/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const out = join(root, "_shots"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(root, "preview.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9346", "--hide-scrollbars", "--autoplay-policy=no-user-gesture-required", "--allow-file-access-from-files", `--user-data-dir=${join(tmpdir(), "ss-clips-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9346/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
await new Promise(r => ws.addEventListener("open", r));
let id = 0; const pending = new Map(), errors = [];
ws.addEventListener("message", e => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); }
  if (m.method === "Runtime.exceptionThrown") errors.push(m.params.exceptionDetails.exception?.description || m.params.exceptionDetails.text);
  if (m.method === "Runtime.consoleAPICalled" && m.params.type === "error") errors.push(m.params.args.map(a => a.description || a.value).join(" "));
});
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const run = async expr => (await send("Runtime.evaluate", { expression: expr, returnByValue: true })).result?.value;
async function shotOf(sel, name){
  const r = await run(`(() => { const b = document.querySelector(${JSON.stringify(sel)}).getBoundingClientRect(); return {x:b.left, y:b.top + scrollY, width:b.width, height:b.height}; })()`);
  const s = await send("Page.captureScreenshot", { format: "png", clip: { ...r, scale: 1 }, captureBeyondViewport: true });
  writeFileSync(join(out, name + ".png"), Buffer.from(s.data, "base64"));
}

await send("Page.enable"); await send("Runtime.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 1200, height: 1700, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url }); await sleep(2000);

/* record every segment change the player makes */
await run(`window.__log = []; (function poll(){ const s = window.__clips.state, k = s.cur + ":" + s.seg; if (__log[__log.length-1]?.k !== k) __log.push({ k, t: Math.round(performance.now()) }); requestAnimationFrame(poll); })()`);
const plan = [["hello", 3000], ["suggest", 3500], ["cheer", 3000], ["breathe", 4000], ["oops", 3000], ["gotit", 3000], ["wow", 3000], ["encourage", 3000], ["comfort", 4500], ["idle", 3000]];
for (const [s, wait] of plan) {
  await run(`window.__clips.request(${JSON.stringify(s)})`);
  await sleep(wait);
  await shotOf(".frame", `phone-${s}`);
}
console.log((await run("window.__log")).map(e => e.k).join("  →  "));
await shotOf("#grid", "grid");
await run(`document.querySelector('[data-bg="check"]').click()`); await sleep(400); await shotOf("#grid", "grid-check");
console.log(errors.length ? "ERRORS:\n" + errors.join("\n") : "no errors");
chrome.kill(); process.exit(0);
