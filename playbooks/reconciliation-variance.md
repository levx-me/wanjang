# Reconciliation and variance: tie two sources, explain plan vs actual

> Sources: [anthropics/knowledge-work-plugins finance: reconciliation, variance-analysis](https://github.com/anthropics/knowledge-work-plugins) (Apache-2.0); month-end close ordering from public vendor accounting blogs (practice, not a standard) · Written 2026-11-04 · Applies to: any

**Use when:** two sources must agree (bank vs ledger, subledger vs control account, export vs export), or actuals must be explained against budget, forecast or prior period. To build the workbook itself read `spreadsheet-model.md`; for exploratory statistics on one dataset read `data-analysis.md`. This playbook is about difference accounting, not modelling.

## Crew procedure
- **Scout** (if inputs are missing): lists the files, columns, date and currency fields, and which source is the system of record. Labels each item Fact (file path), Inference or Assumption.
- **Builder** runs the protocol below with scripts (not by eye) and writes the reconciliation file plus a short narrative. Use sonnet; opus for a variance narrative that goes to leadership.
- **Checker** (fresh context, never the builder) re-runs the totals and the driver sum with a different tool from the builder's (say, SQL or awk if the builder used pandas) and applies the rubric. Returns findings with row or cell reference.
- **QA**: render the output (open the xlsx in LibreOffice or export to PDF; look at it) and confirm a reader sees opening totals, differences and sign-off block without scrolling through helper columns.

## Required inputs (the user supplies; nothing defaulted silently)
1. Both sources, raw and untouched, and which is authoritative.
2. Cutoff date (and timezone if timestamps), period, currency, sign convention.
3. For variance: the comparison basis (budget, forecast, prior period), the driver data (units, prices, headcount, categories).
4. Materiality and escalation thresholds, and age-bucket limits. Any figure quoted in an upstream skill (for example 10% vs budget) is illustrative only; never apply it unasked.
5. Who prepares, who reviews, what counts as support.
6. What "three-way" means if the user uses the term. Sources conflict: vendor statement vs subledger vs ledger, or purchase order vs receipt vs invoice. Ask; state the answer at the top of the output.

## Reconciliation protocol
1. Fix the cutoff and load both raw files. Compute each opening total by script and tie it to the file (row count, sum, min and max date). Stop if a total does not tie to its source.
2. Normalise only what you must (dates, signs, currency, whitespace), logging each transform. Keep the raw columns.
3. Match: exact key first (reference, amount, date), then tolerance matches (amount equal, date within a window the user sets), then many-to-one groups. Record the rule that matched each pair.
4. Itemise every unmatched or differing line. Classify it:
   - **Timing**: will clear on its own (in transit, unposted batch, cutoff slip). Say the expected clear date.
   - **Adjustment**: needs a journal or correction. Draft it as a proposal only.
   - **Investigate**: cause unknown. Say what was checked.
5. Age each open item from its origin date to the cutoff: 0-30, 31-60, 61-90, 90+ days. Flag items over the user's escalation threshold.
6. Prove the arithmetic: source A total, plus/minus listed items, equals source B total. The unreconciled remainder is zero, or it is shown as its own "investigate" lines. Never a plug, a rounding line or a "misc" row to force zero.
7. Close block per reconciliation: preparer, reviewer, date, support reference. Sign-off stays blank.
Close order when this is part of a month-end: cutoff, subledger close, tie-outs, balance-sheet reconciliations, flux review, period lock. Direct postings to a control account are a finding.

## Variance protocol
1. State the basis, period and sign (favourable or adverse) in one line.
2. Decompose by the method that fits the driver, and show each effect in its own row:
   - revenue or cost: price vs volume, rate vs mix;
   - people cost: headcount vs rate vs timing;
   - otherwise: by category, entity or product.
   Name any residual "interaction" effect explicitly instead of folding it into one driver.
3. Drivers must sum to the total variance; recompute in a second tool. A gap means the decomposition is wrong, not rounded.
4. Apply the user's materiality. Explain what crosses it; list what does not in one line.
5. Narrative per item: specific, quantified, causal, forward-looking (what it means for the rest of the period). Reject circular text ("revenue is up because sales are higher"). A cause is a business event the user or a source document confirms; if unconfirmed it is written as a hypothesis with the question to ask.

## Outputs
- Reconciliation file: totals tie-out, matched count, itemised open items (class, age, expected clear or action, support), close block.
- Variance table: basis, actual, comparison, variance in amount and percent, driver rows, flag against threshold.
- Narrative (half a page), and a "could not check" list: unverified causes, missing support, sources not seen, anything assumed.
- Dated: both sources' extract dates, cutoff, run date.

## Rubric the checker applies
1. Opening totals of both sources tie to the raw files (re-run).
2. Unreconciled difference is zero, or every remainder is an "investigate" line.
3. No plug, rounding or catch-all line.
4. Every open item has class, age and support or a stated gap.
5. Matching rules are recorded; no item counted twice (unique-key check).
6. Drivers sum to the variance (recomputed in a second tool); interaction effect named.
7. Narrative has no circular cause and no unconfirmed cause stated as fact.
8. Signs, currency, cutoff and basis stated; thresholds are the user's and cited as such.
9. Rendered output looked at; nothing truncated or hidden.
10. Proposed adjustments marked as proposals, none posted.

## Only the user can do
Set thresholds, tolerances and materiality; confirm causes; approve adjustments and journals; post anything to a ledger; sign off the reconciliation and the close; decide on write-offs. Accounting treatment questions go to a qualified accountant for review.

## Go deeper
anthropics/knowledge-work-plugins (Apache-2.0): `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install finance@knowledge-work-plugins` (reconciliation and variance-analysis; connectors are optional and it works on pasted data). For xlsx output skills see `document-skills@anthropic-agent-skills`.
