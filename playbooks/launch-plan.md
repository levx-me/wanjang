# Launch plan: from readiness gate to post-launch follow-up

> Sources: [coreyhaines31/marketingskills launch, emails](https://github.com/coreyhaines31/marketingskills) (MIT), [anthropics/knowledge-work-plugins marketing campaign-plan, email-sequence](https://github.com/anthropics/knowledge-work-plugins) (Apache-2.0) · Written 2026-11-04 · Applies to: any

**Use when:** planning how a product, feature or site gets announced and followed up. This playbook plans; it does not position or write final copy. Read `positioning` first (it creates `docs/product-context.md`); assets are then written through `marketing-copy`; `seo-basics` covers the search part of a launch.

## Crew procedure
- **Scout:** reads `docs/product-context.md`, the repo (what actually ships, changelog, pricing page), and public pages of the product and 2-3 comparable launches. Output: facts with URLs, gaps list.
- **Planner (opus):** runs the readiness gate, picks phases and channels, writes the campaign brief and dated checklist to `docs/launch/<name>-plan.md`. Unknown audience size, budget, dates, past results = Assumptions, listed for the user.
- **Builder (opus, copy that ships):** writes each asset named in the brief via `marketing-copy`, one file per asset in `docs/launch/assets/`. Never invents quotes, numbers or customers.
- **Designer:** only for assets the brief marks must-have (screenshots, demo, banner).
- **Checker (fresh context):** runs the rubric below against the plan and each asset; a reader who has not seen the plan answers "what is it, who is it for, what do I do next" from the announcement alone.
- Label claims Fact (URL), Inference or Assumption. If `docs/product-context.md` is missing, step one is to create it or list its gaps.

## 1. Readiness gate
Do not schedule an announcement until every line is yes. A failed line becomes the first task, not a footnote.
- **Product ready:** one clear job done well, a whole experience for that job (no visible stubs), something a target user would choose over doing nothing. Two ways to fail: polishing forever (nobody learns it exists) and adding scope forever (the date keeps slipping). Cut scope to the smallest complete version and ship.
- **Context file:** `docs/product-context.md` exists with audience, problem, alternatives and proof.
- **One promise:** a single sentence a stranger can repeat. If the plan needs "and also", pick one.
- **Tracking:** the launch page, signup and first key action are measurable, with a baseline, before day one. Which numbers matter is decided now, not after.
- **Support path:** a named place where questions and bug reports land, and a named person who answers within a stated time. Onboarding works for someone who never talked to the team.
- **Fallbacks:** site holds a traffic spike; pricing and legal pages exist; rollback is known.

## 2. Phases (stop at the earliest one that fits the product)
1. **Private:** a handful of friendly users, one by one. Goal: the core works, usability gaps found. Demo-able is enough.
2. **Alpha:** landing page plus waitlist; invite individually; product runs in production. Goal: first outside validation and a list.
3. **Beta:** teasers about the problem solved; invite the list in waves; label it beta. Goal: broader feedback, early proof.
4. **Early access:** show screenshots and short demos; collect usage numbers and interviews; invite in batches (about 5-10% at a time) or all at once under the early-access label. Goal: confirm it holds at scale, firm up the message with real words from users.
5. **Public launch:** open self-serve signup, start charging if planned, announce everywhere in the plan, then follow up. Goal: reach and conversion into owned channels.
A small feature or tool can collapse phases 1-4 into one private round; say so in the plan. Updates after launch: major = full campaign, medium = targeted email or in-app note, minor = changelog only.

## 3. Channels: owned, rented, borrowed
- **Owned** (email list, site, blog, docs, in-product): compounding, no algorithm. Start with one or two. Everything else points back here.
- **Rented** (social, app stores, video, forums, directories): fast reach, unstable. Pick one or two where the audience already is; every post carries a path to an owned channel.
- **Borrowed** (guest posts, podcasts, newsletters, partners, creators, reviewers): other people's audiences. List who the audience already trusts; pitch something useful to them, not a favour. Convert the attention into owned contacts.
Choose by where the audience is, not where the team is comfortable; effort and lead time go in the brief. Paid is an option only with a budget the user states.

## 4. Email sequence logic (any tool)
One email, one job, one action. Value before ask. Stop sending to anyone who has done the action.
| Sequence | Purpose | Trigger | The one action | Exit |
|---|---|---|---|---|
| Welcome | Deliver what was promised, set expectations | Signup or waitlist join | Take the first step in the product (or confirm interest) | Action done |
| Activation | Get to the first real result | Signed up, key action not done after 1-2 days | Complete that one key action | Action done |
| Nudge | Unstick people who started and stalled | Partial progress, then silence for a set period | Resume at the exact step they left | Resumed or sequence ends |
| Win-back | Learn why they left, show what changed | Long inactivity, expired trial or cancel | Reply with the reason, or return | Returned, replied, or unsubscribed |
Rules: 3-7 emails for welcome/activation, 3-4 for win-back; first email immediate; spacing 1-2 days early, wider later; skip anyone in another active sequence or who contacted support recently; one-click unsubscribe; send in local time. Every email has a timing, a condition, a subject that stands alone, and a plain-text version. Benchmarks vary by list and industry: treat any rate as an Assumption until measured on the user's own data.

## 5. Campaign brief template
Save as `docs/launch/<name>-brief.md`.
```
Goal:      one measurable result, date-bound (Assumption if the user has not set it)
Audience:  [role] who struggles with [pain], wants [outcome], found via [channels]; buying stage
Message:   core promise (one sentence) + 3 supporting points, each with a proof point or marked Assumption
Channels:  owned / rented / borrowed; why each; effort low-med-high; owner
Assets:    name, type, must-have or nice, who writes, due date
Timeline:  milestones worked back from launch day; dependencies (page live before any send)
Metrics:   one primary with a target, 3-5 secondary, where each is read, review dates
Risks:     2-3 (timing, audience mismatch, channel flop, outage) each with a mitigation
Budget:    stated by the user or "none"; production vs distribution; 10-15% contingency
```
Leave about 20% of calendar slots open for reacting to what happens.

## 6. Prioritising
Use ICE (impact, confidence, ease; 1-10 each, multiply) for a short list of launch tactics. Use RICE only when reach can be estimated from real numbers; otherwise it is invented precision. Confidence scores of unmeasured items are Assumptions.

## 7. Checklist (planner fills dates; all send/post items belong to the user)
**Before:** readiness gate passed; brief approved; landing page and capture live; tracking verified; onboarding tested by someone new; assets done and checked; borrowed-channel pitches drafted; support path staffed.
**Launch day:** announcement email; post/page published; social and directory submissions; in-product notice; someone watching replies and errors.
**After:** welcome and activation sequences running; follow up with everyone who engaged; announcement in the next regular roundup; update site pages; collect feedback; metrics review at the dates in the brief; decide the next launch moment.

## Quality bar / rubric
- Gate has a yes/no per line with evidence; no "assumed ready".
- Brief has every field; goal is measurable and dated; every number is sourced or marked Assumption.
- Each email has trigger, one action, exit and timing; no invented quotes or customers.
- Every dependency is ordered (page before send, tracking before traffic).
- Every outward step appears in "Only the user can do" with a date.
- Reader test passes on the announcement alone.

## Only the user can do
The crew drafts; the user performs every one of these, on a dated checklist the planner provides (`YYYY-MM-DD | step | owner=user | done?`): publish the page or post, send any email, submit to directories or platforms, pitch or contact creators, partners, press or customers, spend on ads, set or change live prices, run user interviews, confirm audience size, budget and dates, approve claims about customers and results, and staff launch-day replies.

## Go deeper
- coreyhaines31 `launch`, `emails`: `claude plugin marketplace add coreyhaines31/marketingskills` then `claude plugin install marketing-skills@marketingskills` (MIT). The repo's `tools/` scripts read vendor API keys and some can send email or touch ad accounts; do not run them without the user's say-so.
- anthropics `campaign-plan`, `email-sequence`: `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install marketing@knowledge-work-plugins` (Apache-2.0). Connector parts are vendor-specific; skip them.
