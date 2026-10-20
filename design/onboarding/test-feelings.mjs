// Plays each of the five onboarding experiences end to end in headless Chrome, using real taps and drags,
// screenshots the phone at key moments and reports failures and page errors.
// Usage: node design/onboarding/test-feelings.mjs   (screenshots go to design/onboarding/_shots/feelings/)
import { spawn } from "node:child_process";
import { writeFileSync, mkdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { tmpdir } from "node:os";

const here = dirname(fileURLToPath(import.meta.url));
const out = join(here, "_shots", "feelings"); mkdirSync(out, { recursive: true });
const url = pathToFileURL(join(here, "feelings.html")).href;
const chrome = spawn("C:/Program Files/Google/Chrome/Application/chrome.exe",
  ["--headless=new", "--remote-debugging-port=9338", "--hide-scrollbars", `--user-data-dir=${join(tmpdir(), "ss-feel-prof")}`, "about:blank"]);
const sleep = ms => new Promise(r => setTimeout(r, ms));
let ws;
for (let i = 0; i < 40 && !ws; i++) { await sleep(250); try { const t = await (await fetch("http://127.0.0.1:9338/json/new?about:blank", { method: "PUT" })).json(); ws = new WebSocket(t.webSocketDebuggerUrl); } catch {} }
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

/* A · conversation */
await run(`window.__ob.setX("conversation")`);
await check("A: coach offers a pick", await waitFor(`!!${q("#pick")}`));
await shot("A-1-pick");
await tap(q('.thumb[data-c="luna"]')); await sleep(400); await tap(q("#pick"));
await check("A: asks for a name", await waitFor(`!!${q("#ok")}`));
await tap(q("#ok"));
await check("A: asks stage", await waitFor(`!!${q('.chipx[data-v="peri"]')}`));
await tap(q('.chipx[data-v="peri"]'));
await check("A: asks goals", await waitFor(`!!${q('.chipx[data-v="strong"]')}`));
await tap(q('.chipx[data-v="strong"]')); await sleep(150); await tap(q('.chipx[data-v="protein"]')); await sleep(300);
await shot("A-2-goals");
await tap(q("#gdone"));
await check("A: asks days", await waitFor(`!!${q('.dayb[data-d="0"]')}`));
for (const d of [0, 2, 4]) { await tap(q(`.dayb[data-d="${d}"]`)); await sleep(120); }
await tap(q("#ddone"));
await check("A: plan appears", await waitFor(`!!${q("#go")}`, 15000));
await sleep(600); await shot("A-3-plan");
await check("A: state", await run(`${S}.coach === "luna" && ${S}.stage === "peri" && ${S}.goals.length === 2 && ${S}.days.length === 3`));

/* B · toybox */
await run(`window.__ob.setX("toybox")`); await sleep(2200); await shot("B-1-welcome");
await tap(q("#go")); await sleep(900);
await tap(q('.tb-coach[data-c="luna"]')); await sleep(900); await shot("B-2-pick");
await tap(q("#keep")); await sleep(1300);
await check("B: stage tokens", await waitFor(`!!${q('.toy[data-v="peri"]')}`));
await drag(q('.toy[data-v="peri"]'), 0, 0, q(".bowl")); await sleep(1100);
await shot("B-3-stage-dragged");
await check("B: drag into bowl selects", await run(`!document.querySelector('#next').getAttribute("aria-disabled") || document.querySelector('#next').getAttribute("aria-disabled") === "false"`));
await tap(q("#next")); await sleep(1100);
await tap(q('.toy[data-v="strong"]')); await sleep(900); await tap(q('.toy[data-v="protein"]')); await sleep(900);
await tap(q('.toy[data-v="energy"]')); await sleep(500); await shot("B-4-rim-bounce"); await sleep(700);
await tap(q("#next")); await sleep(1100);
for (const d of ["0", "2", "4"]) { await tap(q(`.toy[data-v="${d}"]`)); await sleep(800); }
await shot("B-5-days");
await tap(q("#next")); await sleep(1800); await shot("B-6-plan");
await check("B: state", await run(`${S}.stage === "peri" && ${S}.goals.join() === "strong,protein" && ${S}.days.join() === "0,2,4"`));

/* C · one drawing */
const regionNext = i => `document.querySelectorAll(".region")[${i}].querySelector("[data-next]")`;
await run(`window.__ob.setX("onedrawing")`); await sleep(1500); await shot("C-1-welcome");
await tap(regionNext(0)); await sleep(1700); await shot("C-2-coach");
await tap(`document.querySelectorAll(".region")[1].querySelector('.thumb[data-c="luna"]')`); await sleep(900);
await tap(regionNext(1)); await sleep(1700);
await tap(`document.querySelectorAll(".region")[2].querySelector('.tile[data-v="peri"]')`); await sleep(600); await shot("C-3-stage");
await tap(regionNext(2)); await sleep(500); await shot("C-3b-camera-moving"); await sleep(1200);
await tap(`document.querySelectorAll(".region")[3].querySelector('.tile[data-v="strong"]')`); await sleep(300);
await tap(`document.querySelectorAll(".region")[3].querySelector('.tile[data-v="protein"]')`); await sleep(500);
await tap(regionNext(3)); await sleep(1700);
for (const d of [0, 2, 4]) { await tap(`document.querySelectorAll(".region")[4].querySelector('.dayb[data-d="${d}"]')`); await sleep(150); }
await tap(regionNext(4)); await sleep(1600); await shot("C-4-zoomed-out");
await check("C: plan reached", await waitFor(`!!document.querySelectorAll(".region")[5].querySelector(".plancard") && window.__ob.S.days.length === 3`, 6000));
await sleep(2400); await shot("C-5-plan");

/* D · index cards */
const topNext = `[...document.querySelectorAll(".ic-card")].pop().querySelector("[data-next]")`;
await run(`window.__ob.setX("cards")`); await sleep(1400); await shot("D-1-welcome");
await drag(`[...document.querySelectorAll(".ic-card")].pop().querySelector(".title")`, -200, 0); await sleep(900);
await check("D: swipe advances", await run(`!![...document.querySelectorAll(".ic-card")].pop().querySelector("#th")`));
await tap(`[...document.querySelectorAll(".ic-card")].pop().querySelector('.thumb[data-c="luna"]')`); await sleep(900); await shot("D-2-coach");
await tap(topNext); await sleep(900);
await drag(`[...document.querySelectorAll(".ic-card")].pop().querySelector(".title")`, -200, 0); await sleep(700);
await check("D: swipe refused without answer", await run(`!![...document.querySelectorAll(".ic-card")].pop().querySelector('.tile[data-v="peri"]')`));
await tap(`[...document.querySelectorAll(".ic-card")].pop().querySelector('.tile[data-v="peri"]')`); await sleep(500); await shot("D-3-stage");
await tap(topNext); await sleep(900);
await tap(`[...document.querySelectorAll(".ic-card")].pop().querySelector('.tile[data-v="strong"]')`); await sleep(300);
await tap(topNext); await sleep(900);
for (const d of [0, 2, 4]) { await tap(`[...document.querySelectorAll(".ic-card")].pop().querySelector('.dayb[data-d="${d}"]')`); await sleep(150); }
await tap(topNext); await sleep(1500); await shot("D-4-plan");
await check("D: plan card", await run(`!![...document.querySelectorAll(".ic-card")].pop().querySelector(".plancard")`));

/* E · collage */
await run(`window.__ob.setX("collage")`); await sleep(1300); await shot("E-1-welcome");
await tap(q("#go")); await sleep(700);
await tap(q('.thumb[data-c="luna"]')); await sleep(1100); await shot("E-2-coach");
await tap(q("#keep")); await sleep(700);
await tap(q('.chipx[data-v="peri"]')); await sleep(1000);
await tap(q("#next")); await sleep(700);
await tap(q('.chipx[data-v="strong"]')); await sleep(900); await tap(q('.chipx[data-v="protein"]')); await sleep(1000); await shot("E-3-goals");
await tap(q("#next")); await sleep(700);
for (const d of [0, 2, 4]) { await tap(q(`.dayb[data-d="${d}"]`)); await sleep(400); }
await shot("E-4-days");
await tap(q("#next")); await sleep(2600); await shot("E-5-plan");
await check("E: stickers on page", await run(`document.querySelectorAll(".cl-page .sticker").length >= 4`));

console.log(`${pass} passed, ${fail} failed`);
console.log(errors.length ? `ERRORS:\n${[...new Set(errors)].join("\n")}` : "no page errors");
ws.close(); chrome.kill(); process.exit(0);
