// Screenshots the three launch screens (light and dark) and their hand-offs, and reports page errors.
// Usage: node design/onboarding/test-launch.mjs   (screenshots go to design/onboarding/_shots/launch/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots", "launch"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "launch.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9342", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-launch-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9342/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
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
const grab = async name => { const s = await send("Page.captureScreenshot", { format: "png" }); writeFileSync(join(out, name + ".png"), Buffer.from(s.data, "base64")); };

await send("Page.enable"); await send("Runtime.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 1200, height: 1300, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url }); await sleep(1500);
await grab("still-light");
await run("window.__launch.dark(true)"); await sleep(600); await grab("still-dark");
await run("window.__launch.dark(false)"); await sleep(400);
for (let i = 0; i < 3; i++) await run(`window.__launch.play(${i})`);
await sleep(1300); await grab("play-1300");
await sleep(1900); await grab("play-3200");
await sleep(1600); await grab("play-4800");
const ok = await run("document.querySelectorAll('.scr').length === 3");
console.log(ok ? "PASS  three options" : "FAIL  three options");
console.log(errors.length ? "ERRORS:\n" + [...new Set(errors)].join("\n") : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
