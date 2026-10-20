/* ======================= one line ======================= */
/* Line grammar: underline = the question · ring = your committed answer ·
   the pen draws real interface (coach, week ruler, plan) · it travels only down the left margin. */
async function oneline(root, e){
  const W = page.clientWidth, H = page.clientHeight, G = 14;
  const today = new Date().toLocaleDateString("en-GB", {weekday:"long", day:"numeric", month:"long"});
  root.innerHTML = `<div class="ol-doc" id="doc"></div>
    <div class="ol-top"><button class="icon-btn ol-back" id="back" type="button" aria-label="Back" hidden><svg viewBox="0 0 24 24"><path d="M15 5 L8 12 L15 19"/></svg></button><span class="ol-step" id="step"></span></div>
    <div class="ol-end" id="end" hidden><p class="hand">Your first week, on one line.</p><button class="btn small" id="again" type="button">Play again</button></div>`;
  const doc = root.querySelector("#doc"), backBtn = root.querySelector("#back"), stepEl = root.querySelector("#step");
  const tileStages = STAGES.map(([id,l],i) => `<button class="tile${i===4?" wide":""}" type="button" role="radio" data-v="${id}" aria-checked="false">${glyph(id)}<b>${l}</b></button>`).join("");
  const tileGoals = GOALS.map(([id,l,d]) => `<button class="tile" type="button" role="checkbox" data-v="${id}" aria-checked="false">${drawing(d)}<b>${l}</b></button>`).join("");
  doc.innerHTML = `
    <section class="ol-sec" data-s="welcome"><div class="meta">Second Strong</div><h1 class="title ol-big">Strong, <em>for years.</em></h1><p class="ol-sub">Two minutes. One line. Your first week.</p><div class="ol-hero" id="hero"></div><div class="spacer"></div><button class="btn" data-next type="button">Begin</button></section>
    <section class="ol-sec" data-s="coach"><div class="meta">1 of 4 · your coach</div><h2 class="title">Pick your <em>coach.</em></h2><div class="ol-show" id="show"></div>
      <div class="thumbs" id="th" role="radiogroup" aria-label="Coach">${ORDER.map(k=>`<button class="thumb" type="button" role="radio" data-c="${k}" aria-checked="${k===S.coach}" aria-label="${CHARS[k].name}"><div data-state="idle">${mascot(k)}</div></button>`).join("")}</div>
      <div class="field"><label for="nm">Name</label><input id="nm" maxlength="14" autocomplete="off" value="${esc(S.name)}"></div><div class="spacer"></div><button class="btn" data-next type="button">Continue</button></section>
    <section class="ol-sec" data-s="stage"><div class="meta">2 of 4 · about you</div><h2 class="title">Where are <em>you?</em></h2><div class="tiles" role="radiogroup" aria-label="Stage">${tileStages}</div><div class="spacer"></div><button class="btn" data-next type="button" aria-disabled="true">Continue</button></section>
    <section class="ol-sec" data-s="goals"><div class="meta">3 of 4 · up to two</div><h2 class="title">What <em>matters?</em></h2><div class="tiles" role="group" aria-label="Goals">${tileGoals}</div><div class="spacer"></div><button class="btn" data-next type="button" aria-disabled="true">Continue</button></section>
    <section class="ol-sec" data-s="days"><div class="meta">4 of 4 · two to four</div><h2 class="title">Your <em>days.</em></h2><div class="ol-week" id="week">${DAYS.map((d,i)=>`<button class="ol-day" type="button" role="checkbox" data-d="${i}" aria-checked="false" aria-label="${d}">${d[0]}</button>`).join("")}</div><p class="hand ol-sum" id="sum">tap the days that usually work</p><div class="spacer"></div><button class="btn" data-next type="button" aria-disabled="true">Make my plan</button></section>
    <section class="ol-sec" data-s="plan"><div class="meta">${esc(today)}</div><h2 class="title">Your first <em>week.</em></h2>
      <div class="ol-prot"><span class="ol-pnum" id="pnum">100<small>g</small></span><span class="meta">protein a day</span></div><div class="ol-gap" id="bar"></div>
      <div class="ol-wk2" id="wk2">${DAYS.map((d,i)=>`<span data-d="${i}"><b>${d[0]}</b><i></i></span>`).join("")}</div><div class="ol-gap"></div>
      <p class="hand ol-note" id="note"></p><div class="spacer"></div><button class="btn ol-start" id="start" type="button" aria-disabled="true">Start my week</button></section>`;
  const secs = [...doc.querySelectorAll(".ol-sec")];
  secs.forEach(s => s.style.minHeight = H + "px");
  await new Promise(r => requestAnimationFrame(r));
  const ink = inkLayer(doc, W, doc.scrollHeight); ink.style.zIndex = 4;
  const R = n => { const d = doc.getBoundingClientRect(), r = n.getBoundingClientRect(); return {x:r.left - d.left, y:r.top - d.top, w:r.width, h:r.height}; };

  /* ---- the pen: one continuous, visible line, like a hand-drawn thread.
          Joins are tangent-matched curves (S-curves and round U-turns), rings are true ellipses,
          and changes of row swing round through the margins so the line never crosses text. ---- */
  let pen = [G, -12], dir = [0, 1], cur = 0, busy = false, queued = false, onRing = false;
  const segs = { a:[], c:[] }, penAt = [], dirAt = [];
  const F = n => n.toFixed(1), RM = W - 18;
  const unit = v => { const l = Math.hypot(v[0], v[1]) || 1; return [v[0]/l, v[1]/l]; };
  function draw(d, list, o = {}){
    const p = document.createElementNS(NS, "path");
    p.setAttribute("d", d); p.setAttribute("fill", "none"); p.setAttribute("stroke", "var(--terra)"); p.setAttribute("stroke-width", "2.4");
    p.setAttribute("stroke-linecap", "round"); p.setAttribute("stroke-linejoin", "round");
    ink.appendChild(p); list.push(p);
    const len = p.getTotalLength(); p.style.strokeDasharray = len; p.style.strokeDashoffset = len;
    const dur = REDUCED ? 1 : Math.max(o.min ?? 380, Math.min(o.max ?? 1800, len * (o.pace ?? 1.0)));
    p.dur = dur;
    p.done = p.animate([{strokeDashoffset:len}, {strokeDashoffset:0}], {duration:dur, delay:REDUCED ? 0 : (o.delay || 0), easing:"cubic-bezier(.4,.05,.35,1)", fill:"forwards"}).finished.catch(() => {});
    return p;
  }
  /* nodes: {p:[x,y], d:[dx,dy]} reached with a tangent-matched curve, or {p, line:true} reached straight */
  function flow(nodes, list, extra = "", end = null, endDir = null, o = {}){
    let d = `M${F(pen[0])} ${F(pen[1])}`, p0 = pen, d0 = dir;
    for (const n of nodes) {
      if (n.line) { d += ` L${F(n.p[0])} ${F(n.p[1])}`; d0 = unit([n.p[0] - p0[0], n.p[1] - p0[1]]); }
      else {
        const dist = Math.hypot(n.p[0] - p0[0], n.p[1] - p0[1]), k = (n.k ?? .42) * dist;
        const cx1 = Math.max(8, Math.min(W - 8, p0[0] + d0[0]*k)), cx2 = Math.max(8, Math.min(W - 8, n.p[0] - n.d[0]*k)); /* curves stay on the page */
        d += ` C${F(cx1)} ${F(p0[1] + d0[1]*k)} ${F(cx2)} ${F(n.p[1] - n.d[1]*k)} ${F(n.p[0])} ${F(n.p[1])}`;
        d0 = n.d;
      }
      p0 = n.p;
    }
    const p = draw(d + extra, list, o);
    pen = end || p0; dir = endDir || d0;
    return p;
  }
  /* ring an element: travel to its top, go round a true ellipse, leave along the same tangent */
  async function toRing(n, list, pad = 7){
    const r = R(n), rx = r.w/2 + pad, ry = r.h/2 + pad, cx = r.x + r.w/2, cy = r.y + r.h/2, top = cy - ry;
    const nodes = [];
    let head;
    if (onRing && Math.abs(pen[1] - top) < 2 && cx > pen[0]) { head = [1, 0]; nodes.push({p:[cx, top], line:true}); }
    else if (onRing && top > pen[1] + 20) { head = [-1, 0]; nodes.push({p:[RM, (pen[1] + top) / 2], d:[0, 1]}, {p:[cx, top], d:head}); }
    else { head = cx < pen[0] - 10 ? [-1, 0] : [1, 0]; nodes.push({p:[cx, top], d:head, k:.5}); }
    const sweep = head[0] > 0 ? 1 : 0;
    const arcs = ` A${F(rx)} ${F(ry)} 0 0 ${sweep} ${F(cx)} ${F(cy + ry)} A${F(rx)} ${F(ry)} 0 0 ${sweep} ${F(cx)} ${F(top)}`;
    onRing = true;
    return flow(nodes, list, arcs, [cx, top], head).done;
  }
  /* back to the left margin through the empty space above the button */
  function toMargin(y, list){
    onRing = false;
    const nodes = dir[0] > .3
      ? [{p:[RM, y - 46], d:[0, 1]}, {p:[G, y + 14], d:[0, 1]}]
      : [{p:[G, Math.min(y, pen[1] + 50)], d:[0, 1]}, {p:[G, y + 14], line:true}];
    return flow(nodes, list).done;
  }
  function camTo(i, dur = 900){ const y = secs[i].offsetTop; doc.style.transition = REDUCED ? "none" : `transform ${dur}ms cubic-bezier(.65,0,.35,1)`; doc.style.transform = `translateY(${-y}px)`; return wait(dur); }
  function chrome(){ backBtn.hidden = cur === 0 || cur >= 5; stepEl.textContent = ""; secs.forEach((s, i) => { s.classList.toggle("on", i <= cur); s.inert = i !== cur; }); }

  /* the coach outline, drawn by the line itself, in doc coordinates */
  function scalePath(d, ox, oy, s){
    const t = d.match(/[a-zA-Z]|-?[\d.]+/g); let out = "", cmd = "", n = [];
    const flush = () => {
      if (!n.length) return;
      if (cmd === "a") { for (let i = 0; i < n.length; i += 7) out += ` ${n[i]*s} ${n[i+1]*s} ${n[i+2]} ${n[i+3]} ${n[i+4]} ${n[i+5]*s} ${n[i+6]*s}`; }
      else if (cmd === cmd.toLowerCase()) out += " " + n.map(v => v * s).join(" ");
      else out += " " + n.map((v, i) => i % 2 ? oy + v * s : ox + v * s).join(" ");
      n = [];
    };
    for (const k of t) { if (/[a-zA-Z]/.test(k)) { flush(); cmd = k; out += " " + k; } else n.push(+k); }
    flush(); return out.trim();
  }
  let companion = null;

  /* ---------- arrive: down the margin, curve in, underline the question ---------- */
  async function arrive(i){
    const s = secs[i], list = segs.a[i] = [];
    chrome(); camTo(i);
    const t = R(s.querySelector(".title em") || s.querySelector(".title")), uy = t.y + t.h + 5;
    const nodes = [];
    if (pen[1] < t.y - 70) nodes.push({p:[G, t.y - 34], d:[0, 1]});
    nodes.push({p:[t.x - 4, uy], d:[1, 0]}, {p:[t.x + t.w + 6, uy], line:true});
    await flow(nodes, list, "", null, null, {min:700}).done;
    alive(e);
    if (i === 0) await drawCoachLine(list);
    if (i === 4) await drawRuler(list);
    if (i === 5) await drawPlan(list);
    penAt[i] = pen.slice(); dirAt[i] = dir.slice();
  }
  async function drawCoachLine(list){
    const host = doc.querySelector("#hero"), r = R(host), sz = Math.min(r.w, r.h), ox = r.x + (r.w - sz)/2, oy = r.y, k = sz / 200;
    host.innerHTML = `<div data-state="hello" class="ol-heroc">${mascot(S.coach)}</div>`;
    const m = host.querySelector(".m"); m.style.opacity = "0";
    const c = CHARS[S.coach], parts = [c.body, ...(c.back || []).filter(p => p.f === "b").map(p => p.d)].map(d => scalePath(d, ox, oy, k));
    const probe = document.createElementNS(NS, "path"); probe.setAttribute("d", parts[0]); ink.appendChild(probe);
    const s0 = probe.getPointAtLength(0), s1 = probe.getPointAtLength(3); probe.remove();
    const t0 = unit([s1.x - s0.x, s1.y - s0.y]), start = [s0.x, s0.y];
    const sub = R(doc.querySelector(".ol-sub"));
    /* down the right margin past the text, then a scoop under the coach into its outline */
    await flow([{p:[RM, sub.y + sub.h + 10], d:[0, 1]}, {p:start, d:t0, k:.55}], list, "", start, t0, {max:1400}).done;
    await Promise.all(parts.map((d, j) => draw(d, list, {delay:j * 120, max:1300}).done));
    alive(e);
    m.style.transition = "opacity 500ms"; m.style.opacity = "1";
    list.slice(-parts.length).forEach(p => { p.style.transition = "opacity 600ms"; p.style.opacity = "0"; });
  }
  async function drawRuler(list){
    const wk = R(doc.querySelector("#week")), days = [...doc.querySelectorAll(".ol-day")].map(R), y = wk.y + wk.h + 12;
    const c = days.map(d => d.x + d.w/2);
    /* a round U-turn into the ruler, then a soft bump under each day, right to left */
    let bumps = "";
    for (let i = 6; i >= 0; i--) { const x = c[i]; bumps += ` L${F(x + 14)} ${F(y)} C${F(x + 7)} ${F(y)} ${F(x + 7)} ${F(y - 9)} ${F(x)} ${F(y - 9)} C${F(x - 7)} ${F(y - 9)} ${F(x - 7)} ${F(y)} ${F(x - 14)} ${F(y)}`; }
    await flow([{p:[RM - 6, y], d:[-1, 0], k:.6}], list, bumps, [c[0] - 14, y], [-1, 0], {max:2200}).done;
  }
  async function drawPlan(list){
    const num = R(doc.querySelector("#pnum")), bar = R(doc.querySelector("#bar")), wk = R(doc.querySelector("#wk2")), note = doc.querySelector("#note"), btn = R(doc.querySelector("#start"));
    const marks = [...doc.querySelectorAll("#wk2 span")];
    marks.forEach(m => m.classList.toggle("on", S.days.includes(+m.dataset.d)));
    const by = bar.y + 6, right = RM - 8;
    /* row 1: a U-turn, then the protein line under the number */
    await flow([{p:[right, by], d:[-1, 0], k:.6}, {p:[num.x - 2, by], line:true}], list).done;
    doc.querySelector(".ol-prot").classList.add("lit");
    /* row 2: round U-turn on the left, then your week, a dot where you train */
    const wy = wk.y + wk.h + 8;
    const p2 = flow([{p:[wk.x + 4, wy], d:[1, 0], k:.7}, {p:[right, wy], line:true}], list, "", null, null, {max:2000});
    marks.forEach(m => { const mr = R(m.querySelector("i")), at = .35 + .65 * (mr.x + mr.w/2 - wk.x) / (right - wk.x); setTimeout(() => m.classList.add("show"), REDUCED ? 0 : p2.dur * Math.min(1, at)); });
    await p2.done; alive(e);
    /* row 3: U-turn on the right, then underline the coach's note */
    note.textContent = `${DAYS[S.days[0]]} first. Easy on rough mornings. — ${coachName()}`;
    note.classList.add("line", "writing"); note.style.setProperty("--d", "1100ms"); note.style.setProperty("--st", "steps(24)");
    await wait(300);
    const nr = R(note), ny = nr.y + nr.h + 6, nEnd = Math.min(right, nr.x + nr.w + 6);
    await flow([{p:[nEnd, ny], d:[-1, 0], k:.7}, {p:[nr.x - 4, ny], line:true}], list).done;
    /* last: a curve down into the button, drawn round, and it becomes real */
    const bx = btn.x, bw = btn.w, bh = btn.h, rr = bh / 2, top = btn.y, bot = top + bh;
    const pill = ` L${F(bx + bw - rr)} ${F(bot)} A${F(rr)} ${F(rr)} 0 0 0 ${F(bx + bw)} ${F(top + rr)} A${F(rr)} ${F(rr)} 0 0 0 ${F(bx + bw - rr)} ${F(top)} L${F(bx + rr)} ${F(top)} A${F(rr)} ${F(rr)} 0 0 0 ${F(bx)} ${F(top + rr)} A${F(rr)} ${F(rr)} 0 0 0 ${F(bx + rr)} ${F(bot)}`;
    await flow([{p:[bx + rr, bot], d:[1, 0], k:.6}], list, pill, [bx + rr, bot], [1, 0], {max:2400}).done; alive(e);
    const sb = doc.querySelector("#start"); sb.classList.add("ready"); sb.setAttribute("aria-disabled", "false");
    companion?.set("proud", 2000);
  }

  /* ---------- commit: ring what you chose, then back to the margin ---------- */
  async function commit(i){
    const s = secs[i], list = segs.c[i] = [];
    onRing = false;
    if (i === 1) {
      await toRing(s.querySelector('.thumb[aria-checked="true"]'), list, 5);
      /* then a U-turn round the right and underline the name, right to left */
      const f = R(s.querySelector("#nm")), w = Math.max(40, Math.min(f.w, s.querySelector("#nm").value.length * 15 + 10)), uy = f.y + f.h + 5;
      await flow([{p:[RM, (pen[1] + uy) / 2], d:[0, 1]}, {p:[f.x + w + 4, uy], d:[-1, 0]}, {p:[f.x - 4, uy], line:true}], list).done;
      onRing = false;
    }
    if (i === 2) await toRing(s.querySelector('.tile[aria-checked="true"]'), list, 6);
    if (i === 3) for (const t of s.querySelectorAll('.tile[aria-checked="true"]')) await toRing(t, list, 6);
    if (i === 4) for (const t of s.querySelectorAll('.ol-day[aria-checked="true"]')) await toRing(t, list, 3);
    alive(e);
    await toMargin(R(s.querySelector("[data-next]")).y - 18, list);
  }

  /* ---------- wiring ---------- */
  const hero = secs[0];
  /* coach section: the chosen coach stands centre, swapped on tap */
  const show = makeCoach(doc.querySelector("#show")); Object.assign(show.el.style, {left:"50%", top:"0", width:"170px", height:"170px", marginLeft:"-85px"});
  doc.querySelector("#th").addEventListener("click", ev => { const b = ev.target.closest(".thumb"); if (!b) return; S.coach = b.dataset.c; if (!S.named) { S.name = CHARS[S.coach].name; doc.querySelector("#nm").value = S.name; } doc.querySelectorAll(".thumb").forEach(t => t.setAttribute("aria-checked", t === b)); show.swap(S.coach); show.set("hello", 1400); });
  doc.querySelector("#nm").addEventListener("input", ev => { S.name = ev.target.value; S.named = true; });
  doc.querySelector("#nm").addEventListener("focus", () => show.set("listening"));
  /* stage, goals, days */
  const gate = (i, ok) => secs[i].querySelector("[data-next]").setAttribute("aria-disabled", String(!ok));
  secs[2].querySelector(".tiles").addEventListener("click", ev => { const b = ev.target.closest(".tile"); if (!b) return; secs[2].querySelectorAll(".tile").forEach(t => t.setAttribute("aria-checked", t === b)); S.stage = b.dataset.v; companion?.set(S.stage === "surg" ? "comfort" : "listening", 1300); gate(2, true); });
  secs[3].querySelector(".tiles").addEventListener("click", ev => { const b = ev.target.closest(".tile"); if (!b) return; const v = b.dataset.v, on = !S.goals.includes(v); if (on && S.goals.length >= 2) { b.animate([{translate:"0"},{translate:"-4px"},{translate:"4px"},{translate:"0"}], {duration:220}); return; } S.goals = on ? S.goals.concat(v) : S.goals.filter(x => x !== v); b.setAttribute("aria-checked", on); if (on) companion?.set("proud", 1300); gate(3, S.goals.length > 0); });
  secs[4].querySelector("#week").addEventListener("click", ev => { const b = ev.target.closest(".ol-day"); if (!b) return; const d = +b.dataset.d, on = !S.days.includes(d); if (on && S.days.length >= 4) return; S.days = (on ? S.days.concat(d) : S.days.filter(x => x !== d)).sort(); b.setAttribute("aria-checked", on); doc.querySelector("#sum").textContent = S.days.length ? `${S.days.length} × 20 minutes` : "tap the days that usually work"; if (on) companion?.set("lifting", 1100); gate(4, S.days.length >= 2); });

  async function next(){
    if (busy) { queued = true; return; } busy = true; queued = false;
    try {
      await commit(cur);
      if (cur === 1) { /* the coach hops into the corner and rides along */
        const from = prect(show.el.querySelector(".m")); companion = makeCoach(root, "ol-companion");
        const to = prect(companion.el); companion.el.style.opacity = "0";
        await fly(show.el.querySelector(".m"), from, to, {arc:-30, dur:620}); alive(e);
        companion.el.style.opacity = "1"; companion.set("hello", 1200);
      }
      cur++; await arrive(cur);
    } catch (err) { if (!(err instanceof Stop)) throw err; return; }
    busy = false;
    /* a Continue pressed while the pen was still drawing is honoured once it finishes */
    if (queued && cur < 5 && secs[cur].querySelector("[data-next]")?.getAttribute("aria-disabled") !== "true") next();
    queued = false;
  }
  async function back(){
    if (busy || cur === 0 || cur >= 5) return; busy = true;
    const fadeOut = list => (list || []).forEach(p => { p.classList.add("fade"); setTimeout(() => p.remove(), 380); });
    fadeOut(segs.a[cur]); fadeOut(segs.c[cur - 1]); segs.a[cur] = []; segs.c[cur - 1] = [];
    if (cur === 2) { companion?.el.remove(); companion = null; }
    cur--; pen = penAt[cur].slice(); dir = dirAt[cur].slice(); chrome(); await camTo(cur, 700); busy = false;
  }
  secs.forEach(s => s.querySelector("[data-next]")?.addEventListener("click", ev => { if (ev.currentTarget.getAttribute("aria-disabled") !== "true") next(); }));
  backBtn.addEventListener("click", back);
  root.addEventListener("keydown", ev => { if (ev.key === "Escape") back(); });

  /* the end: zoom out over the whole page and its single line */
  doc.querySelector("#start").addEventListener("click", async ev => {
    if (ev.currentTarget.getAttribute("aria-disabled") === "true" || busy) return; busy = true;
    companion?.set("hello", 2000);
    const total = doc.scrollHeight, s = Math.min((H - 120) / total, 1), x = (W - W * s) / 2;
    doc.style.transition = REDUCED ? "none" : "transform 1300ms cubic-bezier(.65,0,.35,1)";
    doc.style.transformOrigin = "0 0"; doc.classList.add("overview");
    doc.style.transform = `translate(${x}px, 30px) scale(${s})`;
    companion?.el.classList.add("fade"); stepEl.textContent = "";
    await wait(1300);
    const end = root.querySelector("#end"); end.hidden = false; end.classList.add("rise");
  });
  root.querySelector("#again").addEventListener("click", () => start());

  chrome();
  await arrive(0);
}
