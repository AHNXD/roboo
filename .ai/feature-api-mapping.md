# Feature API Mapping

This file maps current Flutter features to the Postman collection and tells AI agents what is safe to integrate next.

## Current Status Labels

- `UI-only`: screen exists, no real API wiring
- `Partially integrated`: repo/Cubit code exists but does not cleanly match current UI or Postman
- `Ready for integration`: UI exists and the collection has a plausible app-facing endpoint
- `No backend evidence`: feature exists in UI but the Postman collection does not support it

## Best Next Features

### 1. News / Gallery

- Flutter feature: `lib/features/app/news`
- Postman: `Gallery`
- Endpoints:
  - `GET galleries`
  - `GET galleries/{id}`
- Current status: `Ready for integration`
- Why safe:
  - app-facing endpoints exist
  - current screen is a static list
  - read-only flow is simpler than auth/profile
- Likely files:
  - news screen
  - placeholder news repo/Cubit
  - feature models for gallery item and detail

### 2. Store / Products

- Flutter features:
  - `lib/features/app/store`
  - `lib/features/app/product-details`
- Postman: `Products`
- Endpoints:
  - `GET products`
  - `GET products/{id}`
- Current status: `Ready for integration`
- Why safe:
  - app-facing endpoints exist
  - list/detail UI already exists
  - no multipart or auth-heavy write flow required

### 3. Courses

- Flutter features:
  - `lib/features/app/courses`
  - `lib/features/app/course`
- Postman: `Courses`
- Endpoints:
  - `GET courses`
  - `GET courses/{id}`
- Current status: `Ready for integration`, with auth caveat
- Risk:
  - Postman marks the `Courses` folder as bearer-protected
  - collection does not clarify whether public browsing is allowed

## Features That Need Auth Clarification First

### Auth Core

- Flutter feature: `lib/features/auth`
- Postman: `Auth`
- Current status: `Partially integrated`
- Current repo reality:
  - repositories and Cubits exist
  - screens are not fully wired to them
  - request fields in code do not match Postman in key places
- Main mismatch:
  - repo uses `phone`
  - Postman examples use `email`

### Profile

- Flutter feature: `lib/features/app/profile`
- Postman:
  - `GET auth/me`
  - `POST auth/profile`
- Current status: `Ready for integration`, but depends on auth alignment
- Risk:
  - update is multipart
  - current profile UI is static
  - current shared user model reflects old response assumptions

### Forgot Password / Verify Code / Resend Code / Google Login

- Flutter feature: auth forgot-password flow
- Postman: `Auth`
- Current status: `Partially integrated`
- Main mismatch:
  - current repo reset flow is phone-based
  - Postman reset flow is email-based

## Composite Or Indirect Features

### Home

- Flutter feature: `lib/features/app/home`
- Postman match: indirect only
- Current status: `UI-only`
- Notes:
  - no dedicated home endpoint in the collection
  - likely needs composition from courses, categories, gallery, or products later
- Rule:
  - do not invent a home API

### Category-Driven Filters

- Flutter usage is indirect in home/store/courses filters
- Postman: `Category`
- Current status: `Ready for integration only when a specific feature needs it`
- Rule:
  - integrate categories only to support a concrete feature, not as a standalone abstraction first

### Places

- No clear existing Flutter feature module
- Postman: `Places`
- Current status: `Ready for integration only if UI is requested`
- Rule:
  - do not build a places feature proactively

## Features With No Backend Evidence In The Collection

Do not invent endpoints for these:

- cart
- my-courses
- leaderboard
- games
- quizzes
- Roboo AI
- complaints
- faq
- privacy policy

These features currently remain UI-only unless the user provides another API source.

## Likely Shared Files Reused Across Integrations

- `lib/core/Api_services/api_services.dart`
- `lib/core/errors/error_handler.dart`
- `lib/core/errors/failuer.dart`
- `lib/core/utils/cache_helper.dart`
- `lib/core/utils/services_locater.dart`
- `lib/core/utils/routs.dart`
- `lib/core/utils/app_localizations.dart`

## Recommended Order

From safest to riskiest:

1. News / gallery
2. Store / products
3. Product details
4. Courses list
5. Course details
6. Auth core
7. Profile
8. Category-backed filtering where needed
9. Places only if requested
10. Forgot-password, verify-code, resend-code, google login after auth rules are clarified

## Hard Warnings

- Do not treat placeholder repos/Cubits as proof that a feature is already integrated.
- Do not use admin folders to fill missing mobile endpoints.
- Do not infer missing endpoints for cart, quizzes, AI, leaderboard, or my-courses.
- Do not assume response envelopes from Postman when the collection does not show them.
