# Derives moods.src.html (five visual moods, drawn-to-life motion) from variants.src.html,
# plus test-moods.mjs from test-variants.mjs. Run from design/onboarding/.
s = open('variants.src.html', encoding='utf-8').read()

def rep(a, b):
    global s
    assert a in s, a[:70]
    s = s.replace(a, b)

rep('<title>Onboarding Line Variants</title>', '<title>Onboarding Moods</title>')
rep('.page::before{content:""; position:absolute; inset:0; background:repeating-linear-gradient(transparent 0 31px, rgba(59,50,44,.04) 31px 32px); pointer-events:none}',
    '.page{transition:background 600ms var(--ease)}\n.page::before{content:""; position:absolute; inset:0; background:repeating-linear-gradient(transparent 0 31px, var(--rule) 31px 32px); pointer-events:none}\n.page::after{content:""; position:absolute; inset:0; background:var(--glow); pointer-events:none; z-index:0}')
rep('.bell[aria-checked="true"] .bar{fill:#6E6158}', '.bell[aria-checked="true"] .bar{fill:var(--ink2)}')
rep('.wk i{display:block; height:30px; margin-top:6px; border-radius:10px; background:rgba(59,50,44,.07); transform:scale(.5); opacity:0}',
    '.wk i{display:block; height:30px; margin-top:6px; border-radius:10px; background:var(--soft); transform:scale(.5); opacity:0}')
rep('.ink{position:absolute; inset:0; z-index:5; pointer-events:none; overflow:visible; mix-blend-mode:multiply}',
    '.ink{position:absolute; inset:0; z-index:5; pointer-events:none; overflow:visible; mix-blend-mode:var(--blend)}')
rep('.title{font:800 34px/1.02 var(--f-display); letter-spacing:-.035em;', '.title{font:var(--tw) var(--ts)/1.02 var(--f-title); letter-spacing:var(--tls);')
rep('.welcome .title{font-size:52px; max-width:7ch}', '.welcome .title{font-size:calc(var(--ts) * 1.55); max-width:7ch}')

