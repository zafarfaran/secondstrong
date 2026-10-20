// Plays the cold start and captures the big phone at each stage, plus the launch options in light and dark.
// Usage: node design/onboarding/test-coldstart.mjs   (screenshots go to design/onboarding/_shots/coldstart/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots", "coldstart"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "coldstart.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9345", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-cs-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9345/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
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
await send("Emulation.setDeviceMetricsOverride", { width: 1200, height: 1900, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url }); await sleep(1500);
await shotOf("#opts", "opts-light");
await run("window.__cs.dark(true)"); await sleep(500); await shotOf("#opts", "opts-dark");
await run("window.__cs.play()");
const t0 = Date.now();
for (const [ms, name] of [[700, "1-home"], [1450, "2-zoom"], [2300, "3-launch"], [3400, "4-dot"], [4400, "5-wire"], [5600, "6-birds"], [7300, "7-morning"], [8400, "7b-morning"], [10800, "8-today"]]) {
  await sleep(Math.max(0, ms - (Date.now() - t0)));
  await shotOf("#big", name);
}
console.log((await run("document.getElementById('play').textContent")) === "Play again" ? "PASS  sequence finished" : "FAIL  sequence did not finish");
console.log(errors.length ? "ERRORS:\n" + [...new Set(errors)].join("\n") : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
