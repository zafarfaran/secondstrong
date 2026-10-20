# Builds collage.src.html: the shared helpers from feelings.src.html plus the collage experience
# (collage_part.js), offered two ways: plain, and with one continuous line. Run from design/onboarding/.
s = open('feelings.src.html', encoding='utf-8').read()
part = open('collage_part.js', encoding='utf-8').read()

a = s.index('/* ======================= A · conversation')
b = s.index('/* ---------- switcher ---------- */')
s = s[:a] + part + '\n' + s[b:]

x0 = s.index('const EXPS = [')
x1 = s.index('];', x0) + 2
s = s[:x0] + '''const EXPS = [
  {id:"collage", name:"Collage", desc:"Build your plan page as you answer. Picks slap on as taped stickers, days get circled, and the page becomes your plan.", run:(r, e) => collage(r, e, {line:false})},
  {id:"collage-line", name:"Collage + line", desc:"The same page, with one continuous ink line that travels to every sticker as it lands, visits your days and ends under your coach's note.", run:(r, e) => collage(r, e, {line:true})}
];''' + s[x1:]

def rep(o, n):
    global s
    assert o in s, o[:70]
    s = s.replace(o, n)

rep('<title>Onboarding Feelings</title>', '<title>Collage Onboarding</title>')
rep('let X = "toybox";\ntry { X = localStorage.getItem("ss-feel") || "toybox"; } catch(err) {}',
    'let X = "collage";\ntry { X = localStorage.getItem("ss-collage") || "collage"; } catch(err) {}\nif (!["collage", "collage-line"].includes(X)) X = "collage";')
rep('try { localStorage.setItem("ss-feel", X); } catch(err) {}', 'try { localStorage.setItem("ss-collage", X); } catch(err) {}')
rep('<h1>Five ways it could <em>feel.</em></h1>', '<h1>The <em>collage,</em> two ways.</h1>')
rep('<p class="lede">Same Sketchbook look, same drawn-to-life lines, same coach. What changes is how the onboarding behaves. Pick one and play it on the phone.</p>',
    '<p class="lede">A new start page that previews the page you are about to make, then the build. Compare it plain and with one continuous line.</p>')

css = '''
.cl-date{left:18px; top:14px; font:500 10.5px/1 var(--f-mono); letter-spacing:.08em; text-transform:uppercase; color:var(--ink2)}
.cl-title{left:18px; top:30px; font:400 32px/1 var(--f-hand)!important; color:var(--ink)!important; max-width:none!important}
.preview{transition:opacity 200ms}
.pv-num{font:800 38px/.9 var(--f-display); letter-spacing:-.05em}
.pv-num small{font-size:16px}
.pv-label{align-content:center}
.pv-note{font-size:19px; line-height:1.05; transform:rotate(-3deg)}
.cl-cal span{transition:color 200ms, transform 200ms}
.cl-cal span.picked{color:var(--terra); transform:scale(1.15)}
'''
rep('.coach-in .m{width:100%; height:100%; display:block}', '.coach-in .m{width:100%; height:100%; display:block}' + css)
open('collage.src.html', 'w', encoding='utf-8').write(s)

b = open('build.mjs', encoding='utf-8').read()
if '"collage"' not in b:
    open('build.mjs', 'w', encoding='utf-8').write(b.replace('"feelings"]', '"feelings", "collage"]'))
print('ok')