moods_css = r'''
/* ===== moods: every token the phone uses, per feeling ===== */
.page{--rule:rgba(59,50,44,.04); --glow:none; --soft:rgba(59,50,44,.07); --hl:#F0C9A8; --hlw:12; --blend:multiply;
  --f-title:var(--f-display); --tw:800; --ts:34px; --tls:-.035em; --tile-r:20px; --tile-shadow:none}
.page[data-mood="night"]{--bg:#1D1424; --card:#291D33; --ink:#F6EEF8; --ink2:#BCA9C8; --taupe:#7E6B8B; --terra:#C9A7FF; --apricot:#6B4A99;
  --edge:rgba(255,255,255,.09); --rule:rgba(255,255,255,.028); --soft:rgba(255,255,255,.07); --hl:#5C3D8C; --blend:screen;
  --glow:radial-gradient(260px 220px at 78% 12%, rgba(201,167,255,.22), transparent 70%), radial-gradient(420px 300px at 50% 105%, rgba(201,167,255,.10), transparent 70%);
  --shadow:rgba(0,0,0,.5)}
.page[data-mood="night"] .companion{filter:drop-shadow(0 0 22px rgba(201,167,255,.35))}
.page[data-mood="night"] .tile[aria-checked="true"]{box-shadow:0 0 0 1px var(--terra), 0 0 28px -6px rgba(201,167,255,.55)}
.page[data-mood="night"] .btn{background:var(--terra); color:#1D1424; box-shadow:0 8px 30px -10px rgba(201,167,255,.7)}
.page[data-mood="night"] .day[aria-checked="true"]{background:var(--terra); border-color:var(--terra); color:#1D1424}
.page[data-mood="night"] .bell[aria-checked="true"] .plate{fill:var(--terra)}
.page[data-mood="night"] .wk i.on{background:var(--terra)}

.page[data-mood="pop"]{--bg:#C2714F; --card:color-mix(in srgb, var(--bg) 78%, #fff); --ink:#2A1F19; --ink2:#4A3A30; --taupe:#6E5A4D;
  --terra:#2A1F19; --edge:rgba(42,31,25,.16); --rule:transparent; --soft:rgba(42,31,25,.1);
  --hl:color-mix(in srgb, var(--bg) 80%, #5A2A10); --ts:40px; --tls:-.045em}
.page[data-mood="pop"][data-step="1"]{--bg:#E8C05F}
.page[data-mood="pop"][data-step="2"]{--bg:#EDE3D6}
.page[data-mood="pop"][data-step="3"]{--bg:#A9647A; --ink:#1F1418; --ink2:#3A2229}
.page[data-mood="pop"][data-step="4"]{--bg:#E8C05F}
.page[data-mood="pop"][data-step="5"]{--bg:#FBF8F4}
.page[data-mood="pop"][data-step="6"]{--bg:#EDE3D6}
.page[data-mood="pop"] .tile{border-width:2px}

.page[data-mood="calm"]{--bg:#EEF2EA; --card:#FFFFFF; --ink:#2D3A2C; --ink2:#667364; --taupe:#9AA696; --terra:#5F8552; --apricot:#D6E6C2;
  --edge:transparent; --rule:transparent; --soft:#E3E9DD; --hl:#D3E5BD; --tw:700; --tile-r:26px;
  --tile-shadow:0 1px 2px rgba(45,58,44,.06), 0 10px 28px -12px rgba(45,58,44,.18);
  --glow:radial-gradient(500px 360px at 30% -10%, rgba(255,255,255,.7), transparent 70%)}
.page[data-mood="calm"] .tile, .page[data-mood="calm"] .rack, .page[data-mood="calm"] .big, .page[data-mood="calm"] .wkcard, .page[data-mood="calm"] .thumb{border-color:transparent; box-shadow:var(--tile-shadow); border-radius:var(--tile-r)}
.page[data-mood="calm"] .tile[aria-checked="true"]{box-shadow:0 0 0 2px var(--terra), var(--tile-shadow)}
.page[data-mood="calm"] .day{border-color:transparent; background:#fff; box-shadow:var(--tile-shadow)}
.page[data-mood="calm"] .day[aria-checked="true"]{background:var(--terra); color:#fff}
.page[data-mood="calm"] .btn{background:var(--terra)}
.page[data-mood="calm"] .wk i.on{background:var(--terra)}

.page[data-mood="editorial"]{--bg:#F6F4EF; --card:transparent; --ink:#121110; --ink2:#5A5650; --taupe:#9C968D; --terra:#A85A3C;
  --edge:rgba(18,17,16,.16); --rule:transparent; --soft:rgba(18,17,16,.06); --hl:#A85A3C; --hlw:2.4; --blend:normal;
  --f-title:var(--f-serif); --tw:400; --ts:42px; --tls:-.025em; --tile-r:4px}
.page[data-mood="editorial"] .title em{color:var(--terra)}
.page[data-mood="editorial"] .tile, .page[data-mood="editorial"] .thumb, .page[data-mood="editorial"] .day, .page[data-mood="editorial"] .rack, .page[data-mood="editorial"] .big, .page[data-mood="editorial"] .wkcard{border-radius:var(--tile-r)}
.page[data-mood="editorial"] .tile{border-width:1px; background:transparent}
.page[data-mood="editorial"] .tile[aria-checked="true"]{border-color:var(--ink); box-shadow:inset 0 0 0 1px var(--ink)}
.page[data-mood="editorial"] .btn{border-radius:4px}
.page[data-mood="editorial"] .big .num{font-family:var(--f-serif); font-weight:400}
'''
rep('__MASCOT_CSS__', moods_css + '\n__MASCOT_CSS__')

rep('<div class="dmeta">Second Strong · onboarding · line study</div>\n    <h1>Five ways to <em>draw the line.</em></h1>\n    <p class="lede">The same short flow, with far fewer words, in five line treatments. Pick one on the left and play it on the phone.</p>',
    '<div class="dmeta">Second Strong · onboarding · drawn to life</div>\n    <h1>Five <em>feelings.</em></h1>\n    <p class="lede">The same flow and the same drawn-to-life motion, dressed five ways. Pick a mood and play it on the phone.</p>')
