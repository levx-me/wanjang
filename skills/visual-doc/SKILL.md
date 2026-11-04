---
name: visual-doc
description: Turns what was built, changed, decided or planned in the current conversation into an easy-to-read explanation page, written in the user's language, in one fixed visual style (neutral ground, one warm accent, a single-column story with a numbered left table of contents, decision blocks, small data pictures, Chart.js charts, light/dark toggle) and publishes it as a private claude.ai Artifact. Use only when the user asks for it, e.g. "/visual-doc", "explain this as a page", "make this a doc", "문서로 만들어줘". Do not use for README, code comments, PRDs, test plans, wiki notes or plain chat summaries, and never generate one unasked. For a spec, a decision or a progress note that a non-developer must read and approve or answer, use the `brief` skill (/wanjang:brief) instead; it renders through this skill's design files.
---

# visual-doc

Explain a piece of work (a feature, fix, infrastructure, plan, incident, API, decision) to a
chosen reader as one page in the house style, published as an Artifact.

## When

- Run only on request: `/visual-doc`, "make this a page", "explain this as a doc", or the same
  in any language.
- After a large feature, design or plan is settled in conversation, you may offer it **once, in
  one line** ("Want this as a page?"). Do not repeat the offer and do not start without a yes.

## Workflow

1. **Ask the audience, every time.** Use AskUserQuestion before anything else, in the user's
   language: non-developers / frontend developers / backend developers / whole team / external
   partners (other allowed). Ask in the same call only if genuinely unclear: the subject (when
   the conversation covered several), framing ("as if finished" vs current state), language.
2. **Read the example** before your first page in a session:
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/assets/examples/decision-example.html` (structure,
   tone, the decision block; copy no facts).
3. **Plan the page** (in your head or scratch notes, before any markup). Read
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/references/planning.md` first; it points to
   `references/doc-types.md` (openings, backbones, audience, length) and
   `references/diagram-choice.md` (pictures) in the same folder. Every run:
   - **Pick the opening type** (`doc-types.md`) and say which in the reply: **Story** (design,
     proposal, explainer, plan), **Conclusion-first** (review results, status reports,
     incidents) or **Decision** (the page exists to get one to three answers). Nothing else goes
     before section 1: no pin list, no whole-structure picture, no row of cards.
   - **Each decision appears once**, as a `.decide` block (the question, 2-3 options and "do
     nothing", the recommended one marked, cost, time, risk and undo for each, who decides and
     by when). Decision and conclusion-first pages put it at the top, story pages in the last
     section. Anywhere else, link to it; never restate it in a table or a `.goal` box.
   - **Layout rules** (the classes implement them, never work around them): one column; a card
     only where it groups something (`.decide`, `.pair`, `.conclude`, `.tablebox`); no bento
     grid. Layout is the stylesheet's job: use the shared classes.
   - **Three status tags, only where a decision depends on the claim:** `.tag.ok` confirmed,
     `.tag.prop` proposed, `.tag.open` undecided. Closed set: never add a tag kind or relabel
     one. How well something is known (checked, from search, not found) goes once in `.basis` or
     in the appendix, never as a tag on each sentence. State the one main caveat once, near the
     top.
   - **One real numeric example** followed through the scenarios ("with 1,200 orders a day ..."),
     as a small worked table or `.steps`, so the reader sees what a number means for one case.
   - **Source** is what was decided, built, changed or planned in this conversation (plus files
     read in it). Anything not confirmed there is unconfirmed: say so in the sentence or leave it
     out. Never invent numbers, names, dates, relations or behaviour, on a picture or in text.
4. **Load the `artifact-design` skill** (the Artifact tool requires it before writing). This
   skill's frame is the existing design system: apply it; artifact-design's rules fill gaps only
   (theme structure, gutters, copy, checks).
