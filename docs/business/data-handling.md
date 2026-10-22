# Data handling

The quiz and app collect health-related data: weight and goal weight, age range,
menopause stage, symptoms, allergies, sleep, and free-text goals. Treat all of
it as PII.

## Rules for building

- Use RealityMine's [AI Policy](https://realitymine.atlassian.net/wiki/spaces/BMS/pages/3012362282/AI+Policy)
  as the governing policy for any AI-assisted work.
- No real user data in prompts, test fixtures, screenshots, logs or commits.
  Use obviously fake values.
- Do not log quiz answers. Log events and counts, not content.
- Keep secrets out of the repo (`.env*` is gitignored except `.env.example`).
- Analytics and crash tooling must not receive health answers.

## Open items

Retention periods, consent copy, and the legal basis for processing health data
are not yet defined. Tracked in [open questions](../open-questions.md).
