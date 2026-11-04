# Writing rules

Each rule has a check that a script or a reader can apply. A number marked *starting value* has
no study behind it: calibrate it with reader tests (`reader-test.md`) and record the change there.

## Structure

- **S1 The top block stands alone.** The first screen holds the ask, the recommendation with one
  reason, what happens with no answer (and with do nothing, when that differs), and the deadline. Check: from it alone a reader passes
  R1-R3.
- **S2 One decision per document,** or one per decision block, at most 3 blocks (*starting
  value*). More decisions mean more documents.
- **S3 Headings state what the section concludes,** not its topic. Check: from the h1 and the h2s
  alone a reader can say the conclusion (R8).
- **S4 At most 4 body sections** plus the appendix (*starting value*).
- **S5 Two levels only:** a section and the blocks in it (a decision block is a block, not a
  level, and is not in the table of contents). The appendix is the only fold. No fold inside a
  fold, no chain of links.
- **S6 Developer detail lives in the appendix:** file names, commands, field names, versions, tool
  names, error text. Check: the W3 grep finds nothing in the body.
- **S7 A paragraph carries one idea,** and its opening sentence says it.
- **S8 Reasons stay in sentences.** A list item that needs a "because" becomes a sentence. A list
  has a lead-in line, two items or more, one sentence per item.

## Decisions

- **D1 Fixed shape:** question, 2-3 action options, do nothing, one recommended (SKILL.md, the
  decision block).
- **D2 Options in the reader's terms:** each says what changes for the reader, not what the agent
  will do in the code. Check: no option name is a technical noun.
- **D3 Each option has cost, time, risk and undo** (yes / until a date / no). A missing value is
  written "unknown".
- **D4 The recommendation** is one option, with one reason and one downside. A document that
  recommends says so.
- **D5 Do nothing has a cost:** what happens if the reader picks it, and what happens if the reader
  does not answer. When the two differ, state both.
