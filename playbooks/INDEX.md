# Playbooks

Specialist know-how for the Wanjang crew. These ship with the wanjang plugin. The wanjang
reads this index when it splits work and names the playbooks that fit in a worker's brief;
the worker reads them first. Read order: the project's `.claude/playbooks/INDEX.md`, then the
user's `~/.claude/playbooks/INDEX.md`, then this one. A project or the user can shadow a
playbook by name.

One line per playbook: `- [name](file.md) — when to use it`. Write the "when" so it
tells two similar playbooks apart.

## Data
- [postgres-migration](postgres-migration.md) — changing a live Postgres schema without downtime: lock levels, CONCURRENTLY, NOT VALID + VALIDATE, expand/contract renames, batched backfills, Supabase migration files
- [postgres-schema-query](postgres-schema-query.md) — designing tables and writing or tuning queries: types, keys, indexes, EXPLAIN, keyset pagination, SKIP LOCKED queues, RLS performance, pooling

## Backend and delivery
- [api-design](api-design.md) — adding or changing HTTP/JSON endpoints: resources, status codes, problem+json errors, cursor pagination, idempotency keys, versioning, rate limits
- [deploy-config](deploy-config.md) — env vars and secrets, dev/preview/prod, build vs run time, release steps, health checks, rollbacks (Vercel specifics included)
- [cli-design](cli-design.md) — building or changing a command-line tool for people and agents: help, --json, stdout/stderr, exit codes, --dry-run/--yes, TTY detection
- [rust-cli](rust-cli.md) — the Rust side of a CLI (read cli-design first for flags, output, exit codes): crate layout, clap derive, anyhow/thiserror, error-to-exit-code mapping, assert_cmd tests, release profile

## Smart contracts
- [solidity-foundry](solidity-foundry.md) — writing or changing Solidity contracts with Foundry: layout, unit/fuzz/invariant/fork tests, deploy scripts (broadcast only on approval), upgradeable storage layout, CEI and safe tokens
- [contract-audit](contract-audit.md) — reviewing a contract or DeFi change for security: threat model, attack classes (reentrancy, oracle, flash loan, rounding, signatures, upgrades), proving each finding with a Foundry PoC

## Frontend
- [optimistic-ui](optimistic-ui.md) — UI that changes before the server answers (moves, renames, deletes) or reloads after writes: stale-answer guard, per-action rollback, per-item busy state, focus after re-enable, errors announced, corrupt-store recovery (give it to whoever owns the data store too)
- [accessibility](accessibility.md) — UI behaviour and semantics to WCAG 2.2 AA: names, focus, dialogs, drag-and-drop alternatives, target size, live regions, forms
- [nextjs-react-performance](nextjs-react-performance.md) — fast React/Next.js App Router code: waterfalls, server vs client components, bundle size, re-renders, images and fonts, Core Web Vitals

## Quality
- [debugging](debugging.md) — a bug, failure or slowdown with no known cause: feedback loop first, reproduce, instrument boundaries, bisect, fix the cause
- [test-writing](test-writing.md) — writing or fixing tests: seams, independent expected values, determinism, mocks, e2e locators, flaky tests
- [code-review](code-review.md) — reviewing a PR or a worker's diff for design, behaviour, tests and readability; blocking vs nits
- [security-review](security-review.md) — reviewing or building anything that touches auth, payments, permissions, secrets or user data; the checker's security review mode
- [readme](readme.md) — writing or auditing a README: one-line purpose, a quick start that runs, examples, env table, no template boilerplate

## Tooling
- [claude-code-plugin](claude-code-plugin.md) — building Claude Code plugins, hooks, skills, subagents or MCP servers: hook output caps, which events reach main vs subagents, block semantics, version-keyed cache, context cost

## Product and marketing
- [product-discovery](product-discovery.md) — finding out who needs what before building: Fact/Inference/Assumption, jobs to be done, customer-voice mining, interview scripts a human runs, opportunity tree, a result the planner turns into acceptance criteria
- [positioning](positioning.md) — creating or updating the project's docs/product-context.md (audience, alternatives, differentiation, objections, customer language, voice); read first by every other product and marketing playbook
- [marketing-copy](marketing-copy.md) — writing or reviewing copy that ships (landing text, email, ads, posts): inputs, drafting protocol, specificity gate, seven review sweeps, AI-tell list, legal flags
- [page-cro](page-cro.md) — improving a page's conversion: seven factors in impact order, page-type checklists, quick wins / high-impact / test ideas
- [launch-plan](launch-plan.md) — planning a launch: readiness gate, phases, owned/rented/borrowed channels, checklist, email sequence logic
- [pricing-packaging](pricing-packaging.md) — choosing a value metric, tiers and a price method (Van Westendorp etc.); price changes are the user's call
- [seo-basics](seo-basics.md) — search visibility: crawl, technical, on-page, content, authority; untrusted fetched pages; a short AI-search checklist

## Documents
- [deck](deck.md) — slides for investors, a board, sales or a status review: story, one message per slide, text-fit checks (a memo is business-doc, a PDF file problem is pdf-pipeline)
- [business-doc](business-doc.md) — a written Word (docx) document: memo, one-pager, proposal, SOW, report, policy; answer first, real styles, accessible (not slides, not fixed-layout PDF)
- [pdf-pipeline](pdf-pipeline.md) — the file format is the problem: Markdown/HTML to PDF, fill forms, merge/split/redact, extract text or tables, OCR, PDF accessibility

## Finance and data
- [spreadsheet-model](spreadsheet-model.md) — building or auditing an .xlsx others will edit: runway, budget, unit economics, DCF; inputs apart from formulas, checks (not advice)
- [tokenomics-model](tokenomics-model.md) — a token's supply: allocations, cliffs, vesting, emissions, burns, unlock calendar, FDV vs circulating; never decides if it is regulated
- [data-analysis](data-analysis.md) — one dataset to a number, chart and short narrative: SQL/CSV/Parquet metrics, A/B results, "up 20%" claims, join and NULL traps (not a model)
- [reconciliation-variance](reconciliation-variance.md) — two sources must agree (bank vs ledger) or actuals explained against budget; difference accounting, not modelling
- [accounting-treatment-memo](accounting-treatment-memo.md) — a memo on how an entity could account for crypto assets or revenue, ends in review by a qualified accountant; no tax views

## Legal and compliance
- [legal-research](legal-research.md) — what a statute, rule or case says and its status, with cite-checks; the base the other legal playbooks cite; draft for a licensed lawyer
- [contract-review](contract-review.md) — an NDA, SaaS/MSA, DPA or token paperwork checked against the user's positions, or drafted from an open template; ends in qualified counsel review
- [crypto-regulatory-scope](crypto-regulatory-scope.md) — does a licensing, Travel Rule, securities or sanctions regime reach a wallet, SDK, sale or staking feature; a scope map for counsel
- [privacy-compliance](privacy-compliance.md) — privacy notices, data maps, vendor DPAs, data-subject requests (GDPR/CCPA as examples); gap list for a privacy lawyer
