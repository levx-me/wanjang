# Self-check (step 6)

Fix every item before publishing.

## Frame
- [ ] The "Hard rules" in SKILL.md all hold (IDs, secrets, field dumps, unconfirmed points
      marked, framing, language).
- [ ] base.css pasted unchanged; page CSS uses `var(--…)` only (font tokens for another script
      excepted); `body` background comes from the token (it does in base.css).
- [ ] Theme: tokens on `:root`, dark in `@media (prefers-color-scheme: dark)` guarded by
      `:root:not([data-theme="light"])`, and `:root[data-theme="dark"]` (all in base.css).
- [ ] Theme toggle present (top right): switches `data-theme` on `<html>` both ways, label shows
      the current mode, `aria-pressed` + an `aria-label` in the page's language (its `data-*`
      labels), visible focus, choice saved in localStorage inside try/catch, honours an already
      stamped `data-theme`.
- [ ] `lang` set on `nav` and `main`; every fixed label (Contents, the toggle, the decision
      block's field names) is in the page's language.
- [ ] TOC lists every top-level section with its number; the current one is highlighted; short
      names fit on one or two lines.
- [ ] Works at ~400px: ≥16px side gutter, nothing wider than the screen except `.fig` /
      `.tbl-scroll` / `.chart-scroll` / `.tablebox` / `pre`, which scroll in their own container.

## Structure
- [ ] Opening matches its type; nothing but that opening before section 1.
- [ ] Every decision is one `.decide`, at most three per page, written once; elsewhere only a
      link to it. Each has: the question, who decides and by when, what happens with no answer,
      2-3 options plus "do nothing" last, exactly one `.reco` with one reason and one downside,
      and Changes / Cost / Time / Risk / Undo on every option ("unknown" where unknown).
- [ ] 30-second test: the opening tells what this is about, what is asked and how to read it;
      each section's eyebrow + h2 + first sentence tell its point; the h2s alone tell the story.
- [ ] Status tags: only `.ok` / `.prop` / `.open`, only on claims a decision depends on, legend
      in the `.basis` line (at most three items). Count them: `grep -o 'class="tag [a-z]*' page.html | sort | uniq -c`.
- [ ] `.figures` holds 0-4 numbers, each one a decision rests on.
- [ ] One main caveat, stated once near the top; no hedge on every sentence.
- [ ] One numeric example is followed through.
- [ ] No config values, field names or parameters in the body; they are in `.appendix`.

## Counted (non-developer pages; the numbers are starting values)
- [ ] Reading time of the top and body (appendix excluded) about 5 minutes or less, at most 4
      sections plus the decisions. Count:

      python3 -c "import re,sys;h=open(sys.argv[1]).read();h=re.sub(r'(?s)<(style|script|svg|nav)\b.*?</\1>','',h);h=re.sub(r'(?s)<section[^>]*class=\"appendix\".*?</section>','',h);t=re.sub(r'<[^>]+>',' ',h);c=len(re.findall(r'[぀-ヿ㐀-鿿가-힯]',t));w=len(re.sub(r'[぀-ヿ㐀-鿿가-힯]+',' ',t).split());print(w,'words',c,'CJK chars',round(w/200+c/500,1),'min')" page.html

- [ ] Unfamiliar terms on the whole page ≤ 3 (list them); no bracket gloss more than once per
      section; named products or services only where the reader decides about them, each with
      a one-line "what it is".
- [ ] Every body table ≤ 5 columns, ≤ 8 rows, about ≤ 6 words per cell, no sentence in a cell;
      "who has what" is a scorecard.

## Pictures
- [ ] Accent marks only the subject (one series, one node, the recommended option, the
      conclusion numbers); good / warn / bad always come with a word.
- [ ] Charts: Chart.js 4.4.1 from cdnjs only, colours via tokens, redraw on theme change (the
      helper does it), `aria-label` with the finding, numbers also in text or a table, and they
      match.
- [ ] Remove test on every picture: can a bar, a node, a label or the whole picture go without
      losing anything? Remove it. One idea each; no box full of sentences; structure diagrams at
      most 7 nodes, one short line per node.
- [ ] Pictures legible: labels at least 10.5px at the figure's min-width, no label over a box or
      another label; numbers on the picture match the text and the table.
- [ ] Unique marker ids per SVG; every element closed; `<title>` is a 2–4 word name.
- [ ] Optional: one preview/screenshot pass if the session offers it, one round of fixes.
- [ ] Every item of "Writing" in SKILL.md holds (go through them one by one).

## Reader review (paste this part into the reviewer's brief)

The reviewer reads only the page, as the chosen audience reading it for the first time ("You do
not write code. You have five minutes and decide alone." for non-developers). The writer keeps
an answer key for R1-R9 and does not send it. R1-R4 failing blocks publishing on a page with a
decision; the rest are fixed or explained.

| # | Reader's task | Pass when |
|---|---|---|
| R1 | From the top of the page only (up to section 1): what are you asked to decide, by when? | Matches the key. |
| R2 | From the top only: which option is recommended, and why? | Matches. |
| R3 | From the top only: what happens if you pick "do nothing", and if you do not answer? | Both match. |
| R4 | For each option: what does it cost (money, time, risk), and can it be undone? | Every option answered from the page. |
| R5 | What changes for you? | Matches the page's claims. |
| R6 | List every word or name you did not know. | Within the term budget. |
| R7 | What is the page unsure about? | Matches the main caveat. |
| R8 | From the headings alone: what is the conclusion? | Matches. |
| R9 | Five questions the writer predicted a reader would ask. | At least 4 answered from the page. |
| R10 | Where did you stop, reread, or could be misled? | Each place fixed or answered. |

On a page with no decision, R1-R4 become: what is this page telling you, and what, if anything,
must you do?

**Failure samples** (seen on real pages; the reviewer flags any of these):
1. A comparison table of eight columns and twenty rows in the body, cells holding sentences and
   mixed values ("partly: …", "yes (planned)", "?").
2. Six kinds of status tag on one page, most of them about how the writer found the fact rather
   than what is decided, and a page-only tag added on top.
3. A tag or a hedge on nearly every sentence, so the page reads unsure everywhere and the one
   real caveat is lost.
4. Ten or more terms explained in brackets before the first table; product names listed with no
   word on what they are.
5. The same decision asked twice: a box at the top naming two, a table at the end listing four,
   framed differently, with options packed into one cell and "(recommended)" typed in the text.
6. Options with no cost, no risk, no undo, and no "do nothing".
7. Four "key numbers" where the fourth is a date or a count that decides nothing.
8. Eight blocks before section 1, with each top conclusion three sentences long.
9. Six sections and about 7,000 words for a reader who has five minutes; one fold for the lot.
