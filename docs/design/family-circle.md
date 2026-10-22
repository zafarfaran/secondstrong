# Family circle

Status: draft for review, 2026-10-21. Nothing here is built. Tickets: SS-0013 (epic), SS-0014 to SS-0018.

A way for someone (usually an adult child) to pay for, and look out for, a parent
using Second Strong, with the parent's explicit consent. Decisions below come from
a conversation with the product owner; items marked **Open** or **Guess** were not
decided.

## Intent

Adult children often want to help a mother going through perimenopause or later
life and do not know how. Today they can only tell her about the app. The family
circle lets them pay for it, stay in touch with how she is doing, and do small
useful things for her, without her giving up control of her own health data.

## Goals

- A family member can buy Second Strong for relatives on one bill.
- A member shares an overview with chosen people, only after she agrees, and can stop at any time.
- A family member who is not a member herself still finds the app worth opening.
- The member's experience stays hers: her coach, her answers, her account.

## Non-goals

- Covert or default-on monitoring of anyone.
- Showing a family member weight, food logs, symptoms, or what she says to her coach.
- Leaderboards or any comparison between relatives.
- A second app for family members (one app, see [Decisions](#decisions)).
- A free tier. The product is trial then paid, as in the pricing spec.

## Anti-goals

The feature has failed even if it works technically when:

- a relative can pressure someone about weight or eating through it;
- a member cannot tell what is shared, or cannot switch it off in one step;
- paying for the plan ever reads as owning her data.

## Decisions

| # | Decision | Source |
|---|---|---|
| D1 | Monitoring requires the member's explicit consent, revocable at any time | Owner |
| D2 | One app. Family members log into the same app and see a family area inside it | Owner |
| D3 | Monitoring is part of the paid plan. No freemium | Owner |
| D4 | A family member can pay for a relative's subscription | Owner |
| D5 | Someone paying for several relatives gets one bill (a family plan) | Owner |
| D6 | The member owns her account and data. Paying never grants access | Owner direction, wording is the agent's |
| D7 | All four value ideas are wanted: understand her, do small things for her, train alongside her, practical help | Owner |
| D9 | A gifted year carries the same 7-day free trial | Owner |
| D10 | Sign-in offers Apple, Google and email link. Family plan price and seats are decided later | Owner |
| D8 | Build order: foundation, understand, do things, train alongside, practical help | Agreed in conversation |

## How it works

### Accounts and roles

- Every person has their own account and login.
- A **circle** is a group attached to one subscription. It has one **payer** and up to a
  fixed number of **members**.
- A person in the circle has a role per relationship: *member* (receives support,
  has her own coach and data) or *supporter* (looks out for a member). One person can
  be both, for different people.
- The payer is not necessarily a member or a supporter. **Guess:** a payer can use the
  app with no health profile, only to pay and invite.

### Consent and sharing

1. A supporter sends an invite to a member (link). **Guess:** a member can also add a supporter herself.
2. The member sees a plain screen: who is asking, what they would see, and "Share" or "Not now".
3. Sharing is per supporter, with separate switches for each item in the overview.
4. One switch removes a supporter's access. It takes effect at once and nothing past that moment is shared.
5. Her coach tells her when something is shared ("Sam can see that you trained this week").
6. Consent is recorded with time, supporter, and exactly what was agreed. Withdrawal is recorded too.

### What a supporter can see (the overview)

Shareable items, each off until she turns it on: sessions done this week, streak, and a
gentle "quiet week" signal. **Guess:** the quiet-week signal is derived and never shows
why. Never shareable: weight, goal weight, food logs, symptoms, allergies, cycle or
stage answers, coach conversations, free text.

### Paying

- Anyone can pay for a plan. A family plan covers several members on one subscription
  with one bill (D5). **Open:** the number of seats and the price.
- Trial: the 7-day trial from the pricing spec applies once per account ever, and a gifted
  year carries it too (D9). **Open:** how this works for a family plan in the same subscription
  group, and whether the store lets a subscription be bought for another person at all: Apple has
  no native subscription gifting, so this likely needs offer codes or a web purchase, which the
  steering rules limit. Check before building (SS-0018).
- If the payer stops paying, members keep their accounts and data and get a grace
  period to subscribe themselves or take over the plan. **Guess:** 30 days.
- Lifetime stays a one-off purchase for one person and has no family version.

### Entry point

The welcome screen asks who the app is for: "For me" or "For someone I love". The
second path is short: names, how it works, payment, invite. The supporter never sees
the member's health questions, which she answers on her own phone. When she opens an
invite her onboarding starts warmly ("Sam got you this") and sharing is its own step.

## The four value areas

| Area | What the supporter gets | Depends on |
|---|---|---|
| Understand her (SS-0014) | Short, kind guides: what she may be going through, how to help without nagging | The circle (foundation) |
| Do small things (SS-0015) | Send a cheer her coach delivers; suggest a call or walk with a starter drawn only from shared items | Sharing settings |
| Train alongside (SS-0016) | One shared weekly goal and a light plan of their own, no leaderboard, no weight | Core planner |
| Practical help (SS-0017) | Shared shopping list for her meals; gifting groceries | Meal planner (spec: family meal mode waits for a stable planner) |

## Safety and privacy

- This is health data and PII. Use only fake data in code, tests and screenshots. See
  [data handling](../business/data-handling.md).
- Sharing health information with a third party needs a lawful basis. Under GDPR and
  UK GDPR that means explicit consent for special-category data, which this design
  collects and records. US state health-data laws point the same way. A data-protection
  review must pass before launch (SS-0018). This document is not legal advice.
- The app is for adults. Set 18+ in the store listing and gate purchase on date of birth.
  A teenager buying a gift is a separate question for the review.
- Apple treats covert monitoring as stalkerware. The consent step, the visible
  coach notice and the one-step off switch exist to meet that, and must not be removed.
- The spec's safety rules (section 7) apply: nothing in the circle may encourage
  restrictive eating or weight-focused pressure.
- Analytics and crash tools must not receive the overview items or consent content.

## Constraints

- Shared subscription group for store plans (pricing spec 1.4); a family plan must fit it.
- Features never import each other; sharing logic belongs in SSCore with tests first, views stay thin
  (see [iOS architecture](../architecture/ios.md)).
- A backend is needed (accounts, circles, consent log). None exists yet. **Open:** build
  versus buy, region, and retention periods.

## Open questions for the owner

1. Seats per family plan and the price, and how the one-trial rule applies (D5).
2. Can a member invite her own supporter, or only the reverse?
3. Does a payer without a profile use the app at all, or only a web page?
4. Retention: how long are consent records and overview data kept after leaving a circle?
5. Which supporters can be of what kind (children only, any relative, friends)?

## Left to the builder

Screen design, copy, the data model, notification wording, and how the "quiet week"
signal is derived, within the rules above. Record any new decision here or in an ADR.

## Build order and tickets

| Step | Ticket | Notes |
|---|---|---|
| 0 Foundation: circle, consent, family plan, "for someone I love" path | SS-0013 | Blocks everything below |
| 0b Legal and data-protection review, age gate | SS-0018 | Runs alongside; must finish before launch |
| 1 Understand her | SS-0014 | Mostly writing; ships soon after step 0 |
| 2 Do small things | SS-0015 | Needs sharing settings |
| 3 Train alongside | SS-0016 | After the core planner |
| 4 Practical help | SS-0017 | After the meal planner |

This sits after the member onboarding, planner and coach in the roadmap: the circle
is worth building around a product people already use.
