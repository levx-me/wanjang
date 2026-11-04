# Privacy compliance: notices, data maps, DPAs and requests (drafts for counsel)

> Sources: [garethmdowns/gdpr-skill](https://github.com/garethmdowns/gdpr-skill) (MIT; its ICO template is OGL v3.0), [anthropics/knowledge-work-plugins legal compliance-check](https://github.com/anthropics/knowledge-work-plugins/tree/main/legal) (Apache-2.0), [anthropics/claude-for-legal privacy-legal](https://github.com/anthropics/claude-for-legal) (Apache-2.0), all paraphrased; primary texts read 2026-11-04: [GDPR, Reg. (EU) 2016/679, OJ text](http://publications.europa.eu/resource/celex/32016R0679) (Arts 12(3), 13, 14, 28(3), 33), [CCPA statute](https://cppa.ca.gov/regulations/) (Civ. Code 1798.100(a), version effective 2025-01-01), [CPPA approved regulations text, effective 2026-01-01](https://cppa.ca.gov/regulations/ccpa_updates.html) (§§ 7012, 7121, 7155, 7157, 7200) · Written 2026-11-04 · Applies to: any

**Use when:** drafting or checking a privacy notice or policy, mapping the personal data a feature or codebase handles (record of processing, transfer register), checking a vendor's data processing agreement, or answering a data-subject request. For the commercial terms of a whole contract read `contract-review.md`; for open research on what a law says read `legal-research.md`; for securing the code itself read `security-review.md`. GDPR and CCPA/CPRA below are examples; the same method applies to any privacy law the user names.

## Crew procedure
- **Scout** fetches every law the task touches from the official text (see "Fetch the law live") and returns, per point: law, article or section, version or effective date, URL, access date, and the point in its own words. What it cannot open is `[verify]`, never filled from memory.
- **Builder** (opus for anything published or sent) writes the draft from the user's facts and the scout's citations only.
- **Checker** (fresh context, never the builder) applies the rubric, opens each cited URL and re-runs the vendor scan itself.
- **QA**: a second agent recounts the inventory with a different tool than the builder (for example a script over the lockfiles against the builder's spreadsheet) and opens the rendered output (browser for HTML, the user's viewer or `soffice --headless --convert-to pdf` for docx/xlsx; name it) to check the banner, tables and links show.

## Required inputs (the user's; nothing defaulted silently)
1. Whose data: users, customers, staff, minors; and where those people live. This picks the regimes. Do not infer it from the company's address or the code's language. EU GDPR and UK GDPR are separate regimes; a US state law is not federal law.
2. What data, why, and from where (collected from the person or from a third party).
3. Vendors and processors, and where data is stored and accessed from.
4. The role: controller, processor, or both, per activity.
5. Existing documents: current policy, DPAs, past records of processing.
6. Any threshold that decides scope (revenue, number of consumers, data sold or shared) comes from the user, with its source.

Missing facts become `UNKNOWN - reviewer to confirm` in the output, listed again at the top. Never guess one to make a section read well.

## Fetch the law live
Cite the official text with its version and access date. Firm blogs help find the article; they are not the citation.
- EU law: `curl -L -H "Accept: application/xhtml+xml" -H "Accept-Language: eng" http://publications.europa.eu/resource/celex/<CELEX>` returns the Official Journal text when eur-lex.europa.eu will not load (GDPR is 32016R0679).
- Regulator PDFs: download and extract text locally (any PDF-to-text tool; on macOS a PDFKit script works) instead of trusting a summarising fetch.
- Fast-moving status, always re-fetched with a date: the EU-US Data Privacy Framework (upheld at first instance in 2025 and under appeal per secondary sources, `[verify]` on curia.europa.eu), the current standard contractual clauses decision `[verify]`, UK transfer tools `[verify]`, CPPA phase-in dates. Example of the last, read 2026-11-04 from the approved text: existing ADMT use for significant decisions must meet the new rules by 2027-01-01 (§ 7200); risk assessments for ongoing processing by 2027-12-31 (§ 7155), first submission by 2028-04-01 (§ 7157); first cybersecurity audit reports due 2028-04-01, 2029-04-01 or 2030-04-01 depending on revenue tier (§ 7121). Re-read before using.
- Proposals, consultations and recitals are labelled as such and never presented as operative law.

## Tasks

### Notice or policy
Map each required item to the article or section that requires it, with URL. Examples:
- GDPR Art. 13 (collected from the person): controller identity and contact, DPO contact, purposes and legal basis, legitimate interests where relied on, recipients, third-country transfers and safeguards; 13(2): retention or its criteria, the rights, withdrawing consent, complaint to an authority, whether providing data is required, automated decisions. Art. 14 (not collected from the person) adds the categories of data and their source.
- CCPA 1798.100(a) and CPPA § 7012(e): categories (sensitive ones included), purposes, whether each category is sold or shared, retention per category or its criteria, the opt-out link if selling or sharing, a link to the policy; shown at or before collection.
Output a table: item, where it appears in the draft, citation. Any item not applicable states why.

### Codebase or feature data map
1. Scan with tools, not by reading: dependency manifests and lockfiles, outbound hosts (`grep -rEoh 'https?://[A-Za-z0-9.-]+' src | sort -u`), SDK initialisations, env var names for third-party keys, analytics or tag scripts, schema fields that look personal (email, phone, ip, address, dob, location), and what gets logged.
2. Outputs: a short summary; a draft record of processing (activity, data categories, subjects, purpose, suggested legal basis, recipients, retention, storage location); a transfer register (vendor, data, destination country, mechanism, fallback).
3. Tag every inferred row HIGH, MEDIUM or LOW confidence with the file and line it came from. Legal basis is a suggestion for counsel, never a finding.
4. List what a static scan cannot see: runtime config, vendor-side processing, data in backups, manual exports, paper.

### Vendor DPA check (GDPR Art. 28(3) as the example)
Check the contract covers: subject, duration, nature and purpose, data types and subject categories; processing only on documented instructions (transfers included); staff confidentiality; Art. 32 security; subprocessor conditions (prior authorisation, notice of changes, right to object, same terms flowed down); help with data-subject requests; help with security, breach and impact assessments; delete or return at the end; information and audits. Also: breach notice to the controller without undue delay (Art. 33(2)) and whether a fixed window is stated, the transfer mechanism and its fallback, the subprocessor list with locations. Each item: present, partial or missing, with the clause quoted exactly.

### Data-subject request
Confirm identity per the user's procedure; find the data with the map above; draft the reply. Deadlines from the law, fetched: GDPR Art. 12(3) is one month from receipt, extendable by two more months with notice inside the first month; for CCPA fetch the current statute and regulations `[verify]`. Record the received date and the due date at the top.

## Output shape
1. Banner on line one: "DRAFT for review by qualified counsel in <jurisdiction>. Not legal advice. Not a statement of compliance."
2. Regimes in scope, each tied to a stated fact (who lives where), with as-of date.
3. The task output (table, map, checklist or reply).
4. `UNKNOWN` list, then a **Could not check** list (sources not opened, facts not given, what the scan cannot see).
5. Closing **For you** step (below).

## Checker rubric (each pass/fail with location)
1. Banner present on line one; no "compliant", "exempt", "lawful" or "GDPR-ready" as a conclusion anywhere.
2. Each regime matches the user's stated geography and role; UK GDPR kept apart from EU GDPR; state law apart from federal.
3. Every notice item maps to an article or section with a URL the checker opened; the point is on the page; access date present.
4. Every regime status and phase-in date carries an as-of date and a primary source; proposals and recitals labelled.
5. Every inferred row has a confidence tag and a file:line; unknowns read `UNKNOWN - reviewer to confirm`; legal basis worded as a suggestion.
6. Vendor completeness: the checker re-runs the dependency and host scan; every third party found appears in the register, or is listed as excluded with a reason.
7. DPA quotes string-match the contract text.
8. Request deadlines computed from the stated received date; QA recomputes them independently.
9. Could-not-check list present and non-empty unless every source was opened.

## Only the user can
Give the facts about data flows, users' locations and vendors; decide the role and the legal basis; set thresholds; approve the DPO's or counsel's sign-off; publish a notice, sign a DPA, send a request reply. **For you:** have the draft reviewed by a licensed privacy lawyer (or your DPO with counsel) in each relevant jurisdiction before you publish, sign or send it.

## Go deeper
`claude-for-legal` privacy-legal (Apache-2.0; triage, impact assessments, DPA review, request replies): `claude plugin marketplace add anthropics/claude-for-legal` then `claude plugin install privacy-legal@claude-for-legal`; run its setup interview first; outputs are drafts for attorney review. For code scans, `garethmdowns/gdpr-skill` (MIT, no key) is a skill folder: clone it into `~/.claude/skills/`. For Word or PDF output: `document-skills@anthropic-agent-skills` (`claude plugin marketplace add anthropics/skills`).
