# Spreadsheet model: building and auditing xlsx models

> Sources: [FAST Standard](https://www.fast-standard.org) (CC BY 4.0, FAST Standard Organisation; principles Flexible, Appropriate, Structured, Transparent), [anthropics/financial-services](https://github.com/anthropics/financial-services) dcf-model and audit-xls ideas (Apache-2.0, restated in our own words), openpyxl and LibreOffice documentation · Written 2026-11-04 · Applies to: any

**Use when:** building or auditing an .xlsx model: runway, budget, revenue, unit economics, tracker, DCF, three-statement. For checking two datasets against each other use `reconciliation-variance.md`; for slides or memos that quote the model, also read `deck.md` / `business-doc.md`. This playbook is not financial, tax or accounting advice.

## Crew
- **Scout:** fetches the standards or the app's documentation the user names, with URL and date; finds the target app and version (Excel, LibreOffice, Google Sheets) and the reporting framework if the user stated one.
- **Builder:** writes the workbook (openpyxl), recalculates a copy headlessly, runs the scans below. Keeps the formula file as master.
- **Checker (fresh context, never the builder):** applies the rubric, recomputes three cells with a second tool (pandas or DuckDB), opens the render. Reports; does not edit.
- **QA:** changes one input and confirms outputs move the right way; runs the check cells.

## Inputs (ask, never default)
Purpose and audience; periods and granularity; currency and units; every assumption value with source and as-of date; reporting framework (IFRS, US GAAP, none); the target app. Missing assumptions stay labelled `ASSUMPTION - user to supply`, never invented; this holds in an unattended run too, and each such cell is listed under For you. Market data needs a dated source or is left blank.

## Build rules
1. **Layout:** inputs sheet, calculation sheet(s), outputs sheet. Each assumption lives once, in its own labelled cell with unit, source, as-of date.
2. **One row = one calculation** across all periods, same formula in every period column. Formulas, never pasted results; no literal inside a formula (a literal is a hard-coded number inside a formula, other than 0, 1, -1 or a constant such as 12 months per year named on the Inputs sheet); guard division by zero.
3. **Colour code:** inputs blue font (0000FF), formulas black, cross-sheet links green (008000), assumption to confirm yellow fill (FFFF00). No merged cells; header row frozen; units in labels; cash outflows negative; period labels on every block.
4. **Percentages stored as fractions** (0.07, formatted as %).
5. **Functions:** avoid dynamic-array and very new functions (XLOOKUP, FILTER, UNIQUE, SORT, LET, SEQUENCE) unless the target app is known. LibreOffice before 24.8 lacks them and shows #NAME?; 24.8 added XLOOKUP (LibreOffice help page) and, per secondary sources, FILTER, UNIQUE and others. If the app is unknown, prefer INDEX/MATCH and test with `soffice`. Newer Excel functions written by openpyxl may need the `_xlfn.` prefix.
6. **Recalculation:** openpyxl writes formulas but computes none, so cached values are empty. Convert a copy through headless LibreOffice, read values from the copy. Never save a values-loaded workbook over the formula master. Whether a convert always recalculates is not documented: prove it by scanning values, not by assuming. openpyxl must be installed (pip, in a venv); a file only openpyxl wrote has no cached values. If `soffice` is missing, mark recalc, error scan and PDF render "could not check" in the return, or recompute with a Python evaluator (`formulas` or `pycel`); never claim a clean recalc.
7a. **Scans** (openpyxl, on the recalculated copy loaded with `data_only=True`): error cells, any value starting `#REF!`, `#DIV/0!`, `#NAME?`, `#VALUE!`, `#N/A`; on the formula file, formulas matching a numeric literal other than the allowed ones (regex on `cell.value`); row consistency, convert each formula to relative (R1C1-style) form and compare across a row.
7. **Check cells:** totals tie out; begin + change = end; balance sheet balances; cash flow ties to cash. Add a sensitivity table for the two or three drivers that matter (odd-sized axes so the base case sits in the middle).
8. **Valuation models:** terminal growth below the discount rate; flag terminal value above 75% of enterprise value; the user confirms each stage (revenue, margins, discount rate, terminal) before the next.

## Audit mode (report-only)
Scope the sheets; run formula checks and integrity checks; return a findings list (cell, issue, severity, suggested fix). No silent edits; changes only after the user agrees to each finding.

## Rubric (checker, each a pass or fail)
1. Recalculated copy has zero error cells (#REF!, #DIV/0!, #NAME?, #VALUE!, #N/A); the scan output is pasted.
2. Constant-in-formula scan finds no literal; no constant sits in a row whose pattern is formulas.
3. Row-wise consistency: no pattern break in one period; SUM ranges cover the whole block.
4. All check cells and identities pass.
5. Three cells recomputed in a second tool match.
6. One input changed: outputs move, in the right direction; then restored.
7. Every input has source, date, unit; none is unsourced market data.
8. Units, signs and period labels present; no merged cells; header frozen.
9. A sensitivity table (rule 7) exists and its outputs move when an input changes.
10. Rendered to PDF or image with LibreOffice and looked at: readable, nothing cut off or `###`.
11. Any figure quoted in a deck or memo equals its workbook cell.

A green recalc proves the formulas evaluate, not that they are right.

## Outputs
The formula workbook, the recalculated copy, the scan log, the three hand recomputations, the render, a "could not check" list (target-app behaviour, unfetched standards), and the date of every market or status figure.

## For you
You supply and approve the real assumptions (growth, prices, rates), pick the reporting framework and the target app, and decide who may rely on the model. Numbers for investors, lenders or filings need review by a qualified accountant or financial professional in the relevant jurisdiction before use.

**Go deeper:** `financial-analysis@claude-for-financial-services` (Apache-2.0; needs openpyxl and LibreOffice): `claude plugin marketplace add anthropics/financial-services` then `claude plugin install financial-analysis@claude-for-financial-services`. Anthropic's proprietary xlsx skill: `document-skills@anthropic-agent-skills` (marketplace `anthropics/skills`).
