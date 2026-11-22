# Premortem round and question writing

## Premortem (step 3)
1. Frame it as fact: "It is after launch and the feature failed. What happened?" Say this to the user in one line.
2. Generate 5-8 holes yourself (no questions yet), from: each coverage area, the code and docs read in step 0 (scout if more is needed), and the decisions and assumptions so far. Look from several angles: the user, the team building it, alternatives the user already has, a wrong assumption, timing, and who maintains it later. Drop holes already closed by a decision.
3. Ask about them in rounds of up to 4 (one hole per question, most likely or most costly first). Each question: the hole in one line, why it matters, options. The three options are always: address (name how, as 1-2 concrete choices), defer (later, not in this build), accept the risk.
4. For the top 1-3 holes, ask in one round (up to 4 questions): the signal that it is happening, the kill criterion (when we stop or rethink), the fallback if it happens anyway. Offer guessed answers as options, marked "my guess".
5. Bias check, one question: name the likeliest distortion (overconfidence in the estimate, only imagining holes we already have answers for, anchoring on the first idea, optimism about users) and ask what to change. Then ask: "which failure did we not imagine?" with a free-text "Other".
6. Anything the user addresses becomes a rule, edge case or acceptance criterion. Everything goes into the spec's Risks table.

A hole may come back as a new frontier (an "address" answer that opens questions): ask those in the next normal round.

## Writing a good question
- Standalone: the user should not need the chat to answer it. One line of context, then the question.
- Say what the answer changes ("If yes, expense editing needs a lock state").
- Options are concrete and mutually exclusive; the recommended one is first; a guess is labelled "my guess"; a fact found in the code is cited, not guessed.
- Never use a yes/no where a real choice exists; never a strawman alternative.
- No jargon the user did not use. Generic examples only (a travel-planning app).
