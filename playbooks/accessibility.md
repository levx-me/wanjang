# Accessible Web UI (WCAG 2.2 AA)

> Sources: [github/awesome-copilot a11y.instructions.md](https://github.com/github/awesome-copilot) (MIT), [WCAG 2.2 quick reference](https://www.w3.org/WAI/WCAG22/quickref/) (W3C Document License, paraphrased only), [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/) (W3C Document License, paraphrased only), [axe-core rule tags](https://github.com/dequelabs/axe-core/blob/develop/doc/API.md) (MPL-2.0, link only) · Written 2026-10-20 · Applies to: any web UI, WCAG 2.2 AA

**Use when:** building or reviewing HTML/React/Vue UI: components, forms, dialogs, drag and drop, async status. The designer builds to it; the checker and QA verify against it. Visual style belongs to the design playbooks; this one is about behaviour and semantics.

## Before you start
- Check the project's component library (Radix, React Aria, Headless UI, native `<dialog>`): reuse its accessible primitives before writing your own.
- Pattern details (tabs, combobox, menu, dialog keyboard maps): https://www.w3.org/WAI/ARIA/apg/patterns/
- Criterion wording: https://www.w3.org/WAI/WCAG22/quickref/ (filter to level A and AA).

## Rules
1. **Native element first.** Action = `<button type="button">`, navigation = `<a href>`, field = `<input>/<select>/<textarea>`, list = `<ul>`, table = `<table>`. Use landmarks (`header`, `nav`, `main`, `footer`) and one `h1`; headings nest without gaps (style with CSS, not level). `<html lang>` is set; each page has a descriptive `<title>`.
   - Bad: `<div onClick={go}>Save</div>`. Good: `<button onClick={go}>Save</button>`.
   - If you must use ARIA roles, you owe the keyboard behaviour (Enter/Space, arrows per APG) and the states (`aria-expanded`, `aria-selected`, `aria-pressed`).
2. **Every control has an accessible name** (4.1.2). Visible text, `<label for>`, `aria-labelledby`, or `aria-label` for icon-only buttons. The name must contain the visible text (2.5.3): do not label a "Search" button `aria-label="Find"`.
3. **Focus is visible and not hidden** (2.4.7, 2.4.11). Never `outline: none` without a replacement; use `:focus-visible` with a clearly visible ring. Give it at least 3:1 contrast against adjacent colours (good practice under 1.4.11 Non-text Contrast; the stricter size-and-contrast rule, 2.4.13 Focus Appearance, is AAA). 2.4.11 Focus Not Obscured (Minimum) is AA: sticky headers/footers and cookie bars must not fully cover a focused element, so add `scroll-padding-top/bottom` equal to their height.
4. **Focus order follows reading order** (2.4.3). Do not use `tabindex` > 0. Use `tabindex="-1"` only for programmatic focus targets. Keep DOM order equal to visual order; do not reorder with CSS `order`/`flex-direction: row-reverse`/grid placement for interactive content.
5. **Dialogs.** Prefer `<dialog>` with `showModal()`: it gives focus trap, Escape and inert background. Otherwise: `role="dialog" aria-modal="true"` with `aria-labelledby`; on open move focus to the first control (or the title/least destructive button); Tab cycles inside; Escape closes; on close return focus to the element that opened it; set the rest of the page `inert`. Tooltips/popovers on hover or focus must be dismissible (Escape), hoverable and persistent (1.4.13).
6. **Drag and drop needs a single-pointer, non-drag alternative** (2.5.7 Dragging Movements): "Move up/down" buttons, a "Move to…" menu, or click-to-pick then click-to-place. Keyboard reordering must also work and announce the result in a live region ("Item 3 moved to position 1 of 5").
7. **Target size at least 24x24 CSS px** (2.5.8 Target Size (Minimum)), or spacing so a 24px-diameter circle centred on it does not intersect another target or another small target's circle. Inline links in text, equivalent controls elsewhere on the page and browser-native controls are exempt. Aim for 44px on touch-first screens. Tiny icon buttons: pad the hit area, not the icon.
8. **Contrast** (1.4.3, 1.4.11): body text 4.5:1, large text (24px, or 18.66px bold) 3:1, UI boundaries, icons that carry meaning, and focus rings 3:1. Check disabled-looking placeholders and text over images/gradients. Never convey state by colour alone (1.4.1): add text, icon or pattern.
9. **Async status via live regions** (4.1.3). Keep one persistent `<div role="status">` (polite) or `role="alert"` (urgent, errors) in the DOM from page load, then change its text. A region inserted together with its message is often not announced. Use for toasts, "Saved", search result counts, loading/complete. Do not move focus for status; do not announce every keystroke.
10. **Forms.** Visible `<label>` per field (placeholder is not a label). Mark required with `required` plus visible text. On error: `aria-invalid="true"`, error text in an element referenced by `aria-describedby` (with hint text too), text says what is wrong and how to fix it (3.3.1, 3.3.3). On failed submit, move focus to an error summary (links to fields) or the first invalid field. Use `autocomplete` tokens for personal data (1.3.5). Do not block paste or password managers (3.3.8). Do not ask again for data already entered in the same flow (3.3.7).
11. **Reduced motion.** Wrap non-essential animation: `@media (prefers-reduced-motion: reduce) { * { animation-duration:.01ms !important; transition-duration:.01ms !important; scroll-behavior:auto !important } }`, or better, swap parallax/auto-play for a static state. Nothing flashes more than 3 times in any second (2.3.1); content that moves, blinks or scrolls automatically for more than 5s next to other content has a pause/stop/hide control (2.2.2).
12. **Images and icons.** Informative `<img alt="what it conveys">`; decorative `alt=""`; inline decorative SVG `aria-hidden="true" focusable="false"`; icon-only button gets its name on the button, not the SVG. Charts get a text summary or data table. Video has captions.
13. **Layout.** Works at 320px width without two-axis scroll (1.4.10), at 200% zoom, and with user text spacing overrides (1.4.12). No fixed heights on text containers. Do not lock orientation. Use `rem`, not `px`, for font sizes.
14. **Custom widgets: follow APG keyboard maps.** Tabs: arrows move, Tab leaves. Menus/listbox: arrows, Home/End, type-ahead, Escape. Use roving `tabindex` or `aria-activedescendant`; never trap the keyboard (2.1.2).
15. **Never `aria-hidden="true"` on focusable elements**, and never use `role="presentation"` on them. Hide with `hidden`/`inert` instead so both focus and the accessibility tree agree.

## Pitfalls
- Div/span buttons: no focus, no Enter/Space, no role. Found with `grep -rn "onClick" | grep -E "<(div|span)"`.
- Focus lost when the focused element is removed (closing a dialog, deleting a row): move focus to a sensible neighbour or heading deliberately.
- Route changes in SPAs: announce the new page (move focus to the `h1` or update a live region and the document title).
- `aria-label` on a `div`/`span` without a role is ignored by many screen readers.
- Positive `tabindex`, `title`-only names, and "click here" links.
- Custom selects/comboboxes built from scratch: usually wrong. Use a library or native `<select>`.
- Toast with auto-dismiss in 3s: unreadable for slow readers (2.2.1 Timing Adjustable applies when the message needs to be read or acted on). Keep errors until dismissed.
- Text in images, and meaning only in hover tooltips (not reachable by touch/keyboard).

## Verify
- **Keyboard only** (unplug the mouse): Tab/Shift+Tab through every screen; every action reachable and in sensible order; focus ring always visible; Escape closes overlays; focus returns after close; no trap.
- **Screen reader pass** on the key flow: VoiceOver (macOS, Cmd+F5) with Safari, NVDA with Chrome or Firefox, JAWS with Chrome on Windows if the project supports it; on mobile, VoiceOver with iOS Safari and TalkBack with Android Chrome. Check names/roles read correctly, errors and status are announced, headings/landmarks list (rotor) makes sense.
- **Zoom and reflow:** 200% browser zoom and 320px width; OS "reduce motion" on.
- **Automated:** `npx @axe-core/cli <url>`, `@axe-core/playwright` in e2e (`new AxeBuilder({page}).withTags(['wcag2a','wcag2aa','wcag21a','wcag21aa','wcag22aa']).analyze()`; each tag covers only the criteria added in that version, so list all five), or Lighthouse accessibility. Zero violations is required but not sufficient: automated rules catch only a minority of WCAG criteria (published estimates range from well under half to just over half of issues, depending on how they are counted). They catch missing names, contrast and ARIA misuse but cannot judge focus order, meaningful alt text, announcement timing, or keyboard patterns.
- Report findings with the WCAG criterion number and the element.
