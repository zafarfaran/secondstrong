// Clicks through the whole onboarding in headless Chrome, screenshots every moment and reports page errors.
// Usage: node design/onboarding/test-flow.mjs   (screenshots go to design/onboarding/_shots/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "onboarding.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9335", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-onb-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9335/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
await new Promise(r => ws.addEventListener("open", r));
let id = 0; const pending = new Map(), errors = [];
ws.addEventListener("message", e => {
  const m = JSON.parse(e.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m.result); pending.delete(m.id); }
  if (m.method === "Runtime.exceptionThrown") errors.push(m.params.exceptionDetails.exception?.description || m.params.exceptionDetails.text);
  if (m.method === "Runtime.consoleAPICalled" && m.params.type === "error") errors.push(m.params.args.map(a => a.value).join(" "));
});
const send = (method, params = {}) => new Promise(r => { const i = ++id; pending.set(i, r); ws.send(JSON.stringify({ id: i, method, params })); });
const run = async expr => (await send("Runtime.evaluate", { expression: expr, returnByValue: true })).result?.value;
let n = 0;
const shot = async name => { const r = await send("Page.captureScreenshot", { format: "png" }); writeFileSync(join(out, `${String(++n).padStart(2, "0")}-${name}.png`), Buffer.from(r.data, "base64")); };
const click = sel => run(`(() => { const el = document.querySelector(${JSON.stringify(sel)}); if (!el) return "MISSING " + ${JSON.stringify(sel)}; el.click(); return "ok"; })()`);
const check = async (label, expr) => { const v = await run(expr); console.log(`${v ? "PASS" : "FAIL"}  ${label}`); };

await send("Page.enable"); await send("Runtime.enable");
await send("Emulation.setDeviceMetricsOverride", { width: 560, height: 900, deviceScaleFactor: 1, mobile: false });
await send("Page.navigate", { url }); await sleep(600);
await run("localStorage.clear()"); await send("Page.reload"); await sleep(1600);
await shot("welcome");
await check("welcome shows cast of 7", `document.querySelectorAll(".peek").length === 7`);

await click("[data-next]"); await sleep(1100); await shot("coach");
await check("coach scene", `!!document.querySelector(".scene.coach")`);
await click('.thumb[data-c="bramble"]'); await sleep(300);
await run(`(() => { const i = document.querySelector("#nameIn"); i.focus(); i.value = "Bear"; i.dispatchEvent(new Event("input", {bubbles:true})); })()`);
await sleep(700); await shot("coach-named");
await check("coach switched to Bramble", `JSON.parse(localStorage.getItem("ss-onboarding-v1")).coach === "bramble"`);
await check("button says Keep Bear", `document.querySelector("#keepBtn").textContent === "Keep Bear"`);

await click("#keepBtn"); await sleep(1100); await shot("stage");
await check("continue disabled before choosing", `document.querySelector(".scene.stage [data-next]").getAttribute("aria-disabled") === "true"`);
await click('.opt[data-v="peri"]'); await sleep(250);
await click('.chip[data-v="sleep"]'); await sleep(200); await click('.chip[data-v="joints"]'); await sleep(900);
await shot("stage-answered");
await check("notes written", `[...document.querySelectorAll("#notes .note")].map(n => n.textContent).join("|") === "perimenopause|sleep & joints"`);

await click(".scene.stage [data-next]"); await sleep(1100);
await click('.opt[data-v="strong"]'); await sleep(250); await click('.opt[data-v="protein"]'); await sleep(1400);
await shot("goal");
await check("two drawings sketched", `document.querySelectorAll("#canvas .draw").length === 2`);
await click('.opt[data-v="sleep"]'); await sleep(200);
await check("third goal refused", `document.querySelectorAll('.goals [aria-checked="true"]').length === 2`);

await click(".scene.goal [data-next]"); await sleep(1100);
for (const kg of [6, 8]) { await click(`.bell[data-kg="${kg}"]`); await sleep(150); }
for (const d of [0, 2, 4]) { await click(`.day[data-d="${d}"]`); await sleep(150); }
await sleep(800); await shot("week");
await check("notes stay on one line", `document.querySelector("#noteRun").getBoundingClientRect().height < 30`);
await check("week summary", `document.querySelector("#weeksum").textContent.startsWith("3 sessions")`);

// back keeps choices
await run(`document.dispatchEvent(new KeyboardEvent("keydown", {key:"Escape"}))`); await sleep(1100);
await check("back to goal keeps both goals", `document.querySelectorAll('.goals [aria-checked="true"]').length === 2`);
await run(`document.querySelector(".scene.goal [data-next]").click()`); await sleep(1100);
await check("forward again keeps days", `document.querySelectorAll('.day[aria-checked="true"]').length === 3`);

await click(".scene.week [data-next]"); await sleep(700); await shot("reveal-thinking");
await sleep(1500); await shot("reveal-flying");
await sleep(2400); await shot("reveal-settled");
await check("letter mentions perimenopause and first day", `/Perimenopause noted.*Mon/.test(document.querySelector(".letter").textContent)`);

await click(".scene.plan [data-next]"); await sleep(1200); await shot("today");
await check("today scene", `!!document.querySelector(".scene.today")`);

await send("Page.reload"); await sleep(1500);
await check("state persists across reload", `!!document.querySelector(".scene.today")`);

await send("Emulation.setDeviceMetricsOverride", { width: 390, height: 844, deviceScaleFactor: 1, mobile: false });
await click("#restart"); await sleep(1200); await shot("mobile-welcome");
await click("[data-next]"); await sleep(1100); await shot("mobile-coach");

console.log(errors.length ? `ERRORS:\n${errors.join("\n")}` : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
