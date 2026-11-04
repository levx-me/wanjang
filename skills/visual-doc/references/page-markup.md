# Writing the page (step 5)

Write the page into the scratchpad as `<scratchpad>/visual-doc/<slug>.html`.

## More than four sections: parallel workers

A page of more than four sections is written in parallel: write the frame yourself first (everything
up to section 1, the TOC with every section's id, the sprite with every icon the page
uses, page-only CSS), then hand the sections to workers started together in one message,
two or three sections each, at most five. Pick the worker by how much this conversation
holds, since a fork carries all of it on every turn:
- Short conversation (roughly under 100K tokens: a few dozen turns, no long research,
  simulation output or file dumps): forks (`subagent_type: "fork"`), one-line brief each.
- Longer: first write `<slug>.brief.md`, one block per section with exactly what it must say
  (the facts, numbers, conclusion, picture plan from step 3, assumptions to label), then start
  fresh `wanjang:designer` agents (a subagent may start them too), each told to read only the
  frame, the brief's blocks for its sections, this skill's references and `assets/base.css`.
  Nothing else from this conversation reaches them, so a fact missing from the brief is
  missing from the page. Pass the model on every call: `model: "opus"` only for a worker
  whose sections hold a large picture (a structure diagram, the worked example); `model: "sonnet"` for the rest, since the brief already settles what
  to say and draw. If `wanjang:designer` is missing, use `general-purpose` with the same
  model rule.
Each worker writes only its `<section>`s into `<slug>.part-NN.html`, using the frame's ids,
classes and icons and adding no CSS, and never touches `<slug>.html` or another worker's
part. When all have returned, join the parts into the page in order, then self-check the
whole page once.

## Markup

- Start from `assets/skeleton.html`. Order: `<title>` first, Google Fonts `<link>`, then a
  `<style>` containing **all of `assets/base.css` verbatim**, then an optional page-only
  `<style>` that uses tokens only. No `<html>`, `<head>` or `<body>` tags only for a fragment
  published through the Artifact tool (publish wraps it). A local `.html` file needs the full
  page: doctype, `<html>`, `<head>` with charset and viewport meta, `<body>`.
- Keep the **table of contents** (`nav.toc-side` + `details.toc-top`), the **top row with
  the theme toggle**, and all skeleton scripts as they are. Only change text. Every section
  has an `id`, an `.eyebrow` noun label with its number, an h2 question or claim and, when
  the h2 is long, a short `data-toc` name for the TOC.
- Compose with `references/components.md`. The base frame (fonts, tokens, accent use, card
  system, type scale, section rhythm, TOC, table/notes/chips/FAQ styles, SVG grammar, chart
  styling) is fixed; which blocks and where the emphasis falls vary; the layout stays one column.
- Diagrams are inline SVG using only the vocabulary classes (`references/svg-vocabulary.md`,
  including "Data-shaped pictures"); give each an `aria-label` in the page's language and a `.fig w-NNN`
  min-width. Annotate on the picture; add an HTML legend only when it cannot say it itself.
- Icons: copy only the symbols you use from `assets/icons.svg` into one
  `<svg class="sprite">` at the top of the page (skeleton slot), then `<use href="#i-…">`.
  A concept with no icon gets a new symbol in the same style (24×24, stroke 1.6, round caps).
- Charts (many points, a trend) are Chart.js through the skeleton's `vdChart` helper,
  colours from tokens only, each canvas with an `aria-label` in the page's language and its numbers also in text or a table. Drop the
  optional chart block when the page has no chart. Every chart is the standard kind the
  helper makes: a legend whose items toggle their series, hover that highlights the series
  under the pointer and dims the rest, a tooltip with units, axis titles with units. No
  label may overlap another: shorten it, rotate the axis, or move it to the tooltip.
- No other external resources: no images by URL, no scripts or CSS from other hosts. The
  only allowed script is `https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js`
  (exact version); the only stylesheet is the Google Fonts link.

## Language and fonts

- The page is in the user's language. Set `lang` on `nav.toc-side` and `main` (`en`, `ko`,
  `ja`, …); it tells screen readers how to read the page and sets line breaking (base.css keeps
  Korean words whole and lets Japanese and Chinese break between characters).
- Every fixed label is written in that language: "Contents" in the TOC, the theme toggle's four
  `data-*` labels and its `aria-label`, eyebrows, the decision block's field names (Decides, By,
  No answer, Changes, Cost, Time, Risk, Undo) and the recommended label.
- The font link covers Latin (Geist) and Korean (Noto Sans KR). For Japanese or Chinese, replace
  `Noto+Sans+KR` in the link with `Noto+Sans+JP`, `Noto+Sans+SC` or `Noto+Sans+TC`, and set the
  two font tokens in the page-only style, e.g.
  `:root { --font-body: "Geist", "Noto Sans JP", system-ui, sans-serif; --font-display: var(--font-body); }`.
  These two font tokens are the only tokens a page may set.

## Files

- `assets/base.css` — the fixed frame: theme tokens (light + dark, accent, slate, good/warn/bad,
  data series `--c1`…`--c8`), type scale, cards, TOC, blocks, theme toggle, SVG and chart
  classes, responsive rules. Inline verbatim.
- `assets/skeleton.html` — page skeleton: TOC + main, sprite slot, both openings (story and
  conclusion-first), scripts for the toggle, TOC highlight and entry motion, and the optional
  Chart.js block with `vdChart`.
- `assets/icons.svg` — the icon sprite (copy the symbols a page uses).
- `assets/examples/decision-example.html` — the reference page, a made-up decision page: read it
  first (structure, tone, the decision block). It links `../base.css` so it opens from the
  folder; a published page inlines base.css instead.
- `references/diagram-choice.md` — what the reader must do -> which picture, and when none.
- `references/components.md` — every block with markup and when to use it.
- `references/svg-vocabulary.md` — data-shaped pictures first, then the structure-diagram
  grammar, markers, layout rules, icons, and Chart.js.
- `references/doc-types.md` — structure per document type and audience.
