// Plays every line variant end to end in headless Chrome, screenshots the phone at each moment and reports errors.
// Usage: node design/onboarding/test-variants.mjs   (screenshots go to design/onboarding/_shots/variants/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots", "variants"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "variants.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9336", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-var-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9336/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
await new Promise(r => ws.addEventListener("open", r));
let id = 0; const pending = new Map(), errors = [];
ws.addEventListener("message", e => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); }
  if (m.method === "Runtime.exceptionThrown") errors.push(m.params.exceptionDetails.exception?.description || m.params.exceptionDetails.text);
});
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const run = async expr => (await send("Runtime.evaluate", { expression: expr, returnByValue: true, awaitPromise: true })).result?.value;
const click = sel => run(`(() => { const el = document.querySelector(${JSON.stringify(sel)}); if (!el) return "missing"; el.click(); return "ok"; })()`);
async function shot(name){
  const r = await run(`(() => { const b = document.querySelector(".phone").getBoundingClientRect(); return {x:b.left, y:b.top, width:b.width, height:b.height}; })()`);
  const s = await send("Page.captureScreenshot", { format: "png", clip: { ...r, scale: 1 } });
  writeFileSync(join(out, `${name}.png`), Buffer.from(s.data, "base64"));
}
let pass = 0, fail = 0;
const check = async (label, expr) => { const v = await run(expr); v ? pass++ : fail++; if (!v) console.log(`FAIL  ${label}`); };

await send("Page.enable"); await send("Runtime.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 1200, height: 900, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url }); await sleep(1500);

for (const v of ["pen", "thread", "drawn", "curve", "connect"]) {
  await run(`window.__ob.setV(${JSON.stringify(v)})`); await sleep(2200);
  await shot(`${v}-1-welcome`);
  await click(".scene [data-next]"); await sleep(1800);
  await click('.thumb[data-c="luna"]'); await sleep(1600);
  await shot(`${v}-2-coach`);
  await click(".scene [data-next]"); await sleep(1900);
  await click('.tile[data-v="peri"]'); await sleep(900);
  await shot(`${v}-3-stage`);
  await click(".scene [data-next]"); await sleep(1900);
  await click('.tile[data-v="strong"]'); await sleep(500); await click('.tile[data-v="protein"]'); await sleep(1200);
  await shot(`${v}-4-goal`);
  await click(".scene [data-next]"); await sleep(1900);
  for (const kg of [6, 8]) { await click(`.bell[data-kg="${kg}"]`); await sleep(200); }
  for (const d of [0, 2, 4]) { await click(`.day[data-d="${d}"]`); await sleep(250); }
  await sleep(900); await shot(`${v}-5-week`);
  await check(`${v}: three days chosen`, `window.__ob.S.days.length === 3`);
  await click(".scene [data-next]"); await sleep(3200);
  await shot(`${v}-6-reveal`);
  await check(`${v}: reveal shows Mon first or chart`, `!!document.querySelector(".scene.plan")`);
  await click(".scene [data-next]"); await sleep(1800);
  await click('.faces button[aria-label="Okay"]'); await sleep(900);
  await shot(`${v}-7-today`);
  await check(`${v}: reached today`, `!!document.querySelector(".scene.today")`);
  await check(`${v}: ink paths exist where expected`, `${v === "curve" || v === "thread" ? "true" : 'document.querySelectorAll("#ink path").length > 0'}`);
}
// connect: drag from the coach to a tile
await run(`window.__ob.setV("connect")`); await sleep(2000);
await click(".scene [data-next]"); await sleep(1800); await click(".scene [data-next]"); await sleep(1900);
const pts = await run(`(() => { const c = document.querySelector("#companion").getBoundingClientRect(); const t = document.querySelector('.tile[data-v="meno"]').getBoundingClientRect(); return [c.left + 20, c.top + 40, t.left + t.width/2, t.top + t.height/2]; })()`);
await send("Input.dispatchMouseEvent", { type: "mousePressed", x: pts[0], y: pts[1], button: "left", clickCount: 1 });
for (let i = 1; i <= 8; i++) await send("Input.dispatchMouseEvent", { type: "mouseMoved", x: pts[0] + (pts[2] - pts[0]) * i / 8, y: pts[1] + (pts[3] - pts[1]) * i / 8, button: "left" });
await shot("connect-dragging");
await send("Input.dispatchMouseEvent", { type: "mouseReleased", x: pts[2], y: pts[3], button: "left", clickCount: 1 });
await sleep(700); await shot("connect-dropped");
await check("connect: drag selects Menopause", `window.__ob.S.stage === "meno"`);

console.log(`${pass} passed, ${fail} failed`);
console.log(errors.length ? `ERRORS:\n${[...new Set(errors)].join("\n")}` : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
