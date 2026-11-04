---
name: brief
description: Write a brief a person who does not code can read in minutes and answer (a decision brief, an approvable spec, a progress update, or what changed since they last read), and pair each decision in it with one AskUserQuestion. Use when the user or an orchestrating agent needs a non-developer to decide, approve or catch up on agent work. /wanjang:brief [decision|spec|update|changes] <subject>
argument-hint: "[decision|spec|update|changes] <subject>"
---
Arguments: $ARGUMENTS

# brief

Turn agent work (a plan, a spec, a run's progress, a revision) into one document that its owner,
who does not write code, can read alone in a few minutes and then approve, reject, answer or
comment on. Deciding needs plain words; implementing needs precise ones: the precise detail
stays, in the appendix or a separate developer document.

**Reader.** Owns the outcome, knows the goals, does not know the technical context, this
conversation's working names or the tools. Reads alone, decides alone, often on a small window.

**Not for:** documents read by machines, legal text, notes between experts, developer guides,
explainer pages about finished work (that is visual-doc). This skill owns the words, the
document shapes, the decision block and the checks; visual-doc owns the look.

**When.** On request (`/wanjang:brief`), or when an orchestrating agent (the PM) reaches a
decision point or a reviewable state and its workflow calls for a document. Never start one
on your own initiative otherwise.

**Language.** Write in the user's language (the conversation's, or the one the caller names).
The rules hold in every language; the sentence checks have an English and a Korean track.

## Files

- `${CLAUDE_PLUGIN_ROOT}/skills/brief/references/writing-rules.md`: every writing rule with its
  check (structure, decisions, words, honesty, tables, length, language tracks), the passes, and
  the grep commands. Read it before writing.
- `${CLAUDE_PLUGIN_ROOT}/skills/brief/references/render.md`: the HTML markup (the `.decide`
  block, the top block, the receipt) and the Markdown form. Read it before rendering.
- `${CLAUDE_PLUGIN_ROOT}/skills/brief/references/reader-test.md`: the rubric R1-R10, the
  fresh-agent reader test, the real-person variant and the starting values to calibrate.
- The look is visual-doc's: `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/assets/skeleton.html` and
  `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/assets/base.css`, plus its
  `${CLAUDE_PLUGIN_ROOT}/skills/visual-doc/references/components.md`. Use them in place; never
  copy them into this skill.

## Workflow

1. **Pick the type and the form.** Type from the arguments or the caller (A-D below); if the
   user invoked it and the type is unclear, ask once with AskUserQuestion. Form: an **HTML
   page** by default; **Markdown** when the reader works in a doc connector the session has (a
   living document with comments). Both come from the same content.
2. **Before writing, keep two notes** beside the document (same folder, not shown to the
   reader): a **facts list** (every number, unit, date, count word, named amount, baseline, limit, risk, hedge and
   decision taken from the source, each with where it came from) and an **answer key** for R1-R9
   (`reader-test.md`). Source = what was decided, built or found in this conversation, the run's
   files and what the caller hands over. Anything else is not a fact: leave it out or mark it.
3. **Write the content** (the types below, the rules in `writing-rules.md`): top block, at most
   four body sections, at most three decision blocks, the appendix.
4. **Render** (`render.md`). Files go in the run folder when a wanjang run called you, else in
   the scratchpad under `brief/<slug>.html` or `.md`.
5. **Passes, in order, each separate:** tells pass (remove the habits of machine prose; it may
   not add or drop a fact), mechanical checks (`writing-rules.md`: the commands and the D8 consistency check), then the
   **reader test** by a fresh agent (`reader-test.md`). Fix the document, never the key; at most
   two loops, then return with what still fails. R1-R4 failing blocks publishing.
