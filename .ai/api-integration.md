# API Integration

## Source Of Truth

Use `Roboo-API-Collection.json` as the primary API contract for new app integrations.

Do not use `lib/core/Api_services/urls.dart` as the source of truth for paths. It still contains legacy paths such as `login`, `register`, `get_profile`, and unrelated medical/diagnose endpoints that do not match the Roboo Postman collection.

## Current Collection Snapshot

Observed from `Roboo-API-Collection.json`:

- collection name: `Roboo - Professional App API`
- Postman schema: collection v2.1
- base variable: `base_url_app = http://localhost:8000/api/`
- useful variables: `token`, `course_id`, `lesson_id`, `product_id`, `order_id`, `quiz_id`
- no admin folders are present in this export
- most requests include response examples
- every successful JSON response uses the envelope `success`, `message`, `data`

The collection is the best available contract, but still treat odd auth markings as ambiguity when they conflict with expected user flow. Example: `Forgot Password` is under the no-auth Authentication folder but the request itself declares bearer auth.

## Auth And Access Rules

Folder-level auth in the current collection:

- `1. Authentication`: no auth
- `2. My Profile`: bearer `{{token}}`
- `3. Exploration (Public)`: no auth
- `4. Student Learning (Protected)`: bearer `{{token}}`
- `5. Shopping & Shop (Protected)`: bearer `{{token}}`
- `6. Social & Meta`: bearer `{{token}}`

Implementation rules:

- Public exploration endpoints should work without requiring a token.
- Protected endpoints should rely on `ApiServices` bearer injection from `CacheHelper`.
- Do not pass tokens from widgets.
- Do not invent refresh-token behavior; the collection does not document refresh tokens.
- Keep existing unauthorized behavior in `AuthInterceptor` unless the task is explicitly to redesign auth.
- If an endpoint's Postman auth conflicts with the flow name, document it in code or AI docs and verify before forcing a UX change.

## Shared Response Rules

Most responses follow this envelope:

```json
{
  "success": true,
  "message": "translation.or.human.message",
  "data": {}
}
```

