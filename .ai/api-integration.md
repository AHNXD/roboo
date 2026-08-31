# API Integration

## Source Of Truth

Precedence, highest first:

1. `Roboo — Professional App API.postman_collection.json` — the `Roboo — Mobile API` export. This is the newest and most
   complete contract: student app **and** teacher app, with response examples and per-request
   test scripts that document the expected status codes.
2. `UPDATE_PROFILE_API_DOCUMENTATION.md` — older
   prose docs. Still useful for cart/order/profile error-state detail, but the collection wins
   wherever they disagree.
3. This file — a readable digest of the collection, not a replacement for it.

Do not use `lib/core/Api_services/urls.dart` as the source of truth for paths. It still contains
legacy paths such as `login`, `register`, `get_profile` that do not match the collection. Its
`// current …` sections are maintained and safe to extend; add every new endpoint there rather
than inlining a path in a repository.

## Current Collection Snapshot

- collection name: `Roboo — Mobile API`
- Postman schema: collection v2.1
- base variable: `base_url_app = https://api.robooq.com/api/` (HTTPS — see the redirect note below)
- collection-level auth: bearer `{{token}}`
- variables: `token`, `teacher_token`, `course_id`, `lesson_id`, `product_id`, `order_id`,
  `quiz_id`, `homework_id`, `teacher_homework_id`, `student_id`, `section_id`, `submission_id`,
  `coupon_id`, `coupon_code`, `new_email`
- **admin routes are deliberately excluded.** They live behind `/api/admin/*` and belong to the
  web dashboard. Never call them from the app.

Folders:

| # | Folder | Auth | App surface |
| --- | --- | --- | --- |
| 1 | Authentication | none | student + teacher login |
| 2 | My Profile | bearer `token` | profile |
| 3 | Exploration (Public) | none | courses, store, news, faq, legal |
| 4 | Student Learning (Protected) | bearer `token` | course lessons, quizzes |
| 5 | Shopping & Shop (Protected) | bearer `token` | favorites, orders |
| 6 | Social & Meta | bearer `token` | leaderboard, feedback |
| 7 | Enrollment (Student) | bearer `token` | **no app UI yet** |
| 8 | Homework (Student) | bearer `token` | **no app UI yet** |
| 9 | Cart (Student) | bearer `token` | cart |
| 10-13 | Teacher — school, students, homework, coupons | bearer `teacher_token` | **no app UI yet** |
| 99 | Error Cases | mixed | contract tests, not features |
| ZZ | Session End | bearer `token` | logout |

### HTTPS is mandatory

`http://api.robooq.com/...` answers `302` for GET and `307` for POST with a `Location` on
`https://`. Dio does not auto-follow redirects for POST, so every write fails with
`DioExceptionType.badResponse` on plain HTTP. `Urls.baseUrl` must stay `https://`.

## Auth And Access Rules

- Students and teachers sign in through the **same** endpoint, `POST auth/login`. The response
  distinguishes them: `user.is_student` and `user.role_name` (`"teacher"`). The app decides which
  home screen to open from those two fields.
- **One active session per user.** Logging in again revokes the previous token, and `auth/logout`
  revokes the current one. Any protected call after logout answers 401.
- Public exploration endpoints work without a token.
- Protected endpoints rely on `ApiServices` bearer injection from `CacheHelper`. Never pass a
  token from a widget.
- No refresh-token flow is documented. Do not invent one.
- `401` and `403` mean different things and must not be collapsed:
  - `401` — missing, malformed, expired or revoked token. `AuthInterceptor` bounces to login.
  - `403` — authenticated but not allowed, e.g. a student token on a `teacher/*` route. Body is
    `{"success": false, "message": "Unauthorized", "data": null}`. Do **not** log the user out.
- Auth writes are rate limited. `POST auth/register` advertises `x-ratelimit-limit: 5`, and
  verify/resend/forgot/reset all list `429` as a valid answer. Surface "try again later" rather
  than treating 429 as a generic failure.

## Shared Response Rules

Every successful response uses this envelope:

```json
{ "success": true, "message": "translation.or.human.message", "data": {} }
```

Failures keep the same shape with `success: false`. Validation errors:

```json
{
  "success": false,
  "message": "Validation failed",
  "data": { "errors": { "email": ["The email has already been taken."] } }
}
```

Every response carries an `X-Request-Id` header. Include it when reporting a backend bug — it is
how the backend correlates logs.

### Three pagination shapes

Check which one an endpoint uses before writing the parser.

