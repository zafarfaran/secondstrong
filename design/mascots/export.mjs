// Exports each coach from mascot-board.html as a static, layered SVG (for Rive) and a 1024px PNG.
// Usage: node design/mascots/export.mjs   (needs Chrome installed for the PNGs)
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(join(here, "mascot-board.html"), "utf8");
const src = html.slice(html.indexOf("const EYE"), html.indexOf("/* state chips */"));
const { mascot, CHARS, ORDER } = new Function(`${src}; return { mascot, CHARS, ORDER };`)();

const CHROME = process.env.CHROME || "C:/Program Files/Google/Chrome/Application/chrome.exe";
mkdirSync(join(here, "svg"), { recursive: true });
mkdirSync(join(here, "png"), { recursive: true });

// Alternate expressions and props stay in the file as hidden layers, so Rive gets every part.
const hidden = ["e-shut", "e-happy", "mo-open", "db"];

for (const key of ORDER) {
  let svg = mascot(key)
    .replace(/<g class="fx"[\s\S]*<\/svg>$/, "</svg>")
    .replace('class="m"', 'xmlns="http://www.w3.org/2000/svg" width="1024" height="1024"')
    .replace(/var\(--shadow\)/g, "rgba(59,50,44,.22)")
    .replace(/data-layer="(\w+)"/g, 'id="$1"')
    .replace(/class="arm arm-(l|r)"/g, 'id="arm-$1" opacity="0"');
  for (const cls of hidden) svg = svg.replace(new RegExp(`class="${cls}"`, "g"), `class="${cls}" opacity="0"`);
  svg = svg.replace(/\n\s*/g, "\n");

  const svgPath = join(here, "svg", `${key}.svg`);
  writeFileSync(svgPath, `<?xml version="1.0" encoding="UTF-8"?>\n${svg}\n`);

  execFileSync(CHROME, [
    "--headless=new", "--disable-gpu", "--hide-scrollbars", "--window-size=1024,1024",
    "--default-background-color=00000000", `--screenshot=${join(here, "png", `${key}.png`)}`,
    pathToFileURL(svgPath).href,
  ], { stdio: "ignore" });
  console.log(`exported ${CHARS[key].name}`);
}