Validation errors can use:

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "email": ["The email has already been taken."]
    }
  }
}
```

Repository rules:

- Parse `success`, `message`, and `data` defensively.
- Keep uncertain fields nullable.
- Store backend message keys when they are useful, but do not expose backend keys directly as new hardcoded UI text unless the current UI pattern already does that.
- Handle empty lists explicitly in Cubit state.
- Do not create app-wide envelope/pagination abstractions after only one endpoint unless at least two integrated features benefit from the same shape.

## Request And Model Rules

- Use request fields exactly as shown below.
- Keep feature-local request/model classes unless an existing shared model truly matches.
- Dates in requests use `YYYY-MM-DD`, for example `birthdate`.
- Prices are strings in examples, for example `"120.00"` and `"999.00"`. Parse to number only where the UI or business logic needs numeric operations.
- Localized fields commonly come as English plus Arabic pairs: `name`/`name_ar`, `title`/`title_ar`, `description`/`description_ar`, `what_will_learn`/`what_will_learn_ar`, `specifications`/`specifications_ar`.
- Media arrays are commonly named `media_list`; thumbnail images may be identified by `collection_name = thumbnail`.
- Use `FormData` only for multipart requests such as profile image update.

## Shared API Boundaries

### `ApiServices`

Keep shared concerns here:

- base URL
- common JSON headers
- bearer token injection
- language header
- shared interceptors
- shared HTTP verbs

The current `post` method sends JSON by default. If profile upload is integrated, add the smallest necessary multipart support in `ApiServices` or the profile repository without breaking current JSON callers.

### Feature Repository

Keep feature-specific API concerns here:

- endpoint path
- query params
- request body or multipart payload
- response parsing
- conversion to `Failure` through existing error handling

### Cubit

Keep feature flow here:

- initial state
- loading/submitting state
- success/loaded state
- empty state for empty lists
- error state

## Endpoint Reference

All paths below are relative to `base_url_app`.

### 1. Authentication

#### Register

- Method: `POST`
- Path: `auth/register`
- Auth: no auth by folder inheritance
- Description: creates a student account; backend may require OTP verification after registration.
- Valid `heard_about` values: `social_media`, `family`, `friends`, `school`, `competitions`, `other`
- Valid `gender` values: `male`, `female`

Request:

```json
{
  "name": "Ahmed Mohammed",
  "name_ar": "Ahmed Mohammed",
  "email": "student2@example.com",
  "password": "password123",
  "password_confirmation": "password123",
  "birthdate": "1995-05-15",
  "gender": "male",
  "language": "ar",
  "heard_about": ["social_media", "friends"],
  "fcm_token": "fcm_device_token_here"
}
```

Success response data:

- `user`: `id`, `name`, `name_ar`, `email`, `birthdate`, `gender`, `language`, `fcm_token`, `heard_about`, `role_id`, `image`, timestamps
- nested `message`: example says email verification is required
- no token is shown in the register success example

Error example:

- status `422`
- `data.errors.email` is an array of validation messages

#### Login

- Method: `POST`
- Path: `auth/login`
- Auth: no auth by folder inheritance
- Description: authenticates the user and returns a bearer token.

Request:

```json
{
  "email": "student2@example.com",
  "password": "verysecurepassword",
  "fcm_token": "fcm_device_token_here"
}
```

Success response data:

- `user`: profile fields including `points`, `email_verified_at`, `verification_code`, `verification_code_expires_at`
- `token`: bearer token string

#### Login With Google

- Method: `POST`
- Path: `auth/google`
- Auth: no auth by folder inheritance
- Description: exchanges a Google OAuth token for a Roboo API token.

Request:

```json
{
  "token": "GOOGLE_ID_TOKEN_HERE",
  "fcm_token": "optional_fcm"
}
```

Response examples: none in collection. Parse only after backend response is observed.

#### Verify OTP Code

- Method: `POST`
- Path: `auth/verify-code`
- Auth: no auth by folder inheritance

Request:

```json
{
  "email": "student2@example.com",
  "code": "849300"
}
```

Success response data:

- `user`
- `token`

Error example:

- status `400`
- `message = auth.code_expired`
- `data = null`

#### Resend Verification

- Method: `POST`
- Path: `auth/resend-verification`
- Auth: no auth by folder inheritance

Request:

```json
{
  "email": "student2@example.com"
}
```

Success response data: `null`

#### Forgot Password

- Method: `POST`
- Path: `auth/forgot-password`
- Auth: request declares bearer, but this conflicts with the public reset-password flow.

Request:

```json
{
  "email": "student2@example.com"
}
```

Success response data: `null`

Implementation note: verify with backend before making forgot password require an existing token in the UI.

#### Reset Password With Code

- Method: `POST`
- Path: `auth/reset-password`
- Auth: no auth by folder inheritance

Request:

```json
{
  "email": "student2@example.com",
  "code": "832219",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

Success response data:

- `user`
- `token`

### 2. My Profile

All endpoints in this folder inherit bearer `{{token}}`.

#### Get My Details

- Method: `GET`
- Path: `auth/me`

Success response data:

- `user`: `id`, `name`, `name_ar`, `email`, `google_id`, `fcm_token`, `email_verified_at`, `birthdate`, `gender`, `role_id`, `points`, `language`, `heard_about`, `image`, timestamps

#### Update Profile

- Method: `POST`
- Path: `auth/profile`
- Body mode: multipart form-data

Form fields shown:

```text
name=Ahmed Updated
image=<file>
language=en
```

Success response data:

- `user` with updated `name`, `language`, and `image` URL

Implementation note: the example only shows `name`, `image`, and `language`, so do not assume every profile field can be updated unless backend confirms it.

#### Request Password Update Code

- Method: `POST`
- Path: `auth/request-password-update`
- Body: none

Success response data: `null`

#### Update Password With Code

- Method: `POST`
- Path: `auth/update-password`

Request:

```json
{
  "code": "123456",
  "password": "verysecurepassword",
  "password_confirmation": "verysecurepassword"
}
```

Success response data:

- `user`
- `token`

#### Logout

- Method: `POST`
- Path: `auth/logout`
- Response examples: none in collection

Implementation note: clear local token/cache on successful logout; if backend response is empty, keep parsing tolerant.

### 3. Exploration Public

All endpoints in this folder are no-auth by folder inheritance.

#### Courses List

- Method: `GET`
- Path: `courses`
- Example query: `type=online`
- Description: browse courses; collection mentions filters for topic or type.

Example:

```text
GET courses?type=online
```

Success response data:

- `courses`: array of course summaries
- `pagination`: `total`, `per_page`, `current_page`, `last_page`

Course fields:

- `id`, `title`, `title_ar`, `description`, `description_ar`
- `type`, `price`, `image`, `age_group`, `level`
- `what_will_learn`, `what_will_learn_ar`
- `bunny_demo_video_hls_url`
- `sessions_count`, `duration_hours`, `start_date`, `is_active`
- `topic_id`, `topic`, timestamps

#### Courses Details

- Method: `GET`
- Path: `courses/{course_id}`
- Description: detailed course info; if logged in and purchased, lessons may be included.

Success response data:

- course fields from the list endpoint
- `is_unlocked`
- `available_places`
- `lessons`

#### Products List

- Method: `GET`
- Path: `products`

Success response data:

- Laravel-style pagination object with `data` array and pagination URLs/counts

Product fields:

- `id`, `category_id`, `name`, `name_ar`, `description`, `description_ar`
- `price`
- `specifications`, `specifications_ar`
- `media_list`
- `category`
- timestamps

Media fields:

- `id`, `collection_name`, `image_url`

Category fields:

- `id`, `name`, `name_ar`, timestamps

#### Products Details

- Method: `GET`
- Path: `products/{product_id}`

Success response data:

- same product fields as list item
- `category`
- `media_list`

#### Categories

- Method: `GET`
- Path: `categories`

Success response data:

- array of categories
- fields: `id`, `name`, `name_ar`, timestamps

#### Topics

- Method: `GET`
- Path: `topics`

Success response data:

- array of topics
- fields: `id`, `name`, `name_ar`

#### Places Centers

- Method: `GET`
- Path: `places`

Success response data:

- array of places
- fields: `id`, `name`, `name_ar`, `city`, `city_ar`, `latitude`, `longitude`, timestamps

#### Galleries

- Method: `GET`
- Path: `galleries`

Success response data:

- Laravel-style pagination object with `data` array

Gallery fields:

- `id`, `title`, `title_ar`, `description`, `description_ar`
- `media_list`
- timestamps

#### FAQs

- Method: `GET`
- Path: `faqs`

Success response data:

- Laravel-style pagination object with `data` array

FAQ fields:

- `id`, `title`, `title_ar`, `description`, `description_ar`, timestamps

#### Privacy Policy

- Method: `GET`
- Path: `privacy-policy`

Success response data:

- `slug`
- `body_en`
- `body_ar`
- `updated_at`

#### Terms Of Use

- Method: `GET`
- Path: `terms-of-use`

Success response data:

- `slug`
- `body_en`
- `body_ar`
- `updated_at`

### 4. Student Learning Protected

All endpoints in this folder inherit bearer `{{token}}`.

#### Reserve Seat Interest Click

- Method: `POST`
- Path: `courses/{course_id}/reserve-click`
- Description: record that a user clicked reserve for marketing/follow-up.

Request:

```json
{
  "device_id": "UUID-TRACKING-ID"
}
```

Success response data: `null`

#### Unlock With Coupon

- Method: `POST`
- Path: `coupons/apply`

Request:

```json
{
  "code": "LTIIJ3LKUV"
}
```

Success response data:

- `course_id`

#### Lessons List For Course

- Method: `GET`
- Path: `courses/{course_id}/lessons`
- Description: retrieve purchased-course curriculum.

Success response data:

- array of lessons

Lesson fields:

- `id`, `course_id`, `title`, `title_ar`, `description`, `description_ar`
- `order`, `duration_seconds`
- `bunny_video_hls_url`
- `is_free_preview`, `is_locked`, `is_watched`
- `what_will_learn`, `what_will_learn_ar`
- timestamps

#### Lesson Details And Video

- Method: `GET`
- Path: `lessons/{lesson_id}`

Success response data:

- lesson fields from list endpoint
- `quiz`

#### Mark Lesson As Watched

- Method: `POST`
- Path: `courses/{course_id}/mark-watched`

Request:

```json
{
  "lesson_id": 1
}
```

Success response data: `null`

#### Quizzes My List

- Method: `GET`
- Path: `quizzes`

Success response data:

- `quizzes`: array
- `pagination`: `total`, `per_page`, `current_page`, `last_page`

Quiz summary fields:

- `id`, `title`, `title_ar`, `topic_id`, `course_id`, `lesson_id`
- `time_limit`, `points`
- `topic`, `course`, `lesson`
- timestamps

#### Quiz Show Questions

- Method: `GET`
- Path: `quizzes/{quiz_id}`

Success response data:

- quiz summary fields
- `questions_count`
- `questions`

Question fields:

- `id`, `question_text`, `question_text_ar`, `answers`

Answer fields:

- `id`, `answer_text`, `answer_text_ar`, `is_correct`

Implementation note: the example includes `is_correct`; do not expose it in quiz-taking UI unless product requirements explicitly allow showing correctness before submit.

#### Quiz Submit Answers

- Method: `POST`
- Path: `quizzes/{quiz_id}/submit`

Request:

```json
{
  "answers": {
    "1": 9,
    "2": 15
  }
}
```

The request format is `{question_id: selected_option_id}`.

Success response data:

- `success`
- `score`
- `total`
- `points_earned`
- `is_perfect`

### 5. Shopping And Shop Protected

All endpoints in this folder inherit bearer `{{token}}`.

#### Toggle Favorite

- Method: `POST`
- Path: `products/favorite`

Request:

```json
{
  "product_ids": [1]
}
```

Success response data:

- `attached`: product IDs added to favorites
- `detached`: product IDs removed from favorites

Implementation note: response examples show both attach and detach using the same endpoint.

#### My Favorites List

- Method: `GET`
- Path: `favorites`

Success response data:

- Laravel-style pagination object with product `data` array
- product shape matches `Products List`

#### Create Order Checkout

- Method: `POST`
- Path: `orders`
- Description: creates an order. Collection description mentions price matching, but the request example only sends product ID and quantity.

Request:

```json
{
  "items": [
    {
      "product_id": 1,
      "quantity": 1
    }
  ]
}
```

Success response data:

- status `201`
- `id`, `user_id`, `total_price`, timestamps
- `items`
- `user`

Order item fields:

- `id`, `order_id`, `product_id`, `quantity`, `unit_price`, timestamps
- `product`

Implementation note: do not send client-calculated price unless backend confirms it is required; the example omits it.

#### Order History

- Method: `GET`
- Path: `orders`

Success response data:

- Laravel-style pagination object with order `data` array

Order summary fields:

- `id`, `user_id`, `total_price`, timestamps
- `items`

#### Order Details

- Method: `GET`
- Path: `orders/{order_id}`

Success response data:

- `id`, `user_id`, `total_price`, timestamps
- `user`
- `items`

### 6. Social And Meta

Folder declares bearer `{{token}}`.

#### Leaderboard Top Students

- Method: `GET`
- Path: `leaderboard`
- Description says public ranking, but folder declares bearer auth.

Success response data:

- `leaderboard`: array

Leaderboard item fields:

- `name`
- `points`
- `image`

Implementation note: because folder auth and description disagree, verify before treating leaderboard as publicly accessible.

#### Submit Feedback

- Method: `POST`
- Path: `feedbacks`

Request:

```json
{
  "rating": 5,
  "note": "Excellent learning platform!"
}
```

Success response data:

- status `201`
- `id`, `user_id`, `rating`, `note`, timestamps

## Current Repo Mismatches To Respect

- Auth code currently contains phone-based assumptions; Postman uses `email`.
- Reset-password code currently points at older endpoint names; Postman uses `auth/forgot-password`, `auth/reset-password`, `auth/request-password-update`, and `auth/update-password`.
- `Urls` contains paths that do not match the collection.
- Many non-auth features have `temp_repo`, `temp_repo_iplm`, `temp_cubit`, and `temp_state`; they are placeholders, not real integrations.
- `services_locater.dart` registers only shared services plus some auth repositories.

Rule: when implementing a feature, align new API work to this collection unless the user explicitly asks to preserve legacy backend behavior.

## Feature Integration Sequence

For every API-backed feature:

1. Identify the exact feature boundary in `lib/features/`.
2. Check `.ai/feature-api-mapping.md` for the Postman folder, endpoint set, status, and risk notes.
3. Read the current screen, widgets, repo, and Cubit files for that feature.
4. Confirm whether the feature is UI-only, partially integrated, or already integrated.
5. Read the exact Postman requests and response examples in this file or the collection.
6. Add or update feature repository code.
7. Add or update feature-local models.
8. Add or update Cubit states and actions.
9. Wire the screen to Cubit state.
10. Remove only hardcoded data replaced by the new flow.
11. Add DI registrations only for the repository/Cubit dependencies actually used.

Do not integrate multiple unrelated features in one task.

## Collection Gaps And Ambiguities

- `Login With Google` and `Logout` have no response examples.
- `Forgot Password` declares bearer auth even though the reset-password flow is normally public.
- `Leaderboard` is described as public but lives under a bearer-auth folder.
- Course filters mention topic/type, but only `type=online` is shown as a query example.
- Product/order/favorites pagination uses Laravel-style pagination, while courses/quizzes use custom `courses` or `quizzes` arrays plus a smaller `pagination` object.
- `Create Order` description mentions price, but the request body example omits price.
- No endpoint exists in this collection for Roboo AI chat, games, on-boarding, splash, settings, complaints under that name, or my-courses as a direct endpoint.
