# AGENTS.md

## Purpose

This file tells AI agents how to work in this Flutter repository without guessing architecture or API behavior.

## Repository Reality

- This is a Flutter mobile app repository. Do not assume backend code exists here.
- The repo is feature-first under `lib/features/`.
- The architecture is MVVM-shaped: `View -> Cubit -> Repository -> ApiServices`.
- `Cubit` is the ViewModel layer. Do not introduce another state solution.
- Nearly every feature is really integrated: auth, profile, news, courses, course details,
  quizzes, store, product details, cart, orders, favorites, leaderboard, faq, privacy,
  complaints, topics, my-school (enrollment + homework), and home.
- Not integrated: `my-courses` (blocked — no endpoint), `games` and `roboo-ai` (no backend at
  all). See the status table in `.ai/feature-api-mapping.md` — it is verified against the code,
  and `.ai/todo.md` for what is open and why.
- Features that still contain `temp_repo` / `temp_cubit` are the unintegrated ones. Never treat
  those placeholders as evidence that a feature is wired.
- `Roboo — Professional App API.postman_collection.json` (the `Roboo — Mobile API` export) is the
  API source of truth, with one caveat: a few of its examples are stale, and several live endpoints
  are missing from it entirely (`courses/featured`, `courses/favorite`, `courses/favorites`,
  `my/courses` all work and are used by the app). When an example and the live API disagree, the
  live API wins — verify with `curl` and leave a comment at the call site.
  `UPDATE_PROFILE_API_DOCUMENTATION.md` is older and only adds error-state detail for profile.
  The current `lib/core/Api_services/urls.dart` mixes dead legacy paths with maintained ones.
- The backend now also exposes student enrollment, student homework, and a full teacher app. The
  Flutter app has no UI for any of them, and `auth/login` already returns `is_student` /
  `role_name` for branching. Treat those as new features, not integrations.
- For integration work, use the skill at `.claude/skills/api-feature-integration/`; it carries
  the verified code templates for every layer.

## Required Reading Order

Before implementing any API-backed change, read:

1. [`.ai/architecture.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/architecture.md)
2. [`.ai/code-style.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/code-style.md)
3. [`.ai/api-integration.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/api-integration.md)
4. [`.ai/feature-api-mapping.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/feature-api-mapping.md)
5. [`.ai/skills.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/skills.md)
6. [`.ai/todo.md`](/Users/ahn/Documents/Flutter%20Work/roboo/.ai/todo.md) — open work, blockers, backend asks

## Non-Negotiable Rules

- Implement one feature at a time.
- Inspect the target feature’s current Flutter files before editing anything.
- Inspect the matching Postman folder before adding or changing API code.
- Treat `Cubit` as the ViewModel layer. Do not add a separate ViewModel class.
- Keep networking and response parsing out of widgets.
- Put API access in feature repositories that use shared `ApiServices`.
- Use feature-local models unless a model is already shared and truly fits.
- Reuse existing shared services: `ApiServices`, `ErrorHandler`, `CacheHelper`, `services_locater.dart`, shared widgets, localization.
- Prefer app-facing Postman folders. The current collection export has no admin folders; do not invent admin-backed behavior.
- If the collection is unclear, document the ambiguity and stop guessing.

## What Counts As “Current Implementation”

Treat these as real, observed patterns:

- `lib/core/Api_services/api_services.dart` wraps `Dio`
- `lib/core/utils/services_locater.dart` uses `get_it`
- `lib/core/errors/` provides `Failure` + `ErrorHandler`
- `lib/core/utils/app_localizations.dart` provides `"key".tr(context)`
- auth uses repositories plus Cubits
- `lib/core/utils/api_media_url_resolver.dart` normalizes backend image URLs
- integrated features follow one shape: sealed Cubit state, `Either<Failure, T>` repo,
  `StatusDisplayWidget` for loading/empty/error, repo registered in `services_locater.dart`
- the few remaining unintegrated features still hold placeholder repo/Cubit scaffolding

Do not treat these as fully implemented just because files exist:

- `temp_repo.dart`
- `temp_repo_iplm.dart`
- `temp_cubit.dart`
- `temp_state.dart`

## Required Implementation Sequence For Any Feature

1. Identify the exact feature boundary.
2. Check `.ai/feature-api-mapping.md` for the expected Postman match and risk notes.
3. Read the current screen, widgets, repo, and Cubit files for that feature.
4. Confirm whether the feature is:
   - UI-only
   - partially integrated
   - already integrated
5. Read the exact Postman requests for that feature.
6. Add or update repository code.
7. Add or update Cubit states and actions.
8. Wire the screen to Cubit state.
9. Remove only the hardcoded data replaced by the new flow.
10. Leave unrelated features untouched.

## Rules For UI-Only Or Partially Integrated Features

When a feature has UI but no real backend wiring:

- keep the existing feature folder
- replace `temp_*` names only inside the feature you are integrating
- preserve reusable widgets unless their public inputs must change
- move hardcoded lists and submit logic behind Cubit state gradually
- keep route names and screen entry points stable unless the task explicitly requires navigation changes
- add DI registrations only for the new feature pieces you actually use

When a feature has partial auth/data code that conflicts with Postman:

- align new work to the Postman collection
- do not extend legacy mismatches
- document the mismatch in code comments or the AI docs if it affects future work

## Do Not

- Do not call `ApiServices`, `Dio`, or HTTP code from a widget.
- Do not call repositories directly from a View when a Cubit should own the flow.
- Do not bypass Cubit/Bloc if the feature already has or should have presentation state.
- Do not mix rendering logic with request building, JSON parsing, or business rules.
- Do not introduce another state management approach.
- Do not create a second ViewModel abstraction beside Cubit.
- Do not integrate multiple unrelated features in one task unless explicitly requested.
- Do not keep placeholder `temp_*` names in newly integrated code.
- Do not create broad shared abstractions after seeing only one endpoint.
- Do not duplicate existing shared logic from `core/`.
- Do not invent or use admin endpoints as mobile defaults.
- Do not guess response fields, pagination shape, token refresh behavior, or hidden backend rules.

## Completion Standard

A feature integration is not complete unless:

- the feature uses repository + Cubit + View wiring
- the screen no longer depends on replaced hardcoded data
- loading, success, empty, and error states are handled explicitly where applicable
- localization stays consistent
- DI and routing remain consistent with the existing repo
