# Component catalogue

Everything here is styled by `assets/base.css`. The page is **one reading column** (`main`,
max 880px, body 16px / line-height 1.7) with the left table of contents and the theme toggle
from the skeleton. Text, tables, bars and charts all sit in that one column; there is no grid of
cards. A card (white surface, hairline) appears only where it groups something: `.decide`,
`.pair`, `.goal`, a chart box. Reference page: `assets/examples/decision-example.html`
(structure, tone and the decision block only; copy no facts). Labels in the examples below are
English; write them in the page's language.

## Page frame
| Piece | Markup | Use |
|---|---|---|
| Table of contents | `nav.toc-side[lang]` + `details.toc-top` with empty `ol.toc-list` (in the skeleton) | **Always.** Filled by script from each top-level `section[id]` (a `.decide` inside a section is not listed): number and name from the section's `.eyebrow` (`2 · Seats` → `2`, `Seats`); `data-toc` on the section overrides the name. Fixed left rail ≥1180px, sticky "Contents ▾" below. |
| Top row | `header.hero > .topbar > span.eyebrow + button.theme-btn` | **Always.** Eyebrow line left (project · audience · status · date), theme toggle right; its four `data-*` labels in the page's language. |
| Section | `section#id[aria-labelledby] > p.eyebrow + h2#… + p …` | Eyebrow is a numbered noun (`2 · Seats`). h2 is a question or a claim (`Who gets the first 1,000 seats?`, `Left alone, it fills up in March`). Then text, evidence, and a `.conclude` where the section reaches one. Sections are separated by a hairline and 56px. Use `h3` for sub-parts inside a section. |

## Openings
Three ways to open a page (the skeleton has A, with B and C as commented alternatives).
`references/doc-types.md` says which to use.

**A · Story** (design, proposal, explainer): `.eyebrow` line → `h1` → `p.lede` ending with the
reading order → one `p.basis` line (the tags used and what the numbers rest on) → `.figures`
(0-4) → `ol.readorder`. Conclusions come inside the sections after their evidence
(`.conclude`); decisions are `.decide` blocks in the last section.

**B · Conclusion first** (review results, reports): `.eyebrow` → `h1` (the answer) → one
`p.basis` line → three conclusions as `ol.steps` (each at most two short sentences, the first in
bold, plus a link to its section) → the `.decide` block(s) if the reader must decide →
`.figures` (0-4) → sections.

**C · Decision** (the page exists to get an answer): `.eyebrow` → `h1` (the question, or the
recommended answer, in one sentence) → `p.lede` (what we need from you and by when, what we
recommend and why, what happens with no answer) → one `p.basis` line with the main caveat → one
`.decide` per decision (at most three) → at most four sections of reasons → the appendix.

In every opening a decision appears once, as its `.decide`; the rest of the page links to it
(`<a href="#d1">`), never restates it.

## Opening pieces
| Block | Markup | When |
|---|---|---|
| Eyebrow | `p.eyebrow` / `span.eyebrow` | Top line of the page and of every section. Small mono caps, mid colour. |
| Lede | `p.lede` | One paragraph under the h1, 18px ink: what and why, then the reading order (A) or the ask (C). |
| Basis line | `p.basis > span.tag … + b(label) + text` | One line under the h1: the status tags the page uses with a word each (at most three), what every number rests on (period, volume, prices), and how well it is known. Replaces a separate legend. |
| Status legend | `p.taglegend` | Legacy name, still styled: a legend on its own line. New pages put the legend in `.basis`. |
| Number strip | `.figures > .fig > span.v + span.k` (`small` in `.v` for a unit) | **0-4 numbers, only numbers a decision rests on**; leave it out when there are none. One column per number, accent rule above each; 2 per row under 640px. More numbers go to a table. |
| Reading order | `ol.readorder > li > a[href="#sec"] > b(name) + ": question"` | Opening A: one line per section, the section's eyebrow name in bold and its question. |
| Purpose box | `div.goal > p` (optional `p.eyebrow` label) | Optional: the one purpose the page serves. A white card, at most one per page. Never holds a decision (that is `.decide`). |

