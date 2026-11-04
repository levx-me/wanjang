# Accounting treatment memo for crypto holdings or revenue (draft for an accountant)

> Sources: [IFRS Foundation, Holdings of Cryptocurrencies page](https://www.ifrs.org/projects/completed-projects/2019/holdings-of-cryptocurrencies/) (opened 2026-11-04; confirms an IFRS Interpretations Committee agenda decision in June 2019), a Big-4 IFRS digital-assets overview, the IFRS 15 page on ifrs.org, and a Big-4 summary of FASB ASU 2023-08 (fasb.org returned 403 from our fetch, so that standard is a secondary-source example to verify) · Written 2026-11-04 · Applies to: any

**Use when:** drafting a memo that says how an entity could account for crypto assets it holds, or for revenue it earns in or from them, so a qualified accountant can review it. Not for tax (never state a tax view), not for legal classification of a token (read `crypto-regulatory-scope.md`), not for a spreadsheet of balances (read `spreadsheet-model.md` or `reconciliation-variance.md`).

## Crew procedure
- **Scout** fetches the standards live (see "Sources of authority") and returns, per citation: standard, paragraph, effective date, URL, access date, and the exact quoted point. Anything it cannot open is marked `[verify]`, never filled from memory.
- **Builder** (opus) writes the memo in the output shape below, from the user's facts only.
- **Checker** (fresh context, never the builder) applies the rubric, opening every cited URL itself.
- **QA**: a second agent recomputes every number in the memo (journal examples, fair value, totals) with a different tool than the builder used (for example a script against a spreadsheet), and the memo is rendered and looked at (PDF or docx via the user's tool; name the renderer) for tables and numbering.

## Required inputs (all from the user; nothing defaulted)
1. **Reporting framework** the entity uses, and why (law, regulator, lender or listing rule): IFRS, US GAAP, a local GAAP, or other. Ask; do not infer from the country or the tool. The user confirms it in writing before drafting.
2. Entity facts: what assets (named tokens, quantity, how acquired), purpose of holding (trading, long-term, operational, held for customers, treasury), custody (own wallet, third party, exchange), any staking, lending or pledging, and period end date.
3. Revenue facts if relevant: what is delivered, to whom, when control passes, how the price is set and paid (in crypto or fiat), contract terms.
4. Functional and presentation currency; how fair value is observed (which market, which time of day).
5. Prior-period policy and whether this is a change of policy.

## Sources of authority
Read the standard setter's own text. Mirrors and firm summaries help you find the paragraph but are not the citation. Examples to fetch and check, not to assume:
- **IFRS**: no crypto-specific standard. The June 2019 IFRIC agenda decision discusses holdings under IAS 2 (held for sale in the ordinary course of business) and otherwise IAS 38 (intangible assets). Read the decision text and the standards' current version; check for later IASB work.
- **US GAAP**: ASU 2023-08 (ASC 350-60) puts in-scope crypto assets at fair value through net income; stated effective for fiscal years starting after 15 Dec 2024, early adoption allowed. `[verify]` against fasb.org or the codification, including scope criteria and disclosures.
- **Revenue**: the five-step model of IFRS 15 and ASC 606 (identify contract, performance obligations, price, allocate, recognise when control passes). Noncash consideration and measurement date need their own paragraph check `[verify]`.
- **Foreign currency** (IAS 21 / ASC 830), **impairment**, **derecognition**, **custody liabilities** and **staking income** were not researched here: mark each `[verify]` or out of scope in the memo.

## Output shape
1. Header: entity, period, framework (confirmed by whom, when), draft status, date.
2. **Facts table** first: each fact, its source (user, document), and label Fact or Assumption.
3. **Questions and options**: for each accounting question, the options the standards allow on these facts, with citations (standard, paragraph, effective date, URL, access date).
4. **Analysis**: facts applied to each option. Judgement is marked as judgement and kept apart from the facts.
5. **Recommendation**, headed "Draft for accountant", with the effect on presentation (balance sheet, income) and the disclosures to consider. Illustrative journal entries only if every number comes from the facts table.
6. **Could not check** list, and open questions for the accountant.
7. Closing line: "Verify with a qualified accountant in the relevant jurisdiction."

## Checker rubric (each item pass/fail, with the location)
1. The framework is named and the user's confirmation is on record.
2. Every citation URL was opened by the checker and the quoted point is on the page; access date present.
3. Standard version and effective date are given for each; early-adoption and transition noted where they matter.
4. No paragraph number appears that was not seen on a primary page.
5. Facts and judgement are in separate sections; every fact traces to the user.
6. Each number recomputes with a second tool; one input changed moves the outputs.
7. No sentence states or implies a tax treatment, and none says the treatment is "compliant", "correct" or "approved".
8. The "verify with a qualified accountant" line is present, and the could-not-check list is non-empty or says explicitly why it is empty.
9. Status and market figures carry a date.

## Only the user can
Supply the facts and confirm the framework; choose among options; set materiality; approve, sign off and send the memo; engage the accountant or auditor who reviews it. **For you:** have the memo reviewed by a licensed accountant in the relevant jurisdiction before relying on it.

## Go deeper
No packaged plugin covers this directly. Related: `statement-auditor` in anthropics/financial-services (Apache-2.0): `claude plugin marketplace add anthropics/financial-services`, then `claude plugin install <plugin>@financial-services` (find the plugin name in the marketplace listing `[verify]`). For Word or PDF output: `document-skills@anthropic-agent-skills` (`claude plugin marketplace add anthropics/skills`).
