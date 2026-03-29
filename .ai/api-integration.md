# API Integration

## Source Of Truth

For new API work, use the provided Postman collection first.

Do not use `lib/core/Api_services/urls.dart` as the primary source because it contains endpoints and field assumptions that do not cleanly match the Roboo collection.

## What The Postman Collection Actually Provides

Observed from the export:

- collection name: `Roboo`
- variables: `base_url_app`, `base_url_admin`, `token`, `token-admin`
- both base URL variables are empty in the exported file
- request samples exist
- response samples are mostly missing

Implications:

- base URL values are unresolved in the collection
- request payloads are more trustworthy than response structure
- if a response field is not shown in code or a real sample, treat it as unknown

## Mobile-App-Relevant Postman Folders

Use these as the default mobile API surface:

- `Auth`
- `Category`
- `Products`
- `Gallery`
- `Places`
- `Courses`

Do not use these unless the user explicitly asks for admin work:

- `Auth Admin`
- `Categories Admin`
- `Products Admin`
- `Gallery Admin`
- `Places Admin`
- `Courses Admin`
- `Lessons Admin`

## Auth Rules Detected From Postman

Observed collection auth:

- `Auth` folder uses bearer `{{token}}`
- `Courses` folder uses bearer `{{token}}`
- admin folders mostly use bearer `{{token-admin}}`
- some requests explicitly override to `noauth`

Explicit `noauth` requests:

- `auth/google`
- `auth/verify-code`
- `auth/forgot-password`

Important ambiguity:

- `Auth/Register` and `Auth/Login` inherit folder bearer auth in the collection export
- that is likely a collection-level configuration issue, not solid proof that login/register require a token
- do not hardcode a workaround beyond what the backend actually proves

## Request Shape Rules

Use request fields exactly as shown in Postman unless the user provides stronger evidence.

Examples from the collection:

- login uses `email` + `password`
- register uses `name`, `name_ar`, `email`, `password`, `password_confirmation`, `birthdate`, `gender`, `language`, `heard_about`
- forgot-password uses `email`
- verify-code uses `email` + `code`
- profile update uses multipart form-data and can include `image`

Do not extend current phone-based auth/reset assumptions in the repo without confirming they still apply.

## Response Parsing Rules

Because response examples are mostly missing:

- parse only fields required by the current feature
- keep uncertain fields nullable
- avoid large speculative model trees
- add fields later when a feature actually needs them

## Shared API Boundaries

### `ApiServices`

Keep shared concerns here:

- base URL
- common headers
- bearer token injection
- language header
- shared interceptors

### Feature Repository

Keep feature-specific API concerns here:

- endpoint path
- query params
- request body or multipart payload
- response parsing
- conversion to `Failure`

### Cubit

Keep feature flow here:

- loading state
- success/loaded state
- empty state if needed
- error state

## Current Repo Mismatches To Respect

These are real mismatches between code and Postman:

- current auth code uses `phone` in requests where Postman uses `email`
- current reset-password repo points to different endpoint names than the collection
- current `Urls` file contains unrelated or legacy endpoints
- current DI does not register all existing auth/data classes

Rule:

- when integrating or fixing a feature, align new work to Postman unless the user explicitly says to preserve legacy backend behavior

## Multipart Rules

Confirmed mobile-relevant multipart request:

- `POST auth/profile`

Rule:

- support multipart only in the feature being integrated
- do not redesign the whole network layer just to support one upload flow

## Pagination And Query Rules

Observed query hints:

- `galleries?paginate=0`
- admin-only examples include `category_id` and `paginate`

Rule:

- add query params only where the app-facing endpoint shows them
- do not create a generic pagination layer unless at least two real app features require it

## Token Refresh And Retry

Postman does not document refresh tokens.

Current repo behavior:

- 401 triggers redirect to login via `AuthInterceptor`

Rule:

- do not invent refresh token architecture
- keep existing 401 handling unless the user asks for a new auth flow

## Date Rules

Observed request format:

- `birthdate` uses `YYYY-MM-DD`

Rule:

- send dates in the same format when matching those requests

## Feature-By-Feature Integration Method

For every feature:

1. Read the feature’s current Flutter files.
2. Read the matching Postman request set.
3. Confirm whether the feature is UI-only, partially integrated, or already integrated.
4. Add or update repository code first.
5. Add or update Cubit states/actions second.
6. Wire the screen to Cubit third.
7. Remove only the mocked data or placeholder flow replaced by the new implementation.

Do not integrate two unrelated features in the same task.

## Endpoint Groups You Can Map Directly

### Auth

- `POST auth/register`
- `POST auth/login`
- `POST auth/profile`
- `GET auth/me`
- `POST auth/logout`
- `POST auth/google`
- `POST auth/verify-code`
- `POST auth/resend-code`
- `POST auth/forgot-password`

### Categories

- `GET categories`
- `GET categories/{id}`

### Products

- `GET products`
- `GET products/{id}`

### Gallery

- `GET galleries`
- `GET galleries/{id}`

### Places

- `GET places`
- `GET places/{id}`

### Courses

- `GET courses`
- `GET courses/{id}`

## Collection Gaps And Ambiguities

- no concrete base URL values
- almost no response examples
- login/register auth inheritance is ambiguous
- `Courses` folder auth may block early integration if the backend truly requires user auth
- `Lessons Admin/New Request` is empty and should not drive mobile implementation
