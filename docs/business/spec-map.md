# Spec map

`keel-health-pricing-and-features-spec.md` (repo root) is about 715 lines. Do not
load it whole. Find the section, then read only that slice:

```
grep -n '^## ' keel-health-pricing-and-features-spec.md     # section line numbers
sed -n '125,328p' keel-health-pricing-and-features-spec.md  # example: section 2
```

Line numbers drift when the spec is edited; re-run the grep.

| Section | Topic | Read when |
|---|---|---|
| 1 Pricing | Plans, product IDs, paywall rules, trial mechanics, billing compliance, retention, metrics, AI cost control | paywall, subscriptions, analytics |
| 2 Onboarding funnel | Funnel shape, quiz blocks and questions, analysis moment, plan reveal, safety screening (2.6) | onboarding screens, plan reveal |
| 3 Feature matrix | Free vs Pro | gating features |
| 4 Full Pro feature set | Every Pro feature in detail | building any feature |
| 5 Navigation | App navigation | app shell, tabs |
| 6 Build sequencing | Suggested build order | planning |
| 7 Safety requirements | Non-negotiable safety rules | always before health-related logic |
| 8 Reserved | Future premium tier | do not build |
| 9 Open items | Unresolved questions | planning |

## Onboarding quick reference

Quiz blocks: 1 goal and identity, 2 current state, 3 framework education,
4 personalisation inputs, 5 safety screening (mandatory), 6 commitment. Never
open with height and weight. Echo the user's free-text 12-week goal back in the
plan reveal.

## Maintenance

When a spec decision changes, update the spec and, if it affects the summary,
[overview](overview.md). Splitting the spec into files under 600 lines is
tracked in [tech debt](../exec-plans/tech-debt.md).