1. **Named array + small pagination object** — `courses`, `quizzes`, `homework`,
   `homework/submissions/mine`, `teacher/students`, `teacher/homework`,
   `teacher/enrollment-coupons`:

   ```json
   { "data": { "courses": [ … ], "pagination": { "total": 3, "per_page": 25,
                "current_page": 1, "last_page": 1 } } }
   ```

2. **Laravel paginator** — `products`, `galleries`, `faqs`, `favorites`, `orders`. The list is at
   `data.data`, alongside `current_page`, `links`, `next_page_url`, `total`, …

3. **Plain array** — `categories`, `topics`, `places`, `courses/{id}/lessons`. `data` is the array
   itself. `leaderboard` is a one-key object wrapping its array.

Repository rules:

- Parse `success`, `message`, and `data` defensively; keep unproven fields nullable.
- Handle empty lists explicitly as a distinct Cubit state.
- Do not build an app-wide envelope/pagination abstraction until at least two integrated features
  need the identical shape.

## Request And Model Rules

- Dates in requests use `YYYY-MM-DD`, e.g. `birthdate`.
- Prices are strings, e.g. `"120.00"`. Parse to a number only where arithmetic is needed.
- Localized fields come in English + Arabic pairs: `name`/`name_ar`, `title`/`title_ar`,
  `description`/`description_ar`, `what_will_learn`/`what_will_learn_ar`,
  `specifications`/`specifications_ar`, `city`/`city_ar`, `question_text`/`question_text_ar`,
  `answer_text`/`answer_text_ar`.
- Media arrays are named `media_list`; thumbnails carry `collection_name = "thumbnail"`.
- Image URLs come back absolute but pointing at the API host — always run them through
  `ApiMediaUrlResolver.resolve`.
- Use `FormData` only for multipart, currently just `auth/profile`.

## Endpoint Reference

All paths are relative to `base_url_app`.

### 1. Authentication (public)

| Method | Path | Notes |
| --- | --- | --- |
| POST | `auth/register` | student sign-up, may require OTP |
| POST | `auth/login` | students **and** teachers |
| POST | `auth/google` | no response example |
| POST | `auth/verify-code` | email OTP |
| POST | `auth/resend-verification` | throttled |
| POST | `auth/forgot-password` | public in this export |
| POST | `auth/reset-password` | returns `user` + `token` |

**Register** request:

```json
{
  "name": "Ahmed Mohammed", "name_ar": "…",
  "email": "student@example.com",
  "password": "password123", "password_confirmation": "password123",
  "birthdate": "1995-05-15", "gender": "male", "language": "ar",
  "heard_about": ["social_media", "friends"],
  "fcm_token": "fcm_device_token_here"
}
```

`heard_about`: `social_media`, `family`, `friends`, `school`, `competitions`, `other`.
`gender`: `male`, `female`.
Success `data` carries `user` plus a nested `message` ("Please verify your email.") and **no
token** — the token arrives from `verify-code`. `422` on a taken email.

**Login** request `{ "email", "password", "fcm_token" }`. Success `data` = `user` + `token`.
`user` includes `points`, `email_verified_at`, and for teachers `is_student: false` and
`role_name: "teacher"`. Wrong credentials answer `401` (or `429`), and the message must not
reveal whether the account exists.

**Verify OTP** `{ "email", "code" }` → `user` + `token`. Expired code: `400` with
`message = "auth.code_expired"`.

**Reset password** `{ "email", "code", "password", "password_confirmation" }` → `user` + `token`.

### 2. My Profile (bearer)

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| GET | `auth/me` | — | `user` |
| POST | `auth/profile` | multipart: `name`, `image`, `language` | `user` |
| POST | `auth/request-password-update` | — | `null` |
| POST | `auth/update-password` | `code`, `password`, `password_confirmation` | `user` + `token` |

`auth/profile` is multipart form-data. The example only shows `name`, `image`, `language` — do not
assume other fields are editable.

### 3. Exploration (public)

| Method | Path | Query | Response shape |
| --- | --- | --- | --- |
| GET | `courses` | `type`, `topic_id`, `paginate` | named array + pagination |
| GET | `courses/{course_id}` | — | single object |
| GET | `products` | `search`, `category_id` | Laravel paginator |
| GET | `products/{product_id}` | — | single object |
| GET | `categories` | — | plain array |
| GET | `topics` | — | plain array |
| GET | `places` | — | plain array |
| GET | `galleries` | — | Laravel paginator |
| GET | `faqs` | — | Laravel paginator |
| GET | `privacy-policy` | — | single object |
| GET | `terms-of-use` | — | single object |

