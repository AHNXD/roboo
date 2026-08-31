---
name: api-feature-integration
description: Connect a Roboo feature to a backend endpoint and render real data. Use when replacing mock/hardcoded screen data with API data, adding a repository/model/Cubit to a feature, wiring a screen to Cubit state, adding one more endpoint to an integrated feature, or fixing a request/parsing/state bug in this Flutter app.
---

# Roboo API Feature Integration

Wire one feature at a time: `View -> Cubit -> Repository -> ApiServices`. Never widen scope to a second feature.

## Before writing code

1. Read `.ai/feature-api-mapping.md` for the feature's endpoint match, status, and risk notes.
2. Read `.ai/api-integration.md` for the exact request/response shape of that endpoint.
3. Read the feature's current screen + widgets. Find the hardcoded data you are replacing.
4. Copy the closest already-integrated feature as the template — do not invent a new shape:
   - simple list: `lib/features/app/news/`
   - list + filter tabs backed by a second repo: `lib/features/app/courses/`
   - detail by id + shared cubits: `lib/features/app/product-details/`
   - write/submit action: `lib/features/shared/complaints/`

Exact code templates for each layer: `references/patterns.md`.

## API source of truth, in precedence order

1. **The live API.** The collection is good but not perfect: some examples are stale (`POST orders` shows an `items` array the backend ignores) and some live endpoints are absent from it (`courses/featured`, `courses/favorite`, `courses/favorites`, `my/courses`). Where they disagree, the live API wins — check with `curl` and record the finding in a comment at the call site.
2. `Roboo — Professional App API.postman_collection.json` — the `Roboo — Mobile API` export. Broadest coverage; the student app, the teacher app, and the error contract.
3. `UPDATE_PROFILE_API_DOCUMENTATION.md` — older prose doc, still useful for profile error detail. (The cart/orders equivalent was deleted on 2026-08-29; the collection plus the comment in `cart_repo_impl.dart` replaces it.)
4. `.ai/api-integration.md` — readable digest of the collection.

`lib/core/Api_services/urls.dart` still holds dead legacy paths (`login`, `get_profile`, …). Use only the `// current …` sections; add new paths there as `static const`. Never hardcode a path string inside a repository.

If the collection has no endpoint for what the UI needs, stop and report it. Do not invent endpoints — there is still no backend for `my-courses`, `games`, or `roboo-ai`.

## The six edits every integration makes

1. **`lib/core/Api_services/urls.dart`** — add the endpoint const (or an `int id` helper function for paths with params).
2. **`<feature>/data/models/<x>_model.dart`** — hand-written `fromJson`, nullable fields, defensive parse helpers. No codegen in this project.
3. **`<feature>/data/repos/<x>_repo.dart` + `<x>_repo_impl.dart`** — `Future<Either<Failure, T>>`, envelope check, `ErrorHandler.handle` in `catch`.
4. **`<feature>/presentation/view-model/<x>_cubit/<x>_cubit.dart` + `<x>_state.dart`** — `sealed` state with Initial / Loading / Loaded / Empty / Error.
5. **`lib/core/utils/services_locater.dart`** — `getit.registerSingleton<XRepo>(XRepoImpl(getit.get<ApiServices>()));`
6. **`assets/lang/en.json` + `assets/lang/ar.json`** — every new visible string, empty-state message, and backend message key.

Then wire the screen with `BlocProvider` + `BlocBuilder`, and delete the mock list it replaced.

## Rules that are easy to get wrong here

- **Error messages are translation keys, not sentences.** The screen renders `errorMsg.tr(context)`. Every `ErrorHandler` constant and every backend `message` key you can hit (e.g. `auth.code_expired`) must exist in both lang files, or the raw key shows on screen.
- **`ApiServices.get` takes only `endPoint`** — there is no query-parameter map. Build the query string with `Uri(path: Urls.x, queryParameters: {...}).toString()`, as `CoursesRepoImpl._coursesEndpointWithFilters` does.
- **Three pagination shapes exist.** (a) named array + small `pagination` object — courses, quizzes, homework, submissions, teacher lists; (b) Laravel paginator, list at `data['data']` — products, orders, favorites, galleries, faqs; (c) plain array at `data` — categories, topics, places, lessons. Check which one the endpoint returns before parsing.
- **Images:** always run URL fields through `ApiMediaUrlResolver.resolve(...)` in the model. The backend returns `localhost` URLs that are unreachable from a device.
- **Localized fields:** models expose `titleFor(languageCode)` / `nameFor(...)` / `descriptionFor(...)`; screens pass `Localizations.localeOf(context).languageCode`. Do not pick `_ar` fields inside widgets.
- **`price` arrives as a String** — keep it a String unless you need arithmetic.
- **Multipart** (profile image) uses `ApiServices.postFormData`, not `post`.
- **Token** is injected by `ApiServices` from `CacheHelper`. Never pass a token from a widget, and do not gate a screen on login just because the endpoint is in a protected Postman folder — check `.ai/feature-api-mapping.md` risk notes first (leaderboard and forgot-password are both flagged ambiguous).
- **Cubit ownership:** create the feature Cubit at the screen with `BlocProvider(create: (_) => XCubit(getit.get())..load())`. Only app-wide cubits live in `get_it` (`CartCubit`, `FavoritesCubit` as lazy singletons, `OrdersCubit` as a factory) and are reused with `BlocProvider.value(value: getit<CartCubit>())`.
- **`temp_*` files are placeholders, never evidence of integration.** Delete the ones inside the feature you integrate; leave every other feature's alone.
- **401 and 403 are different.** 401 means the token is missing/expired — `AuthInterceptor` bounces to login. 403 means authenticated but not allowed (a student token on a `teacher/*` route); never log the user out for it.
- **Some API surfaces have no screen at all** — student enrollment, student homework, and the whole teacher app. Those are new features, not integrations; check `.ai/feature-api-mapping.md` before assuming a screen exists.

## Done means

- Screen renders from Cubit state; no mock list, no `Dio`/`ApiServices`/JSON parsing anywhere under `presentation/`.
- Loading, loaded, empty, and error are all handled — empty is a distinct state, not an empty list rendered as success.
- Repo is registered in `services_locater.dart`; the feature's `temp_*` files are gone.
- New keys exist in **both** `en.json` and `ar.json`.
- `flutter analyze` is clean for the touched files (`/Users/ahn/develop/flutter/bin/flutter analyze`).
- Report anything the backend contract left ambiguous instead of guessing a field name.

## Running against a real backend

`Urls.ip` is `api.robooq.com` and `Urls.baseUrl` **must** stay `https://`. Plain HTTP answers 302/307 redirects to HTTPS, and Dio does not follow redirects for POST — every write then fails as `DioExceptionType.badResponse`. If reads work and writes 307, that is the cause.

A base-URL change needs a **hot restart**, not a hot reload: `ApiServices` sets `_dio.options.baseUrl` once in its constructor and lives as a `get_it` singleton.

The live database is largely empty, so list screens legitimately render their empty state. Confirm with `curl` before hunting for a parsing bug.
