# Figures: SVG diagrams and Chart.js charts

Two kinds of picture, chosen by what they show:

- **Diagrams** (structure, flows, sequences, before/after) are inline `<svg>` inside
  `<div class="fig w-…">`, drawn by hand with the classes below.
- **Charts** (numbers over time or across items) are Chart.js on a `<canvas>` inside
  `.chart-box`, using the `vdChart` helper from the skeleton. See "Charts" at the end.

Every class is styled by `assets/base.css` through theme tokens, so a figure reads correctly in
light and dark with no extra CSS. Never put literal colours on shapes (`fill="#…"`).

## When to draw

Pick the picture with `references/diagram-choice.md`. Most pictures here are **data-shaped**
(bars, ratio strips, timelines, before/after, a worked example table): see "Data-shaped
pictures". The structure grammar below is for the rare section where how the parts connect is
the point: at most 7 nodes, at most one short line per node, one idea per figure, never a box
filled with sentences. Never draw a whole-structure overview for orientation.

## Data-shaped pictures

The default pictures. Each shows one idea, sits in the one section that needs it, and has its
numbers in the text or a table too. Class names are implemented in `assets/base.css`; markup is in
`references/components.md` and the reference page `assets/examples/decision-example.html`.

| Picture | Classes | Rules |
|---|---|---|
| Bars | `.bars` > `.brow` | one scale for all rows, value at the bar end, tiny values get a visible floor and an honest label, the subject in accent |
| Ratio strip | `.split` + `.legend` | segments add to a real whole, a percent label per segment, aria-label lists the shares; no pies or donuts |
| Timeline | `.timeline` | real dates only, one event per mark, 4 or more events |
| Before / after | `.pair` | same rows, same scale on both sides, the change visible without reading |
| Worked example | `.tablebox` or `.steps` | one real figure followed through every scenario |

For custom SVG bars use the "Bars at true proportion" snippet below. Never put sentences inside
a drawn box; if a label needs more than a few words, it belongs in the text.

## Structure grammar (rare; the legend must match it)


| Meaning | Markup |
|---|---|
| A part of the system | `<g class="nd"><rect rx="12–16"/><text class="nt">Name</text><text class="ns">one-line role</text></g>` |
| The subject of the document (one, maybe two) | `.nd.focus` (accent stroke, soft accent fill) |
| The coordinator everything routes through | `.nd.hub` (2px slate stroke) |
| Outside service, or a place that only records | `.nd.ext` (dashed, tinted) |
| Present but idle in this scene | add `.dim` |
| A system boundary (cloud, machine, org) | `<rect class="grp" rx="22"/>` + `<text class="grp-t">UPPERCASE LABEL</text>` |
| The main thing that moves (request, data, money) | `<path class="fl acc" marker-end="url(#a-acc)"/>` (accent) |
| A second kind of thing moving | `.fl.sl` with `#a-sl` (slate) |
| Read / call / record only, nothing moves | `.fl.ledger` with `#a-led` (thin dashed mid) |
| Blocked or conditional path | `.blk` with `#a-blk` + `<g class="blk-x"><circle r="8–9"/><path d="M-4,-4 L4,4 M4,-4 L-4,4"/></g>` (bad tone) |
| Association, no flow | `<line class="tie"/>` |
| Edge label | `<text class="fll">` (`.fll.acc`, `.fll.mid`); has a halo so it may sit on lines |
| Free caption inside the SVG | `<text class="cap">` (`.cap.mono`, `.cap.ink`) |

At most two moving kinds (accent, slate) plus ledger plus blocked. If a third kind is needed,
split the figure. Accent goes on the path the document is about, nowhere else.

Prefer writing the meaning on the picture (`.fll`, `.cap`) over a legend. Add an HTML legend only
when edge styles mix and labels on the picture cannot say it, in the section head or under the
figure:

```html
<div class="legend">
  <span><i class="ln"></i>Request</span><span><i class="ln sl"></i>Reply</span>
  <span><i class="ln ledger"></i>Read only</span><span><i class="ln blk"></i>Blocked</span>
  <span><i class="bx focus"></i>What we built</span><span><i class="bx ext"></i>Outside service</span>
</div>
```

## Markers (declare once per SVG; ids must be unique per page)

```html
<defs>
  <marker id="a-acc" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path class="mk acc" d="M0,0 L10,5 L0,10 z"/></marker>
  <marker id="a-sl" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path class="mk sl" d="M0,0 L10,5 L0,10 z"/></marker>
  <marker id="a-led" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path class="mk ledger" d="M0,0 L10,5 L0,10 z"/></marker>
  <marker id="a-blk" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path class="mk blk" d="M0,0 L10,5 L0,10 z"/></marker>
</defs>
```
Use `marker-start` too for two-way edges. Prefix ids per figure (`m1-acc`, `m2-acc`) when a page
has several SVGs, because duplicate ids resolve to the first one.

## Layout rules

- viewBox widths 520–1000; keep a 20px margin inside it for outer labels and arrowheads.
- Node sizes: small 130–150×44–56, standard 200–270×56–84. Title baseline at y+26, subtitle lines
  every 18–20px below. Text starts 16px from the left edge of the box.