**Course** fields: `id`, `title`, `title_ar`, `description`, `description_ar`, `type`, `price`,
`image`, `age_group`, `level`, `what_will_learn`, `what_will_learn_ar`,
`bunny_demo_video_hls_url`, `sessions_count`, `duration_hours`, `start_date`, `is_active`,
`topic_id`, `topic`, timestamps. **Course details** adds `is_unlocked`, `available_places`,
`lessons`.

**Product** fields: `id`, `category_id`, `name`, `name_ar`, `description`, `description_ar`,
`price`, `specifications`, `specifications_ar`, `media_list`, `category`, timestamps.
`specifications` appears as an **array of `{key, value}`** in some rows and as a **flat object**
in others, in the same response. Parse both.

**Topic**: `id`, `name`, `name_ar`. **Category**: adds timestamps.
**Place**: `id`, `city`, `city_ar`, `name`, `name_ar`, `latitude`, `longitude`, timestamps.
**Gallery**: `id`, `title`, `title_ar`, `description`, `description_ar`, `media_list`.
**FAQ**: `id`, `title`, `title_ar`, `description`, `description_ar`.
**Legal**: `slug`, `body_en`, `body_ar`, `updated_at`.

### 4. Student Learning (bearer)

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| POST | `courses/{course_id}/reserve-click` | `device_id` | `null` |
| POST | `coupons/apply` | `code` | `course_id` |
| GET | `courses/{course_id}/lessons` | — | plain array of lessons |
| GET | `lessons/{lesson_id}` | — | lesson + `quiz` |
| POST | `courses/{course_id}/mark-watched` | `lesson_id` | `null` |
| GET | `quizzes` | — | `quizzes[]` + `pagination` |
| GET | `quizzes/{quiz_id}` | — | quiz + `questions_count` + `questions[]` |
| POST | `quizzes/{quiz_id}/submit` | `answers` map | score payload |

**Lesson** fields: `id`, `course_id`, `title`, `title_ar`, `description`, `description_ar`,
`what_will_learn`, `what_will_learn_ar`, `bunny_video_hls_url` (absent on locked lessons),
`duration_seconds`, `order`, `is_free_preview`, `is_locked`, `is_watched`, timestamps.
`lessons/{id}` also returns a `quiz` summary — that is how a lesson links to its quiz.

**Quiz list** item: `id`, `title`, `title_ar`, `topic_id`, `course_id`, `lesson_id`, `time_limit`,
`points`, `topic`, `course`, `lesson`, timestamps. **No `questions_count` in the list** — only the
detail response has it. The list takes **no query parameters**, so topic filtering is client-side.

**Quiz submit** body — `{question_id: answer_id}`, keys as strings:

```json
{ "answers": { "1": 9, "2": 15 } }
```

The request description says "selected_option_index", but the example sends **answer ids** (9, 15
are `answers[].id` from the detail response). Follow the example.

Response `data`: `success`, `score`, `total`, `points_earned`, `is_perfect`, `solved`, and
`question_results[]`:

```json
{ "question_id": 1, "selected_answer_id": 9, "is_correct": false, "correct_answer_id": 10 }
```

`question_results` is the **server's** verdict per question, delivered after submitting — the
right channel for revealing answers. Use it to build a post-quiz review.

`solved` means **the quiz had already been solved before**, and points are only ever awarded
once: a live run on 2026-08-26 answered a quiz correctly a second time and returned
`score: 3, total: 3, is_perfect: true, solved: true, points_earned: 0`.

⚠️ Never derive "did the student pass" from `points_earned` — a perfect repeat pays zero. Judge
on `score` / `total`.

⚠️ The quiz **detail** response still includes `is_correct` on every answer, so a client can read
the answers out of the payload before submitting. Now that `question_results` exists, the app no
longer needs that field, and the backend can drop it. Compare with student homework, which never
exposes the correct option.

### 5. Shopping (bearer)

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| POST | `products/favorite` | `product_ids: []` | `attached[]`, `detached[]` |
| GET | `favorites` | — | Laravel paginator of products |
| POST | `orders` | `items: [{product_id, quantity}]` | `201` + order |
| GET | `orders` | — | Laravel paginator of orders |
| GET | `orders/{order_id}` | — | order + `user` + `items` |

