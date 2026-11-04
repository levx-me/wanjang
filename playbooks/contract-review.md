# Contract review and drafting from standard templates

> Sources: review pattern after [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) `commercial-legal` nda-review and [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) `legal` review-contract (both Apache-2.0, pattern only, no text copied); checklist ideas after [evolsb/claude-legal-skill](https://github.com/evolsb/claude-legal-skill) (MIT); drafting base [Common Paper Standards](https://commonpaper.com/standards/) (CC BY 4.0) and [Bonterms](https://github.com/Bonterms) (CC BY 4.0, stated in README) · Written 2026-11-04 · Applies to: any

**Use when:** reviewing an NDA, SaaS or master services agreement, DPA, vendor or customer agreement, or token deal paperwork as a checklist against the user's positions, or drafting one of these from an open standard template. What a statute or rule says goes to `legal-research.md`; privacy notices and gap lists to `privacy-compliance.md`; whether a crypto activity needs a licence to `crypto-regulatory-scope.md`. Output is a draft for review by qualified counsel, never an opinion.

## Crew procedure
- **Scout** (if needed): fetches the template's current version and licence page, and any statute the contract names, through `legal-research.md`. Labels each item Fact (URL, date), Inference or Assumption.
- **Builder** (opus for anything sent out): runs the review or fills the template. Writes to the path the brief names.
- **Checker** (fresh context, never the builder): applies the rubric below with tools (grep, diff), returns findings with location and severity.
- **QA**: renders the output (LibreOffice `soffice --headless --convert-to pdf`, or the user's word processor) and looks at every page: redlines visible, numbering intact, no clipped table, cover page complete.

## Required inputs (all from the user; never defaulted)
1. The document, complete with exhibits, schedules and order forms, or the template chosen for drafting.
2. Which side the user is on (customer or vendor, discloser or recipient, issuer or purchaser).
3. Governing law and venue the user wants, or "as drafted".
4. A positions file: preferred terms, acceptable fallbacks, walk-away points, risk appetite. Without one the review is labelled **"Generic review: no positions supplied"** and nothing is marked GREEN.
5. The deal facts: fees, term, data involved, what is delivered, who holds keys or funds.
A missing input is a gap listed at the top of the return, never guessed.

## Review procedure
1. **Pre-flight.** Is it a draft or executed? List blanks, missing exhibits, truncated or out-of-order pages, unsigned signature blocks, conflicting versions. State the side, governing law and venue as written.
2. **Read all of it before judging any clause.** Clauses interact: a liability cap undone by an uncapped indemnity, a termination right blocked by a notice clause, a definition that narrows a carve-out. Note each against both clause numbers.
3. **Run the checklist** (below), one row per item, even when the clause is absent ("not present" is a finding).
4. **Grade each row** against the positions file: GREEN (matches a preferred or acceptable position), YELLOW (outside preference but inside a fallback, or needs a business call), RED (past a walk-away point, or a missing protection the positions require). Terms that do not belong in an NDA (exclusivity, non-solicit, licence grants, payment) are YELLOW at least. Collect GREEN rows under **Reviewed and acceptable** so the user sees they were read.
5. **Redline** every YELLOW and RED: clause reference, exact current wording quoted, proposed wording, reason, priority (must / should / nice), fallback if refused. Use the smallest edit that works: a word before a phrase, a phrase before a sentence, a sentence before a whole clause.
6. **Recompute numbers** with a second tool (a script or spreadsheet, not the model's head): cap amounts from fees, notice and cure deadlines, renewal and opt-out dates, service credit tiers. Give dates as calendar dates with the counting rule.
7. **Not assessed list:** anything outside the checklist, outside the stated jurisdiction, or needing facts not supplied.

The crew sorts and drafts. It does not negotiate, send or sign.

## Checklist
- **Liability:** cap amount and basis; carve-outs (confidentiality, data breach, IP indemnity, wilful misconduct, fraud); exclusion of indirect or consequential loss, and whether it would swallow the main loss (for a crypto deal, loss of funds or digital assets).
- **Indemnities:** who covers whom, for what (IP, misuse, breach of law, sanctions); inside or outside the cap.
- **IP:** bespoke work versus background IP; licence back; feedback and residuals.
- **Open source:** licence fit with delivery (copyleft and network-use clauses versus proprietary delivery); an SBOM.
- **Service levels:** uptime definition and measurement, credits (sole remedy or not), suspension rights.
- **Data:** DPA attached; roles (controller, processor); subprocessors and objection right; transfer mechanism; breach notice window in hours; deletion or return at end. Cross-check `privacy-compliance.md`.
- **Confidentiality** (NDAs especially): mutual or one-way; definition; standard exclusions (public, already known, independently developed, received from a third party, legally compelled); term and survival; return or destruction with a backup exception.
- **Sanctions and export:** screening representations, termination on designation, export control cooperation. Name real lists only as examples (OFAC, EU, UN) and fetch them live.
- **Crypto statements:** no custody of keys or funds, no regulated services, audit is no security guarantee.
- **Term and exit:** term, auto-renewal and opt-out window, termination for convenience and cause, cure periods, survival.
- **Assignment, change of control, governing law, venue, disputes.**
- **Boilerplate that bites:** order of precedence (agreement, order form, policies); a unilateral right to change policies by URL.

**Token deal paperwork** (future token agreements, token warrants, grants) is reviewed only as a presence checklist, never characterised: securities-law treatment, restricted jurisdictions, lock-up and vesting, delivery mechanics and what happens if no token launches, KYC/AML and sanctions representations, termination events. Each goes to counsel; the crew states no view on whether anything is a security.

## Drafting from a standard template
1. Start from an open template: Common Paper (cover page plus fixed Standard Terms; Cloud Service Agreement current version 3.0 on 2026-11-04) or Bonterms (licence stated in each repo README). Fetch the current version and its licence page live; record version and retrieval date.
2. Put every deal variable on the cover page or order form. Leave the standard terms untouched.
3. If the standard terms must change, mark the document "Derived from <template, version>", keep the licence notice and a link to the original, and list each change.
4. A form under a no-derivatives licence (for example CC BY-ND, used by some widely circulated startup financing forms) is filled in its blanks only and never shipped edited; check its licence before touching it.
5. Never embed forms from generator sites with unknown terms; cite or summarise them.
6. Put a banner at the top: "Draft for review by qualified counsel in <jurisdiction>. Not signed."

## Market numbers
A "market" or "typical" figure (a cap at 12 months of fees, a 30-day cure period) is written as **rule of thumb, unsourced** unless it cites a dated source. Never call one standard.

## Output
Header (document and version, side, governing law, positions file or "Generic review", review date); counts of RED/YELLOW/GREEN with the three items that matter most; the issue table (clause, topic, grade, current wording, proposed wording, reason, priority, fallback); Reviewed and acceptable; clause interactions; recomputed figures with the tool used; not-assessed and could-not-check lists. Drafting adds the filled document, a change list against the template and the attribution block.

## Rubric (the checker applies, with tools)
- Side, governing law and venue stated in the header.
- Every quoted "current wording" string-matches the source file (grep it). One mismatch fails.
- Every RED and YELLOW has a proposed wording and a fallback.
- No GREEN anywhere when no positions file was supplied.
- Every market figure is either sourced and dated or labelled rule of thumb.
- Every checklist item has a row or is in "not assessed".
- No placeholders left: scan for `[ ]`, `[NEED`, `TBD`, `XX`, `__`, `<...>` in the output.
- Defined terms: each capitalised defined term is defined once and used; each cross-reference (Section 7.2, Exhibit B) resolves to a real heading.
- Numbers and dates recomputed by a second tool and matching.
- Drafting: `diff` of the standard terms against the fetched template is clean, or every hunk appears in the change list; attribution line and licence link present; template version stated; no-derivatives forms changed only in blanks; draft banner present.
- No sentence calls the contract "compliant", "enforceable", "market standard" or "safe to sign".
- Output rendered and looked at, renderer named.

## For you
Only you supply the positions, risk appetite and walk-away points, the facts and the jurisdiction, and the commercial terms of a draft. Before relying on, sending or signing anything, have it reviewed by a licensed lawyer in the governing-law jurisdiction (and any other jurisdiction involved). Negotiating, sending and signing are yours alone.

**Go deeper:** `anthropics/claude-for-legal` (Apache-2.0; `commercial-legal` has NDA and commercial contract review and runs a 10-20 minute first-run interview that saves your practice profile; CLM and e-signature connectors are optional, some paid): `claude plugin marketplace add anthropics/claude-for-legal` then `claude plugin install commercial-legal@claude-for-legal`. For filling Common Paper templates into DOCX, `open-agreements/open-agreements` (Apache-2.0 code, each template keeps its own licence, US guidance only): `npm install -g open-agreements`.
