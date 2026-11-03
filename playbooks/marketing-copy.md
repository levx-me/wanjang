# Marketing copy: write it, edit it, check it

> Sources: [coreyhaines31/marketingskills copywriting, copy-editing](https://github.com/coreyhaines31/marketingskills) (MIT), [anthropics/knowledge-work-plugins marketing content-creation, brand-review](https://github.com/anthropics/knowledge-work-plugins) (Apache-2.0), [brand-voice enforcement](https://github.com/anthropics/knowledge-work-plugins/tree/main/partner-built/brand-voice) (MIT, Tribe AI) · Written 2026-11-04 · Applies to: any

**Use when:** writing or revising words a customer will read: landing hero, page sections, email, ad, post. For the structure and layout of a page, read `page-cro.md` too. For what to claim in the first place, read `positioning.md` first; this playbook assumes the claim exists in `docs/product-context.md`.

## Crew procedure
- **Scout** (if inputs are missing): collects customer wording (reviews, tickets, interviews the user supplies) and proof; labels each item Fact (URL), Inference or Assumption.
- **Builder** writes the copy. Use **opus** for copy that ships; sonnet is fine for internal drafts. Follows "Drafting protocol". Writes to the path the brief names.
- **Checker** (fresh context, never the builder) scores the draft with the seven sweeps and the legal flags below and returns a list of findings with location and severity.
- **QA reader test**: a separate agent reads the copy as the target customer described in `docs/product-context.md`, knowing nothing else. It reports, in the reader's words: what the page seems to offer, what confused it, what it did not believe, what it would do next. No rewriting.
- Nothing is sent, published, posted or paid for by the crew (see "Only the user can do").

## Required inputs
Read `docs/product-context.md` first. If it is missing, the first step is to create it (`positioning.md`) or list the gaps to the user. A copy task needs all six; any one missing is listed as a gap, never guessed:
1. product-context file (audience, differentiation, objections, customer language, voice)
2. goal (what the business wants from this piece)
3. channel (page, email, ad, post) and its limits
4. audience stage (cold, aware, evaluating, customer)
5. the one action wanted
6. proof available (numbers, named customers, quotes, certifications), each labelled F/I/A

Unknown numbers, customers and quotes are Assumptions. Write `[NEED: ...]` where proof is missing. Never invent a statistic, testimonial or customer.

## Diagnose the job
- **Blank or generic brief**: build the argument from the context file. Freedom on angle, none on facts.
- **A draft with a real voice**: keep its argument and vocabulary; fix buried leads, vague lines and AI tells.
- **A point edit** ("fix this headline"): change only that, plus the minimum around it, return changed lines with a one-line reason. Skip the sweeps.
State the diagnosis in one line before writing.

## Drafting protocol
1. **Decompose the message** into units: headline, subhead, CTA, each section head and body, proof lines.
2. **Lock the claim before wording.** Write one plain sentence per unit: who it is for, what they get, why believe it (proof label). If the sentence cannot be filled, the unit is a gap, not a writing problem.
3. For each unit draft two or three candidates, keep the best, fix its worst flaw, lock it. Lines already working in an existing draft start locked.
4. Assemble, read once top to bottom for flow, one idea per section.
5. Ration emphasis: one or two punchy moments per page; most lines plain and declarative.
6. Leave-it-alone test: revert any change you cannot give a reason for.

### The three-question gate (every key line)
1. Can the reader picture it (a scene, object, number)?
2. Could it be proven false? "Cuts weekly reporting from 4 hours to 15 minutes" can; "best-in-class" cannot.
3. Swap test: replace your product name with a competitor's. Does the line still read true? Then it fails.
Three yes: keep. Two: sharpen the weak one. Fewer: rewrite from the facts or mark `[NEED: ...]`.

## Seven review sweeps (the checker's rubric)
Run in order, then loop back once through the earlier ones. Each is a checkable item; report the failing line, not a score.
1. **Clarity**: a stranger can say what is offered in one sentence; no insider jargon; one idea per section; no sentence over about 25 words without reason.
2. **Voice**: matches the voice section of the context file (we are / we are not, formality, terms to use and avoid); no drift from casual to corporate; "we" never alternates with "the company".
3. **So what**: every feature line ends in a consequence for the reader ("which means...").
4. **Prove it**: every claim has proof nearby or is softened; "trusted by thousands" and "industry-leading" are failures unless sourced.
5. **Specificity**: vague verbs and adjectives replaced by a number, a time, a named thing; round numbers that look made up are suspect; what cannot be made specific is cut.
6. **Emotion**: the pain or the wanted outcome is felt in the reader's own words from the context file, honestly, never manufactured fear or fake scarcity.
7. **Zero risk and friction**: near the CTA the likely hesitations are answered (price, effort, "what if it fails", what happens next); one clear next step; no hidden cost.

## AI tells (checker fails the line; the fix is rewriting from the facts, not swapping synonyms)
- Contrast reveals: "not X, but Y" built only for drama.
- Lists of negations ("no setup, no forms, no waiting"); one real absence near the CTA is fine.
- A finished claim followed by trailing clauses that restate it.
- A question the copy answers itself, or a colon that unveils a punchline.
- Stock openers and closers ("in today's fast-paced world", "whether you are X or Y", "take it to the next level", "unlock").
- Em dashes in headlines, subjects, ads, posts.
- Filler adjectives (seamless, robust, powerful, innovative) with no fact behind them.
- More than one fragment or one list of three per section; every sentence the same length.
- Exclamation marks; tidy wise-sounding closing lines.
Read it aloud; a human ear catches the rhythm.

## Legal and claim flags (checker marks; the user or counsel decides)
Mark each as a finding with severity High/Medium/Low and the evidence needed to keep it:
- Superlatives and absolutes ("best", "fastest", "only", "guaranteed") without evidence or a stated basis.
- Comparisons to named or implied competitors without a dated, citable source.
- Numbers, savings, results: need a source, scope and time frame.
- Testimonials: need real attribution, permission, and disclosure of any payment or incentive; never composite or invented.
- Health, finance, security and privacy claims: may need disclaimers or regulatory review; flag all of them.
- Guarantees and free offers: terms must be stated and honoured.
- Text or images that look copied from another source.
A declined claim is reported with the closest supportable alternative and the evidence that would unlock the original.

## Channel templates (brief; limits are guides, check the platform)
- **Landing hero**: headline (the outcome for the reader, under about 10 words), subhead (how or for whom, one or two sentences), one CTA naming what they get ("Get my report", not "Submit"), proof line beside it. Match the headline to the traffic source.
- **Email**: subject under about 50 characters, preview text that adds rather than repeats, one idea, one CTA, plain mobile-readable body, unsubscribe and sender identity present.
- **Ad**: one promise, one proof or specific, one CTA; respect each platform's character limits and ad policies; claims pass the legal flags.
- **Post**: first line is the hook (a fact, scene or number the reader cares about); a few short points; one ask. Tone follows the platform without leaving the brand voice.

## Output format
Page copy by unit, then a short annotation per key line (the claim it carries, its proof label), 2-3 alternatives for headline and CTA with the trade-off, and a gaps list (`[NEED: ...]`, Assumptions). For a point edit return only the changed lines with a reason.

## Quality bar
- Context file read; the six inputs recorded or listed as gaps.
- Every key line passes the three-question gate.
- Checker ran all seven sweeps with line-level findings; no open High finding.
- Zero AI-tell hits; zero invented facts; every claim labelled F/I/A.
- Legal flags listed, even if empty.
- QA reader test report attached; any "I did not understand" or "I did not believe" item is fixed or accepted by the user.

## Only the user can do
Supply proof, quotes, permissions and customer language; approve legal and regulatory claims; publish, send, post, run ads, set prices; run A/B tests on the copy.

## Go deeper
- coreyhaines31/marketingskills (MIT): `claude plugin marketplace add coreyhaines31/marketingskills` then `claude plugin install marketing-skills@marketingskills` (all 53 skills; the repo also has `tools/clis` scripts that read vendor API keys and some send email or touch ad accounts: do not run them).
- anthropics/knowledge-work-plugins (Apache-2.0): `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install marketing@knowledge-work-plugins` (content-creation, brand-review) and `claude plugin install brand-voice@knowledge-work-plugins` (MIT, partner-built by Tribe AI; reads Notion, Drive and similar if connected).
