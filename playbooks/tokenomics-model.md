# Tokenomics model: supply, vesting, emissions, unlocks

> Sources: [zupy-fmartinelli/solana-tokenomics-skill](https://github.com/zupy-fmartinelli/solana-tokenomics-skill) (MIT), [cadCAD](https://github.com/cadCAD-org/cadCAD) (MIT, v0.5.3), [TokenEngineeringCommunity/resources](https://github.com/TokenEngineeringCommunity/resources) (MIT), articles at buildmytokenomics.com and tokenomics.com (read as background only, nothing copied) · Written 2026-11-04 · Applies to: any

**Use when:** building or auditing a token's supply schedule: allocations, cliffs, vesting, emissions, burns, unlock calendar, FDV against circulating value, or a staking/yield claim. Not for LLM token cost (a different thing that shares the word). For the spreadsheet mechanics read `spreadsheet-model.md` too; for whether a token is regulated, read `crypto-regulatory-scope.md`. This playbook never decides that.

## Crew procedure
- **Scout** (if inputs are missing): lists what the user supplied versus what is missing; may fetch live reference material (a launch's published schedule) and labels each item Fact (URL + retrieval date), Inference or Assumption.
- **Builder** (sonnet; opus for a published model) writes a monthly table in a spreadsheet or script, with live formulas and an inputs sheet. Writes to the path the brief names.
- **Checker** (fresh context, never the builder) rebuilds the schedule independently (a second tool, e.g. a short Python script) and applies the rubric below. Returns findings with cell and severity.
- **QA**: opens the rendered file (LibreOffice headless to PDF/PNG, or the chart image), looks at each sheet and chart, and reports clipped labels or unreadable axes. Changes one input (a cliff, an emission rate) and confirms every dependent output moves.

## Required inputs (the user supplies; none defaulted silently)
Total supply and whether it is fixed or inflating; each allocation bucket with share, cliff, vesting length and any unlock at launch; emission rule (per month or per block, decay, cap); burn rule; the price case to display (flat by default, labelled an assumption, not a forecast); staking or yield terms if claimed; start date; the jurisdiction the token will be offered in (for the "For you" step only). Missing items: list as gaps and continue only on labelled Assumptions.

## Build
1. Inputs sheet: one cell per parameter, with a unit and a source label. No constants inside formulas.
2. Monthly table (month 0 to at least 48): per bucket, locked, unlocked this month, cumulative unlocked; emissions; burns; **circulating = cumulative unlocked + cumulative emitted - burned**; total supply = initial + emitted - burned.
3. Valuation view, side by side: FDV (total supply x price) and circulating market value (circulating x price). Show FDV growth under emissions at flat price, and the FDV/circulating ratio over time.
4. Unlock calendar: each month's newly unlocked amount as a percentage of circulating supply, with the 6, 12, 24 and 36 month marks highlighted, plus a chart.
5. Yield table: split every reward into **real yield** (paid from fees or revenue actually collected) and **inflationary yield** (paid from newly emitted tokens). Show the dilution to a non-staker, and net yield after dilution.
6. Failure-mode checklist (report each as present or absent, with the cell that shows it): large share unlocked at launch; no cliff for team or investors; one holder or group controlling a large share; emission with no matching demand source; unlocks clustered in one month; yield called "real" while paid by emission; vesting end dates that all coincide.
7. Optional: a parameter sweep or Monte Carlo (cadCAD, Python 3.9+, `pip install cadCAD`). Vesting and FDV are custom state variables there; there is no canonical template. State every distribution assumed.

## Rubric (the checker's list)
1. Allocation shares sum to 100% and amounts sum to total supply (shown as a check cell, and recomputed independently).
2. The independently rebuilt schedule matches month by month (tolerance stated).
3. Circulating never exceeds total supply in any month; no negative locked balance.
4. Formulas are live and reference the inputs sheet; no hardcoded results; no errors (`#REF!`, `#NAME?`, `#DIV/0!`); changing one input moves the outputs.
5. Every yield figure is labelled real or inflationary; none is called "risk-free" or "guaranteed".
6. The monthly unlock share of circulating supply is shown, including month 1 where circulating may be tiny.
7. Price is labelled an assumption; no price prediction, return promise or "undervalued" language.
8. No legal classification asserted (not "utility", not "not a security", not "exempt", not "compliant").
9. Every market or status figure carries its date; a "could not check" list closes the file.
10. Any dependence on spreadsheet functions newer than the target app (XLOOKUP, FILTER, UNIQUE are absent before LibreOffice 24.8) is avoided or the app is tested.

## Hand-off format
The model file, a one-page summary (the unlock calendar chart, the FDV/circulating table, the failure-mode list), the assumption list with labels, and the "could not check" list.

## For you
- Choose the allocation, the emission and burn rules, the vesting and the price case; the playbook only models them.
- Have the final model and anything you publish (docs, a litepaper, a post) reviewed by a qualified lawyer in each jurisdiction where the token is offered or marketed. The model makes no judgement on whether the token is a security, a commodity, a regulated crypto-asset or anything else, and tax treatment is for a licensed tax adviser. Current rules (e.g. MiCA in the EU, US securities and commodities law) are to be fetched from the primary source with their date, never quoted from memory.
- Nothing here is investment advice; do not circulate the yield or valuation figures as a promise.

## Go deeper
- zupy-fmartinelli/solana-tokenomics-skill (MIT; a single maintainer, few stars; Solana-specific parts): clone the repo and read its reference files (supply, vesting, real versus inflationary yield, failure modes); it has no keys or dependencies. Check the repo for a plugin manifest before trying `claude plugin marketplace add zupy-fmartinelli/solana-tokenomics-skill`.
- cadCAD (MIT): `pip install cadCAD` for simulation; TokenEngineeringCommunity/resources (MIT) for reading lists.
