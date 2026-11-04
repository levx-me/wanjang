# Crypto regulatory scope: does regime X reach this product?

> Sources: [Regulation (EU) 2023/1114, MiCA](http://publications.europa.eu/resource/celex/32023R1114) and [Regulation (EU) 2023/1113, transfer of funds and crypto-assets](http://publications.europa.eu/resource/celex/32023R1113) (EU Official Journal, public), [FATF Updated Guidance on Virtual Assets and VASPs, Oct 2021](https://www.bvifsc.vg/sites/default/files/updated-guidance-va-vasp_2021.pdf) (regulator-hosted copy), [OFAC virtual currency FAQs](https://ofac.treasury.gov/faqs/topic/1626) (US public domain); method pattern from [anthropics/claude-for-legal](https://github.com/anthropics/claude-for-legal) (Apache-2.0), nothing copied · Written 2026-11-04 · Applies to: any

**Use when:** someone asks whether a licensing, transfer-information, securities, commodities or sanctions regime reaches a wallet, protocol front end, SDK, token sale, staking or custody-adjacent feature. Output: a scope map for counsel, never a legal opinion. For finding and citing law in general use `legal-research.md`; for a contract use `contract-review.md`; for personal data use `privacy-compliance.md`; for the token's numbers use `tokenomics-model.md`.

## Crew procedure
- **Scout** (sonnet): collects the product facts from the user (list below) and marks each Fact (source), Inference or Assumption. Lists candidate regimes for each jurisdiction the user names, in four families: licensing/authorisation, payments and transfer information (Travel Rule), securities and commodities, sanctions. Fetches each regime's primary text live (never from memory), recording URL, retrieval date and in-force status.
- **Builder** (opus for anything a decision rests on, else sonnet): for each regime, reads the definitions and the operative scope articles, tests the facts against them, and writes one row: in scope / out of scope / unclear, with the article and the facts it turned on. Writes the scope table, the open questions and a "facts that would change the answer" list to the path the brief names.
- **Checker** (fresh context, never the builder): opens every cited URL and confirms the text says what the row says (see Rubric). Re-runs the fact test on three random rows before reading the builder's reasoning.
- **QA**: renders the memo (pandoc or LibreOffice headless to PDF) and looks at it: table fits, links resolve, banner and counsel line visible.

## Required inputs (the user's; none defaulted silently)
- Jurisdictions in play: where the entity is, where users are, where the product is marketed. If not given, stop and ask; do not assume the EU or the US.
- **Control facts**, the ones that decide scope in most regimes:
  - Keys: who holds or can move user assets (user only, the company, a multisig with company signers, a third-party custodian).
  - Upgrades and parameters: who can upgrade contracts, pause, change fees or set parameters; admin keys; timelocks; whether contracts are immutable.
  - Front end: who hosts and runs it, and whether it routes orders, quotes prices or picks counterparties.
  - Money: fees taken, by whom, on what; token issued or sold, to whom, with what rights or promises.
  - Users: accounts, onboarding, an ongoing relationship, support, geo-blocking.
- Product description and architecture, with the version and date it describes.
- Prior counsel advice, licences held, regulator contact (sharing is the user's call).

A missing fact becomes an open question; rows resting on it are unclear.

## Method
1. **List regimes, not conclusions.** Per jurisdiction, one line per candidate regime with its primary source. Examples to show the shape (fetch each live):
   - EU: MiCA (Reg. 2023/1114) for issuance and crypto-asset services; the transfer-information rules (Travel Rule for crypto) are in Reg. 2023/1113, a separate regulation, not in MiCA. Financial instruments under MiFID II sit outside MiCA `[verify]`. ESMA and EBA texts on DeFi and on MiCA's review: fetch from esma.europa.eu `[verify]`.
   - International standard: FATF Recommendations 15 (virtual assets, VASPs) and 16 (payment transparency, revised June 2025 `[verify]`), plus FATF's targeted updates. Standards bind no one directly; cite the national law implementing them.
   - US: SEC and CFTC classification of crypto assets (a joint interpretation of March 2026 and later rule proposals are reported `[verify]`, fetch the Federal Register text); the Howey test for sales; OFAC sanctions and its virtual currency FAQs. Pending bills (for example the CLARITY Act) are proposals, not law, until enacted: fetch their current status with a date.
2. **Read the definition before the exemption.** Find the regime's defined terms (crypto-asset service, VASP, money transmission, security, custody) and test each fact against them. Then read exemptions in the operative articles.
3. **Recitals are not articles.** Example (checked 2026-11-04 against the OJ text): MiCA recital 22 says fully decentralised services with no intermediary should fall outside the Regulation, but the same recital keeps services performed or controlled directly or indirectly by a person in scope, even if part is decentralised. It is interpretive, not an operative exemption, and "fully decentralised" is not defined. Admin keys, front-end control and upgrade power weigh toward scope.
4. **Guidance is not law, and has a date.** Example (verified from the 2021 text, paras 67-69): FATF says a DeFi application, the software alone, is not a VASP, but creators, owners, operators or others with control or sufficient influence may be, even where the arrangement looks decentralised; calling it DeFi is not decisive. Later FATF updates were not read: fetch the current guidance.
5. **Case law has a court and a reach.** Label each holding with the court, date and where it binds. Example (secondary sources only, `[verify]` against the opinion): a US Fifth Circuit ruling of Nov 2024 held immutable smart contracts are not sanctionable property under IEEPA; it binds that circuit only and does not cover mutable contracts or the people behind them.
6. **Function by function.** Split the product into functions (key management, swap routing, staking, fiat on-ramp, token sale, custody of a fee balance) and run steps 2-5 per function. One in-scope function makes the product partly in scope.
7. **Sanctions run regardless.** Note whether the product screens addresses and persons, and against which lists (e.g. OFAC SDN lists carry digital currency addresses but are not exhaustive). Screening is the user's operational choice; the memo only records it.
8. **Risk register (optional).** Per unclear or in-scope row: consequence, likelihood, owner, escalation trigger. The scales are the user's.

## Output
```
DRAFT for review by qualified counsel in <jurisdictions>. Not legal advice. As of <date>.
| Jurisdiction | Regime (primary cite, as-of, in force?) | Function | Definition tested | Facts relied on | Result: in / out / unclear | Article / para |
```
Then: open questions for counsel (numbered, each naming the row); facts that would change the answer ("if the company signs the multisig, row 3 moves to in scope"); proposals and pending changes kept in their own list with status dates; a "could not check" list (every source that could not be opened, and why).

## Rubric (the checker's list)
1. Every regime has a primary citation (official text or regulator site), retrieval date and in-force status. No secondary article stands in for the law.
2. Every cited URL was opened during this task, and the quoted or paraphrased point appears at the cited article or para.
3. Recitals are marked as recitals; guidance as guidance with its date and issuer; standards (FATF) apart from the national law implementing them.
4. Each case holding names its court, date and binding reach; none is generalised beyond it.
5. Proposals, consultations and bills sit apart from law, with a status date checked against the source.
6. Each row lists the facts it depends on, and each fact is traceable to the user or marked Assumption.
7. No row and no summary says "compliant", "exempt", "not a security", "not a VASP" or "no licence needed" as a conclusion. Allowed: "the facts as given point toward / away from scope under Art. X; unclear because Y".
8. No jurisdiction was assumed; every one in the table was named by the user.
9. Every figure or threshold carries its source and date, taken from the text, not memory.
10. The draft banner and the counsel line are present; the "could not check" list closes the memo.

## Fetching
- EU texts: if eur-lex pages fail, request the Official Journal text from the Publications Office by CELEX number: `curl -L -H "Accept: application/xhtml+xml" -H "Accept-Language: eng" http://publications.europa.eu/resource/celex/32023R1114` (works for 32023R1113 too).
- FATF's site often refuses automated fetches; look for a regulator-hosted copy of the same PDF and extract its text locally, then check the title page and date match.
- US: Federal Register and agency sites for rules; the opinion PDF for cases. Summarising fetches can be stale: prefer the raw document.
- Still unreadable: it stays `[verify]` and is not relied on.

## For you
- Supply and confirm the control facts; the answer depends on them, and only you know them.
- Choose the jurisdictions, the risk appetite and whether to screen, geo-block or restructure.
- Have the memo reviewed by qualified counsel in each jurisdiction named. Only counsel's opinion settles scope; the memo is input to it.
- Regulator contact, licence applications and public statements on status are yours, with counsel.

## Go deeper
anthropics/claude-for-legal, plugin `regulatory-legal` (tracking regulatory feeds, diffing policies, gap lists; not crypto-specific; Apache-2.0): `claude plugin marketplace add anthropics/claude-for-legal` then `claude plugin install regulatory-legal@claude-for-legal`. No upstream skill for MiCA, FATF or crypto scope was found.