a = s.index('const VARIANTS = ['); b = s.index('];', a) + 2
s = s[:a] + '''const VARIANTS = [
  {id:"sketch", name:"Sketchbook", desc:"The app's own journal: ivory paper, ink lines, an apricot highlighter. Quiet and personal.", sw:["#FBF8F4","#3B322C","#F0C9A8"]},
  {id:"night", name:"Night studio", desc:"Deep plum, glowing lilac line art and a soft spotlight on the coach. Bold, playful, a little magic.", sw:["#1D1424","#C9A7FF","#F6EEF8"]},
  {id:"pop", name:"Colour field", desc:"The site's terra, honey and plum fill the page and change with every step. Loud, warm, energetic.", sw:["#C2714F","#E8C05F","#A9647A"]},
  {id:"calm", name:"Calm clay", desc:"Soft sage, raised white tiles, gentle shadows, no borders. Soothing, like a deep breath.", sw:["#EEF2EA","#FFFFFF","#5F8552"]},
  {id:"editorial", name:"Editorial", desc:"Black on ivory, big serif headlines, square tiles, a fine terra underline. Considered and grown-up.", sw:["#F6F4EF","#121110","#A85A3C"]}
];''' + s[b:]
rep('''vlist.innerHTML = VARIANTS.map((v, i) => `<li><button class="vbtn" type="button" data-v="${v.id}" aria-pressed="${v.id===V}"><svg viewBox="0 0 44 28" aria-hidden="true"><path d="${v.icon}"/></svg><b><i>${String.fromCharCode(65+i)}</i>${v.name}</b><span>${v.desc}</span></button></li>`).join("");''',
    '''vlist.innerHTML = VARIANTS.map((v, i) => `<li><button class="vbtn" type="button" data-v="${v.id}" aria-pressed="${v.id===M}"><span class="sw" aria-hidden="true">${v.sw.map(c=>`<i style="background:${c}"></i>`).join("")}</span><b><i>${String.fromCharCode(65+i)}</i>${v.name}</b><span>${v.desc}</span></button></li>`).join("");''')
rep('''  V = b.dataset.v; vlist.querySelectorAll(".vbtn").forEach(x => x.setAttribute("aria-pressed", x === b));''',
    '''  M = b.dataset.v; vlist.querySelectorAll(".vbtn").forEach(x => x.setAttribute("aria-pressed", x === b));''')
rep('.vbtn svg{grid-row:span 2; width:44px; height:28px; fill:none; stroke:var(--terra); stroke-width:2.2; stroke-linecap:round; stroke-linejoin:round}',
    '.vbtn .sw{grid-row:span 2; display:flex; width:44px; height:44px; border-radius:12px; overflow:hidden; box-shadow:0 0 0 1px rgba(0,0,0,.08)}\n.vbtn .sw i{flex:1}')
rep('''let S = fresh(), V = "pen";
try { V = localStorage.getItem("ss-lines-variant") || "pen"; } catch(e) {}''', '''let S = fresh(), V = "drawn", M = "night";
try { M = localStorage.getItem("ss-moods") || "night"; } catch(e) {}''')
rep('''  page.className = "page v-" + V;''', '''  page.className = "page v-" + V; page.dataset.mood = M;''')
rep('''  try { localStorage.setItem("ss-lines-variant", V); } catch(e) {}''', '''  try { localStorage.setItem("ss-moods", M); } catch(e) {}''')
rep('''window.__ob = { get S(){ return S; }, get V(){ return V; }, setV(v){ V = v; start(); } };''',
    '''window.__ob = { get S(){ return S; }, get M(){ return M; }, setM(m){ M = m; start(); } };''')
rep('''  S.step = n;
  const name = STEPS[n], next = scenes[name]();''', '''  S.step = n; page.dataset.step = n;
  const name = STEPS[n], next = scenes[name]();''')
rep('const sleep = ms =>', 'const tok = (k, d) => getComputedStyle(page).getPropertyValue(k).trim() || d;\nconst hlw = () => parseFloat(tok("--hlw", "12"));\nconst sleep = ms =>')
U = 'underPts(rel(%s), hlw() < 5 ? %s : %s)'
rep('''stroke(smooth(underPts(rel(t), 2)), {color:"var(--apricot)", w:10, dur:520, delay:350, cls:"hl", opacity:.85});''',
    '''stroke(smooth(underPts(rel(t), 2)), {color:"var(--hl)", w:Math.max(2.4, hlw() - 2), dur:520, delay:350, cls:"hl", opacity:.9});''')
