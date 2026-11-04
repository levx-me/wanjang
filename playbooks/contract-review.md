# Contract review and drafting from standard templates

> Sources: review pattern after [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) `commercial-legal` nda-review and [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins) `legal` review-contract (both Apache-2.0, pattern only); checklist ideas after [evolsb/claude-legal-skill](https://github.com/evolsb/claude-legal-skill) (MIT); drafting base [Common Paper Standards](https://commonpaper.com/standards/) (CC BY 4.0) and [Bonterms](https://github.com/Bonterms) (CC BY 4.0, stated in README) · Written 2026-11-04 · Applies to: any

**Use when:** reviewing an NDA, SaaS or master services agreement, DPA, vendor or customer agreement, or token deal paperwork as a checklist against the user's positions, or drafting one of these from an open standard template. What a statute or rule says goes to `legal-research.md`; privacy notices and gap lists to `privacy-compliance.md`; whether a crypto activity needs a licence to `crypto-regulatory-scope.md`. Output is a draft for qualified counsel, never an opinion.

## Crew procedure
- **Scout** (if needed): fetches the template's current version and licence page, and any statute named, through `legal-research.md`; labels items Fact (URL, date), Inference or Assumption.
- **Builder** (opus for anything sent out): runs the review or fills the template. Writes to the path the brief names.
- **Checker** (fresh context, never the builder): applies the rubric below with tools (grep, diff), returns findings (location, severity).
- **QA**: renders the output (LibreOffice `soffice --headless --convert-to pdf`, or the user's word processor) and looks at every page: redlines visible, numbering intact, no clipped table, cover page complete.

## Required inputs (all from the user; never defaulted)
1. The document with exhibits, schedules and order forms, or the chosen template.
2. Which side the user is on (customer or vendor, discloser or recipient, issuer or purchaser).
3. Governing law and venue the user wants, or "as drafted".
4. A positions file, per topic: `ideal`, `fallback`, `walk-away` (one line each), plus risk appetite. A topic missing from it is graded YELLOW "no position, user to decide", never GREEN. Without a file the review is labelled **"Generic review: no positions supplied"** and nothing is marked GREEN.
5. The deal facts: fees, term, data involved, what is delivered, who holds keys or funds.
A missing input is a gap listed at the top of the return.

## Review procedure
1. **Pre-flight.** Is it a draft or executed? List blanks, missing exhibits, truncated or out-of-order pages, unsigned signature blocks, conflicting versions. State the side, governing law and venue as written.
2. **Read all of it before judging any clause.** Clauses interact (a cap undone by an uncapped indemnity): cite both clauses.
3. **Run the checklist** (below), one row per item, even when the clause is absent ("not present" is a finding).
4. **Grade each row** against the positions file: GREEN (within the ideal), YELLOW (between ideal and fallback, or needs a business call), RED (worse than the fallback; a breached walk-away is RED: stop and flag it). With no fallback in the file, the redline offers only the ideal and says the fallback is the user's. Terms foreign to an NDA (exclusivity, non-solicit, licence grants, payment) are YELLOW at least. List GREEN rows under **Reviewed and acceptable**.
5. **Redline** every YELLOW and RED: clause reference, exact current wording quoted, proposed wording, reason, priority (must / should / nice), fallback if refused. Use the smallest edit that works.
6. **Recompute numbers** with a second tool (a script or spreadsheet, not the model's head): cap amounts from fees, notice and cure deadlines, renewal and opt-out dates, service credit tiers. Give calendar dates and state the counting rule in the return: day 0 is the day of the event, calendar days, the user's timezone; if the end falls on a non-business day, say so and do not roll it silently. Recompute with a second tool.
7. **Not assessed list:** anything outside the checklist or jurisdiction, or needing facts not supplied.

## Checklist
- **Liability:** cap amount and basis; carve-outs (confidentiality, data breach, IP indemnity, wilful misconduct, fraud); exclusion of indirect or consequential loss, and whether it would swallow the main loss (crypto: loss of funds or assets).
- **Indemnities:** who covers whom, for what (IP, misuse, breach of law, sanctions); inside or outside the cap.
- **IP:** bespoke work versus background IP; licence back; feedback and residuals.
- **Open source:** licence fit with delivery (copyleft and network-use clauses versus proprietary delivery); an SBOM.
- **Service levels:** uptime definition and measurement, credits (sole remedy or not), suspension rights.
- **Data:** DPA attached; roles (controller, processor); subprocessors and objection right; transfer mechanism; breach notice window in hours; deletion or return at end. See `privacy-compliance.md`.
- **Confidentiality** (NDAs especially): mutual or one-way; definition; standard exclusions (public, already known, independently developed, received from a third party, legally compelled); term and survival; return or destruction with a backup exception.
- **Sanctions and export:** screening representations, termination on designation, export control cooperation. Name real lists (OFAC, EU, UN) only as examples; fetch live.
- **Crypto statements:** no custody of keys or funds, no regulated services, audit is no security guarantee.
- **Term and exit:** term, auto-renewal and opt-out window, termination for convenience and cause, cure periods, survival.
- **Assignment, change of control, governing law, venue, disputes.**
- **Boilerplate:** order of precedence; unilateral right to change policies by URL.

**Token deal paperwork** (future token agreements, token warrants, grants) is reviewed only as a presence checklist, never characterised: securities-law treatment, restricted jurisdictions, lock-up and vesting, delivery mechanics and what happens if no token launches, KYC/AML and sanctions representations, termination events. Each goes to counsel; the crew states no view on whether anything is a security.

## Drafting from a standard template
1. Start from an open template: Common Paper (cover page plus fixed Standard Terms; Cloud Service Agreement current version 3.0 on 2026-11-04) or Bonterms (licence stated in each repo README). Fetch version and licence page live; record both and the date.
2. Save the fetched template under the run folder (the path the brief gives) so the diff has a fixed copy.
3. Put every deal variable on the cover page or order form. Leave the standard terms untouched.
4. If the standard terms must change, mark the document "Derived from <template, version>", keep the licence notice and a link to the original; list each change.
5. A form under a no-derivatives licence (for example CC BY-ND, used by some widely circulated startup financing forms) is filled in its blanks only and never shipped edited; check its licence before touching it.
6. Never embed forms from generator sites with unknown terms; cite them.
7. Banner at the top: "Draft for review by qualified counsel in <jurisdiction>. Not signed."

## Market numbers
A "market" or "typical" figure (cap at 12 months of fees, 30-day cure) is written as **rule of thumb, unsourced** unless it cites a dated source. Never call one standard.

## Output
Header (document and version, side, governing law, positions file or "Generic review", date); RED/YELLOW/GREEN counts with the top three items; the issue table (clause, topic, grade, current wording, proposed wording, reason, priority, fallback); Reviewed and acceptable; clause interactions; recomputed figures with the tool used; not-assessed and could-not-check lists. Drafting adds the filled document, change list and attribution block.

## Rubric (the checker applies, with tools)
- Side, governing law and venue stated in the header.
- Every quoted "current wording" string-matches the source file (grep it, after normalising whitespace and smart quotes in both). One mismatch fails.
- Every RED and YELLOW has a proposed wording and a fallback.
- No GREEN anywhere when no positions file was supplied.
- Every market figure is either sourced and dated or labelled rule of thumb.
- Every checklist item has a row or is in "not assessed".
- No placeholders left: scan the output for `\[[A-Z _]+\]`, `XX+`, `TBD`, `_{4,}` and `<...>`; a blank signature line is fine.
- Defined terms: each capitalised defined term is defined once and used; each cross-reference (Section 7.2, Exhibit B) resolves to a real heading.
- Numbers and dates match a second-tool recompute.
- Drafting: `diff` of the standard terms against the saved template is clean, or every hunk appears in the change list; attribution line and licence link present; template version stated; no-derivatives forms changed only in blanks; draft banner present.
- No sentence calls the contract "compliant", "enforceable", "market standard" or "safe to sign".
- Output rendered and looked at, renderer named; if `soffice` is missing, render is marked "could not check".
- A .docx input gets tracked changes from a tool that supports them, else a clean redline table plus a comparison; the return says which.

## For you
Only you supply the positions, risk appetite, facts, jurisdiction and commercial terms. Before relying on, sending or signing anything, have it reviewed by a licensed lawyer in the governing-law jurisdiction (and any other jurisdiction involved). Negotiating, sending and signing are yours alone.

**Go deeper:** `anthropics/claude-for-legal` (Apache-2.0; `commercial-legal`: NDA and contract review; a 10-20 minute first-run interview saves your practice profile): `claude plugin marketplace add anthropics/claude-for-legal` then `claude plugin install commercial-legal@claude-for-legal`. For filling Common Paper templates into DOCX, `open-agreements/open-agreements` (Apache-2.0 code, each template keeps its own licence, US guidance only): `npm install -g open-agreements`.
