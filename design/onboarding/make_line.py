# Builds line.src.html: shared helpers from feelings.src.html + the one-line experience (line_part.js).
# Run from design/onboarding/.
s = open('feelings.src.html', encoding='utf-8').read()
part = open('line_part.js', encoding='utf-8').read()
a = s.index('/* ======================= A · conversation')
b = s.index('/* ---------- switcher ---------- */')
s = s[:a] + part + '\n' + s[b:]
x0 = s.index('const EXPS = ['); x1 = s.index('];', x0) + 2
s = s[:x0] + '''const EXPS = [
  {id:"oneline", name:"One line", desc:"", run:oneline}
];''' + s[x1:]

def rep(o, n):
    global s
    assert o in s, o[:70]
    s = s.replace(o, n)

rep('<title>Onboarding Feelings</title>', '<title>One Line Onboarding</title>')
rep('let X = "toybox";\ntry { X = localStorage.getItem("ss-feel") || "toybox"; } catch(err) {}', 'let X = "oneline";')
rep('try { localStorage.setItem("ss-feel", X); } catch(err) {}', '')
rep('<h1>Five ways it could <em>feel.</em></h1>', '<h1>One <em>line.</em></h1>')
rep('<p class="lede">Same Sketchbook look, same drawn-to-life lines, same coach. What changes is how the onboarding behaves. Pick one and play it on the phone.</p>',
    '<p class="lede">A single pen line runs from the first screen to the last. It never decorates: every stroke records an answer or draws something you use.</p>')
rep('<ul class="vlist" id="vlist"></ul>', '''<ul class="legend">
      <li><svg viewBox="0 0 48 20"><path d="M3 12 C14 10 30 14 45 9"/></svg><span><b>Underline</b> the question being asked</span></li>
      <li><svg viewBox="0 0 48 20"><path d="M10 10 C10 2 38 2 38 10 C38 18 10 18 11 8"/></svg><span><b>Ring</b> the answer you commit to, when you press Continue</span></li>
      <li><svg viewBox="0 0 48 20"><path d="M3 14 L45 14 M10 14 l4 -6 4 6 M24 14 l4 -6 4 6"/></svg><span><b>Draws</b> your coach, your week ruler and your plan</span></li>
      <li><svg viewBox="0 0 48 20"><path d="M6 2 C6 8 5 12 6 18"/></svg><span><b>Margin</b> is its only route between moments</span></li>
    </ul>''')
rep('<p class="tip">The phone restarts when you switch</p>', '<p class="tip">Back erases the line to that point · Esc goes back</p>')
rep('''const vlist = document.getElementById("vlist");
vlist.innerHTML = EXPS.map((x, i) => `<li><button class="vbtn" type="button" data-x="${x.id}" aria-pressed="${x.id===X}"><span class="ltr">${String.fromCharCode(65+i)}</span><b>${x.name}</b><span>${x.desc}</span></button></li>`).join("");
vlist.addEventListener("click", ev => { const b = ev.target.closest(".vbtn"); if (!b) return; X = b.dataset.x; vlist.querySelectorAll(".vbtn").forEach(v => v.setAttribute("aria-pressed", v === b)); start(); });''', '')