6. **Publish or hand over.** HTML: publish as visual-doc does when the session has the Artifact
   tool (visual-doc's publish step, including loading artifact-design first), unless the caller
   asked for a local file; otherwise return the path. Markdown: write it into the doc connector,
   scaffold first (`render.md`).
7. **Ask** each decision with AskUserQuestion, paired as below, after the document is out and
   with a link to it. A subagent cannot ask the user: return the questions ready to pass to
   AskUserQuestion as they are, as JSON `{"questions": [{"header", "question", "multiSelect",
   "options": [{"label", "description"}]}]}` plus the document's path, and the session that asks
   writes the answers back.
8. **Write the answer back** into the document as its receipt and republish the same path.

## Every document: one frame

**Top block → body (at most 4 sections) → appendix.** Two levels only: a section and the blocks
in it (a decision block is a block, not a level; the table of contents lists sections, never
blocks). The appendix is the only fold: no fold inside a fold, no chain of links.

The **top block** stands alone: someone who reads only this part still decides correctly.
- h1: the answer or the question, one sentence.
- **What we need from you:** the decision (or approval) and the deadline, or "no deadline".
- **We recommend:** the option, with one reason.
- **If you don't answer:** what happens, and when. When choosing do nothing differs from not
  answering, add **If you choose to do nothing:** what happens.
- One status word if the type has one; under it one line with the basis and the single main caveat.

### A. Decision brief (one decision per document)
1. Top block.
2. **The decision block** (below). In HTML it sits in the opening, under the top block.
3. **Why now:** what changed and what it means for the reader, 2-4 sentences.
4. **What happens next** for each choice, one line each, including when it stops being undoable.
5. Optional: 3-5 questions the reader will likely ask, each answered in more than one line.
6. Appendix: evidence, method, sources, developer detail.

A changed decision is a new dated brief that names the one it replaces; the old one is never
edited again.

### B. Approvable spec
1. Top block: "Approve this to start building X. It takes about N. Later you can still change Y,
   not Z."
2. **What you will be able to do:** 2-5 claims, each one sentence (about 12 words, a starting
   value) the reader can answer yes or no to, split by what the person sees or does, never by
   file or component.
3. **What it will not do**, each with its reason.
4. **How you will know it works:** checks the reader can try themselves ("add a booking; it
   appears in the calendar"), instead of acceptance criteria or priority labels.
5. **Open questions:** who answers each and whether it blocks the start; blocking ones become
   decision blocks.
6. **Cost and time**, and the main risk in one sentence: what could go wrong, how badly, how
   likely, what we will do about it, what we need from you.
7. Appendix: components, files, data, commands.

Verdict: **Approve / Request a change / Cancel**.

### C. Progress update
1. Top block: one status word (on track, at risk, stuck), and its reason if it changed since the
   last update.
2. **Done, Next, Problems:** 1-3 sentences each, outcomes rather than tasks.
3. **Decisions needed:** a link to each decision brief, or an inline decision block if small;
   never a table of decisions.

No verdict; comments only. A problem that needs an answer gets a decision brief.

### D. What changed since you read
1. Top block: one sentence on what changed and why. If the change touches scope, cost or a
   decision already made, the first line reads **"This needs your approval again"** and the
   document carries the verdict again.
2. **Your comments:** each comment the reader left, with what was done: changed, answered, or
   not done and why.
3. **What changed:** the changed parts in document order, each linked in place; unchanged parts
   are not repeated.
4. The host may offer views (with changes marked, as it is now, as it was); write the content, the
   host draws the views. Before revising, save the current version under a dated name and never
   edit that copy; approval applies only to the latest version.

Once a decision is answered or a spec is built, the same document becomes its **receipt**: each
claim is marked done, changed or not done, with the date. That is type D applied to an approved
document, not a fifth type.

## The red line

Making a sentence plainer never changes a number, a unit, a baseline, a limit, a risk, or the
words "unverified" and "estimate". If the plain version would lose accuracy, keep the accurate
wording and split it into two sentences. The checker compares the facts list with the document;
a fact changed, added or dropped by rewording is a blocker.

## The decision block

One per decision, at most three per document. The same fields in HTML and Markdown:

| Field | Rule |
|---|---|
| `id` | short and stable (`d1`, `d2`); survives revisions; the wizard and comments use it |
| `question` | one sentence the reader can answer; `label`: at most 12 characters, the wizard header |
| `options` | 2-3 action options, then **do nothing**; each: `name` (1-5 words, in the reader's terms, never a technical noun), `changes` (one sentence: what changes for the reader), `cost`, `time`, `risk`, `undo` (yes / until a date / no). A value you do not have is written "unknown", never left out |
| `recommended` | one option, listed first; one `reason` and one `downside`, one sentence each |
| `no_answer` | what happens if nobody answers, and when; it may differ from choosing do nothing ("the work waits" vs "we go ahead with the recommendation on <date>"): state both |
| `owner`, `by` | who decides; the date, or "no deadline" |
| `answer` | after the reply: the option, the reader's comment, the date (the receipt) |

At least one real option you do not recommend; do nothing always has its cost. A document that
recommends says so; it never poses as a neutral comparison.

## Pairing each decision with one question

AskUserQuestion takes 1-4 questions per call and 2-4 options per question, allows multiSelect,
adds "Other" (free text) by itself, and limits each header to 12 characters. Hence: at most 3
action options plus do nothing, and at most 3 decision blocks plus one verdict per document.

| In the document | AskUserQuestion |
|---|---|
| Decision block `d1` | header = `label`; question = `question` word for word; options = the block's options in the same order (recommended first, with "(Recommended)" in its label; do nothing last); each description = `changes` and the cost, one line; multiSelect off (the options exclude each other) |
| Verdict (spec, re-approval) | "Approve <title>?"; options Approve / Request a change / Cancel; if comments are still open, Approve's description says how many |
| A comment on a passage | no question: comments stay in the document, anchored by block id and an exact phrase |
| Progress update | no question unless it holds a decision block |

A block with two action options gives a question with three options (recommended, the other, do
nothing); with three action options, four, the limit. Option label = the option's `name` (1-5
words), and only the recommended one adds " (Recommended)". The header (`label`, at most 12
characters) is different in every block of the document.

- Same `id`, option names and order in the document and the question.
- An "Other" answer counts as **Request a change** on that block, never as approval.
- The answer goes into `answer` and into the top block ("Decided on <date>: <option>"), and
  that decision is closed in this document; changing it later takes a new brief that replaces it.
- A comment the reader marked as blocking prevents Approve; other open comments stay open. Before
  an approval that would drop feedback the reader has not sent, say so.
- Proposed edits to text already approved are shown as suggestions to accept or reject, never
  swapped in silently. Never resolve a comment thread the reader started.

## Hard rules

- No secrets, tokens or internal addresses in the document (name a secret by its role). Scan
  before publishing; publishing distributes it.
- Never invent a number, a name, a date or a behaviour. What the source does not say is written as
  "the source doesn't say"; "not found" never becomes "does not exist".
- Revisions change only what was asked; say what else you would change and ask first.
