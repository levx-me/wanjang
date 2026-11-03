# Page CRO: review and build a page to convert

> Sources: [coreyhaines31/marketingskills cro, signup](https://github.com/coreyhaines31/marketingskills) (MIT), [wondelai/skills conversion-optimization, cro-methodology](https://github.com/wondelai/skills) (MIT) · Written 2026-11-04 · Applies to: any

**Use when:** building, reviewing or fixing a page whose job is one action (home, landing, pricing, signup, product). Words are written with `marketing-copy.md`; read it for the copy itself. For who the page is for and what it promises, `positioning.md` comes first and `docs/product-context.md` is read before anything here.

## Crew procedure
- **Designer** builds or revises the page to the factors below, in impact order. Owns layout, hierarchy, mobile, load. Inputs besides the context file: brand (colours, type, logo), any existing layout, and the tech stack.
- **Builder** (opus when the copy ships) owns the headline and all copy, written via `marketing-copy.md`; the designer places it and does not rewrite it.
- **Checker** (fresh context) reviews the finished page against "Factor checklist" and "Page types", returns findings in the output format.
- **QA reader test**: an agent opens the page cold as the target customer from the context file and reports, in the reader's words: what it thinks the page offers after five seconds, where it hesitated, what it did not believe, what it would click. Run at desktop and phone widths when a browser is available.
- Inputs recorded first: page type, the one action, traffic source, current numbers if any (conversion rate, drop-off), what was already tried. Missing numbers are Assumptions.
- Every finding carries an evidence label: **F** Fact (measured data, a recording, a quoted visitor; with source), **I** Inference (reasoned from facts or established practice), **A** Assumption (a guess that needs checking).

## Seven factors, highest impact first
1. **Value proposition**: in five seconds a stranger can say what this is, for whom and why it matters, in the customer's language, with the differentiator (not a competitor-swappable line).
2. **Headline**: states the core outcome, specific, matches the ad or link that brought the visitor.
3. **CTA**: one primary action, visible without scrolling, text names what they get; a clear secondary path for people not ready; repeated at decision points.
4. **Visual hierarchy**: scanning the page alone conveys the message; the important things are the biggest or boldest; images support the message; readable on a phone.
5. **Trust and proof**: attributed testimonials, real numbers, logos, reviews, guarantees, certifications, placed beside the claim and the CTA they support. Only real proof (labels F); missing proof is a `[NEED]`, never filled in.
6. **Objections**: the likely doubts (price, fit, effort, "what if it fails", timing) are answered at the point they arise, not only in a footer FAQ. Source them from the context file or real visitor words.
7. **Friction**: fields that are not needed, unclear next step, confusing navigation, surprise costs, slow load, broken mobile.

Order of work: fix the message (1-2), then the offer and proof (5-6), then the friction (3-4, 7). Better buttons do not rescue an unclear promise.

## Page types (extra checks on top of the factors)
- **Home**: cold visitor understands the positioning; a fast route for each main intent (ready to try, still researching); one dominant action, not six.
- **Landing**: headline matches the traffic source; one CTA; navigation removed or minimal; the whole argument is on the page.
- **Pricing**: plans comparable at a glance; the recommended plan is obvious; answers "which is right for me?"; limits and billing are plain; objections about cost and cancelling answered nearby. Prices shown are the user's; the crew never changes live prices.
- **Signup**: only the fields needed to start; value shown before commitment where possible; effort and what-happens-next stated ("takes about a minute"); inline, plain-language errors; no surprise steps; progress shown if multi-step; privacy wording matches reality.
- **Product or feature**: feature, then benefit, then outcome; a concrete use case or screenshot; a clear path to try or buy.

## How the roles use this
- Designer builds against factors in order and the page type list, and notes any factor it could not satisfy for lack of input.
- Checker goes factor by factor, then page-type items; each failure becomes one finding. A page passes when no factor has an unresolved high-impact finding.
- QA findings go in as F (quoted reader) and are ranked above the checker's I items on the same issue.

## Output format
Group findings in three lists; each item: **what to change**, **factor** (1-7), **evidence** (F/I/A with source), **expected effect** in plain words (e.g. "should make the offer clearer to cold visitors"; say what is unknown). Never state invented percentages or promised lifts; if a benchmark is cited it needs a URL and is labelled F.
- **Quick wins**: small, low-risk, ship now (button text, a proof line next to the CTA, a removed field).
- **High-impact changes**: larger work aimed at factors 1, 2, 5 or 6 (rewritten hero, new proof section, restructured page).
- **Test ideas**: a hypothesis written as "if we change X, then Y improves, because Z", the metric, the segment, and what result would make us keep or drop it. Prefer bold changes to meek tweaks.
Also give 2-3 alternatives for the headline and primary CTA with the trade-off.

## What to measure, and who runs experiments
- Primary metric: completions of the one action divided by visitors to the page. Pair it with a counter-metric so it cannot be gamed (e.g. signups against activation or refunds).
- Segment by traffic source and device; a flat average can hide a collapsing segment.
- Funnel steps before and after the page, to find where people actually leave.
- Qualitative sources: exit or post-signup survey, support tickets, sales calls, recordings. They explain why a number moves.
- Experiments need enough traffic, a pre-stated metric, duration and decision rule, and no peeking. With little traffic, make the change and compare before and after with an explicit revert trigger, and say it is weaker evidence.
- The crew proposes tests; the user runs them, owns the analytics, and decides.

## Quality bar
- Context file and the inputs above recorded; gaps listed.
- Every finding has factor, F/I/A label, expected effect in words; no invented numbers.
- Copy passed `marketing-copy.md` checks.
- QA reader test report attached and its confusion points resolved or accepted.
- One primary action on the page; mobile checked.

## Only the user can do
Ship the page, change live prices, install analytics, run and read A/B tests, collect survey answers and recordings, contact customers for quotes, approve guarantees and claims.

## Go deeper
- coreyhaines31/marketingskills (MIT): `claude plugin marketplace add coreyhaines31/marketingskills` then `claude plugin install marketing-skills@marketingskills` (skills cro, signup, popups; the repo's `tools/clis` scripts read vendor API keys and some touch ad accounts or send email: do not run them).
- wondelai/skills (MIT): `claude plugin marketplace add wondelai/skills` then `claude plugin install marketing-cro@wondelai-skills` (cro-methodology, storybrand-messaging); the conversion-optimization journey skill lives in the repo too, check its README for the plugin that bundles it.