## Decision block
One per decision, at most three per page. The markup is a contract shared with the `brief`
skill; keep the classes exactly.

```html
<section class="decide" id="d1" aria-labelledby="d1-q">
  <h3 class="decide-q" id="d1-q">Which sign-in should customers use from March?</h3>
  <p class="decide-meta"><b>Decides</b> Head of product · <b>By</b> 2026-12-01</p>
  <p class="decide-meta"><b>No answer</b> we keep passwords only and start nothing</p>
  <div class="opt reco">
    <h4>Add email sign-in links <span class="reco-label">Recommended</span></h4>
    <p class="opt-why">Halves the "forgot password" tickets. Customers on slow email wait a minute to get in.</p>
    <dl class="opt-facts">
      <dt>Changes</dt><dd>Customers can sign in from a link, or keep their password</dd>
      <dt>Cost</dt><dd>About $30 a month for sending email</dd>
      <dt>Time</dt><dd>3 weeks</dd>
      <dt>Risk</dt><dd>Links land in spam for some providers</dd>
      <dt>Undo</dt><dd>Yes, switch off at any time</dd>
    </dl>
  </div>
  <div class="opt">…a real alternative, same five facts…</div>
  <div class="opt none"><h4>Do nothing</h4><dl class="opt-facts">…what keeps happening, and its cost…</dl></div>
</section>
```

| Piece | Markup | Rule |
|---|---|---|
| Block | `section.decide#dN` | Stable id `d1`, `d2`, `d3`: it survives revisions and is the id of the paired AskUserQuestion. A grey panel; options sit on it as cards. `aria-labelledby` pointing at the question is recommended. |
| Question | `h3.decide-q` | One sentence the reader can answer. |
| Who and when | `p.decide-meta` with `b` labels | `Decides` who · `By` a date or "no deadline". A second `p.decide-meta` says what happens if nobody answers, and when; it can differ from "do nothing" ("work waits" vs "we go ahead with the recommendation on 1 Dec"). |
| Option | `div.opt > h4 + dl.opt-facts` | 2-3 real options, then "do nothing". The name is 1-5 words in the reader's terms, never a technical noun. Order = the wizard's order: recommended first, do nothing last. |
| Recommended | `div.opt.reco`, `h4 > span.reco-label`, `p.opt-why` | Exactly one. `opt-why` holds one reason and one downside, both one sentence. Accent ring and a lift. |
| Facts | `dl.opt-facts > dt + dd` × 5 | `Changes` (one sentence, for the reader), `Cost`, `Time`, `Risk`, `Undo` (yes / until a date / no), in the page's language. A missing value is written "unknown", never left out. Labels stack above values under 420px. |
| Do nothing | `div.opt.none` | Always last. Dashed outline, no fill. States what keeps happening and what that costs. |
| Answer (receipt) | `div.opt.chosen` on the picked option + `p.decide-answer` after the meta | After the reader answers: the picked option gets a green ring, and `p.decide-answer > b(answer) + text` says what was picked, any comment, who answered and when. The decision is then closed; a later change is a new page. |

A decision with more than three options, or options that need a table to compare, is two
decisions or a decision the writer has not narrowed yet: narrow it before writing the block.

## Status tags
Three decision states, always with the word inside the tag (colour never carries meaning alone):
`span.tag.ok` confirmed · `span.tag.prop` proposed · `span.tag.open` undecided. This is a closed
set: a page never adds a tag kind (no page-only `.tag.xyz`) and never relabels one. Tag only a
claim the decision depends on; a claim with no tag reads as settled, so an unsettled claim the
decision does not depend on goes to the appendix or is said plainly in the sentence. How well
something is known (checked, from search, not found) is not a tag: say it once in `.basis`, or
per row in an appendix table. Put a tag after an h3, in a small table's status column, or inline
after the sentence it qualifies.

```html
<p class="basis"><span class="tag ok">Confirmed</span> decided · <span class="tag prop">Proposed</span> for review · <span class="tag open">Open</span> not decided. <b>Numbers assume</b> 1,200 orders a day, prices as of 1 October; supplier figures are from their public pages, not checked with them.</p>
<h3>Orders ship from one warehouse <span class="tag ok">Confirmed</span></h3>
```

