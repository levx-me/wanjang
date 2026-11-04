# Rendering a brief

One content model (top block, body sections, decision blocks, appendix), two forms. The HTML page
uses visual-doc's design files in place; this file only maps the brief onto them. For any block not
named here, visual-doc's `references/components.md` is the authority.

## HTML page

Start from visual-doc's `assets/skeleton.html` with **all of** its `assets/base.css` pasted into
the page's `<style>`, then follow visual-doc's markup rules (`references/page-markup.md`). Add only
page-specific rules after the pasted stylesheet, using its tokens. Set `<html lang>` to the
document's language.

**Top block** (in `header.hero`, under the skeleton's top row):

```html
<p class="eyebrow">Decision brief · for the shop owner · 5 Nov</p>  <!-- type · reader · date -->
<h1>Move order emails to a new sending service before the sale?</h1>
<div class="goal">
  <p><b>What we need from you:</b> a choice on <a href="#d1">the sending service</a>, by 12 Nov.</p>
  <p><b>We recommend:</b> switching now, because a third of order emails reach spam today.</p>
  <p><b>If you don't answer:</b> nothing changes and the sale runs on the current service.</p>
</div>
<p class="basis"><b>Basis</b> last 30 days of orders · <b>Unsure</b> the spam share is an estimate from one week.</p>
```

- A progress update puts its status word first in `.goal`; a spec or a re-approval puts its
  verdict line there ("Approve this to start ...").
- A number strip (`.figures`) is optional: 0-4 numbers, only ones the decision rests on.
- A legend (`p.taglegend`) only when the page uses status tags: at most the three decision states,
  `.tag.ok` decided, `.tag.prop` proposed, `.tag.open` open, with the word written in the tag.

**Body sections:** `section#id > p.eyebrow + h2 + ...` as in visual-doc; the h2 states the
section's conclusion. Tables at most 3 columns and 6 rows (`div.tablebox`); scorecards use the
`.sc` cells from base.css. Detail most readers skip goes in a `details.more`, never one inside
another.

**Decision block**, its own section directly in `main`, right after "Why now". `data-toc` holds the
`label`, so the table of contents shows it. Recommended option first, do nothing last:

```html
<section class="decide" id="d1" data-toc="Sending">
  <h3 class="decide-q">Which service sends order emails during the sale?</h3>
  <p class="decide-meta">Decides: <b>you</b> · by <b>12 Nov</b> · No answer: <b>the current service stays</b></p>
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

Translate the field names (Changes, Cost, Time, Risk, Undo, Recommended) into the document's
language; keep them identical across blocks. Every option carries all five; a value you lack is
"unknown".

**Receipt.** When the answer comes back: add `<span class="tag ok">Decided</span>` to the h3, a
`div.decide-answer` right under `.decide-meta` (`<b>Decided on 8 Nov: Switch now.</b>` and the
reader's comment, if any), the class `chosen` on the chosen `.opt`, and the same line at the top of
`.goal`. Republish the same path.

**Appendix:** `section.appendix` at the end, with visual-doc's neutral label (details) or its
developer label (files, commands, versions). Evidence quality, sources, method, large tables and
the developer detail live here.

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
