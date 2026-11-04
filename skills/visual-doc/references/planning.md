# Planning the page (step 3)

The page is a story a first-time reader follows from the top to the bottom, in one column. Text
is the main medium; only the core is drawn. Claude decides what to draw; never ask the reader.
The opening types, section backbones and the length budget are in `doc-types.md`; which picture
fits (and what never to draw) is in `diagram-choice.md`. The rules below hold in addition.

- **Decisions first.** List what the reader must decide. Each becomes one `.decide` (question,
  2-3 options plus do nothing, cost / time / risk / undo for each, the recommendation with one
  reason and one downside, who decides and by when). If any of these is missing from the
  conversation, write "unknown" or ask before writing; never fill it in.
- **Baseline and the main caveat at the top** (`.basis`): every assumption the numbers rest on,
  and how well they are known, once.
- **Term budget, counted:** for non-developers at most 3 unfamiliar terms on the whole page; for
  other audiences at most 1-2 new terms per section. Each explained in what the reader does or
  sees ("a hold means you cannot sell the item for 6 months"). Past that, cut a term or move the
  part to the appendix. Keep a glossary as you plan: every term, its one name, where it is first
  explained.
- **Plain body, developer detail in the appendix.** The body uses plain words and %.
  Configuration values, parameters, field names, routes, formulas and code go to one final
  `.appendix` section (a `details.more` inside it for long ones).
- **Each section** gives its point first, then two or three supports; the rest is folded in
  `details.more`. Say each thing once.
- **Write for a first-time reader** (rules in "Writing" in SKILL.md).
- **Prefer** hand-drawn bars at true proportion (`.bars`/`.brow`) over Chart.js for a few bars.
  Keep a table only where comparing rows across columns is the point, and within the body caps
  (5 columns, 8 rows, about 6 words per cell); a bigger one goes to the appendix.
- **Caps:** accent on one or two things per screen (the subject, the recommended option);
  status tones mark severity and do not count against that; one small line icon per concept
  from `assets/icons.svg`, the same icon for the same concept everywhere.
