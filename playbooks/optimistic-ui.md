# Optimistic UI and client state

> Sources: the recurring client-state bugs found in blind reviews of agent-built Kanban apps (in-house, 2026-10); React docs on state and effects (https://react.dev/learn) · Written 2026-10-21 · Applies to: React 18/19 and any client that updates the UI before the server answers

**Use when:** a UI changes local state before the server confirms (moves, reorders, renames, deletes, toggles), refetches after a write, or disables controls while saving. For load time and bundle size use `nextjs-react-performance.md`; for focus and announcements in general use `accessibility.md`.

## Before you start
- Find every place the client writes to the server and every place it reloads data: list them; each rule below applies to each pair.
- Decide one source of truth for the list on screen (one state hook or store), so every write and reload goes through it.

## Rules
1. **Number your reloads; drop stale answers.** Keep a counter. Every write and every reload takes the next number before it starts; a reload's answer is applied only if no newer write or reload started since. An optimistic change must also bump the counter, or a reload that left earlier lands later and snaps the item back.
   ```ts
   const seq = useRef(0);
   async function reload() { const mine = ++seq.current; const data = await api.get(); if (mine === seq.current) setBoard(data); }
   function moveCard(...) { ++seq.current; setBoard(b => applyMove(b, ...)); api.move(...).then(reload, rollback); }
   ```
2. **Roll back the one change, not the whole screen.** On failure, undo only what that action did (put the card back where it was, restore that title), applied to the current state with a functional update. Never `setState(snapshotTakenBefore)`: it wipes every other change made while the request was in flight.
3. **Prefer per-item busy state to a global lock.** Disable only the control or item being saved. A board-wide "one save at a time" lock either refuses the user's next action (and loses it if the caller ignores the refusal) or greys out everything on a slow network. If you must serialise, queue actions instead of refusing them.
4. **Give focus back after the control is enabled again.** Focusing an input while it is still `disabled` does nothing. Restore focus in an effect that runs after the saving flag clears, or after the element re-mounts (look it up by id or ref after render), never in the same tick that flips `disabled`.
5. **Keep forms open on failure and say why.** The input keeps the user's text, the error sits next to the field with `aria-invalid` and `aria-describedby`, and the message lives in an element that is always mounted with `role="alert"` (or a polite live region), so screen readers announce it. Don't show the same error twice (inline and in a banner).
6. **Server side: survive a corrupt store.** If the data file or row cannot be parsed, keep the bad copy aside (`board.json.corrupt-<time>`), start from a clean default, log it, and tell the user something was reset. A store that throws on every request is a permanent outage.
7. **Saves on blur fire once.** A rename committed on blur must not re-submit when focus leaves again after a failure: track that the value was already sent, or commit on Enter and cancel on Escape.

## Pitfalls
- **"It works on my machine" timing.** These races only show with a slow network or two quick actions. Test with the network throttled, and with two moves in a row before the first answer.
- **Refetch on success.** Refetching after every write invites rule 1's race; patch state from the write's own response when the API returns the updated item.
- **Effects that read stale closures.** A handler that reads `board` from render scope after an `await` sees the old board; use functional updates or a ref.

## Verify
- Two quick moves in a row (throttled network): both land; nothing snaps back.
- Make one request fail (devtools offline, or a stubbed 500) while another is in flight: only the failed change rolls back.
- Fail a rename: the input keeps the text and the focus, and the error is read out (VoiceOver or NVDA, or the element has `role="alert"`).
- Corrupt the data file by hand: the app recovers to a default and says so.
- A test covers the reload-sequence guard and the per-action rollback as pure functions where possible.
