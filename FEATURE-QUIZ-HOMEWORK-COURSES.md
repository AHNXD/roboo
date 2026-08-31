# Quiz, Homework & Course-Catalog Features

Student-facing features, documented here instead of Postman: what each
endpoint returns, the rule it enforces, the automated test that proves it,
and a runnable `curl` example. All endpoints below sit behind
`auth:sanctum` unless marked **Public**, and every response is wrapped in
the standard envelope:

```json
{ "success": true, "message": "...", "data": { /* shown per-endpoint below */ } }
```

Run every test referenced here with:

```bash
export DB_HOST=127.0.0.1 DB_USERNAME=root DB_PASSWORD=
php artisan test tests/Feature/Mobile
```

Last verified: **43 passed (249 assertions)**, full `tests/Feature/Mobile` suite.

---

## 1. Quiz — solved status & single point payout

**Rule:** a student can retake a non-course quiz as many times as they like,
but `points` on their account can only ever be incremented once per quiz. A
course/lesson quiz instead blocks any second attempt outright. The backend
is the sole source of truth — `solved` and `points_awarded` are computed
from `quiz_attempts`, never from anything the client sends.

Enforced in [`QuizService::submitQuiz()`](../app/Services/QuizService.php#L127):

```php
$alreadySolved = $this->quizRepository->hasEarnedPoints($userId, $quizId);
...
$isPerfect = ($score === $totalQuestions && $totalQuestions > 0);
$pointsAwarded = $isPerfect && ! $alreadySolved;   // <-- the whole guarantee
```

`hasEarnedPoints()` is a straight `quiz_attempts` lookup for a row with
`points_awarded = true` for that `(user_id, quiz_id)` pair
([`QuizRepository.php:105`](../app/Repositories/QuizRepository.php#L105)).

### Endpoints

| Method | Path | Auth |
|---|---|---|
| GET | `/api/quizzes` | required |
| GET | `/api/quizzes/{id}` | required |
| POST | `/api/quizzes/{id}/submit` | required |

`GET /api/quizzes` and `GET /api/quizzes/{id}` both add a `solved` boolean
per quiz — `true` once the authenticated student holds a `points_awarded`
attempt for it ([`QuizResource.php:29`](../app/Http/Resources/QuizResource.php#L29)).

### `POST /api/quizzes/{id}/submit`

Request:

```json
{ "answers": { "12": 45, "13": 47 } }
```

`answers` maps `question_id -> answer_id` (an option index is also accepted
for backward compatibility).

Response (`data`):

```json
{
  "success": true,
  "score": 2,
  "total": 2,
  "points_earned": 10,
  "is_perfect": true,
  "solved": true,
  "question_results": [
    { "question_id": 12, "selected_answer_id": 45, "is_correct": true, "correct_answer_id": 45 }
  ]
}
```

Submitting the **same** quiz again after a perfect score still returns
`"solved": true` and `"is_perfect": true`, but `"points_earned": 0` — and
`user.points` in the database does not move.

A course/lesson quiz refuses the second attempt entirely:

```json
{ "success": false, "message": "You have already taken this course quiz. Only one attempt is allowed.", "solved": true }
```

### curl

```bash
TOKEN=... # Sanctum bearer token for a student

# First solve — awards points
curl -s -X POST https://api.robooq.com/api/quizzes/12/submit \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"answers": {"45": 101}}'

# Retake — same perfect score, points_earned is now 0
curl -s -X POST https://api.robooq.com/api/quizzes/12/submit \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"answers": {"45": 101}}'
```

### Tests — [`tests/Feature/Mobile/QuizSubmissionTest.php`](../tests/Feature/Mobile/QuizSubmissionTest.php)

| Test | Proves |
|---|---|
| `a_wrong_answer_reveals_the_correct_answer_id` | `question_results` always carries the right answer, win or lose |
| `a_perfect_score_awards_points_and_marks_the_quiz_solved` | first perfect solve credits `quiz.points` to the student |
| **`retaking_an_already_solved_quiz_reports_solved_but_does_not_regrant_points`** | second perfect submission: `points_earned: 0`, `user.points` unchanged — **the double-payout guard** |
| `a_course_quiz_blocks_a_second_attempt_and_still_reports_solved` | course/lesson quizzes reject any retake, not just re-payout |
| `quiz_list_reports_solved_per_authenticated_student` | `GET /api/quizzes` carries `solved` per-quiz |
| `quiz_list_is_paginated_by_default_and_still_reports_solved` | pagination doesn't drop `solved` |
| `quiz_detail_reports_solved_for_the_authenticated_student` | `GET /api/quizzes/{id}` carries `solved` |

---

## 2. Homework — per-question correction display

**Rule:** an MCQ homework submission's per-question correctness
(`question_results`) is visible to the student only once the teacher
releases the mark (`status = returned`) — identical gating to `score` and
`feedback`. A teacher (or anyone who is not the submission's owner) always
sees it. Non-MCQ homework (text/media) never has `question_results` — there
is no "correct answer" to show.

Enforced in
[`HomeworkSubmissionResource::questionResults()`](../app/Http/Resources/HomeworkSubmissionResource.php#L103),
gated by the same `$withheld` flag as `score`/`feedback`
([line 42](../app/Http/Resources/HomeworkSubmissionResource.php#L42)):

```php
$withheld = $isOwner && $this->status !== 'returned';
...
'question_results' => $withheld ? null : $this->questionResults(),
```

The correct answer always comes from `homework_options.is_correct` in the
database — never from the student's own submitted `answers`.

### Endpoints

| Method | Path | Auth |
|---|---|---|
| GET | `/api/homework/{id}` | student |
| POST | `/api/homework/{id}/submit` | student |
| GET | `/api/homework/submissions/mine` | student |
| POST | `/api/teacher/submissions/{id}/correct` | teacher |

### `POST /api/homework/{id}/submit`

Request (`multipart/form-data` or JSON):

```json
{ "answers": { "7": 22, "8": 24 } }
```

Response right after submit (MCQ auto-corrects instantly, but the mark is
still `withheld` — status is `corrected`, not `returned`):

```json
{
  "id": 501, "homework_id": 9, "status": "corrected",
  "score": null, "feedback": null, "question_results": null,
  "is_score_released": false
}
```

### `GET /api/homework/{id}` (student, after the teacher releases the mark)

```json
{
  "my_submission": {
    "status": "returned",
    "score": 8,
    "is_score_released": true,
    "question_results": [
      { "question_id": 7, "selected_option_id": 22, "is_correct": true, "correct_option_id": 22 },
      { "question_id": 8, "selected_option_id": 24, "is_correct": false, "correct_option_id": 25 }
    ]
  }
}
```

### curl

```bash
STUDENT=... ; TEACHER=...

curl -s -X POST https://api.robooq.com/api/homework/9/submit \
  -H "Authorization: Bearer $STUDENT" -H "Content-Type: application/json" \
  -d '{"answers": {"7": 22, "8": 24}}'

# Teacher releases the marks for the whole homework
curl -s -X POST https://api.robooq.com/api/teacher/homework/9/release \
  -H "Authorization: Bearer $TEACHER"

# Student can now see question_results
curl -s https://api.robooq.com/api/homework/9 -H "Authorization: Bearer $STUDENT"
```

### Tests — [`tests/Feature/Mobile/HomeworkSubmissionTest.php`](../tests/Feature/Mobile/HomeworkSubmissionTest.php)

| Test | Proves |
|---|---|
| `mcq_question_results_are_withheld_until_the_teacher_releases_the_mark` | student sees `null` right after auto-correction, sees the real array only once `status = returned` |
| `mcq_question_results_are_never_withheld_from_a_non_owner` | a teacher reading the same submission always sees it, regardless of status |
| `text_homework_never_has_question_results` | non-MCQ homework is always `null`, released or not |

---

## 2b. Homework — bilingual content (Arabic/English)

**New:** homework title, description, MCQ question text, and MCQ option
labels each now carry an optional Arabic counterpart —
`title_ar`, `description_ar`, `question_ar` (per question), `label_ar`
(per option). Same pattern courses/lessons/quizzes already use everywhere
else in this API. **All four are nullable** — a teacher who only fills in
the English side is not blocked, and the field is simply `null` for that
row, never omitted.

This is plain content translation, not the answer key: `label_ar` is the
Arabic text of an option, not whether it's correct. `question_results`
(the per-submission correctness breakdown documented above) is untouched —
it only ever carried IDs and a boolean, no question/option text.

Present on every endpoint that already returns homework/questions:
`GET /api/homework`, `GET /api/homework/{id}`,
`GET /api/homework/submissions/mine` (nested `homework` object).

### Response shape

```json
{
  "id": 9,
  "title": "Fractions Quiz",
  "title_ar": "اختبار الكسور",
  "description": "Basic fractions.",
  "description_ar": "أساسيات الكسور.",
  "type": "mcq",
  "questions": [
    {
      "id": 7,
      "question": "What is 1/2 + 1/2?",
      "question_ar": "كم يساوي 1/2 + 1/2؟",
      "options": [
        { "id": 22, "label": "1", "label_ar": "1" },
        { "id": 23, "label": "3", "label_ar": "3" }
      ]
    }
  ]
}
```

A homework created without any Arabic text (or an older row from before
this change) simply has `title_ar`, `description_ar`, `question_ar`,
`label_ar` all `null` — every existing client that ignores unread fields
keeps working exactly as before.

### curl

```bash
curl -s https://api.robooq.com/api/homework/9 -H "Authorization: Bearer $STUDENT"
# .title_ar / .description_ar / .questions[].question_ar / .questions[].options[].label_ar
```

### Tests — [`tests/Feature/Mobile/HomeworkSubmissionTest.php`](../tests/Feature/Mobile/HomeworkSubmissionTest.php)

| Test | Proves |
|---|---|
| `homework_title_description_and_mcq_text_are_bilingual` | Arabic fields round-trip through create → the create response → a fresh `GET`; omitting Arabic entirely still creates the homework fine, with those fields `null` |

---

## 3. My Courses

**Rule:** `GET /api/my/courses` returns exactly the authenticated student's
purchased + active courses, each with the same `is_unlocked`/`progress`
shape `GET /api/courses/{id}` already computes — no second progress system.

Implemented in
[`CourseRepository::getPurchasedForUser()`](../app/Repositories/CourseRepository.php):
filters `course_user` for the student, requires `is_active`, eager-loads
`lessons` so `CourseResource` fills in `progress`.

### Endpoint

| Method | Path | Auth |
|---|---|---|
| GET | `/api/my/courses` | student |

### Response

```json
{
  "data": [
    {
      "id": 4, "title": "Algebra II", "is_unlocked": true,
      "progress": { "watched_count": 3, "total_count": 10, "percentage": 30.0 }
    }
  ]
}
```

A student with no purchases gets `"data": []`.

### curl

```bash
curl -s https://api.robooq.com/api/my/courses -H "Authorization: Bearer $TOKEN"
```

### Tests — [`tests/Feature/Mobile/CourseCatalogTest.php`](../tests/Feature/Mobile/CourseCatalogTest.php)

| Test | Proves |
|---|---|
| `my_courses_returns_only_purchased_active_courses_with_progress` | unpurchased and inactive courses are excluded; progress is correct |
| `my_courses_is_empty_for_a_student_with_no_purchases` | empty state, no error |

---

## 4. Featured Courses

**Rule:** `GET /api/courses/featured` (public) returns up to 5 courses
ranked by how many students purchased them (`course_user` count). If
literally nothing has ever been purchased platform-wide, it falls back to a
random sample instead of an empty list — never a mix of the two rules in
one response.

Implemented in
[`CourseRepository::getFeatured()`](../app/Repositories/CourseRepository.php):
`withCount('users')->having('users_count', '>', 0)->orderByDesc('users_count')->limit(5)`,
falling back to `inRandomOrder()->limit(5)` only when that query is empty.
`courses/featured` is registered **before** `courses/{id}` in
[`routes/api.php`](../routes/api.php) so the numeric wildcard cannot swallow
it.

### Endpoint

| Method | Path | Auth |
|---|---|---|
| GET | `/api/courses/featured` | **public** |

### Response

```json
{
  "data": [
    { "id": 4, "title": "Algebra II", "purchases_count": 37 },
    { "id": 9, "title": "Intro to Physics", "purchases_count": 12 }
  ]
}
```

`purchases_count` only appears here — it is set solely when the query used
`withCount('users')`, which only `featured()` does.

### curl

```bash
curl -s https://api.robooq.com/api/courses/featured
```

### Tests — [`tests/Feature/Mobile/CourseCatalogTest.php`](../tests/Feature/Mobile/CourseCatalogTest.php)

| Test | Proves |
|---|---|
| `featured_courses_ranks_by_purchase_count_and_caps_at_five` | ordering and the 5-item cap |
| `featured_courses_returns_fewer_than_five_when_fewer_are_purchased` | doesn't pad with unrelated courses |
| `featured_courses_falls_back_to_a_random_sample_when_nothing_is_purchased` | fallback rule, not a mix |
| `featured_route_is_not_swallowed_by_the_show_route_wildcard` | `/courses/featured` never hits `CourseController@show` |

---

## 5. Course cards — video count & favorites

**Rule:** every course list/detail surface (`/courses`, `/courses/{id}`,
`/my/courses`, `/courses/featured`, `/courses/favorites`) carries
`lessons_count` (the "number of videos") and `is_favorite`, computed
server-side — never trust a client-sent favorite flag. Both keys are
**always present** (never `$this->when()`'d away), same convention as
`solved`/`is_score_released` elsewhere: `is_favorite` is `false` for guests
by construction, `lessons_count` is `null` only if neither a
`withCount('lessons')` nor a loaded `lessons` relation reached the resource
(never happens on these five endpoints).

`GET /courses` and `GET /courses/{id}` are public but now carry
`optional.sanctum` middleware (same as `/products`) — a guest gets
`is_favorite: false`, a student who sends a bearer token gets their real
favorite status, without a second authenticated-only endpoint.

Implemented in
[`CourseRepository::applyListAnnotations()`](../app/Repositories/CourseRepository.php)
(`withCount('lessons')` + `withExists(['favoritedBy as is_favorite' => ...])`)
and read back in
[`CourseResource.php`](../app/Http/Resources/CourseResource.php).

Course card fields already present before this change and unaffected:
`title`/`title_ar`, `description`/`description_ar`, `image`, `type`
(`online`/`offline`), `duration_hours`. `GET /api/courses/{id}` (course
details) is untouched — it already returns the full `CourseResource` plus
`lessons`, `attachments`, `quizzes` and `progress` once relations are
loaded, exactly as it did before.

### Favorites endpoints

| Method | Path | Auth |
|---|---|---|
| POST | `/api/courses/favorite` | student |
| GET | `/api/courses/favorites` | student |

Storage: a dedicated `course_favorites` pivot table (`user_id`, `course_id`,
unique pair) — parallel to the existing `favorites` table for products, not
a reuse of it, since that table is hard-wired to `product_id`. Toggling is
literal toggle semantics (`$user->courseFavorites()->toggle($courseIds)`):
sending an already-favorited id un-favorites it.

`POST /api/courses/favorite`:

```json
{ "course_ids": [4, 9] }
```

Response (`data`): `{"attached": [4, 9], "detached": [], "updated": []}` —
Laravel's native `toggle()` return shape.

`GET /api/courses/favorites` — same paginated shape as `GET /api/courses`,
filtered to the student's favorites, every row carrying `is_favorite: true`.

### curl

```bash
TOKEN=...

curl -s -X POST https://api.robooq.com/api/courses/favorite \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"course_ids": [4, 9]}'

curl -s https://api.robooq.com/api/courses/favorites -H "Authorization: Bearer $TOKEN"
```

### Lesson video link

**Rule:** [`LessonResource.php`](../app/Http/Resources/LessonResource.php)
now also returns `video_url` — the exact same signed Bunny HLS
(`.m3u8`) stream as the existing `bunny_video_hls_url`, under a plain name a
mobile client can bind a video player to directly without knowing the
stream is Bunny-backed. HLS plays natively in Flutter's `video_player`
package on both iOS (AVPlayer) and Android (ExoPlayer) — no extra plugin
needed. Gated by the same `canAccessContent` rule as the rest of the
lesson's content fields (purchased, admin, or a free-preview lesson) —
`null` otherwise. Present on `GET /api/courses/{id}` (nested per lesson),
`GET /api/courses/{id}/lessons`, and `GET /api/lessons/{id}`.

```bash
curl -s https://api.robooq.com/api/lessons/12 -H "Authorization: Bearer $TOKEN"
# data.video_url -> "https://vz-b37f7d66-b03.b-cdn.net/bcdn_token=.../12/playlist.m3u8"
```

### Tests — [`tests/Feature/Mobile/CourseFavoriteTest.php`](../tests/Feature/Mobile/CourseFavoriteTest.php)

| Test | Proves |
|---|---|
| `guest_sees_courses_without_is_favorite_flag` | anonymous browsing always gets `is_favorite: false`, never omitted |
| `authenticated_mobile_user_sees_is_favorite_on_browse` | correct per-course flag on both the list and the detail view |
| `mobile_toggle_favorite_and_list_favorites` | toggle on, list, toggle one off, list again |
| `favorite_endpoint_requires_token` | both favorites endpoints 401 without a bearer token |
| `course_list_and_detail_report_lessons_count` | `lessons_count` matches the real number of lessons on both the list and detail views |

A Phase 1 non-regression invariant (F2, [`docs/PHASE-1-INVARIANTS.md`](PHASE-1-INVARIANTS.md))
locks response keys against silent drift; `lessons_count`, `is_favorite` and
`video_url` are recorded there as an explicit owner-approved addition dated
2026-08-27, alongside the enforcing allowlist in
[`tests/Feature/Phase1/NonRegressionTest.php`](../tests/Feature/Phase1/NonRegressionTest.php).

---

## 6. Performance fix — lesson list N+1

**Bug:** `GET /api/courses/{id}/lessons` ran
`->course->users()->where('user_id', $user->id)->exists()` **inside
`LessonResource`, once per lesson** — the same purchase check repeated N
times for a course with N lessons, since purchase status doesn't vary
per-lesson. A 12-lesson course meant 12 near-identical extra queries on
every open of that screen.

**Same bug also caused a correctness gap:** this endpoint never set
`is_watched` on any lesson, so it always reported `false` — even for
lessons the student had actually watched — because nothing computed the
watched-lesson set before `LessonResource` ran. (`CourseResource`'s
nested-lessons path already did this correctly; the standalone lessons-list
endpoint just never got the same treatment.)

**Fix:**
- [`LessonRepository::getByCourse()`](../app/Repositories/LessonRepository.php)
  now eager-loads `['quiz', 'course.users']`.
- [`LessonResource::resolveIsPurchased()`](../app/Http/Resources/LessonResource.php)
  uses the already-loaded `course.users` collection
  (`$this->course->users->contains($user->id)`) when the caller eager-loaded
  it, falling back to a query only when it didn't (the single-lesson
  `show()` endpoint, where N+1 was never a concern — unchanged there).
- [`LessonController::index()`](../app/Http/Controllers/Api/LessonController.php)
  computes the watched-lesson-id set **once** per request (mirroring
  `CourseResource`'s existing pattern exactly) instead of leaving
  `is_watched` unset.
- `bunny_video_hls_url` and `video_url` also used to independently
  recompute the identical signed HLS token twice per lesson; now computed
  once and reused for both.

No response shape changed — `is_watched`, `bunny_video_hls_url` and
`video_url` were already keys in this response; only their *values* are now
correct/cheaper to produce, which is why this needed no F2 allowlist entry.

### Endpoint affected

| Method | Path | Auth |
|---|---|---|
| GET | `/api/courses/{id}/lessons` | student |

### Tests — [`tests/Feature/Mobile/LessonListPerformanceTest.php`](../tests/Feature/Mobile/LessonListPerformanceTest.php)

| Test | Proves |
|---|---|
| `lesson_list_query_count_does_not_grow_with_lesson_count` | same course, same request, only lesson count changes (2 → 12) — query count via `DB::getQueryLog()` is identical both times |
| `lesson_list_reports_is_watched_per_lesson` | a watched lesson reports `is_watched: true`, an unwatched one `false`, on this exact endpoint |
