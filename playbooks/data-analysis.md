# Data analysis: from a question to a number you can defend

> Sources: [anthropics/knowledge-work-plugins `data` (validate-data, statistical-analysis)](https://github.com/anthropics/knowledge-work-plugins) (Apache-2.0), [DuckDB documentation](https://duckdb.org/docs/stable/) (stable pages), [Datawrapper chart-types guide](https://www.datawrapper.de/chart-types), [Financial Times visual-vocabulary](https://github.com/ft-interactive/chart-doctor) (MIT, link only); SQL join, NULL and timezone traps are common practice with no single primary source, so treat them as checks to run, not citations · Written 2026-11-04 · Applies to: any

**Use when:** a metric from SQL, CSV or Parquet; an A/B result; a claim like "up 20%"; a chart or an HTML dashboard. For a spreadsheet that others will edit, read `spreadsheet-model.md`. For matching two ledgers or explaining a variance, read `reconciliation-variance.md`. This playbook ends in a number plus a chart plus a short narrative, not in a model.

## Crew procedure
- **Scout** (if inputs are missing): finds where the data lives, its schema, grain, refresh time and owner; reads any existing definition of the metric. Labels each item Fact (path or URL), Inference or Assumption. Never fills a missing definition.
- **Builder** works in this order: restate the question and the metric definition, query, validate, statistics, chart, narrative. Use **opus** when the result will drive a decision, sonnet otherwise. Saves the queries, a results table per figure and the chart source next to the output.
- **Checker** (fresh context, never the builder) applies the rubric below by re-running queries itself, not by reading the builder's summary. Returns findings with location and severity, and a rating: Ready, Caveats, or Needs revision.
- **QA**: opens the rendered chart or page (browser or image viewer; name it) and reads it as the audience: what does it say, what would they ask next. No rewriting.

## Required inputs
1. The question, in the user's words, and the decision it feeds.
2. Metric definition: numerator, denominator, grain (per user, per order, per day), period, filters, what counts as active or converted. If absent, write a candidate definition labelled Assumption and ask the user to confirm before the numbers are called final.
3. Data source and provenance: who produced it, when, what is excluded.
4. Time zone for all date logic, and whether the latest period is complete.
5. For an experiment: the hypothesis, the primary metric fixed before looking, the planned sample size or stopping rule, assignment unit.

## Method
**Local files.** DuckDB reads CSV and Parquet in place. Do not trust sniffing for anything that matters: set header, delimiter and column types explicitly, keep IDs as text, and compare the row count with the file's line count. Convert large CSVs to Parquet once and query that. Syntax changes between versions, so check the stable docs for the installed version `[verify]`.

**SQL traps** (each is a rubric item):
- Count rows before and after every join; an unexplained change means a fan-out or a dropped key.
- Aggregate to the join grain first, then join.
- Prefer NOT EXISTS to NOT IN when the subquery column can be NULL; NOT IN then returns nothing.
- A filter on the right table in WHERE turns a LEFT JOIN into an inner join; put it in ON.
- Give window functions an explicit frame; the default frame with ORDER BY is not "the whole partition".
- Divide with NULLIF(denominator, 0) and decide what a zero denominator should show.
- State one time zone; convert once, at the edge; define day boundaries in it.
- Do not compare a complete period with a partial one.

**Validation before statistics.**
- The total ties to the source by a second, independent query (different route, not a copy of the first).
- The denominator is the same population across periods being compared.
- No average of averages; recompute from sums and counts.
- Duplicates, NULLs, test or internal rows, and out-of-range values counted and reported.
- Survivorship: ask "who is not in this data?" (churned users, failed events, rows dropped by a filter) and say what the answer changes.

**Statistics.**
- Report mean and median when the distribution is skewed; look at the spread.
- Give an effect size with an interval, not only a p-value. A significant tiny effect is not an important one.
- Do not remove outliers silently; show the result with and without, and say why.
- Count every comparison you ran. Many tests need a correction or a plain statement that the finding is exploratory.
- Re-cut by at least one segment that could flip the result (Simpson's paradox): platform, region, cohort, size.
- Association is not cause; say which design would support a causal claim and whether this one does.
- For an experiment, do not stop when significance appears unless the plan said so.

**Charts.** Choose by the statement being made: bars to compare close shares, a line for change over time, a table when exact values matter. Bars start at zero; a line may not, but say so. Label axes with units, title with the finding, show the period and the data date. Put the numbers behind each chart in a table or text beside it. Colour must not be the only carrier of meaning. Render, open and look at it before handing it over.

**Narrative.** One paragraph per finding, each figure traceable to a results table. Lead with the answer, then the size, the uncertainty and the caveat. Date-stamp the data ("data as of ...") and every market or status figure.

## Outputs
Metric definition; queries; row-count log; reconciliation result; results tables; chart file(s); narrative; "could not check" list; rating (Ready / Caveats / Needs revision).

## Rubric (the checker's list)
1. Metric definition written with grain and period.
2. Row counts shown before and after each join and explained.
3. Query total reconciled to the source by a second, independent query.
4. Incomplete period and time zone handled and stated.
5. Effect size and interval given, not just a p-value; number of comparisons stated.
6. A segment re-cut was run and reported, even if nothing changed.
7. The chart renders (opened and looked at; renderer named); axis labels, units and baseline correct.
8. Every figure in the prose appears in a result table, and recomputes with a second tool.
9. Data date stamped; provenance and exclusions stated.
10. Rating given with reasons; unchecked items listed.

## Only the user can
Confirm the metric definition and the data's provenance, supply anything missing from the inputs, set thresholds (what counts as a meaningful change), and decide what action the result justifies. Nothing here is defaulted silently.

## Could not check (report these every time)
Whether the source data is complete or correct upstream; definitions the user did not confirm; causal claims beyond the design; any DuckDB syntax not tested on the installed version.

## Go deeper
Upstream: `data` plugin in `anthropics/knowledge-work-plugins` (Apache-2.0; warehouse and BI connectors are optional). Install: `claude plugin marketplace add anthropics/knowledge-work-plugins` then `claude plugin install data@knowledge-work-plugins`.