5. **Write the page** into the scratchpad as `<scratchpad>/visual-doc/<slug>.html`, starting
   from `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/assets/skeleton.html` with **all of
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/assets/base.css` verbatim**. Read
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/references/page-markup.md` before writing (markup,
   language, icons, charts, allowed external resources, and parallel workers for a page of more
   than four sections). Every block and its markup:
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/references/components.md`.
6. **Self-check** (fix before publishing). Read
   `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/references/self-check.md` and go through every item,
   the counted ones included.
   **Then a reader review, by someone else:** start a fresh agent (`wanjang:checker`, or
   `general-purpose` if missing) with the page path, the audience, the "Writing" rules below,
   and the reader rubric and failure samples from `self-check.md` pasted in. It reads the page as
   that audience reading it for the first time, answers the rubric from the page alone, and
   returns every place it got stuck or misled (path:line, the rule, a fix). Fix all of them,
   then publish. Skip this only for a one-line edit.
7. **Publish** with the Artifact tool: `file_path` = the page, `icon` = one generic word (e.g.
   `document`, `diagram`, `api`, `plan`), `description` = one sentence saying what the page
   explains and for whom. To update later, republish the **same path** (omit `icon`).
8. **Reply** with the link, one line on audience and type, and any unconfirmed points the reader
   should check. Keep it short.

## Hard rules

- **No internal IDs**: no requirement, test or ticket codes (FR-12, UT-03, OPS-04 …) in the
  page. Describe the behaviour instead. Decision block ids (`d1`) are anchors, not text.
- **No Swagger-style dumps**: never list every field, type or parameter. Explain what a value
  means and how to use it; show only the fields a reader acts on.
- **No secrets or internal addresses**: no tokens, keys, passwords, connection strings, internal
  hostnames, private IPs, full private repo paths, signed URLs. Name secrets by role ("the
  deploy token"). Publishing distributes the page; scan the final HTML before publishing. A
  public identifier may appear shortened (`9f3c…a41e`).
- **Plain language for the chosen audience**; code identifiers stay as-is in `<code>`, and for a
  non-developer audience only in the appendix.
- **Framing**: when asked to "describe as if complete", write in finished-state present tense and
  drop progress notes; otherwise state status honestly (status tags, the date in the eyebrow).
- **Language**: the language the user writes in, unless they ask for another. Set `lang` on
  `nav` and `main`, and write every label (table of contents, theme toggle, eyebrows, the
  decision block's field names) in that language.
- **Revisions change only what was asked.** "Only the top title" changes the top title and
  nothing else; say what else you would change and ask before touching it.

## Writing

The page is read by someone who was not in this conversation. These are the mistakes that came
back on every page; check each one before the reader review.

1. **Open by type, then one point per section.** Story: the lede and reading order, evidence,
   then each section's `.conclude`, decisions last. Conclusion-first: the answer, three
   conclusions (at most two short sentences each), the decisions. Decision: the question, the
   decision blocks, then the reasons. Each section: one point, two or three supports, the rest
   folded in `details.more` or the appendix. Nothing said twice.
2. **No word the reader hasn't met.**
   - Plain word first. If a term matters, it follows once, explained by what the reader does or
     sees. At most one gloss in brackets per section; a term that needs more goes in a glossary
     fold in the appendix.
   - Term budget, counted: for non-developers at most 3 terms the reader may not know on the
     whole page; for other audiences at most 2 new terms per section.
   - Named things (products, services, people, tools) appear only when the reader decides about
     them or acts on them, with a one-line "what it is" at first mention.
   - No working names from this conversation ("path B", "option F", "the v2 plan", internal
     model or variable names): say what it is ("the plan we proposed first").
   - No empty risk words: not "risk" or "issue" alone, but what goes wrong, for whom, how much.
   - One name per concept across the whole page, matching the glossary.
3. **Numbers read at once.** Every number has its unit and what it is compared with ("$10,500 a
   month, 39% less than now"). No bare pairs like "105M / 172M". Give one representative value
   (the mean or the base case, saying which) rather than a range, and put the range in
   `<details>` if it matters. Every number in the text matches the table or calculation it comes
   from; recheck them against the source before publishing. Making a sentence plainer never
   changes a number, a limit, a risk or an "unconfirmed".
4. **Document voice.** A neutral written register in the page's language, not the chat's. The
   h2 is a short question or claim ("Who gets the first 1,000 seats?", "Left alone, it fills up
   in March"); the eyebrow above it is a numbered noun label ("2 · Seats"). In Korean, the body
   is in 합니다체 (not the chat's 해요체) and the h2 uses the same register.
5. **Small tables.** In the body at most 5 columns, 8 rows and about 6 words per cell, no
   sentence in a cell; a bigger table goes to the appendix with one sentence in the body saying
   what it shows. "Who has what" becomes a scorecard (`.sc`).
6. **A chart earns its place** (see `diagram-choice.md`): it shows a result, not the inputs; it
   uses the standard legend toggle and hover highlight; no overlapping labels.
7. **Honest.** No overstatement ("definitely", "revolutionary" without evidence); the main
   caveat is stated once near the top; a fact found wrong is corrected, not left. A page that
   recommends says so (the `.reco` option, with its reason and its downside); it never poses as
   a neutral comparison.
- **No invention**: unconfirmed points are said to be unconfirmed, or omitted.
- Not a local file by default; write it to the scratchpad only as publish input. Give a file
  only if the user asks for one.
