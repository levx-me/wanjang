# Playbook notices

The repository is MIT. Exceptions and sources are below.

- `cli-design.md` and `security-review.md` are **CC BY-SA 4.0** (they adapt CC BY-SA material: clig.dev, Trail of Bits skills, OWASP).
- The product and marketing playbooks are written in our own words and link the upstream projects; those texts are not included.
- `deanpeters/product-manager-skills` is CC BY-NC-SA 4.0 and is used for method only.
- `contract-review` takes its drafting base from Common Paper Standards and Bonterms (CC BY 4.0); they are attributed there and in its row below.
- Apache-2.0 sources (anthropics/knowledge-work-plugins, anthropics/financial-services, anthropics/claude-for-legal) are attributed in the rows; patterns and ideas are restated, no text is copied.
- The Anthropic docx, xlsx, pptx and pdf skills (anthropics/skills) are proprietary: the playbooks only name them and tell how to install them; nothing is copied or bundled.
- All other playbooks paraphrase their sources; licences are as listed.

| Playbook | Sources and licences |
|---|---|
| accessibility | github/awesome-copilot a11y.instructions (MIT); WCAG 2.2 quick reference and WAI-ARIA Authoring Practices (W3C Document License, paraphrased); axe-core rule tags (MPL-2.0, link only) |
| accounting-treatment-memo | IFRS Foundation Holdings of Cryptocurrencies page and IFRS 15 page (linked, facts only); Big-4 summaries of IFRS digital assets and FASB ASU 2023-08 (secondary sources, to verify; fasb.org not read) |
| api-design | Zalando RESTful API Guidelines, Google AIP, Microsoft REST API Guidelines (all CC-BY-4.0); IETF RFC 9457, 9745, 8594, Idempotency-Key and RateLimit drafts |
| business-doc | Pandoc User's Manual (GPL-2.0, read only, nothing copied); Microsoft Word accessibility guidance (link only); Minto pyramid and BLUF (ideas only); anthropics/skills docx and doc-coauthoring (proprietary or unstated, named only) |
| claude-code-plugin | Claude Code docs (plugins, hooks, subagents, memory, output styles, skills); building the wanjang and Steading plugins |
| cli-design | clig.dev (CC-BY-SA 4.0, paraphrased); no-color.org (link only); the user's own cli-checklist rule. File is CC BY-SA 4.0 |
| code-review | Google Engineering Practices: code review (CC-BY-3.0); awesome-copilot code review instructions (MIT); agency-agents minimal-change engineer (MIT, paraphrased) |
| contract-audit | agency-agents security-blockchain-security-auditor (MIT, paraphrased); SWC Registry; Solodit; OpenZeppelin Contracts docs |
| contract-review | anthropics/claude-for-legal nda-review and anthropics/knowledge-work-plugins legal review-contract (Apache-2.0, pattern only); evolsb/claude-legal-skill (MIT, checklist ideas); Common Paper Standards and Bonterms (CC BY 4.0, drafting base, attributed in the file) |
| crypto-regulatory-scope | Regulation (EU) 2023/1114 MiCA and 2023/1113 (EU Official Journal, public); FATF Updated Guidance on Virtual Assets and VASPs 2021 (regulator-hosted copy); OFAC virtual currency FAQs (US public domain); anthropics/claude-for-legal (Apache-2.0, method only) |
| data-analysis | anthropics/knowledge-work-plugins data validate-data, statistical-analysis (Apache-2.0); DuckDB docs; Datawrapper chart-types guide; Financial Times visual-vocabulary (MIT, link only) |
| debugging | mattpocock/skills diagnosing-bugs (MIT); obra/superpowers systematic-debugging (MIT) |
| deck | Sequoia "Writing a business plan" (section list); andyqiu847-ai/high-quality-slides (MIT); Marp CLI (MIT); python-pptx docs (MIT); anthropics/skills pptx (proprietary, named only) |
| deploy-config | The Twelve-Factor App (CC-BY-4.0); vercel-labs/agent-skills deploy-to-vercel (MIT); Vercel docs (proprietary, linked only) |
| legal-research | Own fetch tests of official texts; WenzhuoXu/lawgent Cite Check (no licence stated, idea only); davendra/uk-legal-skills (FSL-1.1-Apache-2.0, idea only, no text copied); anthropics/claude-for-legal (Apache-2.0, [verify] marking) |
| nextjs-react-performance | vercel-labs/agent-skills react-best-practices (MIT); web.dev Core Web Vitals (CC-BY 4.0); Next.js docs (link only) |
| optimistic-ui | In-house findings from blind reviews of agent-built Kanban apps; React docs (link only) |
| pdf-pipeline | Pandoc manual (GPL, read only); Typst docs (Apache-2.0); WeasyPrint docs (BSD); Marp CLI (MIT); PDF/UA and Matterhorn points unverified; anthropics/skills pdf (proprietary, named only) |
| postgres-migration | strong_migrations (MIT); Squawk rules (Apache-2.0); supabase/agent-skills (MIT); PostgreSQL docs (PostgreSQL Licence); supabase/cli#2898 (MIT repo) |
| postgres-schema-query | supabase/agent-skills (MIT); wshobson/agents postgresql-table-design (MIT); Postgres wiki "Don't Do This" (no licence stated, paraphrased); PostgreSQL docs (PostgreSQL Licence); Supabase RLS docs |
| privacy-compliance | garethmdowns/gdpr-skill (MIT; its ICO template is OGL v3.0); anthropics/knowledge-work-plugins legal compliance-check and anthropics/claude-for-legal privacy-legal (Apache-2.0); GDPR (EU OJ text), CCPA statute and CPPA regulations (public texts); all paraphrased |
| readme | makeareadme.com / dguo/make-a-readme (MIT); the user's own readme-guide rule |
| reconciliation-variance | anthropics/knowledge-work-plugins finance reconciliation, variance-analysis (Apache-2.0); month-end close ordering from public vendor blogs (practice) |
| rust-cli | Command Line Applications in Rust (link only); clap derive docs; agency-agents engineering-rust-refactoring-specialist (MIT, paraphrased) |
| security-review | Trail of Bits skills (CC-BY-SA-4.0, paraphrased); OWASP Cheat Sheet Series and ASVS (CC-BY-SA, paraphrased); awesome-copilot security-and-owasp (MIT); agency-agents security-ai-generated-code-auditor (MIT, paraphrased). File is CC BY-SA 4.0 |
| solidity-foundry | agency-agents engineering-solidity-smart-contract-engineer (MIT, paraphrased); Foundry Book |
| spreadsheet-model | FAST Standard (CC BY 4.0); anthropics/financial-services dcf-model and audit-xls (Apache-2.0, restated); openpyxl and LibreOffice docs; anthropics/skills xlsx (proprietary, named only) |
| test-writing | mattpocock/skills tdd (MIT); anthropics/skills webapp-testing (Apache-2.0); Playwright docs (link only); Google Testing Blog (link only) |
| tokenomics-model | zupy-fmartinelli/solana-tokenomics-skill (MIT); cadCAD (MIT); TokenEngineeringCommunity/resources (MIT); buildmytokenomics.com and tokenomics.com (background only, nothing copied) |
| product-discovery | wondelai/skills mom-test, jobs-to-be-done (MIT); phuryn/pm-skills opportunity-solution-tree, interview-script, summarize-interview (MIT); anthropics/knowledge-work-plugins synthesize-research (Apache-2.0); deanpeters/Product-Manager-Skills voice-of-customer-miner (CC BY-NC-SA 4.0, method only, no text reused) |
| positioning | coreyhaines31/marketingskills product-marketing, customer-research (MIT); anthropics/knowledge-work-plugins marketing competitive-brief (Apache-2.0); brand-voice guideline-generation (MIT, Tribe AI); deanpeters/Product-Manager-Skills positioning-statement (CC BY-NC-SA 4.0, method only) |
| marketing-copy | coreyhaines31/marketingskills copywriting, copy-editing (MIT); anthropics/knowledge-work-plugins marketing content-creation, brand-review (Apache-2.0); brand-voice enforcement (MIT, Tribe AI) |
| page-cro | coreyhaines31/marketingskills cro, signup (MIT); wondelai/skills conversion-optimization, cro-methodology (MIT) |
| launch-plan | coreyhaines31/marketingskills launch, emails (MIT); anthropics/knowledge-work-plugins marketing campaign-plan, email-sequence (Apache-2.0) |
| pricing-packaging | coreyhaines31/marketingskills pricing (MIT); wondelai/skills monetizing-innovation (MIT); phuryn/pm-skills pricing-strategy, monetization-strategy (MIT) |
| seo-basics | coreyhaines31/marketingskills seo-audit, ai-seo (MIT); structure only from anthropics/knowledge-work-plugins marketing seo-audit (Apache-2.0, not used otherwise) |

## Skills

The `brief` skill (`skills/brief/`) is written in our own words; these sources shaped its ideas, and no text is copied.

| Skill | Sources and licences |
|---|---|
| brief | nicobailon/visual-explainer (https://github.com/nicobailon/visual-explainer, MIT): in-page ask and options, build receipt, verdict first; olivervvvv/plain-language-skill (https://github.com/olivervvvv/plain-language-skill, MIT): top block that stands alone, content headings, "source doesn't say", tables to bullets; blader/humanizer (https://github.com/blader/humanizer, MIT): a separate pass for tells, "added or dropped a fact?" check; anthropics/knowledge-work-plugins stakeholder-update, write-spec, status-report and anthropics/skills internal-comms (Apache-2.0): decision line, risk sentence, non-goals, open questions by owner; anthropics/skills doc-coauthoring (licence not confirmed, idea only): reader test with a context-free agent; plain-language guidance (GOV.UK, digital.gov, NN/G, ADR practice, BLUF; cited, ideas only) |