- Draw edges **before** nodes so boxes cover line ends; end arrows 2px short of the box edge.
- Prefer straight or single-curve paths. No crossing if a re-order avoids it.
- Edge labels: about 24 Latin or 14 CJK characters at most; numbers (`① Request`) must match the
  numbered list below.
- Set `.fig.w-NNN` (460 default, 560 / 640 / 760 / 900) so labels stay ≥10.5px; the container
  scrolls sideways on phones. Pick NNN ≈ viewBox width × 0.9.
- `role="img"` and an `aria-label` in the page's language that states what the figure shows in one or two
  sentences (the relationship, not "diagram").

## Minimal structure map

```html
<div class="fig w-760"><svg viewBox="0 0 820 260" role="img" aria-label="…">
  <defs><!-- markers --></defs>
  <rect class="grp" x="20" y="20" width="520" height="220" rx="22"/>
  <text class="grp-t" x="40" y="46">SERVICE</text>
  <path class="fl acc" d="M240,130 L338,130" marker-end="url(#a-acc)"/>
  <text class="fll" x="256" y="120">① Request</text>
  <path class="fl ledger" d="M480,130 L598,130" marker-end="url(#a-led)"/>
  <g class="nd"><rect x="40" y="96" width="200" height="68" rx="14"/><text class="nt" x="56" y="124">Sender</text><text class="ns" x="56" y="144">one-line role</text></g>
  <g class="nd focus"><rect x="340" y="90" width="140" height="80" rx="16"/><text class="nt" x="356" y="120">New check</text><text class="ns" x="356" y="140">what it decides</text></g>
  <g class="nd ext"><rect x="600" y="100" width="200" height="60" rx="14"/><text class="nt" x="616" y="126">Outside service</text><text class="ns" x="616" y="146">read only</text></g>
</svg></div>
```


## Icons, bars, parked nodes

Styled by base.css; copy the snippets and change coordinates and text. Pins (`.pin`), `.ann`
annotations, `.stn` step markers, `.walk` and `.fixbox` are legacy hero patterns: do not use
them in new pages (use `.steps`, `.conclude`, `.tag`).

### Icons

Copy the symbols the page uses from `assets/icons.svg` into one sprite at the top of the page:

```html
<svg class="sprite" aria-hidden="true" focusable="false">
  <symbol id="i-indexer" viewBox="0 0 24 24"><path d="M4 6h11M4 10.5h11M4 15h6"/><circle cx="16.5" cy="15.5" r="3.2"/><path d="M18.8 17.8L21 20"/></symbol>
</svg>
```
In an SVG node, the icon sits 16px in, 14–16px down, and the title moves right to make room:
```html
<g class="nd"><rect x="40" y="126" width="310" height="60" rx="14"/>
  <use class="ic" href="#i-contract" x="56" y="144" width="24" height="24"/>
  <text class="nt" x="90" y="151">Payments service</text><text class="ns" x="90" y="170">anyone can create a refund</text></g>
```
In HTML: `<svg class="ico" aria-hidden="true"><use href="#i-wallet"/></svg>` (in a `summary` or a list item). One icon per concept, the same one wherever
the concept appears. Icons in `.nd.focus` turn accent, in `.nd.ext` mid, by themselves.

| id | concept | id | concept | id | concept |
|---|---|---|---|---|---|
| `i-anyone` | anyone, outsider | `i-member` | user on a phone, member | `i-wallet` | wallet, funds |
| `i-key` | key, secret, signer | `i-lock` | locked, immutable | `i-shield` | protection |
| `i-ok` | verified, safe | `i-x` | fails, rejected, false positive | `i-vote` | vote, governance |
| `i-sliders` | parameters, risk settings | `i-contract` | contract, document, paper | `i-log` | log, text lines |
| `i-book` | order book, ledger | `i-batch` | batch job, list | `i-db` | database |
| `i-server` | server, infrastructure | `i-indexer` | indexer, lookup | `i-search` | review, search |
| `i-merge` | merge, filter, funnel | `i-review` | human review, visibility | `i-eyeoff` | hidden, not visible |
| `i-bot` | bot, automation | `i-aipr` | AI pull request | `i-package` | dependency, package |
| `i-bug` | code bug | `i-chain` | chain, link | `i-bridge` | bridge |
| `i-oracle` | oracle, signal | `i-faucet` | faucet, drip | `i-pool` | liquidity pool |
| `i-liq` | liquidation, drop | `i-cut` | forced close, cut | `i-thin` | thin market |
| `i-same` | nothing changed | | | | |

### Bars at true proportion (`rect.bar`, `.bn`, `.bv`)

