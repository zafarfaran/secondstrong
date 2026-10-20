// Plays each of the five onboarding experiences end to end in headless Chrome, using real taps and drags,
// screenshots the phone at key moments and reports failures and page errors.
// Usage: node design/onboarding/test-feelings.mjs   (screenshots go to design/onboarding/_shots/feelings/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots", "line"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "line.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9340", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-line-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9340/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
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
async function waitFor(js, ms = 12000){ const t0 = Date.now(); while (Date.now() - t0 < ms) { if (await run(js)) return true; await sleep(120); } return false; }
const q = sel => `document.querySelector(${JSON.stringify(sel)})`;
async function center(js){ return run(`(() => { const n = ${js}; if (!n) return null; const r = n.getBoundingClientRect(); return [r.left + r.width/2, r.top + r.height/2]; })()`); }
async function tap(js){ const c = await center(js); if (!c) return false; for (const type of ["mousePressed", "mouseReleased"]) await send("Input.dispatchMouseEvent", { type, x:c[0], y:c[1], button:"left", clickCount:1 }); return true; }
async function drag(js, dx, dy, toJs){
  const a = await center(js); if (!a) return false; const b = toJs ? await center(toJs) : [a[0] + dx, a[1] + dy];
  await send("Input.dispatchMouseEvent", { type:"mousePressed", x:a[0], y:a[1], button:"left", clickCount:1 });
  for (let i = 1; i <= 10; i++) { await send("Input.dispatchMouseEvent", { type:"mouseMoved", x:a[0] + (b[0]-a[0])*i/10, y:a[1] + (b[1]-a[1])*i/10, button:"left" }); await sleep(16); }
  await send("Input.dispatchMouseEvent", { type:"mouseReleased", x:b[0], y:b[1], button:"left", clickCount:1 }); return true;
}
async function shot(name){
  const r = await run(`(() => { const b = document.querySelector(".phone").getBoundingClientRect(); return {x:b.left, y:b.top, width:b.width, height:b.height}; })()`);
  const s = await send("Page.captureScreenshot", { format:"png", clip:{ ...r, scale:1 } });
  writeFileSync(join(out, `${name}.png`), Buffer.from(s.data, "base64"));
}
let pass = 0, fail = 0;
async function check(label, ok){ if (ok) pass++; else { fail++; console.log("FAIL ", label); } }
const S = "window.__ob.S";

await send("Page.enable"); await send("Runtime.enable");
await send("Emulation.setDeviceMetricsOverride", { width:1200, height:900, deviceScaleFactor:1, mobile:false });
await send("Page.navigate", { url }); await sleep(1500);


const cur = sel => `document.querySelector(${JSON.stringify(".ol-sec:not([inert]) " + sel)})`;
const nextBtn = `document.querySelector(".ol-sec:not([inert]) [data-next]")`;
const paths = () => run(`document.querySelectorAll("#doc .ink path:not(.fade)").length`);
await sleep(1200); await shot("1-drawing-coach"); await sleep(2600); await shot("2-welcome");
await check("welcome: line drew the coach", (await paths()) >= 2);
await tap(nextBtn); await sleep(2200); await shot("3-coach");
await tap(cur('.thumb[data-c="luna"]')); await sleep(800);
await tap(nextBtn); await sleep(3600); await shot("4-stage");
await check("coach rides along", await run(`!!document.querySelector(".ol-companion")`));
await tap(cur('.tile[data-v="peri"]')); await sleep(400);
const before = await paths();
await tap(nextBtn); await sleep(3000);
const after = await paths();
await check("commit adds line", after > before);
await run(`document.querySelector("#back").click()`); await sleep(1200);
await check("back erases the line", (await paths()) < after);
await check("back keeps the answer", await run(`document.querySelector('.tile[data-v="peri"]').getAttribute("aria-checked") === "true"`));
await tap(nextBtn); await sleep(3000); await shot("5-goals");
await tap(cur('.tile[data-v="strong"]')); await sleep(200); await tap(cur('.tile[data-v="protein"]')); await sleep(300);
await tap(nextBtn); await sleep(1500); await shot("5b-goals-commit"); await sleep(2900); await shot("6-days-ruler");
for (const d of [0, 2, 4]) { await tap(cur(`.ol-day[data-d="${d}"]`)); await sleep(150); }
await shot("7-days-picked");
await tap(nextBtn); await sleep(1700); await shot("7b-days-commit"); await sleep(2100); await shot("8-plan-drawing");
await check("plan: start becomes real", await waitFor(`document.querySelector("#start").classList.contains("ready")`, 12000));
await sleep(600); await shot("9-plan");
await check("state", await run(`window.__ob.S.coach === "luna" && window.__ob.S.stage === "peri" && window.__ob.S.goals.join() === "strong,protein" && window.__ob.S.days.join() === "0,2,4"`));
await tap(`document.querySelector("#start")`); await sleep(2000); await shot("10-overview");
await check("overview shown", await run(`!document.querySelector("#end").hidden`));
console.log(`${pass} passed, ${fail} failed`);
console.log(errors.length ? `ERRORS:\n${[...new Set(errors)].join("\n")}` : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