`products/favorite` is a toggle — the same call attaches or detaches, and the response says which.
**Create order answers `201`, not `200`.** Its description mentions a `price` field but the example
omits it; do not send a client-calculated price.

### 6. Social & Meta (bearer)

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| GET | `leaderboard` | — | `leaderboard[]` of `name`, `points`, `image` |
| POST | `feedbacks` | `rating`, `note` | `201` + feedback |

Leaderboard is described as public ranking but sits in a bearer folder. `image` can be `null`.

### 7. Enrollment (Student, bearer) — no app UI yet

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| GET | `enrollment` | — | `is_enrolled`, `school`, `school_class`, `section` |
| POST | `enrollment/redeem` | `code` | enrollment |

A student who has not redeemed a coupon has `is_enrolled: false` and `school`, `school_class`,
`section` all `null`. Redemption is single use — a second attempt with the same code answers `422`.

Until a student is enrolled they have no `section_id`, and the homework endpoints return an
**empty list rather than an error**.

`school`: `id`, `name`, `name_ar`, `address`, `phone`, `is_active`, timestamps.
`school_class`: `id`, `school_id`, `name`, `name_ar`, `grade_level`, `is_active`, timestamps.
`section`: `id`, `school_class_id`, `name`, `name_ar`, `is_active`, timestamps.

### 8. Homework (Student, bearer) — no app UI yet

| Method | Path | Body | Returns |
| --- | --- | --- | --- |
| GET | `homework` | — | `homework[]` + `pagination` |
| GET | `homework/{homework_id}` | — | homework + `questions[]` with options |
| POST | `homework/{homework_id}/submit` | `answers` | graded submission with `score` |
| GET | `homework/submissions/mine` | — | `submissions[]` + `pagination` |

Only **published** homework for the student's own section is listed.

**Since 2026-08-26 the correction is released with the mark.** `my_submission.question_results`
carries `{question_id, selected_option_id, is_correct, correct_option_id}` per question, gated on
`status = returned` exactly like `score` and `feedback` — `null` while withheld, and never present
for non-MCQ homework. Note the field names differ from the quiz equivalent (`*_option_id` here,
`*_answer_id` there). Full rules in `FEATURE-QUIZ-HOMEWORK-COURSES.md`.

Before that change the answer was withheld permanently, which is what the older text below
described:

**The correct option was never sent to the student — before *or* after marking.** Verified on the
live API (2026-08-26) against a `returned` homework with a released full score:

- `GET homework/{id}` questions are `{id, question, order, score}`, options `{id, label, order}`
- the submission carries `answers` (chosen option ids), `score`, `feedback`, `status`,
  `is_score_released` — and nothing per question
- `GET homework/submissions/mine` adds nothing either
- `GET teacher/homework/{id}` does have the correct option, but answers **403** to a student token

So the app can show a student *what they answered* and *what they scored*, but **not which
answers were right**. There is no homework equivalent of the quiz `question_results`. Building
that UI needs a backend change — see `.ai/todo.md`.

**Submit accepts two shapes** — a list or a map:

```json
{ "answers": [ { "question_id": 1, "option_id": 1 } ] }
{ "answers": { "1": 1 } }
```

An `option_id` that does not belong to its `question_id` is rejected with `422` rather than
silently scored zero.

**Withheld marks:** a submission's `score` is `null` and `is_score_released` is `false` until its
`status` becomes `"returned"`. Statuses seen: `missing`, `submitted`, `corrected`, `returned`.
Never render a score before it is released — show "awaiting marking" instead.

Out-of-scope or non-existent homework ids both answer `404`, so ids cannot be enumerated.

### 9. Cart (Student, bearer)

| Method | Path | Body |
| --- | --- | --- |
| GET | `cart` | — |
| POST | `cart/items` | `product_id`, `quantity` |
| POST | `cart/items/update` | `product_id`, `quantity` |
| POST | `cart/items/remove` | `product_id` |
| POST | `cart/clear` | — |

`data` is `{ items: [], summary: { item_count, subtotal } }`. Adding a product already in the cart
**increases** its quantity; `cart/items/update` sets an **absolute** quantity, not a delta.
`cart/clear` is safe on an already-empty cart. The cart is a draft; `orders` is the commit.

