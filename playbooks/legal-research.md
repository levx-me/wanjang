# Legal research: what the law says, where, and as of when

> Sources: method from our own fetch tests of official texts (2026-11-04); cite-check round trip after the idea in WenzhuoXu/lawgent Cite Check (licence not stated, idea only); status classes after [davendra/uk-legal-skills](https://github.com/davendra/uk-legal-skills) (FSL-1.1-Apache-2.0, idea only, no text copied); `[verify]` marking after [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) (Apache-2.0) · Written 2026-11-04 · Applies to: any

**Use when:** a task asks what a statute, regulation, guidance or case says, whether it reaches a set of facts, or what its status is, in any jurisdiction. Every other legal playbook leans on this one for its citations. For clause-by-clause work on a contract read `contract-review.md`; for privacy notices and gap lists `privacy-compliance.md`; for crypto licensing, Travel Rule or sanctions scope `crypto-regulatory-scope.md`. This playbook produces research drafts, not legal advice.

## Crew procedure
- **Scout** fetches each primary source live, in the source order below, and records it in the authority table. It never cites from memory: a rule it has not reopened today is `[verify]`.
- **Builder** (opus for anything the user will rely on) writes the memo from the authority table only. A point with no row in the table is not in the memo, or is marked `[verify]`.
- **Checker** (fresh context, never the builder) runs the cite-check pass and the rubric, and recomputes every date and deadline with a second tool (`python3 -c` with `datetime`, or a calendar library), not by reading the builder's arithmetic.
- **QA reader**: a separate agent reads only the memo's question and short answer, then the authorities, and says whether the answer follows from the quoted text or reaches past it. No rewriting.

## Required inputs (the user's, never defaulted)
1. **Jurisdiction and level**: supranational, national or federal, state or province, local. If two may apply, both are listed and researched.
2. **The facts**, in the user's words, and the date they happened or will happen.
3. **The question**, in one sentence.
4. **"As of" date** for the law: today, or a past date if the facts are past.
5. Any sources the user already holds (an advice letter, a regulator's letter), labelled as theirs.

Missing any of 1-4: stop and ask. If the caller insists on proceeding, write the gap as a labelled Assumption on the first line, never silently. No home-country default: a US rule is never applied to an EU or UK question, or the other way round.

## Source order
1. **Official text**: the official gazette or journal, the legislature's or government's legal portal, the court's own site for judgments.
2. **The regulator**: its rules, guidance, FAQs, decisions.
3. **Secondary** (law firm notes, encyclopaedias, blogs, summaries): only to find a primary source. Never cited as the authority.

Translations are unofficial. Cite the original-language text and name the translation source and date. Directory sites of world law exist, but many links in them are stale: use them to find the official portal, then go there.

## Fetch fallback (before any `[verify]`)
A blocked page (403, an empty 202, a bot challenge) is not a missing source. In order:
1. **Raw text over summaries.** A fetch tool that summarises through a small model can hand back stale or paraphrased text. Prefer `curl`, an official API, or a raw file; quote only text you saw.
2. **A mirror of the same document.** Example: when EUR-Lex is unreadable, the EU Publications Office serves the Official Journal text: `curl -L -H "Accept: application/xhtml+xml" -H "Accept-Language: eng" http://publications.europa.eu/resource/celex/<CELEX>` (worked 2026-11-04 for 32016R0679, 32023R1113, 32023R1114). For a blocked standard-setter PDF, look for the same PDF hosted by a national regulator, and confirm title, date and paragraph numbers match.
3. **Local extraction** of a PDF that comes back as binary (`pdftotext`, or any PDF text library on the machine).
4. Only then mark it `[verify]` and put it on the could-not-check list.

## The authority table
One row per authority, before any drafting:

| Field | Rule |
|---|---|
| Instrument | full name and number, e.g. "Regulation (EU) 2016/679" |
| Pinpoint | article, section, paragraph; recital or annex named as such |
| Kind | operative text, recital/preamble, guidance, FAQ, judgment, proposal |
| URL | the official or mirror URL actually read |
| Retrieved | date fetched |
| Version | consolidated version date, or publication date in the journal |
| Status as of the "as of" date | in force, in force from a later date, transitional, amended, proposed, repealed, or unknown |
| Quote | the exact words relied on, short |

Keep these apart, always:
- **Recital or preamble vs operative article.** A recital explains; it does not create or remove an obligation. A memo may say "recital 22 suggests"; it may not say "the regulation exempts".
- **Proposed vs enacted vs in force.** A bill, consultation or draft regulatory technical standard is not law. An enacted rule may apply only from a later date: give both dates.
- **Holding vs reach.** A judgment binds within its court's system and on its facts. Name the court, the date and whether it is on appeal.
- **Guidance vs law.** Standard-setter recommendations and regulator FAQs inform; national law implements. Say which one a point rests on.

## Examples to practise on (re-verify each; they move)
- GDPR Art. 13 and 14: information to give the data subject (operative), versus recitals on the same topic.
- MiCA recital 22 on fully decentralised services, versus the operative scope articles of Regulation (EU) 2023/1114.
- The EU crypto Travel Rule lives in Regulation (EU) 2023/1113, not in MiCA.
- FATF Recommendations 15 and 16 and the 2021 updated guidance on virtual assets (paragraphs on DeFi owners and operators); fetch the current R.16 text, which was revised in 2025 `[verify]`.
- CCPA notice at collection, Cal. Civ. Code 1798.100(a), and the regulator's current regulations page for what is in force and from when.
- OFAC FAQs on virtual currency, including the reporting deadline for blocked property: count the business days with a second tool.

## Writing the memo
1. **First lines:** jurisdiction and level, "as of" date, the question, any labelled Assumptions.
2. **Short answer** in a few sentences, hedged to what the quotes support ("the text appears to", "on these facts it may"). Never "compliant", "exempt", "enforceable", "legal" or "illegal" as a conclusion.
3. **Analysis** point by point, each point citing a row of the authority table by pinpoint.
4. **Open questions**: facts that would change the answer, conflicts between sources, pending changes with their expected dates.
5. **Could-not-check list**: every `[verify]` item, why it failed (403, not found, paywalled), and what the worker tried. Present even when empty.
6. **Last line:** "Draft for review by qualified counsel in <jurisdiction>."

Numbers and dates (thresholds, fines, deadlines, effective dates) each carry their source row. A day count names the rule used (calendar or business days, which holidays, which time zone) and is recomputed by the checker.

## Outputs
- The memo (Markdown, or the format the brief names), rendered and looked at before hand-off: open the Markdown in a renderer (`pandoc memo.md -o memo.html` and a browser, or the editor's preview) and check the table and the quotes display whole; name the renderer in the return.
- The authority table, as a section of the memo or a sidecar file.
- The checker's cite-check log: each citation reopened, match or mismatch.

## Rubric (the checker's pass)
Report each failure with its location; no scores.
1. Jurisdiction, level and "as of" date appear in the first lines; Assumptions are labelled.
2. Every authority has an official or mirror URL, a retrieval date, a version and a status as of a date.
3. Cite-check: reopen at least 3 citations chosen at random (all of them if there are 5 or fewer, and every one the short answer rests on). The quoted words appear at that pinpoint and say what the memo says. A citation the checker cannot reopen moves to the could-not-check list; it is never left as confirmed.
4. No recital, preamble, FAQ or guidance cited as an operative rule; no proposal cited as law; no judgment stretched past its court or facts.
5. No secondary source cited as the authority.
6. No unsourced number or date; every day count recomputed with a second tool and matching.
7. No conclusion word ("compliant", "exempt", "enforceable") stated as a finding.
8. A could-not-check list exists.
9. The memo was rendered and looked at; the renderer is named.
10. The final counsel line is present and names the jurisdiction.

Any failure on 2, 3, 4 or 7 sends the memo back to the builder.

## For you
Only you name the jurisdiction, state the facts and the "as of" date, and decide how much legal risk to carry. Before anyone relies on this memo, have it reviewed by a licensed lawyer in each jurisdiction involved. Acting on it, filing anything and talking to a regulator are your decisions.

**Go deeper:** `anthropics/claude-for-legal` (Apache-2.0; practice-area plugins, `regulatory-legal` for rule tracking and gap work, `privacy-legal` for privacy; core use needs no key, research connectors are optional and some are paid; without one, citations are marked `[verify]`): `claude plugin marketplace add anthropics/claude-for-legal` then `claude plugin install regulatory-legal@claude-for-legal`.
