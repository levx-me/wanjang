# Choosing structure: opening type × audience

No fixed templates. Pick the **opening type** from the conversation, then shape depth and
vocabulary by audience. Say which type you picked in the reply. The page is one column, read top
to bottom; each section has an `.eyebrow` numbered noun label ("2 · Seats"), an h2 that is a
short question or claim, and its point as the first sentence.

## The three openings

**Story** — design, proposal, explainer, plan, how it works. Evidence first, conclusions after.
1. `.eyebrow` line (who, status, date, version) → h1 → `.lede` (what this is, ends with the
   reading order).
2. One `.basis` line: the status tags the page uses (at most three) and the baseline the numbers
   rest on.
3. `.figures`: 0-4 numbers a decision rests on; none is fine.
4. `.readorder`: the sections in reading order, one line each.
5. Sections. Each is evidence (text, one data-shaped picture, a worked example), then its
   conclusion in a `.conclude` box.
6. Last section: **Decide**, one `.decide` block per decision. Leave it out when the reader has
   nothing to decide; list open questions nobody is asked to answer yet as a short `ul.notes`.
7. `.appendix`: long tables, sources, method, configuration, developer detail.

**Conclusion-first** — review / audit results, status reports, incident reports. The reader
wants the verdict.
1. h1 = the answer (one sentence). Status tag and date in the `.eyebrow`.
2. One `.basis` line.
3. Exactly three conclusions, each at most two short sentences.
4. The `.decide` block(s), when the reader must decide.
5. `.figures`: 0-4 numbers.
6. Sections of evidence, each with its `.conclude`. `.appendix` last.

**Decision** — the page exists to get one to three answers from the reader (an approval, a
choice between options, a go / no-go).
1. h1 = the question, or the recommended answer, in one sentence.
2. `.lede`: what we need from you and by when, what we recommend and the one reason, what
   happens if nobody answers. Someone who reads only this part still decides correctly.
3. One `.basis` line with the one main caveat.
4. One `.decide` per decision, at most three. More decisions are more pages.
5. At most four sections of reasons and evidence, each heading stating its conclusion.
6. `.appendix`.

Nothing else goes before section 1: no pin list, no row of cards, no whole-structure picture. A
decision is written once, as its `.decide`; a later section that mentions it links to `#d1`.

## Audience dials

| Audience | Vocabulary | Depth | Keep | Drop |
|---|---|---|---|---|
| Non-developers (product, operations, management) | everyday words; at most 3 unfamiliar terms on the whole page, each explained once by what the reader does or sees | outcomes, timing, risk, cost | before/after, what changes for people, limits, worst case, one worked example, the decision | code, file names, commands, field names, versions, tool and library names the reader does not choose between: all to the appendix |
| Frontend developers | screens, states, values on screen | which call feeds which screen, empty/edge states, units, refresh | value → UI tables, edge cases, one small code snippet if it prevents a bug | server internals, database layout |
| Backend developers | system terms OK | data flow, boundaries, atomicity, failure handling, ops | a small structure diagram when structure is the point, sequence, invariants | UI copy |
| Whole team | plain first, technical detail in `details.more` and `.appendix` | why + what changed + who must act | key numbers, action list per role | deep internals in the main flow |
| External partners | product terms, no internal names | what they can rely on, how to integrate | guarantees, flows at their boundary, limits | internal hostnames, service names, team process, unreleased plans |

Config values and developer detail go to `.appendix` for every audience; for developers the
appendix is simply bigger.

## Section backbones (adapt, reorder, skip freely)

These are story-type section orders; for the other openings, the same sections follow the
opening.

**New feature** — what the user can now do → how it goes for one real case (worked example) →
edge cases and limits → what is not included → decide.

**Fix or change** — what was wrong, what is true now → before vs after (`.pair`) → why it
happened, in one section → what changes for the reader → how to verify.

**Infrastructure and operations** — what the setup is for → the few parts and who owns them (a
small diagram only if structure is the point) → a request followed through → where secrets and
permissions live (by role, never values) → failure and worst case → checklist.

**Plan or decision** — the problem in reader terms → evidence → the options as a `.decide` (one
real numeric example followed through each option) → phases. Use the Decision opening when the
reader must answer.

**Incident** (conclusion-first) — impact, status → `.timeline` → cause → what was done → what
prevents a repeat → open follow-ups.

**API usage** — what the API lets you build → common rules (units, auth, errors) → one section
per use case with a worked call → caching / freshness. Meaning and usage in the body; exhaustive
field lists stay out (link to reference docs).

**How it works** — the one rule in plain words → a worked example → scenarios → safeguards →
operations.

## Length

**Non-developer page, counted:** the top and the body (appendix excluded) read in about 5
minutes, and hold at most 4 sections plus the decisions. Reading time = words ÷ 200 per minute
for space-separated languages, or characters ÷ 500 per minute for Chinese, Japanese and Korean
(starting values, to calibrate by reader tests). `self-check.md` has the counting command. Over
budget: move evidence, long tables and method to the appendix, or cut.

A developer guide: as long as the use cases need, with detail folded into `details.more` and
`.appendix`. Per section: 1-2 new terms at most. A section with no number, picture, table or
worked example is probably prose that belongs in another section.
