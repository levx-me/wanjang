# Deck: slides from notes, rendered and checked

> Sources: [Sequoia, "Writing a business plan"](https://www.sequoiacap.com/article/writing-a-business-plan/) (section list; page read 2026-11-04), [andyqiu847-ai/high-quality-slides](https://github.com/andyqiu847-ai/high-quality-slides) (MIT; phase gating and anti-patterns), [Marp CLI](https://github.com/marp-team/marp-cli) (MIT; export notes), [python-pptx text docs](https://python-pptx.readthedocs.io/en/latest/user/text.html) (the library never measures text) · Written 2026-11-04 · Applies to: any

**Use when:** turning notes into slides for investors, a board, sales or a status review. For a written memo or one-pager, read `business-doc.md`. For numbers behind the slides, read `spreadsheet-model.md` first. For the pitch's claim and audience, `positioning.md`.

## Crew procedure
- **Scout** (if inputs are missing): gathers the user's notes, prior decks and the workbook; lists which tools exist (pptxgenjs, python-pptx, Marp, Typst, LibreOffice, poppler); labels each fact Fact (source), Inference or Assumption.
- **Builder** works in the order below and stops at each gate that needs the user. Use **opus** for the outline and titles, sonnet for assembly.
- **Checker** (fresh context) applies the rubric to the rendered images and the extracted text, and reports slide number plus defect.
- **QA reader test**: a separate agent sees only the images, in order, and says in the audience's words what the deck asks for and what it did not believe.

## Required inputs (open questions if absent; never defaulted silently)
1. Audience and what they decide; 2. the single ask or decision; 3. the time slot; 4. the facts and numbers, each with a source or an Assumption label; 5. brand (logo, colours, fonts) or permission to stay neutral; 6. page size (16:9 unless told otherwise) and the language and script of the text.

## Steps
1. **Facts file.** Every number, name and date gets a source line or the label Assumption. Numbers must equal the workbook; if they do not, fix one side and say which. Never invent a market size, customer or quote; mark `[NEED: ...]`.
2. **Outline as claim titles.** Each slide title is a full sentence stating its point; read alone, the titles tell the story (ghost-deck test). Gate: the user approves the outline before any design.
3. **Sections, as ranges.** Investor decks usually cover purpose, problem, solution, why now, market, alternatives, model, team, numbers, vision, and end with the ask, runway and use of funds. Public advice on length disagrees (about 10 to 19); fewer is better, detail goes to an appendix. Board and sales decks drop what the audience does not decide on.
4. **Design tokens, one sample slide.** One dominant colour plus a neutral and one accent; body text readable at the back of the room (about 18 pt or more); real margins; native charts, not pasted images, with the data table in the notes or appendix. Gate: the user approves the sample.
5. **Build** with whatever exists on the machine. Use real layouts and placeholders, not text boxes stacked by hand. Add alt text to images and charts, and speaker notes per slide (what to say, the source of each number).
6. **Render and look.** Convert to PDF (LibreOffice headless) then to images (pdftoppm), and view every slide. Check overflow first, then overlap, contrast, empty bullets, black or missing shading, tofu boxes. Fix, re-render, look again. Name the renderer in the report: LibreOffice fitting differs from PowerPoint, so borderline fit counts as a failure. Libraries that write PPTX cannot measure text, so only the render tells.
7. **Strip leftovers.** Extract the text and grep for placeholder, lorem, TODO, stale names, old dates, comments, and author or revision metadata.

## Rubric (checker; each item pass or fail with slide number)
1. Titles alone read as the story and each is a claim, not a label.
2. At most about 40 words and one exhibit per content slide; no slide with seven or more bullets.
3. Each number traces to the facts file or is marked Assumption on the slide; none contradicts the workbook; scales and units are labelled.
4. Text extraction shows no placeholder, lorem, `[NEED]`, stale name or hidden slide.
5. All slides rendered and viewed; none overflows or overlaps; text contrast is readable in both a projector and a print view.
6. The file reopens in LibreOffice with no repair prompt; fonts are embedded or installed for the script used (check CJK and right-to-left text explicitly).
7. The last content slide is the ask with runway or use of funds, or the decision wanted; not "Thank you".
8. Every chart has a source line and a date; market and status figures are date-stamped.
9. Alt text on non-text items; speaker notes present.
10. No claim in the deck goes beyond the facts file (forecasts are labelled as such; any statement about securities, returns or regulatory status is flagged for counsel).

## Output
The deck file, the PDF, the slide images folder, the outline, the facts file, and a report with the renderer used, the failing items fixed, and a **could not check** list (PowerPoint or Keynote rendering, fonts not installed, sources not reachable).

## Only the user can do
The real numbers and the ask; naming the audience; logos and brand approval; approval of outline and sample; deciding what to disclose; sending the deck or presenting it. For fundraising decks, review by a licensed professional in the relevant jurisdiction before sending.

## Go deeper
Anthropic's pptx skill (proprietary, not bundled here; needs node, pptxgenjs, markitdown, LibreOffice, poppler): `claude plugin marketplace add anthropics/skills` then `claude plugin install document-skills@anthropic-agent-skills`. For an HTML-deck workflow with phase gates: andyqiu847-ai/high-quality-slides (MIT).
