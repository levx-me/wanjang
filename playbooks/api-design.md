# HTTP/JSON API Design

> Sources: [Zalando RESTful API Guidelines](https://opensource.zalando.com/restful-api-guidelines/) (CC-BY-4.0), [Google AIP](https://google.aip.dev) (CC-BY-4.0), [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines) (CC-BY-4.0), IETF [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457), [RFC 9745](https://www.rfc-editor.org/rfc/rfc9745), [RFC 8594](https://www.rfc-editor.org/rfc/rfc8594), [Idempotency-Key draft](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/), [RateLimit draft](https://datatracker.ietf.org/doc/draft-ietf-httpapi-ratelimit-headers/) · Written 2026-10-20 · Applies to: any REST-style API, including Next.js route handlers

**Use when:** adding or changing HTTP endpoints, response shapes or error formats. For security of those endpoints see `security-review.md`; for reviewing the diff see `code-review.md`.

## Before you start
- Read the project's existing API first (routes, error helper, pagination helper, casing). Consistency with it beats these defaults. Match it unless it is broken.
- Find the clients (own frontend, mobile, third parties). Public or deployed clients mean every change must be additive.
- Next.js: route handlers live in `app/**/route.ts` and export `GET`, `POST`, ...; caching and runtime behaviour change between versions, so check the current docs (https://nextjs.org/docs/app/api-reference/file-conventions/route) first.

## Rules
**Resources and URLs**
1. Nouns, plural, lower-case, kebab-case path segments: `/orders/{order_id}/line-items`. No verbs: not `/getOrder`, not `/orders/create`.
2. Nest only one level when the child cannot exist without the parent. Otherwise filter: `/line-items?order_id=...`.
3. An action that is not CRUD becomes a sub-resource or a state change: `POST /orders/{id}/cancellation`, or `PATCH` a `status`. If it truly is a command, `POST /orders/{id}:cancel` is acceptable (Google style); pick one style per API.
4. Ids are opaque strings. Do not expose sequential database ids if enumeration matters.

**Methods and status codes**
5. `GET` safe and cacheable, no side effects. `PUT` replaces (idempotent). `PATCH` partial update (JSON Merge Patch, `application/merge-patch+json`). `DELETE` idempotent. `POST` creates or runs a command.
6. Use the most specific code: `200` read/update, `201` + `Location` on create, `202` accepted for async, `204` no body, `400` malformed, `401` not authenticated, `403` authenticated but forbidden, `404`, `409` conflict, `412` precondition (ETag/If-Match), `415`, `422` semantic validation failure, `429` with `Retry-After`. Never `200` with an error body. Never `500` for client mistakes.
7. Check permission before existence when leaking existence is a risk (return 404 for both).

**Errors**
8. One error shape everywhere, `application/problem+json` (RFC 9457):
```json
{ "type": "https://api.example.com/problems/insufficient-funds",
  "title": "Insufficient funds", "status": 409,
  "detail": "Balance 10.00 is below 25.00.", "instance": "/payments/123",
  "code": "insufficient_funds" }
```
9. `type` and `code` are stable machine identifiers; `title`/`detail` are for humans and may change. Clients switch on `code`, never on text.
10. Validation errors list every problem, not just the first: add `"errors": [{"field": "email", "code": "invalid_format", "detail": "..."}]` with a JSON pointer or field path.
11. No stack traces, SQL, file paths or internal hostnames in any error.

**Naming, types, dates**
12. Pick one casing for JSON properties and query params for the whole API (Zalando: `snake_case`; Microsoft/Google JSON: `camelCase`). Follow the project; if none, `snake_case`. Enums as `UPPER_SNAKE_CASE` strings.
13. Top-level response is always an object, never a bare array (cannot be extended).
14. Timestamps: RFC 3339, UTC, uppercase `T` and `Z`: `2026-10-20T09:30:00Z`; names end in `_at`. Date-only: `2026-10-20`. Durations ISO 8601 (`PT15M`). Money as `{ "amount": "12.50", "currency": "EUR" }` with amount a string or integer minor units; never a float.
15. `null` vs missing: decide and document. Prefer omitting unset optional fields; do not change an existing choice.

**Collections**
16. Paginate every list from day one. Cursor-based: request `?limit=50&cursor=...`, response `{ "items": [...], "next_cursor": "..." }` (null or absent at the end). Cursor is opaque. Enforce a max `limit` (e.g. 100) and a default.
17. Offset pagination only for small, stable data. Skip total counts unless needed (expensive, and wrong under change).
18. Filtering by plain query params (`?status=OPEN&created_after=2026-01-01T00:00:00Z`); sorting `?sort=-created_at`. Allow-list sortable and filterable fields.

**Idempotency and concurrency**
19. Retried `POST` must not duplicate money or orders. Accept an `Idempotency-Key` header on creating/charging endpoints: store key + request hash + response for 24h+; same key and same body returns the stored response; same key with a different body is `422`; a retry while the first request is still running is `409` (IETF draft-ietf-httpapi-idempotency-key-header, not yet an RFC). Back it with a unique DB constraint, not an in-memory check.
20. Updates to shared resources use ETag with `If-Match` (or a `version` field) and return `412`/`409` on mismatch.

**Long-running work**
21. If it can exceed a few seconds, return `202 Accepted` with `Location: /operations/{id}`. `GET` on it returns `{ "id", "status": "RUNNING|SUCCEEDED|FAILED", "result" or "error" }`, with `Retry-After` while running. Keep operations at least 24h. Do not hold a request open.

**Compatibility and versioning**
22. Never break clients. Allowed: add optional request fields, add response fields, add endpoints, add optional query params. Breaking: remove or rename a field, change a type or format, make an optional input required, add an enum value clients switch on without a default, tighten validation, change error codes, change defaults.
23. Clients must ignore unknown response fields; say so in the docs.
24. If a break is unavoidable: ship the new shape alongside the old (new field name, or a new version), announce deprecation, send `Deprecation` (RFC 9745) and `Sunset` (RFC 8594) headers, measure old usage, remove only after it reaches zero. Version via header/media type or a single `/v2` prefix; do not mix schemes.

**Rate limits**
25. Return `429` with `Retry-After`; optionally the `RateLimit` and `RateLimit-Policy` fields from draft-ietf-httpapi-ratelimit-headers (still a draft; earlier drafts and many vendors use `RateLimit-Limit`/`-Remaining`/`-Reset` or `X-RateLimit-*`, so match what clients already parse). Limit per caller, not just per IP.

## Pitfalls
- Returning the DB row as-is: leaks columns and freezes the schema as the API. Map to a response type.
- Different error shapes per route (one throws `{error: "..."}`, another `{message}`).
- Enum or field "tidy-up" renames that look internal but are on the wire.
- Offset pagination with inserts mid-listing: duplicates and gaps.
- `PUT` that silently ignores omitted fields, or `PATCH` that treats omitted as null.
- Idempotency stored after the side effect: crash between them double-charges. Reserve the key first.
- Next.js: a `GET` handler can be statically cached in some versions; check current caching defaults before returning per-user data.

## Verify
- Write or update the OpenAPI doc (or types) in the same change; run its linter (`npx @stoplight/spectral-cli lint openapi.yaml`) if present.
- `curl -i` each new route: success, validation failure, unauthenticated, forbidden, not found, repeat of the same POST. Check status, `Content-Type`, body shape.
- Diff the old and new response shape against existing clients and tests; run the project's tests, type-check and lint.