rep('''    stroke(smooth(underPts(rel(lab), -3)), {color:"var(--apricot)", w:12, dur:420, cls:"pick", opacity:.9});''',
    '''    stroke(smooth(underPts(rel(lab), hlw() < 5 ? 3 : -3)), {color:"var(--hl)", w:hlw(), dur:420, cls:"pick", opacity:.95});''')
rep('''stage.querySelectorAll('.tile[aria-checked="true"] b').forEach(b => stroke(smooth(underPts(rel(b), -3)), {color:"var(--apricot)", w:12, dur:1, cls:"pick", opacity:.9}));''',
    '''stage.querySelectorAll('.tile[aria-checked="true"] b').forEach(b => stroke(smooth(underPts(rel(b), hlw() < 5 ? 3 : -3)), {color:"var(--hl)", w:hlw(), dur:1, cls:"pick", opacity:.95}));''')
rep('''    stroke(smooth(underPts(n, -14)), {color:"var(--apricot)", w:16, dur:600, delay:700, opacity:.85, cls:"hlnum"});''',
    '''    stroke(smooth(underPts(n, hlw() < 5 ? 4 : -14)), {color:"var(--hl)", w:hlw() < 5 ? hlw() : 16, dur:600, delay:700, opacity:.9, cls:"hlnum"});''')
rep('''    else if (V === "drawn" && b.matches(".tile")) stroke(smooth(underPts(rel(b.querySelector("b")), -3)), {color:"var(--apricot)", w:12, dur:1, cls:"pick", opacity:.9});''',
    '''    else if (V === "drawn" && b.matches(".tile")) stroke(smooth(underPts(rel(b.querySelector("b")), hlw() < 5 ? 3 : -3)), {color:"var(--hl)", w:hlw(), dur:1, cls:"pick", opacity:.95});''')
rep('''      if (V === "drawn") { clearInk(); stroke(smooth(underPts(rel(b), -6)), {color:"var(--apricot)", w:10, dur:400, opacity:.9}); }''',
    '''      if (V === "drawn") { clearInk(); stroke(smooth(underPts(rel(b), hlw() < 5 ? 2 : -6)), {color:"var(--hl)", w:Math.max(2.4, hlw() - 2), dur:400, opacity:.9}); }''')
rep('''    setTimeout(() => el.querySelectorAll(".wk i.on").forEach(i => { i.style.transition = "background 300ms"; i.style.background = "var(--ink)"; }), 1400);''',
    '''    setTimeout(() => el.querySelectorAll(".wk i.on").forEach(i => { i.style.transition = "background 300ms"; i.style.background = ""; }), 1400);''')
rep('<p class="tip">Esc goes back · Enter continues · the phone resets when you switch</p>', '<p class="tip">Esc goes back · Enter continues · the phone restarts when you switch mood</p>')
open('moods.src.html', 'w', encoding='utf-8').write(s)

b = open('build.mjs', encoding='utf-8').read()
if '"moods"' not in b:
    open('build.mjs', 'w', encoding='utf-8').write(b.replace('["onboarding", "variants"]', '["onboarding", "variants", "moods"]'))

t = open('test-variants.mjs', encoding='utf-8').read()
t = t.replace('variants.html', 'moods.html').replace('"_shots", "variants"', '"_shots", "moods"').replace('9336', '9337').replace('ss-var-prof', 'ss-mood-prof')
t = t.replace('for (const v of ["pen", "thread", "drawn", "curve", "connect"]) {', 'for (const v of ["sketch", "night", "pop", "calm", "editorial"]) {')
t = t.replace('window.__ob.setV(${JSON.stringify(v)})', 'window.__ob.setM(${JSON.stringify(v)})')
t = t.replace('''await check(`${v}: ink paths exist where expected`, `${v === "curve" || v === "thread" ? "true" : 'document.querySelectorAll("#ink path").length > 0'}`);''',
              '''await check(`${v}: highlighter drawn`, `document.querySelectorAll("#ink path").length > 0`);''')
cut = t.index('// connect: drag'); end = t.index('console.log(`${pass} passed')
t = t[:cut] + t[end:]
open('test-moods.mjs', 'w', encoding='utf-8').write(t)
print('ok')
