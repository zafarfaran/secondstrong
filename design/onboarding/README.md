# Onboarding and motion prototypes

Self-contained HTML prototypes in the Sketchbook look. Open any `.html` file in a browser; each works offline apart from Google Fonts.

| File | What it shows | Status |
|---|---|---|
| `line.html` | Onboarding drawn by one continuous pen line | **Chosen** |
| `coldstart.html` | Icon tap → launch screen → birds on a wire → Today, plus launch options | **Chosen** (option A) |
| `intro.html` | Five cast-peek intros (first open and returning) and four between-screen moments | Birds on a wire and Peek loader **chosen** |
| `loaders.html` | Six loading moments drawn with the pen | Reference |
| `launch.html` | Three still launch screens on paper | Superseded by `coldstart.html` |
| `collage.html` | Build-your-page collage, plain and with a line | Explored |
| `feelings.html` | Five interaction models: conversation, toybox, one drawing, index cards, collage | Explored |
| `moods.html` | Five visual moods | Explored |
| `variants.html` | Five line treatments | Explored |
| `onboarding.html` | Page-turn notebook with margin notes | Explored |

## How they're built

- `*.src.html` are the sources. `node design/onboarding/build.mjs` injects the coach rig from `../mascots/mascot-board.html` and the line drawings from `app-directions/shared/draw/`, writing the `.html` files.
- `moods`, `collage` and `line` sources are generated from `feelings.src.html` by `make_moods.py`, `make_collage.py` (with `collage_part.js`) and `make_line.py` (with `line_part.js`). Edit the part, run the make script, then the build.
- `test-*.mjs` play each prototype in headless Chrome with real taps and drags, check it works and save screenshots to `_shots/` (not committed).
