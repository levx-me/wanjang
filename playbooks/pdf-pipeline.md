# PDF pipeline: make a PDF, change one, pull data out of one

> Sources: [Pandoc manual](https://pandoc.org/MANUAL.html) (GPL, read-only), [Typst text docs](https://typst.app/docs/reference/text/text/) (Apache-2.0), [WeasyPrint first steps](https://doc.courtbouillon.org/weasyprint/stable/first_steps.html) (BSD), [Marp CLI](https://github.com/marp-team/marp-cli) (MIT); PDF/UA and Matterhorn points are from search summaries, not the standards: `[verify]` before quoting. Checked by reading, 2026-11-04 · Written 2026-11-04 · Applies to: any

**Use when:** the deliverable or the input is a PDF: Markdown or HTML to PDF, fill a form, merge/split/rotate/redact, extract text or tables, OCR a scan, basic accessibility. For slide content and story read `deck.md`; for a Word or business document's content read `business-doc.md`; this playbook starts when the file format is the problem.

## Crew procedure
- **Scout**: inventories what is installed (`pandoc`, `typst`, `weasyprint`, `marp`, `xelatex`, `qpdf`, `pdftotext`, `pdffonts`, `tesseract`, Python `pypdf`/`pdfplumber`) and the fonts (`fc-list`). Lists scripts in the source text (Latin, CJK, Arabic/Hebrew). Reports what is missing; does not install system packages without the PM's say.
- **Builder** (sonnet) picks the route, runs it on a scratch copy, writes to the path the brief names, never over the source.
- **Checker** (fresh context) applies the rubric with commands, and looks at every page image.
- **QA**: a second agent opens the output with a different tool than the builder used (for example `pdftotext` vs the builder's library) and reports differences.

## Required inputs (the user's; none defaulted silently)
Source file or text; target (page size, page count, orientation, language, filename); for a form: whether it may be filed and who supplies each value; for redaction: exactly what must go; for extraction: which tables and the expected columns.

## Pick the route (check installed first)
- Prose, reports: pandoc to a PDF engine (xelatex or lualatex, or typst), or Typst directly for layout control.
- Styled HTML pages: WeasyPrint (needs Pango and system fonts).
- Slides from Markdown: Marp CLI (needs a Chromium-type browser installed).
- Existing PDFs: `pypdf` or `qpdf` to merge, split, rotate; `pdfplumber` for text and tables; `pdftotext` (poppler) as the independent reader.
- Scans (no extractable text): OCR (`tesseract`, via page images) only after confirming text really is absent.
- Fillable form: list the fields first, fill, then render and look. A flat form with no fields is a layout job, not a fill job; tell the user.

## Fonts and scripts
- Choose a font that has the script. Pandoc with xelatex: set `CJKmainfont` for CJK; right-to-left works best on xelatex with the `dir` variable. Typst: set `lang` (direction follows it) and a font that covers the script; its glyph fallback is on by default, but turned off a missing glyph shows as a box without a warning.
- WeasyPrint: install fonts the normal system way; squares mean the font is missing. RTL and CJK behaviour here is unconfirmed `[verify]` by a test page.
- Headless Linux and CI usually lack CJK and metric-compatible fonts: check `fc-list :lang=<code>` before the run.
- Unicode sub/superscript characters can render as boxes in a library's built-in fonts (reportlab's, for one): use the library's markup for them instead.

## Redaction
Drawing a black box over text does not remove it. Remove the text from the content, save, then prove absence by extracting text and searching for each redacted string (also in metadata, bookmarks, form fields and attachments). Redaction is the user's decision; the builder lists what it removed.

## Accessibility basics (not a conformance claim)
Set document title and language, use real headings and reading order, give images alt text, embed fonts, mark tables with header rows. Run a machine checker if one is installed, then a human pass (read order, contrast). Never write that a file "meets PDF/UA" or any law's requirement: name the checker and its result.

## Rubric (checker; each item is a command or a look)
1. `pdffonts` shows every font embedded (`emb` = yes).
2. Extracted text contains no U+FFFD and no unexpected `.notdef` boxes.
3. Every page rendered to an image (name the renderer, for example `pdftoppm`) and viewed; borderline overflow or clipping fails.
4. Page count, page size and file size match the target.
5. Title and language set (`pdfinfo`, or the metadata dump).
6. Extracted tables compared with the source on at least 3 rows, including the last row and a row with an empty cell; totals recomputed with a second tool.
7. Filled form values visible in the render, not only in the field dictionary.
8. Redacted text absent from extracted text, metadata and attachments.
9. Merge/split: page order and count equal the plan; bookmarks and links still resolve if they existed.
10. Source file untouched (checksum before and after).

## Outputs
The PDF at the named path; a short note with route, versions of the tools, commands run, page count; a "could not check" list (for example no accessibility checker installed, scripts not testable, no second reader); dated figures if any.

## Only the user can do
Provide the source and the values; decide whether a form may be filed or sent; confirm what to redact; sign off the final file, including accessibility and any legal use.

## Go deeper
Anthropic's `pdf` skill (proprietary, not bundled or copied here): `claude plugin marketplace add anthropics/skills` then `claude plugin install document-skills@anthropic-agent-skills`. It expects pypdf, pdfplumber, reportlab, poppler, qpdf and tesseract; whether it installs on your plan is unchecked. Open tools above: Pandoc (GPL), Typst (Apache-2.0), WeasyPrint (BSD), Marp CLI (MIT).
