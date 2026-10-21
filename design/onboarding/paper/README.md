# Onboarding: paper + one line

Canvas: https://claude.ai/artifact/F2efuUSXGKovnnpGWyHrS3 (row 1 dark, row 2 light; Play on Welcome walks it)

The chosen one-line onboarding (`../line.html`) with the paper look from the final sign-in:
one ink line runs through every screen, underlining the question, ringing the answer and drawing on
into the plan, over torn-paper art.

1. **Welcome**: "Let's build *your week.*" The coaches sit at the foot of a paper path; the line runs into it.
2. **Your coach**: each coach on a small paper hill; the line rings the one you pick; name field.
3. **About you**: the stages as paper moons (waxing, full, waning, half, behind a cloud).
4. **What matters**: up to two of strength, protein, energy, sleep as paper cut-outs.
5. **Your days**: day chips, the line loops each chosen day; paper flags along the path.
6. **Your first week**: protein target, the session days, and the line climbs to the flag.

## Files

- `gen_paper.py`: scenes (`gpt-image-2`, sign-in collages as style reference) and transparent paper icons
  (`gpt-image-1.5`, since gpt-image-2 can't do transparency). `OPENAI_API_KEY` from the environment.
- `prepare_art.py`: snaps scenes to the screen colour, trims icons, stands each real coach on the paper hill.
- `make_screens.py <canvas project folder>`: writes the 12 screens and the canvas index. The line paths are
  coordinates in that script, one per screen.
- `art/` generated originals, `web/` what the canvas uses, `screens/` a copy of the canvas files.
