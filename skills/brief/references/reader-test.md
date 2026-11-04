# Checking a brief

A brief is plain when its intended reader can locate, understand and use what they need. A reader
doing the task tests that; a readability score never does.

## Rubric (R1-R10)

The reader answers from the document only; the answers are compared with the writer's answer key.
Each item is pass or fail. **R1-R4 failing blocks publishing**; any other failure is fixed or
explained in the report.

| # | Reader's task | Passes when |
|---|---|---|
| R1 | From the top block only: say in one sentence what you are asked to decide, and by when. | It matches the key. |
| R2 | From the top block only: name the recommended option and its reason. | It matches. |
| R3 | From the top block only: say what happens if you choose nothing, and if you do not answer. | It matches, with both cases when they differ. |
| R4 | For each option: what it costs (money, time, risk), and can it be undone? | Every option answered; "unknown" counts only where the document says unknown. |
| R5 | Say what will change for you (spec: what you will be able to do; update: what is done). | It matches the claims. |
| R6 | List every word or name you did not know. | At most the W1 budget, none of the W3 kinds. |
| R7 | Name the one thing the document is unsure about. | It matches the main caveat (H2). |
| R8 | From the headings alone: say the document's conclusion. | It matches (S3). |
| R9 | Answer the 5 questions the writer predicted a reader would ask. | At least 4 of 5 right (*starting value*). |
| R10 | Where did you stop or reread? Where could you have been misled? | Each place fixed or answered. |

Not every type uses every item: a progress update with no decision skips R2-R4; a what-changed note
answers R1 as "what changed and do I need to approve again".

Mechanical checks run beside it (`writing-rules.md`, Commands): the facts diff (H1), sentence flags
(E1-E3 or K1-K4), the W3 grep, table size (T1), tag kinds (H3), section count (S4), reading time
(L1), and every decision block field filled (D1-D7).

## Agent reader test (every document)

0. Before the test the writer has the **facts list** and the **answer key** for R1-R9 (written
   before the draft is final). Neither goes to the reader.
1. Start a fresh agent (`wanjang:checker`; `general-purpose` if missing), never the writer and
   never a fork of the writer's context. Give it only: the document, this persona, and the
   questions. Persona: "You own this product and do not write code. You have 3 minutes and you
   will decide alone. Answer only from what is in front of you."
2. **Pass 1, top block only** (save it as its own file and withhold the rest): R1-R3.
3. **Pass 2, the whole document:** R4-R10.
4. A separate check, by the same or another fresh agent, runs the mechanical checks and the facts
   diff against the facts list.
5. Compare with the key. Fix each failure in the document, never in the key, and rerun only the
   failed items. After two loops, return to the caller with what still fails.

## Real-person variant (calibration, now and then, not per document)

1. Pick 3-5 people who do not code and have not seen the work (*starting value*).
2. Give them the top block only and ask R1-R3 aloud; note the time and the mistakes. Then the whole
   document: ask R4 and "where did you stop?".
3. Record per document type: time to answer R1, R1-R4 accuracy, the words they did not know, their
   language. Move the starting values with that record and log each change below with its
   evidence.
4. Keep the language tracks apart: a threshold found with English readers does not carry over to
   Korean ones, or the reverse.

## Starting values

None of these has a study behind it yet.

| Rule | Value |
|---|---|
| S2 decision blocks per document | 3 |
| S4 body sections | 4 |
| W1 unknown terms per document | 3 |
| T1 body table | 3 columns, 6 rows |
| L1 reading minutes (decision / spec / update / what changed) | 3 / 5 / 1 / 2 |
| L1 reading speed | English 200 words, Korean 500 non-space characters per minute |
| E1 sentence / first sentence | 25 / 20 words |
| K1 sentence | 60 non-space characters, 2 connective endings |
| Spec claim | about 12 words |
| R9 predicted questions right | 4 of 5 |
| Real-person panel | 3-5 people |

## Calibration log

Add a line per change: date, rule, old value → new value, evidence (panel size, language, result).

(none yet)
