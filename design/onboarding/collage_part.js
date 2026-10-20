/* ======================= collage (with an optional continuous line) ======================= */
async function collage(root, e, opt = {}){
  const W = page.clientWidth, H = page.clientHeight;
  const today = new Date().toLocaleDateString("en-GB", {weekday:"long", day:"numeric", month:"long"});
  root.innerHTML = `<div class="cl-page" id="pg"><div class="cl-date">${esc(today)}</div><div class="cl-title line writing" id="ttl">My week</div></div><div class="cl-tray" id="tray"></div>`;
  const pg = root.querySelector("#pg"), tray = root.querySelector("#tray"), ttl = root.querySelector("#ttl");
  ttl.style.setProperty("--d", "700ms"); ttl.style.setProperty("--st", "steps(10)");
  const PW = W - 24;
  const ink = inkLayer(pg, PW, 760);
  const SL = { coach:[PW-118, 18, 104, 104], stage:[18, 76, 112, 112], g0:[144, 150, 100, 110], g1:[254, 162, 100, 110], cal:[16, 314, PW-32, 40] };
  const slotEls = {};
  for (const [k, [x, y, w, h]] of Object.entries(SL)) { if (k === "cal") continue; const s = el("div", "slot"); Object.assign(s.style, {left:x+"px", top:y+"px", width:w+"px", height:h+"px", opacity:"0"}); pg.appendChild(s); slotEls[k] = s; }
  const cal = el("div", "cl-cal", DAYS.map(d => `<span>${d[0]}</span>`).join("")); Object.assign(cal.style, {left:SL.cal[0]+"px", top:SL.cal[1]+"px", width:SL.cal[2]+"px", opacity:".35"}); pg.appendChild(cal);
  const nameTag = el("div", "hand"); Object.assign(nameTag.style, {left:(SL.coach[0]-4)+"px", top:(SL.coach[1]+SL.coach[3]+4)+"px", width:"112px", textAlign:"center", fontSize:"20px"}); pg.appendChild(nameTag);
  const show = html => { tray.innerHTML = html; [...tray.children].forEach((c, i) => { c.classList.add("rise"); c.style.animationDelay = i*60 + "ms"; }); drawGlyphs(tray, 80); };
  const box = k => { const [x, y, w, h] = SL[k]; return {x, y, w, h}; };

  /* ---- the continuous line: one pen, extended to each new thing on the page ---- */
  let pen = null;
  const visited = {};
  function extend(pts, dur = 900){ if (!opt.line) return null; const p = stroke(ink, smooth(pen ? [pen, ...pts] : pts), {color:"var(--terra)", w:2.4, dur}); pen = pts[pts.length - 1]; return p; }
  /* a small knot: the thread loops once at a point, like string tied through tape */
  function knot(pt, key, o = {}){
    if (!opt.line || (key && visited[key])) return null; if (key) visited[key] = true;
    const r = o.r ?? 6, loop = [];
    for (let i = 0; i <= 12; i++) { const a = Math.PI/2 + i/12 * Math.PI * 2.1; loop.push([pt[0] + Math.cos(a)*r, pt[1] - r + Math.sin(a)*r]); }
    const mid = pen ? [(pen[0] + pt[0])/2 + (o.sway ?? 0), Math.min(pen[1], pt[1]) - (o.lift ?? 28)] : null;
    return extend(mid ? [mid, [pt[0], pt[1] + 2], ...loop] : loop, o.dur || 900);
  }
  function visit(r, key, o = {}){
    if (!opt.line || (key && visited[key])) return null; if (key) visited[key] = true;
    const cx = r.x + r.w/2, cy = r.y + r.h/2, a = pen ? Math.atan2(pen[1] - cy, pen[0] - cx) : Math.PI;
    const loop = ringPts(r, o.pad ?? 9, o.turns ?? 1.06, a);
    const start = loop[0], mid = pen ? [(pen[0] + start[0])/2 + (o.sway ?? 0), Math.min(pen[1], start[1]) - (o.lift ?? 26)] : null;
    return extend(mid ? [mid, ...loop] : loop, o.dur || 1000);
  }

  /* ---- stickers ---- */
  const stuck = {};
  let coachSticker = null;
  async function stick(key, from, html, rot){
    const [x, y, w, h] = SL[key];
    if (stuck[key]) { const old = stuck[key]; old.classList.add("peel"); setTimeout(() => old.remove(), 420); }
    const s = el("div", "sticker", html); Object.assign(s.style, {left:x+"px", top:y+"px", width:w+"px", height:h+"px", transform:`rotate(${rot}deg)`, visibility:"hidden"});
    s.style.setProperty("--tape", "0"); pg.appendChild(s); stuck[key] = s;
    if (slotEls[key]) slotEls[key].style.opacity = "0";
    const fr = prect(from), to = prect(s);
    await fly(s, {x:fr.x, y:fr.y, w:fr.w, h:fr.w * h / w}, to, {arc:-60, rot, dur:560}); alive(e);
    s.style.visibility = "visible"; s.classList.add("slap"); requestAnimationFrame(() => s.style.setProperty("--tape", "1"));
    knot([x + w/2 + 18, y - 2], key);
    return s;
  }

  /* ---- welcome: a preview of the page you're about to make ---- */
  const preview = [];
  const pv = (html, x, y, w, h, rot, depth, cls = "") => {
    const s = el("div", "sticker preview " + cls, html); Object.assign(s.style, {left:x+"px", top:y+"px", width:w+"px", height:h+"px", transform:`rotate(${rot}deg)`});
    s.style.setProperty("--tape", "0"); s._depth = depth; s._rot = rot; pg.appendChild(s); preview.push(s); return s;
  };
  const pDraw = pv(`<div class="draw drawme" style="--src:url(${DRAW.squat})"></div><b>Strength</b>`, 22, 84, 112, 128, -7, 8);
  const pCoach = pv(`<div class="coach-in" data-state="hello" style="width:100%;height:100%">${mascot(S.coach)}</div>`, PW - 168, 74, 144, 144, 5, 14);
  const pMoon = pv(`${glyph("peri")}<b>Perimenopause</b>`, 34, 232, 118, 82, 4, 6);
  const pNum = pv(`<div class="pv-num">100<small>g</small></div><b>protein a day</b>`, PW - 156, 240, 128, 84, -3, 10, "pv-label");
  const note = el("div", "hand pv-note", `this is what we'll make`); Object.assign(note.style, {left:"0", right:"0", top:"344px", textAlign:"center"}); pg.appendChild(note);
  const arrow = document.createElementNS(NS, "svg"); arrow.setAttribute("class", "pv-arrow"); arrow.setAttribute("viewBox", "0 0 40 40"); Object.assign(arrow.style, {left:(PW/2 - 20)+"px", top:"300px", width:"40px", height:"40px", position:"absolute", overflow:"visible"}); pg.appendChild(arrow);
  cal.style.opacity = "0";
  preview.forEach((s, i) => {
    s.style.opacity = "0";
    setTimeout(() => { if (e !== epoch) return; s.style.opacity = "1"; s.classList.add("slap"); s.style.setProperty("--tape", "1"); drawGlyphs(s, 120); }, 700 + i * 260);
  });
  note.style.opacity = "0"; setTimeout(() => { if (e !== epoch) return; note.style.cssText += ";opacity:1;transition:opacity 300ms"; stroke(arrow, "M22 38 C18 28 24 16 20 6 M20 6 l-5 7 M20 6 l5 7", {color:"var(--terra)", w:2.2, dur:520}); }, 1900);
  setTimeout(() => { const ci = pCoach.querySelector(".coach-in"); if (ci) ci.dataset.state = "idle"; }, 2600);
  /* stickers lean towards the pointer, and wiggle when tapped */
  const lean = ev => { const r = pg.getBoundingClientRect(), nx = (ev.clientX - r.left) / r.width - .5, ny = (ev.clientY - r.top) / r.height - .5;
    preview.forEach(s => { s.style.transition = "transform 220ms var(--ease)"; s.style.transform = `translate(${nx * s._depth}px, ${ny * s._depth}px) rotate(${s._rot + nx * 4}deg)`; }); };
  pg.addEventListener("pointermove", lean);
  preview.forEach(s => s.addEventListener("click", () => { s.animate([{rotate:"0deg"},{rotate:"-6deg"},{rotate:"5deg"},{rotate:"0deg"}], {duration:420, easing:"ease-out"}); const ci = s.querySelector(".coach-in"); if (ci) { ci.dataset.state = "proud"; setTimeout(() => ci.dataset.state = "idle", 1700); } }));
  show(`<div class="meta">Second Strong</div><h1 class="title">Let's make your <em>first page.</em></h1><p class="hand" style="margin:-4px 0 0">Two minutes. One page. All yours.</p><div class="spacer"></div><button class="btn" id="go" type="button">Begin</button>`);
  setTimeout(() => { if (e !== epoch) return; highlight(ink, relTo(ttl, pg), {dy:-4, w:10, dur:500, cls:"w"}); if (opt.line) extend([[-8, 60], [10, 58], ...underPts(relTo(ttl, pg), 2), [relTo(ttl, pg).x + relTo(ttl, pg).w + 24, 52], [PW - 150, 60]], 1300); }, 750);
  await once(tray, "#go"); alive(e);
  pg.removeEventListener("pointermove", lean);
  /* the preview peels away: your page starts blank */
  preview.forEach((s, i) => setTimeout(() => { s.classList.add("peel"); setTimeout(() => s.remove(), 420); }, i * 90));
  note.classList.add("fade"); arrow.classList.add("fade"); dropMarks(ink, "w");
  await wait(420);
  cal.style.transition = "opacity 400ms"; cal.style.opacity = "1";
  Object.values(slotEls).forEach((sl, i) => { sl.style.transition = `opacity 300ms ${i*80}ms`; sl.style.opacity = "1"; });

  /* ---- coach ---- */
  show(`<div class="meta">Your coach</div><h2 class="title">Pick <em>one.</em></h2><div class="thumbs" id="th">${ORDER.map(k=>`<button class="thumb" type="button" data-c="${k}" aria-checked="false" aria-label="${CHARS[k].name}"><div data-state="idle">${mascot(k)}</div></button>`).join("")}</div>
    <div class="field"><label for="nm">Name</label><input id="nm" maxlength="14" autocomplete="off" value=""></div><div class="spacer"></div><button class="btn" id="keep" type="button" aria-disabled="true">Keep</button>`);
  const nm = tray.querySelector("#nm"), keep = tray.querySelector("#keep");
  tray.querySelector("#th").addEventListener("click", async ev => {
    const b = ev.target.closest(".thumb"); if (!b) return;
    S.coach = b.dataset.c; if (!S.named) S.name = CHARS[S.coach].name;
    tray.querySelectorAll(".thumb").forEach(t => t.setAttribute("aria-checked", t === b));
    nm.value = S.name; keep.textContent = "Keep " + coachName(); keep.setAttribute("aria-disabled", "false"); nameTag.textContent = coachName();
    coachSticker = await stick("coach", b, `<div class="coach-in" data-state="hello" style="width:100%;height:100%">${mascot(S.coach)}</div>`, 4);
    setTimeout(() => { const ci = coachSticker?.querySelector(".coach-in"); if (ci) ci.dataset.state = "idle"; }, 1600);
  });
  nm.addEventListener("input", () => { S.name = nm.value; S.named = true; keep.textContent = "Keep " + coachName(); nameTag.textContent = coachName(); });
  await once(tray, "#keep"); alive(e);
  const cstate = (s, ms) => { const ci = coachSticker?.querySelector(".coach-in"); if (!ci) return; ci.dataset.state = s; if (ms) setTimeout(() => ci.dataset.state = "idle", ms); };

  /* ---- stage ---- */
  show(`<h2 class="title">Where are <em>you?</em></h2><div class="opts">${STAGES.map(([id,l])=>`<button class="chipx" type="button" data-v="${id}">${glyph(id)}${l}</button>`).join("")}</div><div class="spacer"></div><button class="btn" id="next" type="button" aria-disabled="true">Continue</button>`);
  tray.querySelector(".opts").addEventListener("click", async ev => {
    const b = ev.target.closest(".chipx"); if (!b) return; S.stage = b.dataset.v;
    tray.querySelectorAll(".chipx").forEach(t => t.setAttribute("aria-checked", t === b)); tray.querySelector("#next").setAttribute("aria-disabled", "false");
    cstate(S.stage === "surg" ? "comfort" : "listening", 1300);
    await stick("stage", b.querySelector(".glyph"), `${glyph(S.stage)}<b>${STAGES.find(x => x[0] === S.stage)[1]}</b>`, -5);
  });
  await once(tray, "#next"); alive(e);

  /* ---- goals ---- */
  show(`<h2 class="title">What <em>matters?</em></h2><div class="opts">${GOALS.map(([id,l,d])=>`<button class="chipx" type="button" data-v="${id}" aria-checked="false">${drawing(d)}${l}</button>`).join("")}</div><p class="hand" style="margin:0;min-height:22px" id="hint"></p><button class="btn" id="next" type="button" aria-disabled="true">Continue</button>`);
  tray.querySelector(".opts").addEventListener("click", async ev => {
    const b = ev.target.closest(".chipx"); if (!b) return; const v = b.dataset.v, on = !S.goals.includes(v);
    if (on && S.goals.length >= 2) { tray.querySelector("#hint").textContent = "two is plenty"; return; }
    tray.querySelector("#hint").textContent = "";
    S.goals = on ? S.goals.concat(v) : S.goals.filter(x => x !== v); b.setAttribute("aria-checked", on);
    tray.querySelector("#next").setAttribute("aria-disabled", String(!S.goals.length));
    if (on) { cstate("proud", 1300); const g = GOALS.find(x => x[0] === v); await stick("g" + (S.goals.length - 1), b.querySelector(".draw"), `<div class="draw" style="--src:url(${DRAW[g[2]]})"></div><b>${g[1]}</b>`, S.goals.length === 1 ? -4 : 6); }
    else { ["g0","g1"].forEach(k => { if (stuck[k]) { stuck[k].classList.add("peel"); const o = stuck[k]; setTimeout(() => o.remove(), 420); delete stuck[k]; slotEls[k].style.opacity = "1"; } });
      S.goals.forEach((gv, i) => { const g = GOALS.find(x => x[0] === gv); const s = el("div", "sticker slap", `<div class="draw" style="--src:url(${DRAW[g[2]]})"></div><b>${g[1]}</b>`); const [x,y,w,h] = SL["g"+i]; Object.assign(s.style, {left:x+"px", top:y+"px", width:w+"px", height:h+"px", transform:`rotate(${i ? 6 : -4}deg)`}); pg.appendChild(s); stuck["g"+i] = s; slotEls["g"+i].style.opacity = "0"; }); }
  });
  await once(tray, "#next"); alive(e);

  /* ---- days: circled on the page (by the line itself, in the line version) ---- */
  show(`<h2 class="title">Your <em>days.</em></h2><div class="dayrow">${DAYS.map((d,i)=>`<button class="dayb" type="button" data-d="${i}" aria-checked="false" aria-label="${d}">${d[0]}</button>`).join("")}</div><div class="spacer"></div><button class="btn" id="next" type="button" aria-disabled="true">Finish my page</button>`);
  const circles = {};
  tray.querySelector(".dayrow").addEventListener("click", ev => {
    const b = ev.target.closest(".dayb"); if (!b) return; const d = +b.dataset.d, on = !S.days.includes(d); if (on && S.days.length >= 4) return;
    S.days = (on ? S.days.concat(d) : S.days.filter(x => x !== d)).sort(); b.setAttribute("aria-checked", on);
    const letter = cal.children[d];
    if (opt.line) { letter.classList.toggle("picked", on); }
    else if (on) circles[d] = stroke(ink, smooth(ringPts(relTo(letter, pg), 7, 1.1, -1.8)), {dur:460});
    else circles[d]?.classList.add("fade");
    if (on) cstate("lifting", 1100);
    tray.querySelector("#next").setAttribute("aria-disabled", String(S.days.length < 2));
  });
  await once(tray, "#next"); alive(e);
  if (opt.line) {
    const cr = relTo(cal, pg);
    extend([[PW - 9, pen ? pen[1] + 40 : 200], [PW - 9, cr.y + cr.h + 14]], 700); await wait(560);
    for (const d of S.days.slice().reverse()) { const r = relTo(cal.children[d], pg); knot([r.x + r.w/2, r.y + r.h + 10], "d" + d, {lift:-4, r:5, dur:560}); await wait(460); }
  }

  /* ---- reveal: the tray drops away and the page becomes the plan ---- */
  tray.classList.add("gone");
  await wait(250);
  pg.style.height = (H - 60) + "px";
  Object.values(slotEls).forEach(s => s.style.opacity = "0");
  const big = el("div", "", `<div style="font:800 46px/.9 var(--f-display);letter-spacing:-.05em">100<small style="font-size:20px">g</small></div><div class="meta" style="margin-top:4px">protein a day</div>`);
  Object.assign(big.style, {left:"142px", top:"66px", maxWidth:"92px"}); pg.appendChild(big);
  big.animate([{transform:"scale(1.3) rotate(-4deg)", opacity:0}, {transform:"none", opacity:1}], {duration:REDUCED?1:480, delay:REDUCED?0:400, easing:"cubic-bezier(.3,1.5,.5,1)", fill:"backwards"});
  await wait(700);
  highlight(ink, relTo(big.firstElementChild, pg), {dy:-12, w:16, dur:600});
  if (opt.line) { const r = relTo(big.firstElementChild, pg), cr = relTo(cal, pg); extend([[9, cr.y + cr.h + 6], [9, cr.y - 30], [9, r.y + r.h + 40], [r.x - 12, r.y + r.h + 10], ...underPts(r, 6), [r.x + r.w + 16, r.y + r.h - 6]], 1300); }
  await wait(opt.line ? 900 : 200);
  const nt = el("div", "hand line writing", `${DAYS[S.days[0]]} first. Easy on rough mornings. — ${esc(coachName())}`);
  nt.style.setProperty("--d", "1200ms"); nt.style.setProperty("--st", "steps(24)");
  Object.assign(nt.style, {left:"18px", top:"376px", right:"18px"}); pg.appendChild(nt);
  if (opt.line) { const r = relTo(nt, pg), u = underPts({x:r.x, y:r.y, w:Math.min(r.w, PW - 40), h:r.h}, 4).reverse(); extend([[PW - 9, (pen ? pen[1] : 120) + 30], [PW - 9, r.y + r.h - 2], ...u, [r.x - 8, r.y + r.h + 22], [r.x + 30, r.y + r.h + 30]], 1600); }
  cstate("proud", 2000);
  const go = el("button", "btn", "Start my week"); go.type = "button"; Object.assign(go.style, {position:"absolute", left:"22px", right:"22px", bottom:"22px", width:"auto"}); root.appendChild(go); go.classList.add("rise");
  await new Promise(r => go.addEventListener("click", r, {once:true})); alive(e);
  cstate("hello", 2000);
}
