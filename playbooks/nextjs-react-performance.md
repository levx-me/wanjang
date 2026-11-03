# Fast React and Next.js (App Router)

> Sources: [vercel-labs/agent-skills react-best-practices](https://github.com/vercel-labs/agent-skills) (MIT), [web.dev Core Web Vitals](https://web.dev/articles/vitals) (CC-BY 4.0), [Next.js docs](https://nextjs.org/docs) (link only; image, after, optimizePackageImports, lazy-loading, package-bundling pages checked 2026-10-20) · Written 2026-10-20 · Applies to: React 18/19, Next.js App Router (docs index showed 16.x)

**Use when:** writing or reviewing React/Next.js code where load time, bundle size, or interaction latency matters. Not for backend/DB tuning (see the database playbook) or visual design.

## Before you start
- Check the installed Next.js and React versions (`package.json`). Caching and rendering APIs change between majors.
- **Check current docs first for anything about caching, revalidation, `use cache`, PPR/Cache Components, `fetch` defaults:** https://nextjs.org/docs and the machine-readable index https://nextjs.org/docs/llms.txt. Do not rely on memory for defaults.
- Measure a baseline before changing anything (see Verify). Fix the biggest cost first: waterfalls and bundle size beat micro-optimisation.

## Rules
Ordered by typical impact.

**1. Remove request waterfalls**
- Start independent fetches together: `const [user, posts] = await Promise.all([getUser(id), getPosts(id)])`. Sequential `await` of independent calls is the most common slowdown.
- Start a promise early, await late: create the promise at the top, do other work, `await` where used. Move `await` into the branch that needs it; check cheap sync conditions before awaiting remote flags.
- Parent-child waterfalls: a server component that awaits data then renders a child that awaits more is serial. Hoist both fetches, or pass promises down and `use()` them, or split into sibling components so they run in parallel.
- Wrap slow, non-critical parts in `<Suspense fallback>` so the shell streams first. Add `loading.tsx` per route segment.
- Dedupe within a request with `React.cache()` for non-`fetch` data (DB, SDK calls). Per-request only; for cross-request use the framework cache.
- Work not needed for the response (logging, analytics) goes in `after()` from `next/server` (stable since 15.1; `unstable_after` in 15.0).

**2. Server vs client components, small client bundle**
- Default to server components. Add `"use client"` only to the smallest leaf that needs state, effects, or browser APIs. Push it down: a `<LikeButton>` client leaf, not a client page.
- A client component can render server components passed as `children`/props; use that to keep large subtrees on the server.
- Props crossing the boundary are serialised into the HTML/RSC payload: pass ids and the fields used, not whole DB rows. Do not pass the same big object twice.
- Heavy libraries (markdown, charts, date, syntax highlighting) run on the server when possible.
- Import directly, not from barrel files: `import Button from "@/ui/Button"`, not `from "@/ui"`; for icon/util packages add them to `experimental.optimizePackageImports` (still experimental; `lucide-react`, `date-fns`, `lodash-es` and others are optimised by default, see https://nextjs.org/docs/app/api-reference/config/next-config-js/optimizePackageImports).
- Load heavy, below-the-fold or interaction-only components with `next/dynamic` (`dynamic(() => import("./Chart"), { ssr: false })` only for truly browser-only code; `ssr: false` only works when `dynamic()` is called inside a Client Component, so put the call in a `"use client"` wrapper). Load analytics/third-party scripts with `next/script` strategy `afterInteractive` or `lazyOnload`.
- Preload on intent: call the dynamic `import()` on hover/focus of the trigger.

**3. Re-renders**
- Put state as low as possible, next to the only component that uses it. Typing in an input must not re-render the page.
- Split a component so the fast-changing part is a small child; pass slow parts as `children`.
- Derive values during render; do not mirror props into state with `useEffect`. Put event logic in handlers, not effects.
- Do not read state only to use it inside a callback (use a ref or functional `setState(s => ...)`).
- Do not define components inside components (remounts every render). Hoist static JSX and constant arrays/objects out of the component.
- `memo`/`useMemo`/`useCallback` only where the Profiler shows a costly re-render or the value is a dependency of another hook/memoised child. If the React Compiler is enabled (check `next.config`), prefer not to hand-memoise.
- Non-urgent updates (filtering a big list while typing): `startTransition` or `useDeferredValue` keeps INP low.
- Lazy state init for expensive values: `useState(() => build())`. Effect dependencies should be primitives.

**4. Lists and keys**
- `key` is a stable id from the data, never the array index for lists that reorder/insert/delete, never `Math.random()`.
- Over ~100 rows: paginate, or virtualise (`@tanstack/react-virtual`), or use CSS `content-visibility: auto` with `contain-intrinsic-size`.
- Use `Map`/`Set` for repeated lookups instead of `.find`/`.includes` in loops; one pass instead of chained `filter().map()` on large arrays.
- Render conditionals with a ternary when the left side may be `0` (`{count ? <X/> : null}`), not `count && <X/>`.

**5. Images, fonts, scripts**
- `next/image` for all content images with real `width`/`height` (or `fill` + sized parent) and `sizes` that matches the layout. Only the LCP image loads eagerly: Next 16 deprecated `priority`; use `preload` (or, as the docs prefer in most cases, `loading="eager"` / `fetchPriority="high"`); on 15 and earlier use `priority`. Everything else stays lazy (the default).
- `next/font` for fonts (self-hosted, no layout shift, `display: swap`); subset to needed glyphs; load only used weights. Do not add `<link>` to Google Fonts in a Next app.
- Scripts: `next/script`; any manual `<script>` gets `defer` or `async`.

**6. Caching and revalidation — check current Next.js docs first**
- Defaults for `fetch`, route handlers and pages differ between 14, 15 and 16 (and with Cache Components). Read https://nextjs.org/docs/app/getting-started/caching and https://nextjs.org/docs/app/getting-started/revalidating for the installed version, then state the cache behaviour explicitly in code instead of relying on defaults.
- Decide per data: static, time-based revalidate, tag-based on-demand (`revalidateTag` / `revalidatePath` after a mutation), or dynamic per request. Per-user data must never land in a shared cache.
- Module-level mutable variables on the server are shared between requests: never store request/user data there.
- Server actions are public endpoints: authenticate and authorise inside each one.

## Pitfalls
- `"use client"` at the top of a layout or page pulls the whole subtree into the bundle.
- Importing a whole library for one function (`import _ from "lodash"`): use per-function imports or native.
- Awaiting in a `for` loop over items (N+1 waterfall): `Promise.all(items.map(...))` (mind concurrency limits to the upstream).
- Context value created inline (`value={{a,b}}`) re-renders every consumer; memoise it or split contexts.
- Hydration mismatch from `Date.now()`, `Math.random()`, `window` checks in render: move to effect or mark with `suppressHydrationWarning` only for known cases.
- Images without dimensions cause CLS; web fonts without `next/font` cause CLS and slow LCP.
- Optimising by guess: memo everywhere adds cost and bugs with no gain.
- Stale cache after mutation because no revalidate call was made.

## Verify
- Targets at the 75th percentile (field data): **LCP <= 2.5 s, INP <= 200 ms, CLS <= 0.1** (https://web.dev/articles/vitals). Lab: Lighthouse / Chrome DevTools Performance panel (throttle CPU 4x and network). Field: `useReportWebVitals` or Vercel/Search Console data.
- Bundle: `next build` output shows per-route First Load JS; analyse with `next analyze` (Turbopack, 16.1+) or `@next/bundle-analyzer` (`ANALYZE=true next build`, webpack only); see https://nextjs.org/docs/app/guides/package-bundling. Find what a client route pulls in and whether it should be server or dynamic.
- Re-renders: React DevTools Profiler, "record why each component rendered"; fix only what is costly.
- Waterfalls: DevTools Network tab (serial bars) and server logs timing; confirm independent fetches overlap.
- `next build && next start` to test (dev mode is not representative). Run the project's type-check and lint.
