// Builds onboarding.html from onboarding.src.html: injects the coach rig from the mascot board
// and embeds the Sketchbook line drawings as data URIs. Usage: node design/onboarding/build.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..", "..");
const board = readFileSync(join(root, "design/mascots/mascot-board.html"), "utf8");
const css = board.slice(board.indexOf("/* ===== soft mascot rig v2 ===== */"), board.indexOf("@media (prefers-reduced-motion: reduce)", board.indexOf("/* ===== soft mascot rig v2")));
const js = board.slice(board.indexOf("const EYE"), board.indexOf("/* state chips */"));

const drawings = { SQUAT: "09-squat", PLATE: "06-plate", SITSTAND: "24-sitstand", MORNING: "20-morning", WIND: "23-wind" };
for (const name of ["onboarding", "variants", "moods", "feelings", "collage", "line", "loaders", "launch", "intro", "coldstart"]) {
let out = readFileSync(join(here, `${name}.src.html`), "utf8")
  .replace("__MASCOT_CSS__", () => css)
  .replace("__MASCOT_JS__", () => js);
for (const [token, file] of Object.entries(drawings)) {
  const b64 = readFileSync(join(root, "app-directions/shared/draw", `${file}.webp`)).toString("base64");
  out = out.replace(`__${token}__`, `data:image/webp;base64,${b64}`);
}
for (const t of ["SQUAT","PLATE","SITSTAND","MORNING","WIND"]) if (out.includes(`__${t}__`)) throw new Error(`unfilled ${t}`);
writeFileSync(join(here, `${name}.html`), out);
console.log(`built ${name}.html (${Math.round(out.length / 1024)} KB)`);
}
