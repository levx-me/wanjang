# Product discovery: customers, jobs, opportunities

> Sources: [wondelai/skills mom-test, jobs-to-be-done](https://github.com/wondelai/skills) (MIT), [phuryn/pm-skills opportunity-solution-tree, interview-script, summarize-interview](https://github.com/phuryn/pm-skills) (MIT), [anthropics/knowledge-work-plugins synthesize-research](https://github.com/anthropics/knowledge-work-plugins) (Apache-2.0), method only from [deanpeters/Product-Manager-Skills voice-of-customer-miner](https://github.com/deanpeters/Product-Manager-Skills) (CC BY-NC-SA 4.0, no text reused) · Written 2026-11-04 · Applies to: any

**Use when:** deciding what to build or who it is for, before writing specs or copy: learn what customers struggle with, what they use today, and which problem is worth solving. Not for positioning, messaging or pricing (read `positioning` first for `docs/product-context.md`, then come back here for evidence), and not for testing a built feature (`test-writing.md`). Its output, a discovery summary, is what the planner turns into acceptance criteria.

## Crew procedure
1. **Read** `docs/product-context.md`. Missing and needed: create it with the `positioning` playbook, or list the gaps for the user. Then ask the user the decision this discovery informs; no decision, no discovery.
2. **Scouts (parallel, sonnet)**: one on customers of the product or segment (VoC mining), one on competitors and alternatives (what people use today, incl. doing nothing). Each returns a note with labelled claims and URLs, saved to `docs/discovery/raw/<topic>-<scout>.md`.
3. **Planner (opus)**: writes the job statement, the interview script, the opportunity tree and the summary (below) in `docs/discovery/<YYYY-MM-DD>-<topic>.md`. Does not invent what is unknown.
4. **User** runs the interviews (see Only the user can do) and pastes transcripts back; the planner scores and folds them in, then revises the summary.
5. **Checker** (fresh agent) runs the rubric at the end. The planner then turns the summary's "Decision and acceptance hints" into acceptance criteria.

## Label every claim
- **Fact**: sourced (URL, transcript line, number with date). Verbatim quotes are Facts only with their URL.
- **Inference**: reasoned from named Facts. Say which ones.
- **Assumption**: not known. Goes on the list the user sees; each gets "how to test it".
Never invent a customer, a quote, a count or a rating. "Unknown" is a valid answer and shorter than an invention.

## Job statement (JTBD)
People hire a product to make progress in a situation; demographics do not predict it, circumstances do.
- Form: **When** [situation], **I want to** [progress], **so I can** [outcome]. It names no product and no solution. Jobs outlast solutions.
- Cover three sides, each with evidence or marked Assumption: **functional** (what must get done), **emotional** (how they want to feel), **social** (how they want to be seen).
- Map the **four forces** of a switch: **push** (what is wrong now), **pull** (what the new thing promises), **anxiety** (fear it will not work, cost of learning), **habit** (comfort with the current way). Change happens when push + pull beat anxiety + habit. Most products only add pull; look hardest at anxiety and habit.
- List the real alternatives for the job, including workarounds (spreadsheet, a person, a shrug). Not using anything is often the main rival.

## Voice-of-customer mining (scouts, public web only)
1. **Search plan first** (3 lines in the note): whose voice, which sources, how you separate what people said from your reading of it.
2. **Sweep** review sites, app stores, Reddit and practitioner forums, community boards, issue trackers and public support threads, comparison and "alternative to X" threads. Use plain web search and fetch; keep date and URL for each item.
3. **Bias per source** (write it next to the source): review sites skew angry or incentivized; app stores skew to update anger; vendor communities skew loyal; Reddit skews vocal and technical; "alternative to" threads skew to people already leaving.
4. **Capture verbatims**: short, exact, with URL and date. Quote marks mean copied text. Paraphrase goes without quote marks and is an Inference.
5. **Theme by need, not feature**: "export is broken" becomes "cannot get my data where my team works". Name each theme in 4-8 words, solution-free.
6. **Honest frequency** per theme: *recurring* (several independent sources/threads), *concentrated* (one thread or one author), or *isolated but vivid*. Give counts and the window. One articulate ranter is not a theme.
7. **Switching triggers**: what pushed people off a product, what pulled them to another (feeds the four forces).

Thin public footprint (new or niche market): say so and lean on interviews. Close with 3 opportunity hypotheses (as problems) and 3 assumptions to test. Public voice is a hypothesis source, never a verdict.

## Interviews: the agent writes, a human runs
The agent never talks to customers. It drafts the script, then scores what comes back.

**Three rules.** (1) Talk about their life, not your idea; do not pitch. (2) Ask about specific past events, not generics or the future. (3) Talk less; they should speak about 80%. A question fails if it gets "yes" whatever the truth. Good questions can kill your idea.

**Bad data to deflect**: compliments ("great idea"), fluff ("I usually", "I would", "I might"), unrooted ideas (feature requests with no story). Answer with: what do you do today, when did it last happen, show me.

**Script shape** (30-40 min): opening (learning, not selling; permission to record) · context (role, a normal week) · the story (the *last time* X happened: first thought, what was going on, what they tried, who they asked, what they chose, what scared them, how it went) · pains and workarounds · what they pay or spend now · wrap-up (anything I missed? who else should I talk to?) · **the ask**: one commitment that costs them something (time, an intro, a deposit), decided before the call.

**Question bank** (past tense, specific):
- Tell me about the last time you [did the job]. What happened right before?
- What did you try first? What else? Why did you stop?
- What is the hardest part? What does it cost you (hours, money, embarrassment)?
- What are you using for this now, and what do you do around its gaps?
- Have you looked for something better? What did you find, what stopped you?
- Where does the money for this come from? Who else has a say?
- What were you afraid might go wrong when you switched, or why have you not?
- Who else should I talk to?
Avoid: "Would you use...", "Do you think...", "How much would you pay for...", anything naming a solution or benefit.

**Rubric for transcripts the user pastes (score out of 7, 1 point each)**: talked about their life; concrete past facts; a commitment obtained; they spoke most of the time; something learned that could change the plan; beliefs updated; facts separable from opinions. For each failed row quote the line and give the better question. Then summarize: date, role, current solution, what they like, problems (job, outcome wanted, importance, satisfaction), surprises, action items. Facts and interpretation in separate columns. Tag every quote with participant type, not name.


## Opportunity tree (lean)
- **Outcome**: one measurable result for this discovery (from the decision in step 1).
- **Opportunities**: 3-7 customer problems, written from their side ("I struggle to..."), from VoC and interviews. Not features.
- **Score**: importance x (1 - satisfaction), both on 0-1. Importance and satisfaction come from evidence (frequency, intensity, workarounds, current alternatives); unevidenced numbers are Assumptions and shown as such. Focus on the top 2-3.
- **Solutions**: at least 3 per focus opportunity, different in kind (not three versions of one idea). Do not let the first idea win.
- **Experiments**: 1-2 cheap ones per promising solution: hypothesis, method, metric, pass threshold set beforehand. Prefer tests where the customer risks something (signs up, replies with data, pays a deposit, gives an intro) over opinion polls. The crew may draft them; the user runs them.

## Synthesize and triangulate
- Code every observation (behaviour vs stated attitude; context; intensity cues like emotion, frequency, workaround effort). Group into themes; keep outliers visible.
- **Triangulate**: a finding stands on 2+ independent sources or methods (VoC, interviews, analytics, competitor facts, the user's own data). One source = hypothesis, label it Low confidence.
- **Conflicts**: list every place sources disagree (e.g. reviews say price, interviews say trust), check whether they measure different people or moments, and report both. Never silently pick one.

## Output: `docs/discovery/<date>-<topic>.md`
1. Decision this informs; sources used and dates; sample sizes.
2. Job statement(s) with three sides and four forces; alternatives.
3. 5-8 findings (statement, evidence with URLs, frequency, impact, confidence), behaviour weighed above stated preference, then conflicts, then opportunity tree with scores.
4. Assumptions list for the user, each with a test.
5. **Decision and acceptance hints**: the recommended opportunity, who it is for, what "solved" looks like in observable terms (the planner turns each into a testable acceptance criterion), what is out of scope.
6. Next experiments and interviews, in order.

## Quality bar / rubric
- Every claim is labelled Fact/Inference/Assumption; every Fact has a URL, transcript reference or dated number.
- Each quote appears at its source (spot-check three by fetching the URL); none is paraphrased inside quote marks.
- Job statement names no product; has functional, emotional, social sides and all four forces, or says which are unknown.
- Each VoC source has a stated bias; each theme states frequency as recurring, concentrated or isolated, with counts.
- Themes are needs, not feature names.
- Tree has one outcome, 3-7 opportunities, scores shown with their basis, 3+ solutions per focus opportunity, 1-2 experiments each with a threshold.
- Conflicts section exists (or says none found, and why that is plausible).
- Interview scripts contain no leading question, pitch or hypothetical; each has an ask.
- Assumptions are listed for the user; no invented customers or numbers.
- Summary ends with acceptance hints the planner can use without reading the raw notes.

## Only the user can do
- Recruit and run the interviews, ask for the commitment, and paste transcripts back. The crew does not contact anyone.
- Post in communities, send surveys, or message customers.
- Share private data (support tickets, analytics, sales notes) the crew cannot reach.
- Decide which opportunity to bet on; run the experiments with real customers; set any price.

## Go deeper
- wondelai mom-test + jobs-to-be-done (MIT): `claude plugin marketplace add wondelai/skills` then `claude plugin install product-strategy@wondelai-skills`. Their `references/` hold question patterns and case studies.
- phuryn opportunity-solution-tree, interview-script, summarize-interview (MIT): `claude plugin marketplace add phuryn/pm-skills` then `claude plugin install pm-product-discovery@pm-skills`.
- anthropics synthesize-research (Apache-2.0): `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install product-management@knowledge-work-plugins`. It can read connected tools (analytics, support); connect only what you intend.
- deanpeters voice-of-customer-miner (CC BY-NC-SA 4.0, non-commercial; this playbook uses the method only): `claude plugin marketplace add deanpeters/Product-Manager-Skills`, then install the plugin named for the skill. Both phuryn and deanpeters name their marketplace `pm-skills`; check each README before adding.