### 10-13. Teacher app (bearer `teacher_token`) — no app UI yet

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `teacher/me` | profile + `sections[]` + `context{classes, schools}` |
| GET | `teacher/assignments` | raw `schools[]`, `classes[]`, `sections[]` |
| GET | `teacher/stats` | `students_total`, `students_active`, `schools_count`, `classes_count`, `sections_count` |
| GET | `teacher/students` | `students[]` + `pagination`; query `search`, `section_id` |
| GET | `teacher/students/{student_id}` | one student + section |
| GET | `teacher/homework` | owned homework, drafts included |
| POST | `teacher/homework` | create with questions — answers **201** |
| GET | `teacher/homework/{id}` | teacher view — **does** include the correct option |
| POST | `teacher/homework/{id}` | update; `{"is_published": true}` publishes |
| GET | `teacher/homework/{id}/submissions` | who answered and what they scored |
| GET | `teacher/homework/{id}/roster` | `rows[]` + `summary` — includes students who did **not** submit |
| POST | `teacher/submissions/{id}/correct` | `score`, `feedback` — manual override |
| POST | `teacher/homework/{id}/release` | publishes every marked submission at once |
| DELETE | `teacher/homework/{id}` | soft delete; submissions kept |
| GET/POST/DELETE | `teacher/enrollment-coupons` | list / create (`section_id`, `quantity`) / delete |

Teacher scoping: a teacher assigned to a class can act on every section inside it, which is why
`teacher/me` returns both the raw assignment and an expanded `sections`. A student outside their
sections answers `404`, identical to a non-existent student.

`POST teacher/homework` requirements: `type` is required and one of `mcq`, `text`, `image`,
`video`, `image_text`, `video_text`; `correction_type` is `automatic` or `manual`; target
**exactly one** of `section_id` or `school_class_id` (both or neither → `422`); each question needs
at least 2 options, exactly one with `is_correct: true`.

`roster` summary keys: `students`, `missing`, `submitted`, `corrected`, `returned` — and they add
up to the roster size. `release` reports `{ "released": n }` and is safe to re-run.

A coupon that has been redeemed cannot be deleted.

### ZZ. Logout

`POST auth/logout` invalidates the current token. Clear the local token/cache on success and keep
parsing tolerant — the collection has no response example.

## Error Contract

The collection's `99. Error Cases` folder asserts these on purpose:

| Case | Status | Body |
| --- | --- | --- |
| protected route, no token | 401 | envelope, no data leak |
| protected route, garbage token | 401 | envelope |
| student token on `teacher/*` | 403 | `{"success": false, "message": "Unauthorized", "data": null}` |
| unknown route | 404 | `{"success": false, "message": "Resource not found", "data": null}` |
| out-of-scope homework id | 404 | same as not-found |
| malformed login body | 422 | names the offending fields |
| wrong credentials | 401 or 429 | must not reveal whether the account exists |

Errors are always JSON, never an HTML error page, and never carry a stack trace
(`APP_DEBUG=false` in production).

## Collection Gaps And Ambiguities

- `Login with Google` and `Logout` still have no response examples.
- `Forgot Password` is public here, resolving the earlier bearer-auth contradiction.
- `Leaderboard` is described as a public ranking but lives in a bearer folder.
- Quiz submit description ("selected_option_index") contradicts its own example (answer ids).
- Quiz answers expose `is_correct` **before** submitting; homework never does. Since the submit
  response now returns `question_results`, the pre-submit field is redundant and should be dropped
  by the backend.
- `solved` is only described by observation (already-solved repeat pays no points); the backend
  has not documented it.
- The `question_results`/`solved` fields were added to the collection on 2026-08-26 and are not
  yet confirmed on the deployed API — an app log from earlier that day returned neither. Parse
  them optionally.
- `Create Order` mentions a price field its example omits.
- No endpoint exists for Roboo AI chat, games, on-boarding, splash, settings, or a direct
  enrolled-courses ("my courses") list. `courses/{id}.is_unlocked` is the only enrollment signal,
  and it is per-course.
- No progress percentage is exposed for a course; `lessons[].is_watched` is the only raw material.

## Feature Integration Sequence

For every API-backed feature:

1. Identify the exact feature boundary in `lib/features/`.
2. Check `.ai/feature-api-mapping.md` for the folder, endpoint set, status, and risk notes.
3. Read the current screen, widgets, repo, and Cubit files for that feature.
4. Read the exact Postman request and response example.
5. Add the endpoint to `Urls`, then repository, models, Cubit states, screen wiring.
6. Register the repository in `services_locater.dart`.
7. Remove only the hardcoded data the new flow replaces.

Do not integrate multiple unrelated features in one task. Code templates live in
`.claude/skills/api-feature-integration/references/patterns.md`.