Legacy: `.tag.calc` and `.tag.assume` are still styled so old pages render; new pages do not
use them.

## Section blocks
| Block | Markup | When |
|---|---|---|
| Conclusion box | `div.conclude > p.eyebrow(Conclusion)? + p > b(one sentence) + text` | Where a section concludes, **after** its evidence. One per section at most. Accent tint with an accent edge. |
| Steps | `div.steps > div.step > p > b + text` (or `ol.steps > li`) | An ordered process, a set of mechanisms, or opening B's three conclusions. Circled numbers; bold first sentence. |
| Pair | `div.pair > div > h3 + p/ul` (two children) | Pros / cons, before / after. Two small cards side by side, stacked under 720px. Two options the reader must choose between are a `.decide`, not a pair. |
| Ratio strip | `div.split[role=img][aria-label] > span[style="--f: 70; --c: var(--c1)"]` (+ `span.out` for a part outside the whole) + `div.legend > span > i[style="--c: …"] + name` | One whole split into shares (where each sale goes). `--f` is the number, so widths are true. Segment text is short (a number); the legend carries the names. |
| Bars | `div.bars[role=list] > div.brow[role=listitem](.on) > span(name) + span.bar > b[style="width: NN%; --c: …"] + span.v` | 2–10 labelled shares or sizes. Widths at true proportion (largest = 100%). `.on` marks the subject in accent. |
| Timeline | `div.timeline[role=img][aria-label] > svg[aria-hidden]` with `line.track`, `rect.ph` (phase), `circle.ev(.alt)` (event), `text.t` (label), `text.s` (note) | Things in time order: a lifecycle, a schedule, phases. Scrolls sideways under 640px. |
| Table | `div.tablebox > table` with `caption` (units, source, date), `th.r`/`td.r` (numbers, right), `td.k` (row name), `tr.hl` (the row that matters) | Numbers behind a picture, a small comparison. **In the body: at most 5 columns, 8 rows, about 6 words per cell, no sentence in a cell.** Bigger tables go to the appendix (inside a `details.more`) with one sentence in the body saying what they show. Cells wrap; the first column and numbers do not. |
| Scorecard | `div.tablebox > table` whose cells hold `span.sc.yes` / `.sc.part` / `.sc.no` / `.sc.unk` with a word | "Who has what": one word per cell from a closed set (yes / partly / no / unknown) next to a filled, half, empty or dashed dot; rows sorted by what matters; the finding in one sentence under it. Compare the 3-5 that matter in the body; the rest in the appendix. |
| Chart | `div.shell > div.core > div.chart-box > canvas[role=img][aria-label]` + `div.chart-legend` | Trends over time (Chart.js via `vdChart`, see skeleton). Always followed by a `.tablebox` or text with the same numbers. |
| Folded detail | `details.more > summary + p/…` | Detail most readers skip: method, caveats, full lists. One level only: no fold inside a fold. |
| Appendix | `section.appendix` (eyebrow `Appendix · Details` or `Appendix · For developers`) | Last section, quieter type. **Details**: long tables, sources, method, a glossary fold (`details.more > dl.kv`). **For developers**: files, functions, commands. A page may have both labels in one appendix (two `h3`s) or pick one. |

```html
<table>
  <thead><tr><th>Provider</th><th>Email links</th><th>Phone codes</th></tr></thead>
  <tbody>
    <tr class="hl"><td>Ours today</td><td><span class="sc no">No</span></td><td><span class="sc yes">Yes</span></td></tr>
    <tr><td>Provider A</td><td><span class="sc yes">Yes</span></td><td><span class="sc part">Partly</span></td></tr>
    <tr><td>Provider B</td><td><span class="sc unk">Unknown</span></td><td><span class="sc yes">Yes</span></td></tr>
  </tbody>
</table>
```

