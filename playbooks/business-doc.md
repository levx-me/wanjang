# Business document: memo, one-pager, proposal, report, policy

> Sources: [Pandoc User's Manual](https://pandoc.org/MANUAL.html) (GPL-2.0, read for docx output, reference doc, TOC behaviour), [Microsoft: make Word documents accessible](https://support.microsoft.com/en-us/office/make-your-word-documents-accessible-to-people-with-disabilities-d9bf3683-87ac-47ea-b91a-78dcacb3c66d) (read for heading, list, table and alt-text practice), answer-first writing (Minto pyramid, BLUF: secondary sources, ideas only) · Written 2026-11-04 · Applies to: any

**Use when:** producing a written business document as a Word file (docx): memo, one-pager, proposal or statement of work, report, internal policy. For slides read `deck.md`; for a fixed-layout PDF read `pdf-pipeline.md`; for numbers-first work read `spreadsheet-model.md`; for contract text read `contract-review.md`. Marketing copy is `marketing-copy.md`.

## Crew procedure
- **Scout** (when facts are missing): gathers source material the user supplied or points to; labels each item Fact (with URL or file and retrieval date), Inference or Assumption. Never fills a gap from memory.
- **Builder** writes the document and builds the file. Use **opus** for anything leaving the building, sonnet for internal drafts. Follows "Build protocol".
- **Checker** (fresh context, never the builder) applies the rubric below to the file itself (XML scan plus rendered pages) and returns findings with location.
- **QA reader**: a separate agent that gets only the finished document and the question list from step 2. It answers each question from the document alone and reports what it could not answer or misread. No rewriting.

## Required inputs
The user supplies, in the brief; anything missing is listed as a gap in the return and, if work proceeds, written as a labelled Assumption, never silently:
1. purpose and the decision or action the document should produce
2. audience (who reads it, what they already know, how long they will give it) and their region (page size, date and number format, spelling)
3. source facts, figures, prices, dates, commitments, each labelled F/I/A
4. house style: a `reference.docx` or template if one exists
5. whether it goes outside the organisation (triggers the metadata scan)
6. an existing file, if this is an edit

Unknown figures, names and commitments are `[NEED: ...]`, not guesses. Never invent a statistic, quote or client.

## Build protocol
1. **Answer first.** Page 1 states the recommendation or conclusion, the main reason, and the ask (decision, approval, date). Then grouped arguments, then evidence and appendices. A report or policy still opens with a short summary of this kind.
2. **Reader test setup.** Write 5 to 10 questions the reader will ask (what, why, how much, by when, what if it fails, what do you need from me). Keep them for the QA reader; fix any gap they expose before delivery.
3. **Use real structure.** Heading styles, list styles with numbering definitions, tables with a marked header row, a table-of-contents field where the document runs beyond a few pages, cross-references as fields. Never typed bullets, manual line breaks for spacing, or runs of spaces and tabs for alignment.
4. **Page setup explicit.** Set page size (Letter or A4 by the reader's region), margins, header/footer, page numbers. For a brand or house style, build from a reference docx so styles, margins and headers come from it.
5. **Tool limits to plan for.** Pandoc emits a TOC only as an instruction: Word must update fields on open, so say so in the return or regenerate through LibreOffice. Pandoc writes no comments or tracked changes; to produce redlines, edit the XML (`w:ins` / `w:del` with id, author, date) or use a revisions add-on. python-docx has no TOC or tracked-changes support in the versions I could not confirm; check the current docs before relying on either `[verify]`.
6. **Editing an existing file:** change the minimum, never rebuild from scratch, keep its styles. Save a before copy and diff the text and the XML after.
7. **Figures:** every number carries a source and date in the text or a footnote. Recompute totals and percentages with a second tool (a short script or spreadsheet), not the tool that produced them.
8. **Alt text** on every image and chart; table header row set; link text that says where it goes.

## Rubric (the checker's list; report the failing item and location, not a score)
1. Page 1 states recommendation, reason and ask.
2. Every reader-test question is answered from the document alone.
3. Headings use styles with no skipped levels; list paragraphs carry list properties and table headers are flagged (XML scan, not eyeballing).
4. Page size matches the reader's region; margins and fonts consistent.
5. Rendered pages were viewed (LibreOffice to PDF, then page images): no table overflow, no clipped text, no black or odd shading, no orphan heading at a page foot. LibreOffice is not Word; a borderline fit counts as a fail, and say which renderer was used.
6. No placeholders left, no `Error! Reference source not found`, no empty fields, TOC present and populated or flagged as needing a field update.
7. For anything leaving the organisation: no tracked changes, no comments, no stray author, company or template path in document properties, no hidden text.
8. Every figure cited with source and date; totals re-add with the second tool; status and market numbers date-stamped.
9. Claims, prices and promises match the source facts exactly; nothing the user did not supply.

## Legal and commercial wording
A proposal, SOW or policy creates obligations. The builder writes scope, deliverables, dates and fees only from user-supplied terms. Warranty, liability, termination, IP and data-protection wording are drafts for review by qualified counsel in the relevant jurisdiction; never describe a document as compliant or enforceable.

## Only the user can
Set purpose and audience; supply facts, prices, commitments and dates; choose region and style; approve legal and commercial wording; sign, send and publish.

## Could not check (state in every return)
List what was not verified: the file opened in Word (only LibreOffice rendered), fields updated, fonts missing on the reader's machine, right-to-left or CJK layout, source figures not independently confirmed.

## Go deeper
Upstream: `document-skills` plugin in `anthropics/skills` (docx skill; proprietary, ideas only, not bundled here; needs the docx npm package or python-docx, pandoc, LibreOffice, poppler) and the `doc-coauthoring` skill in the same repo (licence not stated). Install: `claude plugin marketplace add anthropics/skills` then `claude plugin install document-skills@anthropic-agent-skills`.