- **D6 One real alternative** that you do not recommend is present.
- **D7 Who decides, by when.** No deadline: say so.
- **D8 The dates and durations agree.** Write a timeline in the notes (today, the deadline, each
  option's start, finish and "undo until" date, every date in the facts list) and check: each
  option's time fits before the deadline or the date it is meant to beat; "undo until" falls after
  the option finishes; no option contradicts a stated fact (a vendor shutdown, a quote's expiry, a
  closed window). "3 weeks" starting on the deadline date that ends on a shutdown date fails.
  Fix the option or say in the document why it still holds.

## Words (every language)

- **W1 Term budget:** at most 3 terms the reader may not know in the whole document (*starting
  value*), each explained at its first use in terms of what the reader does or sees. Check: the
  reader agent lists the words it did not know (R6); the count is 3 or fewer.
- **W2 Plain word first.** Say the plain thing; if the term matters, give it once, after. At most
  one bracketed gloss per section.
- **W3 Not in the body** (move to the appendix or replace): code identifiers, file paths,
  commands, version numbers, internal IDs, names of tools and libraries the reader does not choose
  between, working names from the conversation ("option F", "path B", "the v2 plan").
- **W4 Named things** (products, services, people) appear only when the reader decides about them,
  with a one-line "what it is" at first mention.
- **W5 Numbers** carry a unit and a comparison ("about 2 minutes slower than today", never "much
  slower"). One representative value in the body; the range goes to the appendix.
- **W6 No empty risk words.** Not "risk" or "issue" alone: what goes wrong, for whom, how much.
- **W7 Name the actor.** Every action says who does what, where, and to what end. If the source
  does not say who, write "the source doesn't say".
- **W8 Speak to the reader** as "you", or the natural equivalent in the language.

## Honesty (the red line)

- **H1 Clarity never changes a fact.** Numbers, units, baselines, limits, risks and the words
  "unverified" and "estimate" survive every rewrite. If the plain wording would lose
  accuracy, keep the accurate wording and split it into two sentences. Check: the facts diff below.
- **H2 One main caveat,** in plain words, once, near the top. Per-claim hedges only where the
  decision rests on that claim.
- **H3 Two status systems, kept apart.** Decision state may tag a body claim, with three tags
  only: decided (`.tag.ok`), proposed (`.tag.prop`), open (`.tag.open`); tag only claims the
  decision depends on. Evidence quality (checked / from a search / not found) goes in the basis
  line or the appendix, never on each sentence.
- **H4 Unknowns stay visible.** "Not found" is not "does not exist"; when the source is silent, say
  so instead of filling the gap.

## Tables and pictures

- **T1 Body tables:** at most 3 columns and 6 rows, no sentence in a cell (*starting value*). A
  larger table goes to the appendix, with one sentence in the body saying what it shows.
- **T2 "Who has what" matrices** become a scorecard: one word per cell from a closed set (yes,
  partly, no, unknown), rows sorted, the finding in one sentence under it.
- **T3 Every number that matters gets a sentence** on what it means. A chart only when it shows a
  result the reader acts on.

## Length

- **L1 Reading time of the top block and body,** the optional number strip included (*starting values*): decision brief 3 minutes or
  less, spec 5, progress update 1, what changed 2. Measure: English 200 words a minute; Korean 500
  non-space characters a minute; other languages, use the closer of the two and say it is
  unverified.
- **L2 Cut the first draft to about half.** Record the draft and final length.

## English track

- **E1** Flag sentences over 25 words for splitting. The first sentence of the top block stays
  under 20 words (*starting value*).
- **E2** Flag hidden verbs: a -tion, -ment or -ance noun carried by make, give, conduct or perform
  ("make a decision" → "decide").
- **E3** Flag the passive voice with no actor.
- **E4** A grade level of 6-8 is a screen only; a score never passes a document by itself.

## Korean track

No numeric Korean standard was found; all counts are *starting values*. No readability formula
(they do not work for Korean).

- **K1 Sentence length:** flag a sentence over about 60 non-space characters, or one joining more
  than two clauses with connective endings (-고, -며, -는데, -지만, -아서/-어서, -므로). Split at the
  connective.
- **K2 Noun stacks:** flag three or more Sino-Korean nouns in a row with no particle ("검토 진행 완료
  예정") and turn them into a verb phrase ("다음 주에 검토를 마칩니다").
- **K3 Loanwords and jargon:** use the plain word where a standard plain-language term list gives
  one (가이드라인 → 지침, 인프라 → 기반 시설); keep a loanword the reader uses in daily work.
- **K4** Flag two or more of "~에 대한", "~적", "~화", "~성" in one sentence.
- **K5 Register:** the body in 합니다체; headings are a short claim or question in the same
  register. Chat replies stay in the chat's register.
- **K6 Subject present** when the actor matters (who does it, pays, decides); dropping it is fine
  only when the actor is the reader.
- **K7 Anchors:** comment anchors use exact phrases or character offsets, never word splits.

Other languages: apply every rule above the tracks; take the sentence checks from the closer
track and mark their thresholds unverified.

## Passes

Separate, in this order.

1. **Write** from the facts list.
2. **Tells pass:** remove the habits of machine prose (inflated openers and closers, a list of
   three where one item is meant, vague praise, signposting, hedges piled on hedges, the same
   sentence rhythm throughout). It may not add or drop a fact (H1).
3. **Mechanical checks** (commands below, and the D8 timeline check).
4. **Reader test** by a fresh agent (`reader-test.md`); fix; two loops at most, then report what
   still fails to the caller.

## Commands

Facts list: one fact per line, each starting with an id (`F1 ...`), and every date, weekday,
deadline, count word ("one", "two", "half"), named amount ("$600") and hedge the document uses is
in it, written as the document writes it. The commands below read it, so a fact left out of the
list shows up as an added fact.

`strip.py` writes the text of the HTML page. `body` stops at the appendix; both drop the buttons,
scripts, the contents list and every tag, including tags that span lines, so attribute text is
never counted. `<code>` becomes a backtick so W3 sees it.

```sh
cat > strip.py <<'PY'
import html, re, sys
t = open(sys.argv[1], encoding="utf-8").read()
t = re.search(r"<main.*</main>", t, re.S).group(0)
if sys.argv[2] == "body":  # the appendix is the last section
    m = re.search(r'<section[^>]*class="[^"]*\bappendix\b', t)
    t = t[:m.start()] if m else t
t = re.sub(r"<(script|style|button)\b.*?</\1>|<details class=\"toc-top\".*?</details>|<!--.*?-->", " ", t, flags=re.S)
t = re.sub(r"<code[^>]*>", "`", t)
t = re.sub(r"</?(p|h[1-6]|li|dt|dd|tr|div|section|header|details|summary|caption)\b[^>]*>", "\n", t)
print(html.unescape(re.sub(r"<[^>]*>", "", t)))
PY
python3 -I strip.py brief.html body > body.txt
python3 -I strip.py brief.html all > all.txt
# Markdown instead: cut at the appendix heading, whatever its wording
sed '/^## <appendix heading>/,$d' brief.md > body.txt; cp brief.md all.txt
```

```sh
# W3: developer words in the body (each hit is moved or replaced)
grep -nE '`|[A-Za-z0-9_-]+\.(js|jsx|ts|tsx|py|rb|go|rs|java|sh|sql|json|ya?ml|toml|md|html|css)\b|(^|[ (])--?[a-z][a-z-]+|\bv?[0-9]+\.[0-9]+\.[0-9]+\b|\b[a-z]+[A-Z][A-Za-z]*\b|\b[a-z0-9]+_[a-z0-9_]+\b|\b[A-Z]{2,}-[0-9]+\b|\b(option|path|plan|variant) [A-Z]\b' body.txt
# L1: reading minutes (English words / 200; Korean non-space characters / 500)
echo "$(wc -w < body.txt) / 200" | bc -l
echo "$(LC_ALL=en_US.UTF-8 tr -d '[:space:]' < body.txt | LC_ALL=en_US.UTF-8 wc -m) / 500" | bc -l
# E1 / K1: one sentence per line (a heading or block is a sentence of its own), then the long ones
perl -CSD -ne 's/\s+/ /g; s/^ | $//g; next unless length; s/([.!?]) /$1\n/g; print "$_\n"' body.txt > sentences.txt
awk 'NF > 25' sentences.txt                                     # English
perl -CSD -ne '$n = () = /\S/g; print if $n > 60' sentences.txt # Korean
```

H1 facts diff, on the whole document (appendix included). `tok` lists a file's numbers (trailing
punctuation trimmed, so `$600,` and `$600` are both `600`), count words, months and weekdays (cut
to three letters), and ignores the fact ids (`F4`, `F10`):

```sh
tok() { perl -ne 's/^F\d+ //; while (/\d[\d.,:%]*/g) { ($t = $&) =~ s/[.,:]+$//; print "$t\n" } print lc($&), "\n" while /\b(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|half|third|quarter|twice|dozen)\b/gi; print substr($&, 0, 3), "\n" while /\b(?:Jan(?:uary)?|Feb(?:ruary)?|March|April|May|June|July|Aug(?:ust)?|Sept?(?:ember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?|Mon(?:day)?|Tue(?:s(?:day)?)?|Wed(?:nesday)?|Thu(?:rs(?:day)?)?|Fri(?:day)?|Sat(?:urday)?|Sun(?:day)?)\b/g' "$1" | sort -u; }
echo "in the facts list only (dropped or reworded):"; comm -23 <(tok facts.md) <(tok all.txt)
echo "in the document only (added):";                 comm -13 <(tok facts.md) <(tok all.txt)
for w in unverified estimate about "not found" "doesn't say"; do   # hedges
  grep -qi "$w" facts.md && ! grep -qi "$w" all.txt && echo "hedge lost: $w"; done
```

Every line the diff prints is explained or fixed: a dropped or added number, date or count word is
a blocker unless it is the document's own date or a word like "one" in ordinary use. The diff shows
that the listed facts survive; whether the list is complete is the reader test's job.