```html
<section id="s2" aria-labelledby="h-s2">
  <p class="eyebrow">2 · Orders</p>
  <h2 id="h-s2">Most orders come from the web shop</h2>
  <p>Orders by channel over the last 90 days.</p>
  <div class="bars" role="list" aria-label="Orders by channel">
    <div class="brow on" role="listitem"><span>Web shop</span><span class="bar"><b style="width:100%"></b></span><span class="v">60%</span></div>
    <div class="brow" role="listitem"><span>Phone</span><span class="bar"><b style="width:41.7%; --c: var(--c2)"></b></span><span class="v">25%</span></div>
  </div>
  <div class="split" role="img" aria-label="Each sale: supplier 70%, shipping 18%, card fees 2%, margin 10%">
    <span style="--f: 70; --c: var(--c1)">70%</span><span style="--f: 18; --c: var(--c2)">18%</span><span style="--f: 2; --c: var(--c8)"></span><span style="--f: 10; --c: var(--c3)">10%</span>
  </div>
  <div class="legend"><span><i style="--c: var(--c1)"></i>Supplier</span><span><i style="--c: var(--c2)"></i>Shipping</span><span><i style="--c: var(--c8)"></i>Card fees</span><span><i style="--c: var(--c3)"></i>Margin</span></div>
  <div class="conclude"><p class="eyebrow">Conclusion</p><p><b>The web shop carries the business.</b> The next section asks what to change there first.</p></div>
</section>
```

## Other blocks (still supported)
| Block | Markup | Best for |
|---|---|---|
| Callout | `.note(.warn/.bad/.good) > b.pill-n + div` | A caution or a status note inside a section. |
| Bullet notes | `ul.notes > li` | Caveats, consequences, short facts. |
| Actions | `ol.act > li > div(b + text) + span.who` | Who does what next. |
| Definitions | `dl.kv > div > dt + dd` | Terms (the glossary fold), settings, fields. |
| Situations | `.state > div > span.when + span.what` | "When X, the reader sees Y". |
| Filter chips | `.chips[role=group][aria-label] > button.chip[aria-pressed]` | Switching a chart's metric. |
| Code | `pre.code` | Only when the reader will type or check it (usually in the appendix). |
| FAQ | `.faq > details > summary + div.body` | Questions. |
| Diagram | `.fig.w-NNN > svg` + `.legend` | Relationships and structure; see `svg-vocabulary.md`. `.fig` alone is the diagram wrapper; inside `.figures` it is a number. |
| Source line | `p.foot` | Data source, as-of date, at the end. |

## Legacy (old pages keep working; do not use on new pages)
`.bento` / `.span-*` grid of cards, `.sec-head` + `.pill` section heads, the hero conclusion grid
`.cc` / `.cc-card`, the hero key-number line `.counts`, the hero map card `.map-head` / `.swipe`,
the pin list `.walk` / `.pn` under a hero map, `.kf` / `.kpis` / `.stats` number tiles, the
`.tag.calc` / `.tag.assume` tags, `.taglegend` as its own line, and a decision as a `.goal` box
or a table. Their replacements: one column, `.eyebrow` + h2, `.conclude` after evidence,
`.figures`, `.steps`, the three tags in `.basis`, `.decide`. `.pin` / `.ann` / `.stn` / `.fixbox`
remain fine inside a section's own diagram.

## Colour use
- `--accent` marks the one thing to look at: the subject bar, the number strip rule, the current
  TOC entry, conclusion boxes, the recommended option. Do not spread it.
- `--slate` is the comparison / baseline (and the scorecard dots). `--good` `--warn` `--bad`
  only for real states, always with a word; `--good` also rings the chosen option.
- `--c1`…`--c8` are categorical series, in order; `--c8` is "other".

## Utilities
`.small` (14px, mid) · `.muted` (mid colour) · `.num` / `.mono` (tabular mono) · `.mt8` ·
`.stack` · `.reveal` (entry motion, visible at rest).

## Page-only CSS
Allowed for genuinely new pieces (a figure min-width, a special chart height) and for the font
tokens of a script the font link does not cover (`page-markup.md`). Use only `var(--…)` tokens,
never literal colours, never override base components' spacing, and never add a status tag.
