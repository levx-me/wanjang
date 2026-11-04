# Choosing the picture

Readers follow the page top to bottom. Text carries it; a picture appears only in the section that
needs it, shows **one idea**, and lets the reader see a number, a share or a change faster than a
paragraph would. For each section write one line before building: **shape / picture / why**
("revenue split six ways / ratio strip / the size of each share is visible at once"). When no row fits, write prose.

## Shape of the data -> picture

| The section shows… | Picture | Markup | Not when |
|---|---|---|---|
| a few quantities to compare | true-proportion bars | `.bars` / `.brow` (or SVG `rect.bar`) | many points or a trend (Chart.js); fewer than 3 items (sentence) |
| how one whole is shared | ratio strip | `.split` + `.legend` | the parts do not add up to a real whole; pies and donuts, ever |
| how something develops over time | timeline | `.timeline` | fewer than 4 dated events (a sentence or `.steps`) |
| a trend, many points | line chart | Chart.js through `vdChart` | a few points (bars or a sentence) |
| a change, two states | before / after | `.pair` (same scale, same rows) | one value changed (sentence: "120 -> 180") |
| what a number means for one person | worked numeric example | `.tablebox` or `.steps`, one real figure followed through the scenarios ("with a $10,000 budget") | the example is invented |
| do things in order | steps | `.steps` / `.step` (3-4 steps) | unordered items (bullets) |
| choose between options | decision block | `.decide` (options as cards with cost, time, risk, undo) | one difference (a sentence); scores you would invent |
| remember a few numbers | key numbers | `.figures` (`.fig`, `.v`, `.k`), 0-4 numbers a decision rests on | more than 4 (table); numbers that decide nothing |
| see a decision state | status tag | `.tag.ok/.prop/.open`, only on claims a decision depends on | colour without a word, ever; how a fact was found (say it in `.basis`) |
| not miss a risk | note with a tag | a sentence with `.tag`; `.conclude` for the section's takeaway | every section has one |
| look up values | table | `.tablebox`, at most 5 columns × 8 rows in the body; bigger ones in the appendix | the point is the size gap (bars) |
| see who has what | scorecard | `.tablebox` with `.sc.yes/.part/.no/.unk` cells | more than about 5 rows in the body (appendix) |
| how parts connect | **structure diagram** | see below | structure is not the point |

A picture is never the only copy of a fact: the same numbers appear in the text or a table.

## Structure diagrams: rare

Draw one only when **how the parts connect is the point** of that section (who talks to whom,
which way something moves, where a boundary lies). Then:
- at most **7 nodes**, at most **one short line** per node (a name and, at most, a few words);
- one kind of arrow in accent; a second kind only if the point needs it;
- it lives in the one section that explains the structure, not at the top of the page;
- no pins, no annotations that restate the text, no sentences inside boxes.

If the boxes need sentences to make sense, the picture is wrong: write the sentences as prose
and draw the numbers instead.

## Never draw

- A box filled with sentences, or a diagram that is text in boxes.
- What two or three sentences say; a two-item comparison; an unordered list as boxes and arrows
  (arrows mean order or flow).
- A picture that repeats the title or the lede.
- A whole-structure overview "for orientation", or the same overview twice.
- Re-plots of the assumptions or inputs as if they were a result.
- Relations, numbers or steps the conversation does not support.

## The worked example

Choose one real case that makes the section's point obvious ("with a $10,000 budget", one
request, one user). Follow it through each scenario with the same figure, in a small table or `.steps`,
so the reader compares outcomes on one base. It must come from the conversation or files read.
State its baseline in `.basis` at the top of the page.