One scale for the whole figure: width = value × (track width ÷ largest value). Never stretch a
tiny bar to be visible; give it a 2–3px floor and let the value label say the rest. Group rows
with `.grp-t` headings when the grouping is the point.
```html
<!-- scale: 380px / 7.653 -->
<text class="bn" x="20" y="59">Plan A</text><rect class="bar acc" x="230" y="48" width="380" height="14" rx="3"/><text class="bv ink" x="618" y="59">7.653</text>
<text class="bn" x="20" y="83">Plan B</text><rect class="bar" x="230" y="72" width="69.8" height="14" rx="3"/><text class="bv" x="307.8" y="83">1.405</text>
<text class="bn" x="20" y="107">Plan C</text><rect class="bar" style="--c: var(--c3)" x="230" y="96" width="2.9" height="14" rx="1"/><text class="bv" x="240.9" y="107">0.059</text>
```
Tones: default slate, `.acc` (the subject), `.mid`, `.faint` (unknown / not counted), `.good`
`.warn` `.bad`, or `style="--c: var(--cN)"` for a category. A part-of-whole bar is one row of
segments with `.bar-t` labels inside (`.bar-t.ink` on light segments) and a `.brk` bracket over
a span. Put the numbers in a `<details>` "Show as a table" too.

### Dim and parked nodes

`.nd.dim` (any node type, e.g. `.nd.ext.dim`) for options that are parked, later or out of scope:
present so the whole stays visible, quiet so the eye skips them. Say why in its `.ns` line
("phase 2", "on hold").

## Charts (Chart.js)

### Chart, SVG or table?

| The reader needs… | Use |
|---|---|
| a trend over time, a change between periods, many points | Chart.js **line** |
| 3–12 items compared on one measure | `.bars` or hand-drawn SVG **bars at true proportion** ("Bars at true proportion"); Chart.js bar only when the reader needs hover or many items |
| a range or a before → after per item (start–end, min–max) | horizontal **dot/range**: Chart.js floating bar (`data: [[from, to], …]`, `indexAxis: 'y'`) or an SVG with `.gl` / `.ax` |
| 2–6 shares of one whole | `.split` + `.legend` (no chart) |
| exact values to look up, or fewer than ~5 numbers | a `.tablebox` or `.figures` |
| structure, only when it is the point (at most 7 nodes) | an SVG diagram |

No pies, donuts, 3D, dual axes or stacked areas with more than 3 series. One chart per point.

### Setup

Only when the page has a chart, keep the skeleton's optional block: the single script
`https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js` and the `vdChart`
helper. No other chart library or plugin file.

```html
<div class="card-title"><h3>Orders handled a week</h3></div>
<div class="chart-box"><canvas id="c-trend" role="img" aria-label="Over four weeks, orders handled rose from 120 to 180 a week."></canvas></div>
<div class="chart-legend"><span style="--c: var(--accent)">This year</span><span class="dash" style="--c: var(--slate)">Last year</span></div>
```

```js
const trend = vdChart(document.getElementById('c-trend'), (t) => ({
  type: 'line',
  data: { labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'], datasets: [
    { label: 'This year', data: [120, 140, 165, 180], borderColor: t('--accent'), backgroundColor: t('--accent'), borderWidth: 2.4, pointRadius: 3, tension: .3 },
    { label: 'Last year', data: [118, 121, 119, 124], borderColor: t('--slate'), backgroundColor: t('--slate'), borderWidth: 1.6, borderDash: [5, 4], pointRadius: 0, tension: .3 }
  ] },
  options: { responsive: true, maintainAspectRatio: false, interaction: { mode: 'index', intersect: false },
    plugins: { legend: { display: false }, tooltip: { backgroundColor: t('--core'), titleColor: t('--ink'), bodyColor: t('--ink'), borderColor: t('--faint'), borderWidth: 1, padding: 10 } },
    scales: { x: { grid: { display: false }, border: { color: t('--faint') } }, y: { grid: { color: t('--hair') }, border: { display: false } } } }
}));
// after a chip changes what build() reads: trend.redraw();
```

- **Colours only from tokens** through `t('--name')` / `t.c(n)`: the subject series `--accent`
  (2.4px), the baseline `--slate` (1.6px, dashed), other categories `--c1`…`--c8` in order.
  Grid `--hair`, axis `--faint`, text `--mid`, tooltip on `--core`. The helper rebuilds every
  chart when the theme changes, so never cache colours outside `build`.
- Hide Chart.js's own legend and use `.chart-legend` (same colours; `.dash` for dashed series).
- `maintainAspectRatio: false`; the height comes from `.chart-box` (340px, `.sm` 260px, 280px on
  phones). Many categories: wrap in `.chart-scroll` so it scrolls sideways.
- Axes: ticks name values the data reaches; do not start a small-change axis at 0; label units in
  the card title (`(orders)`, `(%)`) rather than on every tick; log scale only when values span
  orders of magnitude, and say so in the card text.

### Accessibility and fallback

- Each `<canvas>` gets `role="img"` and an `aria-label` in the page's language stating the
  finding with its key numbers ("…rose from 120 to 180 a week"), not "chart".
- The numbers must also exist as text: a `.figures` block beside it, a table (inline or in a
  `details.more` "Show as a table"), or the section paragraph. If the script fails to load, the page
  still says everything.
- Numbers in the chart, the label, the text and the table must match.
