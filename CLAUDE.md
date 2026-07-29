# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- `pnpm dev` — run the server with hot reload (tsx watch)
- `pnpm build` — compile TypeScript to `dist/`
- `pnpm start` — run the compiled server (`dist/server.js`)
- `pnpm typecheck` — type-check without emitting

There is no test suite or lint config in this repo currently.

Requires a `.env` file (see `.env.example`) with `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `FRONTEND_ORIGIN`. Env vars are parsed and validated at boot by `src/config/env.ts` (Zod schema, also covers optional `PORT`, `NODE_ENV`, `TRUST_PROXY`) — the process exits immediately if config is invalid, rather than starting in a broken state.

## Architecture

Express + TypeScript API backing a gym-tracking app, using Supabase (Postgres) purely as a data layer. There is **no service-role key anywhere** and no privileged DB access from the backend process — every request is executed as the calling user via their JWT, and Postgres Row Level Security (RLS) is the actual access-control boundary. Route handlers never bypass this.

Request flow:

1. `src/server.ts` boots `createApp()` from `src/app.ts` — sets up helmet, CORS (explicit `FRONTEND_ORIGIN` allowlist, no credentials since auth is Bearer-token only), JSON body limit, pino request logging (with `Authorization` redacted), and a global rate limiter.
2. `src/routes/index.ts` mounts `requireAuth` (`src/middleware/auth.ts`) on all of `/api/*`, then `userRateLimit` (`src/middleware/userRateLimit.ts`) — a per-user, in-memory sliding-window limiter keyed on `req.user.id`, applied after auth so limits are per-account rather than per-IP. There is no unauthenticated data route.
3. `requireAuth` validates the bearer token against Supabase Auth (`authClient.auth.getUser`), then builds a **per-request** Supabase client scoped to that user's JWT (`createUserScopedClient`, in `src/lib/supabase.ts`) and attaches it as `req.supabase`, plus `req.user`. All downstream DB calls go through `req.supabase`, so RLS enforces ownership — handlers generally don't need to double-check `user_id` on reads, though writes still filter `.eq("user_id", req.user!.id)` where relevant (see routines routes) as defense in depth.
4. Each resource has a route file (`src/routes/*.routes.ts`) and a matching Zod schema file (`src/schemas/*.schema.ts`). Route handlers call `validate(schema, part)` (`src/middleware/validate.ts`) as middleware, which parses and replaces `req.body`/`req.query`/`req.params` in place.
5. Errors: throw `AppError(statusCode, message)` from `src/middleware/errors.ts`; async handlers are wrapped in `asyncHandler` so rejections reach the centralized `errorHandler`, which never leaks internals (stack traces, raw Postgres errors) to the client — only `req.log.error`/`console.error` server-side.
6. Admin-only mutations (e.g. exercise catalog writes in `exercises.routes.ts`) add `requireAdmin` (`src/middleware/requireAdmin.ts`) after `requireAuth`, which checks `profiles.is_admin` for the calling user via `req.supabase` and throws `403` otherwise. Regular authenticated users can still read/search the resource.

### Schema conventions (Zod)

- All object schemas use `.strict()` — this is intentional and important: it rejects unknown keys, which is what stops a client from smuggling server-computed fields (e.g. `user_id`, `owner_id`, `is_personal_record`) into a request body.
- Params validated via shared `uuidParamSchema` in `src/schemas/common.schema.ts`; extend it (`uuidParamSchema.extend({...})`) for routes with multiple path IDs (e.g. `/:id/exercises/:reId`).
- Create/update schemas are typically split (update = all fields optional), and cross-field invariants use `.refine(...)` (e.g. `target_reps_max >= target_reps_min` in `routine.schema.ts`).

### Data model

Supabase/Postgres tables, built up incrementally across `supabase/migrations/*.sql`: `profiles` (incl. `is_admin`), `exercises` (incl. `image_url`, admin-owned via `owner_id`), `routines`, `routine_exercises`, `workout_sessions`, `workout_sets`, `body_measurements`, plus a `routine_summary` view (exercise count + last-completed date, used by the routines list endpoint). Nested reads use PostgREST embedding, e.g. `.select("*, routine_exercises(*, exercises(*))")`. Routine creation with nested exercises goes through a Postgres RPC (`create_routine_with_exercises`, `0009_create_routine_with_exercises_rpc.sql`) rather than multiple round-trip inserts, so it stays atomic under RLS.

Migrations are additive and sequential (`NNNN_description.sql`) — never edit a migration that's already landed; add a new one, even for small fixes (see `0010_fix_routine_summary_security.sql` correcting `0002`).

### Adding a new resource

Follow the existing routine/exercise/session pattern: add a schema file under `src/schemas/`, a router under `src/routes/` using `validate(...)` + `asyncHandler(...)` + `req.supabase!`, mount it in `src/routes/index.ts`, and add any new tables/RLS policies as a new file in `supabase/migrations/`.

## Related

`/Users/jaiderquimbaya/Documents/Desarrollo/gymtracker/frontend` is a sibling project (this repo is the backend only, run as a pnpm workspace member per `pnpm-workspace.yaml`).
