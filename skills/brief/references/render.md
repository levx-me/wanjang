# Rendering a brief

One content model (top block, body sections, decision blocks, appendix), two forms. The HTML page
uses visual-doc's design files in place; this file only maps the brief onto them. For any block not
named here, visual-doc's `references/components.md` is the authority.

## HTML page

Start from visual-doc's `assets/skeleton.html` with **all of** its `assets/base.css` pasted into
the page's `<style>`, then follow visual-doc's markup rules (`references/page-markup.md`). Add only
page-specific rules after the pasted stylesheet, using its tokens. Set `lang` on `nav` and `main`
to the document's language. Where this file and visual-doc's `components.md`, `base.css` or
`skeleton.html` differ, theirs win.

**A file for the Artifact tool is a fragment** (it starts at `<title>`; no `<html>`, `<head>` or
`<body>`: publish wraps it, as page-markup.md says). **A local file the reader opens from disk
needs the full page** around the same content, or the browser renders it in quirks mode with no
viewport on a phone:

```html
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <!-- the skeleton from <title> through its last <style> -->
</head><body>
  <!-- the rest of the skeleton: sprite, nav, main, scripts -->
</body></html>
```

**Top block** is the skeleton's opening C, in `header.hero`: the top row (eyebrow and theme
button), `h1`, one `p.lede`, one `p.basis`, then the decision blocks. No `.goal` box: it never
holds a decision.

```html
<h1>Move order emails to a new sending service before the sale?</h1>
<p class="lede"><b>What we need from you:</b> a choice on <a href="#d1">the sending service</a>, by 12 Nov.
  <b>We recommend:</b> switching now, because a third of order emails reach spam today.
  <b>If you don't answer:</b> nothing changes and the sale runs on the current service.</p>
<p class="basis"><span class="tag prop">Proposed</span> for you to decide. <b>Basis</b> last 30 days of orders. <b>Unsure</b> the spam share is an estimate from one week.</p>
```

The eyebrow in the top row reads `type · reader · date` ("Decision brief · for the shop owner ·
5 Nov"). When "do nothing" and "no answer" differ, the lede states both. A progress update starts
the lede with its status word (bold); a spec or a re-approval starts it with the verdict line
("Approve this to start ...").

- `.basis` carries the legend and the evidence line in one line: the decision tags the page uses
  (at most the three states, `.tag.ok` decided, `.tag.prop` proposed, `.tag.open` open, each with
  its word inside the tag), what the numbers rest on, and the one main caveat. No `p.taglegend`.
- A number strip (`.figures`, after `.basis`) is optional: 0-4 numbers, only ones the decision
  rests on. Its words count toward the reading-time budget (L1) like any others.

**Body sections:** `section#id > p.eyebrow ("2 · Why now") + h2 + ...`; the h2 states the
section's conclusion. The table of contents is built by the skeleton's script from those
eyebrows; do not hand-write it or add `data-toc`. Tables at most 3 columns and 6 rows
(`div.tablebox`); scorecards use the `.sc` cells from base.css. A `details.more` is allowed only in
the appendix.

**Decision block** (`section.decide`, the markup of components.md). Type A puts it in
`header.hero` right after `.basis`, as the skeleton's opening C and the visual-doc example do; the
other types put it inside the section that raises the question ("Open questions", "Decisions
needed"). A `.decide` nested in the header or in a section is not listed in the table of contents.
Recommended option first, do nothing last:

```html
<section class="decide" id="d1" aria-labelledby="d1-q">
  <h3 class="decide-q" id="d1-q">Which service sends order emails during the sale?</h3>
  <p class="decide-meta"><b>Decides</b> you · <b>By</b> 12 Nov</p>
  <p class="decide-meta"><b>No answer</b> the current service stays</p>
  <div class="opt reco">
    <h4>Switch now <span class="reco-label">Recommended</span></h4>
    <p class="opt-why">Most order emails reach the inbox before the sale starts. Downside: two days of setup in a busy week.</p>
    <dl class="opt-facts">
      <dt>Changes</dt><dd>Customers get order emails from a new sender name.</dd>
      <dt>Cost</dt><dd>About $40 a month more than today.</dd>
      <dt>Time</dt><dd>2 days</dd>
      <dt>Risk</dt><dd>If setup slips, some emails go out late on the first sale day.</dd>
      <dt>Undo</dt><dd>Yes, until the end of the month.</dd>
    </dl>
  </div>
  <div class="opt">
    <h4>Switch after the sale</h4>
    <dl class="opt-facts">...</dl>
  </div>
  <div class="opt none">
    <h4>Do nothing</h4>
    <dl class="opt-facts">...</dl>
  </div>
</section>
```

Translate the field names (Decides, By, No answer, Changes, Cost, Time, Risk, Undo, Recommended)
into the document's language; keep them identical across blocks. Every option carries all five
facts; a value you lack is "unknown". The block's `label` (the wizard header) is not shown on the
page: keep it in the notes beside the document, with the `id`.

**Receipt.** When the answer comes back: add `<span class="tag ok">Decided</span>` to the h3, a
`p.decide-answer` after the second `p.decide-meta` (`<b>Decided on 8 Nov</b> Switch now. The
reader's comment, if any.`), the class `chosen` on the chosen `.opt`, and the same line at the
start of `.lede`. Republish the same path.

**Appendix:** `section.appendix` at the end, with visual-doc's neutral label (details) or its
developer label (files, commands, versions). Evidence quality, sources, method, large tables and
the developer detail live here, in `details.more` where long.

## Markdown (doc connector)

For a living document with comments. Scaffold first: the title and one pending block per section,
then fill each section in turn. Headings and labels in the document's language:

```markdown
# <the answer or the question, one sentence>

**What we need from you:** <decision> by <date>.
**We recommend:** <option>, because <reason>.
**If you don't answer:** <what happens, and when>.
<basis and the main caveat, one line>

## <a heading that states the section's conclusion>
...

## Decide: <question>
<!-- block id d1; the label (12 characters at most) is the wizard header -->
1. **<option>** (recommended): <what changes>. Cost: … Time: … Risk: … Undo: …
   Why we recommend it: … Its downside: …
2. **<option>**: <what changes>. Cost: … Time: … Risk: … Undo: …
3. **Do nothing**: <what happens>. Cost: … Time: … Risk: … Undo: …
Decides: <who>, by <date>. If no one answers: <what happens>.

## Details (appendix)
```

- The receipt is a line under the decision heading: **Decided on <date>: <option>.** plus the
  reader's comment, and the same line under the title.
- Folds may not render in a connector: put the appendix in its own tab if the connector has tabs,
  else at the end under a plain heading.
- Status words are always written out; colour never carries meaning alone.
- Comments arrive anchored to an exact phrase or a whole tab: reply in the thread, and when you
  edit, point to the comment the edit answers.