css = '''
.legend{list-style:none; margin:4px 0 0; padding:0; display:grid; gap:12px}
.legend li{display:grid; grid-template-columns:48px 1fr; gap:12px; align-items:center; font-size:14.5px; color:var(--deskInk2)}
.legend b{color:var(--deskInk); font-weight:700}
.legend svg{width:48px; height:20px; fill:none; stroke:var(--terra); stroke-width:2.2; stroke-linecap:round; stroke-linejoin:round}
.ol-doc{position:absolute; left:0; top:0; width:100%; will-change:transform}
.ol-sec{position:relative; padding:92px 22px 26px 34px; display:flex; flex-direction:column; gap:16px; opacity:0; transition:opacity 500ms var(--ease)}
.ol-sec.on{opacity:1}
.ol-big{font-size:50px!important; max-width:7ch}
.ol-sub{margin:-4px 0 0; color:var(--ink2); font-size:15.5px}
.ol-hero{height:240px; position:relative; flex:none}
.ol-heroc{position:absolute; inset:0; display:grid; place-items:center}
.ol-heroc .m{width:240px; height:240px}
.ol-show{height:170px; position:relative; flex:none}
.ol-top{position:absolute; left:0; right:0; top:0; height:60px; z-index:8; display:flex; align-items:center; justify-content:space-between; padding:14px 18px 0 12px; pointer-events:none; background:linear-gradient(var(--bg) 60%, transparent)}
.ol-top > *{pointer-events:auto}
.icon-btn{appearance:none; border:0; background:transparent; width:40px; height:40px; border-radius:50%; display:grid; place-items:center; cursor:pointer}
.icon-btn svg{width:20px; height:20px; fill:none; stroke:var(--ink); stroke-width:2; stroke-linecap:round; stroke-linejoin:round}
.ol-back[hidden]{display:grid!important; visibility:hidden}
.ol-step{font:500 11px/1 var(--f-mono); letter-spacing:.08em; color:var(--ink2); margin-right:64px}
.ol-companion{width:74px; height:74px; right:14px; top:46px; z-index:9}
.ol-week{display:grid; grid-template-columns:repeat(7,1fr); gap:6px; margin-top:12px}
.ol-day{appearance:none; height:46px; border:0; background:transparent; border-radius:50%; font:800 18px/1 var(--f-display); cursor:pointer; color:var(--ink2); transition:color 160ms, transform 160ms var(--ease), background 200ms}
.ol-day:active{transform:scale(.92)}
.ol-day[aria-checked="true"]{color:var(--bg); background:var(--ink); animation:stamp 380ms var(--spring)}
.ol-sum{margin:14px 0 0; text-align:center}
.ol-prot{display:flex; align-items:baseline; gap:12px; margin-top:6px}
.ol-pnum{font:800 64px/.9 var(--f-display); letter-spacing:-.05em; opacity:.18; transition:opacity 500ms}
.ol-pnum small{font-size:24px}
.ol-prot.lit .ol-pnum{opacity:1}
.ol-gap{height:14px}
.ol-wk2{display:grid; grid-template-columns:repeat(7,1fr); text-align:center}
.ol-wk2 b{display:block; font:500 11px/1 var(--f-mono); color:var(--ink2)}
.ol-wk2 i{display:block; width:14px; height:14px; margin:10px auto 0; border-radius:50%; background:transparent; transform:scale(0); transition:transform 380ms var(--spring)}
.ol-wk2 span.on i{background:var(--ink)}
.ol-wk2 span.show i{transform:scale(1)}
.ol-wk2 span.on b{color:var(--ink); font-weight:700}
.ol-note{min-height:52px; margin:0}
.ol-start{background:transparent; color:var(--ink); transition:background 400ms, color 400ms}
.ol-start.ready{background:var(--ink); color:var(--bg)}
.ol-end[hidden]{display:none!important}
.overview .ink path.transit{opacity:.5!important; stroke:#A8968A!important; stroke-width:1.6px!important}
.overview .ink path{vector-effect:non-scaling-stroke; stroke-dasharray:none!important; stroke-width:3.2px; stroke:#A85A3C}
.overview .ol-sec > *{opacity:.3; transition:opacity 900ms}
.ol-end{position:absolute; left:0; right:0; bottom:22px; z-index:9; display:grid; justify-items:center; gap:10px}
.ol-end .hand{margin:0; font-size:22px}
'''
rep('.coach-in .m{width:100%; height:100%; display:block}', '.coach-in .m{width:100%; height:100%; display:block}' + css)
open('line.src.html', 'w', encoding='utf-8').write(s)
b = open('build.mjs', encoding='utf-8').read()
if '"line"' not in b:
    open('build.mjs', 'w', encoding='utf-8').write(b.replace('"collage"]', '"collage", "line"]'))
print('ok')
