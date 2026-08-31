# Pending Work

Updated 2026-08-26, after the `Roboo — Mobile API` collection refresh.

The refresh changed **exactly one** thing versus the previous export: the quiz submit response
gained `solved` and `question_results[]`. Everything else in the collection is byte-identical
(75 requests, none added, none removed). The rest of this list is work that was already open.

## 1. Done (2026-08-26)

### 1.1 Parse the new quiz submit fields — DONE
- `lib/features/app/quizes/data/models/quiz_result_model.dart`
- Add `solved` (bool) and `questionResults` (`List<QuizQuestionResultModel>`), parsed from
  `solved` / `question_results`.
- New model `quiz_question_result_model.dart`:
  `question_id`, `selected_answer_id`, `is_correct`, `correct_answer_id`.
- **Keep both optional.** The collection documents them, but an app log from 2026-08-26 returned
  a submit response without either field, so the deployed API may still be behind. Absent →
  empty list, and the result screen keeps working.

### 1.2 Per-question review on the result screen — DONE
- `lib/features/app/quizes/presentation/view/quiz_result_screen.dart`
- Under the score card, list each question with the student's answer and, when wrong, the correct
  one — driven by `question_results`, i.e. the **server's** verdict.
- The screen currently receives only `quizId` + the answers map, so it has no question text.
  Either extend `QuizResultArgs` with the loaded `List<QuestionModel>` (cheap, no extra request)
  or re-fetch `GET quizzes/{quiz_id}` on the result screen (one more round trip).
  Preference: pass the questions through; `QuizCubit` already holds them.
- Hide the section entirely when `question_results` is empty, so the screen still reads well
  against the older response shape.

**As built:** `QuizQuestionResultModel` added; `QuizResultModel` gained `solved` +
`questionResults`, both optional. `QuizCompleted` now carries the questions through
`QuizResultArgs`, so no extra request. The review marks only the chosen and the correct answer,
using `QuizOptionItem` so it matches the in-quiz and homework-review look. The result body
scrolls with the action button pinned. Verified against both the collection's response and the
one the deployed API actually returned — the latter yields an empty review and the screen is
unchanged from before.

## 2. Product decisions

### 2.1 When is the correct answer revealed?
Today the quiz reveals correctness **during** the quiz, from `is_correct` in
`GET quizzes/{quiz_id}` — the answers are in the payload before the student answers.
`question_results` now gives the same information from the server *after* submitting.

Options:
- **(a) Keep as is.** Instant feedback per question; answers remain readable from the payload.
- **(b) Move the reveal to the result screen.** The in-quiz button becomes plain "Next", and
  §1.2 becomes the only place correctness is shown. Then ask the backend to drop `is_correct`
  from the quiz detail (§4.1). Better integrity if quiz points feed the leaderboard.

### 2.2 Free-preview lessons are unreachable — RESOLVED 2026-08-29

Shipped: a locked course now shows its curriculum with playable previews. See the section at the
end of this file.

### 2.3 "Popular courses" is not a ranking
`home_screen.dart` shows the first 3 of `GET courses`. The API has no popularity signal. Either
rename the section or get a `featured` / `?sort=popular` from the backend.

## 2b. Backend features applied (from `FEATURE-QUIZ-HOMEWORK-COURSES.md`)

**Round 1, applied 2026-08-26, verified live 2026-08-28** — all deployed and confirmed:

| API | App | Live check |
| --- | --- | --- |
| homework `question_results` | review marks right/wrong per question | 3 results on homework 10 |
| `GET my/courses` | My Courses screen + home card | 200 (empty for the demo student) |
| `GET courses/featured` | home "Popular courses" | 200, 1 course, `purchases_count: 2` |
| `solved` on quiz list/detail | badge on the quiz row | present, 12 quizzes |
| `progress` on `GET courses/{id}` | course progress, preferred over the derived count | present when purchased |

**Round 2, applied 2026-08-28:**

| API | App |
| --- | --- |
| homework `title_ar` / `description_ar` / `question_ar` / `label_ar` | list, detail and review render the locale's text |
| `lessons_count` on every course surface | the "N videos" chip, replacing `sessions_count` |
| `is_favorite` + `POST courses/favorite` | working heart on the course list, home and details |
| `video_url` on lessons | parsed, preferred over `bunny_video_hls_url` |
| `is_watched` fix on `courses/{id}/lessons` | values only, no app change |

Notes:

- `GET courses/favorites` returns `{courses, pagination}`, **not** the plain array the doc's
  "same shape as `GET /api/courses`" implies. Not consumed yet — there is no course-favorites
  screen; the heart is driven by `is_favorite` plus the toggle response.
- The favourite toggle was exercised against the live API (on, verified, off again) — response is
  `{"attached":[1],"detached":[]}` with no `updated` key; the model defaults it to empty.
- `HomeCubit._loadFeatured` still falls back to `GET courses` if featured fails. Featured now
  works, so **this bridge can be deleted** — kept for one release in case the route regresses.
- `CourseProgressCard` still shows a decorative heart; only the course list and details toggle.

### Google sign-in — code complete 2026-08-28, blocked on Firebase config

`POST auth/google` takes `{token: <Google ID token>, fcm_token}`. The app side is done:
`GoogleAuthService` (google_sign_in 7.x), `LoginRepo.loginWithGoogle`,
`LoginCubit.loginWithGoogle`, and the previously dead button on the login screen. Cancelling the
Google sheet returns to the form silently; failures show a localized message. Logout also signs
out of Google so the account chooser reappears.

**It cannot work until Google sign-in is enabled for the Firebase project.** Verified 2026-08-28:

- `android/app/google-services.json` contains **no `oauth_client` entries** — Android needs an
  Android client (type 1, keyed to the app's SHA-1) and a web client (type 3) to mint an ID token.
- `ios/Runner/GoogleService-Info.plist` has **no `CLIENT_ID` / `REVERSED_CLIENT_ID`**.

Steps for whoever owns the Firebase console:

1. Firebase → Authentication → Sign-in method → enable **Google**.
2. Project settings → add the app's **SHA-1 and SHA-256** (debug and release keystores).
3. Re-download `google-services.json` and `GoogleService-Info.plist` and replace both.
4. iOS: add the `REVERSED_CLIENT_ID` from the new plist as a URL scheme in `ios/Runner/Info.plist`.
5. Put the **web client id** (`client_type: 3`) in `GoogleAuthService.serverClientId` — without it
   Android signs the user in but returns no ID token, which the service logs explicitly.

Unknown until then: the success response shape. A bad token answers
`401 {"success": false, "message": "auth.google_login_failed"}` — a translation key, now in both
lang files. The success path is assumed to match `auth/login` (`data.user` + `data.token`), which
is what the shared `_sessionFromResponse` handles; confirm on first real sign-in.

### Course favourites screen — done 2026-08-29

`GET courses/favorites` is wired into the favourites screen, which is now two tabs (Store /
Courses) styled like the course-details tab bar. The courses tab reads the same app-wide
`CourseFavoritesCubit` the hearts everywhere else write to, so un-favouriting from the list drops
the row immediately and stays consistent with the courses list and home.

Verified against the live API: favouriting course 1 made it appear in the list with
`is_favorite: true` and `lessons_count: 5`; state restored afterwards. Note the response is
`{courses, pagination}` — the named-array shape — not the plain array the feature doc implies.

### Endpoints deliberately not wired

- `GET courses/{id}/lessons` — redundant; `GET courses/{id}` already embeds the lessons, video
  urls included. One caveat: `GET lessons/{id}` also returns a per-lesson `quiz` object that the
  embedded list omits, so a lesson-level quiz is invisible to the app today. Course-level quizzes
  (`quizzes` on the course) are wired and unaffected.
- `GET homework/submissions/mine` — redundant; `GET homework` embeds `my_submission`. Only worth
  it for a cross-homework submission history.
- `GET places` — no screen needs it; course details use the course's own `available_places`.

## 3. Blocked on the backend

| Item | Blocker |
| --- | --- |
| ~~My Courses list~~ | **Unblocked** — `GET my/courses` is specified and wired (§2b); waiting on deployment. |
| ~~Course progress percentage~~ | **Unblocked** — `progress` on the course detail and on `my/courses` (§2b). |
| ~~Homework types `image`, `video`, `image_text`, `video_text`~~ | **Done 2026-08-31** — contract probed live and all types implemented; see the section at the end. |
| Homework attachments | `attachments[]` is empty in all seeded data, so the shape is unknown. |
| ~~Per-answer correctness in homework review~~ | **Unblocked** — the backend added `question_results`; the app renders it (§2b). |
| ~~Homework types `image`, `video`, `image_text`, `video_text`~~ | **Done 2026-08-31** — contract probed live and all types implemented; see the section at the end. |
| Text homework submit body | The app sends `{"content": "..."}`, inferred from the submission field name. Unverified — the collection documents only the mcq body. |
| ~~Teacher app (folders 10-13)~~ | **Out of mobile scope** — confirmed 2026-08-29 that the teacher experience lives in the web dashboard. Those 18 endpoints are not app work. |

## 4. Backend asks

1. ~~**Deploy `FEATURE-QUIZ-HOMEWORK-COURSES.md`.**~~ **Done** — verified live 2026-08-29:
   `my/courses` and `courses/featured` both answer 200 (they were 404/500), and `progress`,
   `attachments` and `quizzes` are on the course detail. Note `courses/featured` answers 200 with
   no valid token, so it is public; every other course endpoint requires auth.
2. **Drop `is_correct` from `GET quizzes/{quiz_id}`** once §2.1(b) is chosen — `question_results`
   replaces it, and homework already withholds the correct option.
3. ~~**Confirm `solved`.**~~ Answered by `FEATURE-QUIZ-HOMEWORK-COURSES.md`: `solved` means the
   student holds a points-awarded attempt, and points pay out once per quiz. Course/lesson
   quizzes additionally refuse a second attempt outright, with an English message the app
   surfaces as-is (see ask 5).
4. **Define a pass mark.** There is none in the API. The app treats half the questions as a pass
   (`QuizResultModel.isPassed`); change that one getter if the product disagrees.
5. **Return a translation key for enrollment errors.** A bad code answers
   `422 {"message": "This code is not valid."}` — an English sentence, so Arabic users see
   English. Elsewhere the API returns keys (`auth.code_expired`) which the app translates.
6. **Expose contact details from the API.** There is no settings/contact/social endpoint, so the
   WhatsApp number and the Facebook/Instagram urls are hardcoded in `AppContact`
   (`lib/core/utils/constats.dart`) and every one of them is currently **empty**, which hides the
   WhatsApp buttons and the settings social icons. Two ways to close this, in order of preference:
   (a) the backend adds a small public `GET settings` returning the number and the social urls, so
   marketing can change them without an app release; or (b) the owner sends the values and they are
   compiled in. Until then those controls stay hidden and offline-course booking falls back to the
   "reserve request sent" message.
7. **Upload the missing lesson videos.** Course 1 lessons 4 and 5 have no `video_url`, and *both*
   of course 2's free-preview lessons (6 and 7) have none — so course 2 currently advertises a
   preview it cannot play. The app hides an unplayable preview rather than showing a dead one.
8. **Normalise course `level`.** Values are `easy` / `mid` / `hard`; `mid` is the odd one out and
   was the cause of an untranslated label until it was mapped in `CourseDetailsModel`.
9. `question_results` / `solved` are confirmed deployed as of 2026-08-26.

## 5. App-level loose ends

### Push notifications — wired 2026-08-28

Where the device token goes, and when:

| Moment | Channel |
| --- | --- |
| register | `fcm_token` inside `POST auth/register` (already wired; now actually populated) |
| login | `fcm_token` inside `POST auth/login` (added) |
| token arrives or rotates later | `POST auth/profile` with **only** `fcm_token` |

`auth/profile` accepting a partial `fcm_token` body is **undocumented** — verified against the
live API on 2026-08-28 (probe sent, `fcm_token` updated, other fields untouched, value restored).
It is the only channel that works mid-session; the collection lists `fcm_token` on
register/login/google only, and there is no device endpoint.

`FcmTokenSync` owns this: it caches the token, remembers which value the backend already has, and
skips the profile call when the token went out with the auth request. It does nothing while
logged out, because the next login carries the token anyway.

Fixed along the way:

- `@drawable/ic_launcher` does not exist in this project — every notification specified it as its
  icon and would have failed to display. Now `@mipmap/ic_launcher`, which does exist.
- iOS fetched `getAPNSToken()` and sent *that* to the backend. The server wants the FCM
  registration token: `getToken()` on both platforms, after APNS is ready on iOS.
- `final String fcmToken = CacheHelper.getData(...)` crashed when nothing was cached yet.
- A `hasFCMToken` flag meant the token was fetched once and never re-read.
- `android.permission.POST_NOTIFICATIONS` was missing, so Android 13+ could never grant it.
- Firebase init is wrapped: a broken config now means "no push", not a dead app.
- ~~WhatsApp buttons and "open in maps" need `url_launcher`.~~ **Done 2026-08-29** — see the
  section at the end of this file.
- ~~`GET products` supports `search` and `category_id`; neither is wired to the store UI.~~
  **Done 2026-08-29** — see the section at the end of this file.


## Collection conformance audit — 2026-08-29

Checked every request body and response shape the app sends/parses against the examples in
`Roboo — Professional App API.postman_collection.json` (75 requests). The app matches the examples
almost everywhere; these were the exceptions.

| Finding | Resolution |
| --- | --- |
| `POST orders` example sends an `items` array; the app sends `{}` | **App is right, example is stale.** Verified live against an empty cart: both bodies return the identical `422 {"errors":{"cart":["Your cart is empty."]}}`, so `items` is ignored and the order is built from the server-side cart. No order was created by the probe. Recorded in a comment in `cart_repo_impl.dart`. |
| `POST feedbacks` repo accepted **only** `201` | Now accepts `200` or `201`. The example returns 201, so this was latent, not live. |
| `courses/featured`, `courses/favorite`, `courses/favorites`, `my/courses` are **absent from the collection** | All four verified live and returning 200. The app parses each correctly (`featured` and `my/courses` are plain arrays, `favorites` is `{courses, pagination}`). The collection is incomplete, not the app. |
| The collection was renamed and `ORDERS_AND_CART_API_DOCUMENTATION.md` deleted | `AGENTS.md`, the skill, and both `.ai` docs pointed at filenames that no longer exist. All updated; the orders/cart contract that only lived in the deleted file is now recorded here and at the call site. |
| Every user payload leaks `verification_code` and `verification_code_expires_at` | Not used by the app and should not be. Worth raising with the backend — `auth/me`, `auth/login`, `auth/profile`, `auth/verify-code`, `auth/reset-password`, `auth/update-password` and the `user` nested in orders all return a live OTP. |
| ~~`pagination` objects are parsed but never used~~ | **Done 2026-08-29** — infinite scroll on the store, courses, news and order history. See the section at the end of this file. |

Confirmed correct, no change needed: the three pagination shapes; quiz submit as a map and
homework submit as a list (the collection accepts both forms); `products/favorite` sending
`product_ids`; the multipart profile update (`name`, `name_ar`, `birthdate`, `gender`, `language`
are all real user fields); product `specifications`/`specifications_ar` parsing and localization;
and the 422 contract — `ApiServices` leaves Dio's default `validateStatus` in place, so a 422
throws and `ErrorHandler._handleValidationErrors` reads the nested `data.errors` and surfaces the
specific message rather than the generic "Validation failed".

~~Noted but not acted on: `ApiServices` sets no timeouts.~~ **Done 2026-08-29** — see below.


## Video playback — done 2026-08-29

Playback shipped. `video_player: ^2.11.1` + `chewie: ^1.8.5` (the only new dependencies); the
Android debug APK builds with both native plugins.

- `lib/core/widgets/app_video_player.dart` — one inline HLS player. Handles init failure with a
  retry, because the Bunny urls are signed and expire (`expires=` in the query), so a stream that
  played earlier in a session can legitimately stop working later.
- `lib/core/widgets/full_screen_video_player.dart` — `show(context, url:, title:)`, mirroring
  `FullScreenImageViewer.show`. Ready for the news videos too.
- `video_player_screen.dart` — rewritten from mock to real. Takes `VideoPlayerArgs(courseId,
  lessons, initialIndex)`, plays lesson by lesson, and pops `true` if anything was marked watched
  so the course details screen re-fetches its progress.
- `LessonPlayerCubit` — owns the playing index and the watched set.
- Entry points: a lesson row in the Videos tab opens that lesson; the "Go to video" CTA resumes at
  the first unwatched, unlocked lesson; the info tab's intro-video thumbnail (previously a dead
  play button) now plays `bunny_demo_video_hls_url` full-screen.
- `POST courses/{id}/mark-watched` runs both from an explicit **Mark as watched** button in the
  video body and automatically when playback reaches the end. Confirmed live against the owner's
  own account: `{"lesson_id": 1}` returns `200 {"success":true,"message":"Lesson marked as
  watched","data":null}` and moves `progress` from 0% to 20%.
- The endpoint is **idempotent, not a toggle** — a second identical call still answers 200 and
  leaves `watched_count` at 1. There is no un-watch endpoint, so the tick is final; the UI shows a
  button before and a plain tick after, never a toggle.
- Marking is optimistic and reverts if the request fails, with the failure surfaced as a message,
  so the screen never shows progress the server did not record.

New model fields: `LessonModel.quiz` (a lesson can carry its own quiz — lesson 1 of course 1 has
quiz #13) and `LessonModel.hasVideo`. A lesson can be unlocked and still have no video: lessons 4
and 5 of course 1 have no url, and the player shows "no video yet" rather than a black rectangle.

Not done, deliberately:

- ~~**Free previews on a locked course are unreachable.**~~ **Done 2026-08-29** — see the section
  at the end of this file.
- ~~**Screen-capture protection during playback.**~~ **Done 2026-08-29** — see the section at the
  end of this file.
- **The "Download Video" chip** in the video body was a decorative `Container` with no tap handler
  and no download support behind it. It now shows the lesson's real state (duration, or a
  "Watched" tick) instead. Real downloads would need a downloader plus storage permissions.


## Outbound links — done 2026-08-29

`url_launcher: ^6.3.2` added. Everything outbound goes through
`lib/core/utils/external_links.dart`, so a launch that fails always reports itself instead of
looking like a dead button:

| Control | Was | Now |
| --- | --- | --- |
| Course attachment | Copied the url to the clipboard | Opens it. Long-press still copies, which is the only way to reach a file type the device cannot open. |
| Course centre in the locations dialog | Plain text | Opens `latitude`/`longitude` in the device's map app. Rows without coordinates stay plain text. |
| "Book via WhatsApp" (offline courses) | Showed a message and did nothing | Opens a chat with the course name prefilled. |
| "Contact us on WhatsApp" (code dialog) | Closed the dialog | Opens a chat asking for an activation code. |
| Settings social icons | No `onTap` at all | Open WhatsApp/Facebook/Instagram. |

`AppContact` in `lib/core/utils/constats.dart` holds the number and the two social urls, because
**the API exposes no contact details** — there is no settings/contact/social endpoint anywhere in
the collection. Any value left empty hides its control rather than opening a broken chat, so the
buttons are wired but invisible until the values are filled in.

A file attachment's `file_path` is a storage path, so `CourseAttachmentModel.url` now runs it
through `ApiMediaUrlResolver` — otherwise it is not an absolute url and cannot be opened. Seeded
`link` attachments are real: both `robooq.com/syllabus/1` and `/reading/1` answer 200.

Android needed `<queries>` entries for the `https` and `geo` VIEW intents. Without them Android 11+
hides browser and map apps behind package-visibility filtering, `canLaunchUrl` returns false, and
every link fails silently. Debug APK builds with the plugin.


## Free previews on locked courses — done 2026-08-29

A locked course now shows a **Videos tab** alongside the info tab, listing the whole curriculum:
free previews are playable and carry a green "Free" chip, everything else is a locked row that
does not respond to a tap. Attachments stay behind the paywall (the API omits them anyway), so a
locked course has two tabs and an unlocked one has three.

The API makes this easy: on a locked course the preview lessons come back `is_locked: false` with
a `video_url`, and the rest come back `is_locked: true` with no url at all. Nothing has to be
inferred, and no paid content is exposed.

Three details that matter:

- **A preview is only offered when its video actually exists.** Both of course 2's previews are
  flagged `is_free_preview: true` but carry no url — badging those as "Free" and then showing "no
  video yet" is worse than showing nothing, so they render as ordinary locked rows.
- **The player only ever receives the playable previews** on a locked course, so "Next video"
  cannot walk a non-buyer into paid content.
- **Progress is not tracked in preview mode.** No progress bar, no "Mark as watched" button and no
  automatic call on completion — `mark-watched` on a course the student does not own is
  meaningless, and this avoids finding out the hard way whether the backend 403s it.

The tab count now depends on data that arrives after the first build, so the fixed
`TabController(length: 3)` in `initState` was replaced by `DefaultTabController` around the tabs.


## Store search — done 2026-08-29

The category filter was already wired end to end; **search was the missing half**. `GET products`
now receives `search` alongside `category_id`, and the store screen has a search field above the
category row.

Verified against the live API before building anything:

| Probe | Result |
| --- | --- |
| `search=kit` | products 1, 2 |
| `search=طقم` | products 1, 2, **8** |
| `search=SERVO` | product 5 — case insensitive |
| `search=ardu` | product 1 — partial words match |
| `search=kit&category_id=1` | 2 results — the filters AND together |
| `search=kit&category_id=4` | 0 results |
| `search=` (empty) | all 8 — an empty value is the same as no filter |

So the backend matches **both** `name` and `name_ar` regardless of the app's language. Worth
knowing: an English search for "kit" misses "Roboo Tool Set" (id 8) because only its Arabic name
contains طقم — that is a data gap, not an app one.

Implementation notes:

- **Typing is debounced by 400ms**, so a word is one request rather than one per keystroke
  (verified: three keystrokes produced a single call). Clearing the field skips the debounce
  because it should feel instant.
- The query lives in the cubit and is carried on every content-bearing state, so search and
  category compose in both directions: narrowing by category keeps the query, and clearing the
  query keeps the category.
- Empty results distinguish "this store has no products" from "nothing matched *your term*",
  which is the difference between a broken-looking screen and an obvious one.
- `StoreCubit` gained `SafeEmit` and cancels its timer in `close()` — a pending debounce firing
  into a disposed cubit was a real crash waiting to happen once a timer was introduced.
- `StoreSearchField` owns its own `TextEditingController` so the text survives the rebuild that
  every result triggers.


## Robustness: timeouts and pagination — done 2026-08-29

### Timeouts

Dio applies none of its own, so a stalled request previously hung forever behind a spinner with
nothing the user could act on. `ApiServices` now sets `connectTimeout` 15s, `receiveTimeout` 30s,
`sendTimeout` 30s, and 60s for multipart uploads, which carry an image.

The receive window is deliberately generous: `GET courses/1` has been observed taking 13.6s, so a
tighter limit would cancel real responses. No new strings were needed — `ErrorHandler` already maps
`connectionTimeout` / `sendTimeout` / `receiveTimeout` to keys that exist in both language files.
(All 13 `ErrorHandler` keys were audited against `en.json` and `ar.json`: every one resolves.)

### Pagination

`per_page` is **ignored** by the backend — it always answers 25 — so only `page` is worth sending.
Verified live: `products?per_page=3` still returns all 8 with `per_page: 25`, while `page=2`
correctly reports `current_page: 2`.

Shared pieces:

- `lib/core/models/pagination_model.dart` — `PaginationModel` parses **both** response shapes (the
  Laravel paginator's root fields and the named `pagination` object) since both carry the same four
  keys, plus `PagedResult<T>` and a `pagedEndpoint(path, page)` helper. A response with no paging
  metadata parses as a single complete page, so nothing can loop forever requesting page 2.
- `lib/core/widgets/load_more_listener.dart` — wraps a scrollable and fires 400px from the bottom.
  It wraps rather than owning a `ScrollController`, so it works with the store's grid and the other
  screens' lists without each one creating and disposing a controller.

Wired: **store products** (sliver grid, so the footer spinner shares the scrollable), **courses**,
**news/galleries**, **order history**. Each keeps its filters: changing category, topic or search
restarts at page 1 rather than appending to a stale list.

Verified against a fake repo returning 3 pages, since no live dataset reaches 25 rows yet:
accumulates 25 → 50 → 57, ids contiguous with no duplicates, stops requesting past the last page,
a failed page leaves the visible list intact and the next scroll retries, and two rapid scroll
notifications fire exactly one request.

Also wired, 2026-08-29 (second pass): **homework**, **FAQs** and **course favourites** take the
same infinite scroll.

**Quizzes is the exception, on purpose.** Its topic tabs filter on the client — `GET quizzes`
documents no topic parameter — so a tab can only be correct once every quiz is loaded. Infinite
scroll there would silently show a partial topic with no indication anything was missing, which is
worse than a slightly longer first load. So the cubit walks every page up front. That is one
request today (13 quizzes), and a `_maxPages = 20` cap stops a runaway loop if the backend ever
reports `last_page` wrongly — verified: a repo that always claims another page exists stops at 20
instead of hanging.

**Product favourites stay on page 1, deliberately.** `FavoritesCubit` is an app-wide singleton
whose favourite-id set backs the heart on every product card; paging it would mean a card on store
page 2 showing an unfilled heart purely because its id had not been fetched yet.


## Screen-capture protection — done 2026-08-29

`no_screenshot` was already a dependency, `disableScreenshot()` already existed, and nothing in the
app had ever called it: protection was never on anywhere. The lesson player now blocks capture.

`lib/core/widgets/secure_screen.dart` wraps a subtree and holds the protection for as long as it is
mounted. Two details make it safe:

- **It acquires in `initState` and releases in `dispose`,** not in a button callback. `dispose` runs
  on every exit path — the back button, the system gesture, a route replacement — so there is no
  way to leave the player with capture still blocked app-wide.
- **It is reference counted.** Protection is one global window flag, so a nested secure screen (the
  player, then the video's own fullscreen route) must not let the inner one unlock while the outer
  still shows paid content. Verified with a mocked method channel: opening fires exactly one
  `screenshotOff`, an inner secure screen disappearing fires nothing, and `screenshotOn` only
  arrives when the last one leaves.

Applied to `VideoPlayerScreen` only. The course intro video (`FullScreenVideoPlayer`) is marketing
material and is deliberately left capturable.

What each platform actually promises, since they differ:

- **Android** sets `FLAG_SECURE`, which blocks screenshots and screen recording outright.
- **iOS** has no equivalent api. The plugin uses ScreenProtectorKit's protected layer, which blanks
  the captured output — reliable in practice, but not a platform guarantee.
- Neither stops someone pointing a second camera at the screen. This raises the cost of casual
  copying; it is not DRM. Real protection would mean signed playback with a DRM system.

`main.dart` still calls `enableScreenshot()` at startup, which is worth keeping: the plugin
persists its state across launches, so that call is the reset if the app is ever killed mid-video.


## Backend changes of 30 Aug 2026 — applied

The backend shipped `CHANGES-FOR-FLUTTER-2026-08-30.md`. Every item was re-verified against the
live API before touching code.

### Verified fixed, no app change needed

- **Video playback.** Fetched a lesson's signed URL straight from `GET courses/1` and pulled the
  master playlist: `200`, real HLS. The demo URL too. Bunny was misconfigured, not the app.
- **Google sign-in.** The server now verifies an ID token instead of treating it as an access
  token. The app already sends `authentication.idToken`, so nothing changed.
- **`is_correct` removed** from `GET quizzes` and `GET quizzes/{id}` — confirmed absent.

### The `is_correct` removal broke the quiz screen — fixed

`quiz_screen.dart` coloured each answer by `answer.isCorrect` after "Check answer". With the field
gone it parsed as `false` for every option, so **every answer would have rendered as wrong** and no
answer would ever have shown green.

The two-step "check, then next" flow existed only to reveal correctness, so it collapsed to one
step: pick an answer, press Next/Finish. `AnswerModel.isCorrect`, `QuizCubit.checkAnswer()` and
`QuizState.isAnswerChecked` are gone. A selection stays changeable until the student moves on,
which a locked-in wrong tap previously made permanent. Correctness reaches the student on the
result screen, from `question_results`, exactly as the backend intends.

### Applied

| Change | What the app does now |
| --- | --- |
| `solved` on embedded quizzes | `CourseQuizModel` parses it; a finished course quiz shows the completed tick in the videos tab, and a finished lesson quiz says so on its card — without opening it. Confirmed present on `lessons[].quiz` even for a locked course. |
| Attachment `url` + `title_ar` | `CourseAttachmentModel` prefers the server-resolved `url`, keeps the `link_url`/`file_path` fallback for a deployment without the resolver, and the tab now shows the Arabic title in Arabic. |
| `GET settings` | New `AppSettingsRepo` + `AppSettingsHolder`, fetched once at startup without blocking the first frame. `AppContact` reads from it instead of the hardcoded blanks. **The live endpoint currently returns all three fields as `null`**, so the WhatsApp buttons and social icons stay hidden until someone fills them in on the dashboard. |
| `DELETE auth/profile` | The Delete Account button works: a confirmation dialog naming what is lost, destructive action as the non-default choice, then the same local session clear as logout and a return to onboarding. Route existence confirmed by an unauthenticated call answering 401 — **never called authenticated, since it is irreversible.** |
| `GET notifications` + read endpoints | New feature: model, repo, cubit, screen, route, DI. The bell icon opens it. Unread rows carry a fill, a border and a dot; "mark all as read" appears only when something is unread; marking is optimistic and reverts on failure. Infinite scroll via the shared `LoadMoreListener`. A `new_course` notification opens that course — `meta.course_id` arrives as a **string** and is parsed, verified against the live payload. |

Homework `my_submission` and `is_score_released` were already handled correctly, and the confirmed
pass mark (50%) and `level` values (`easy`/`mid`/`hard`) already match what the app assumes.

### Owed back to the backend

They asked what the app sends for homework submission. It sends, and has always sent:

- **Multiple choice** — `{"answers": [{"question_id": 1, "option_id": 9}]}` (the collection
  documents both this and a map form; the app uses the list).
- **Text** — `{"content": "..."}`. This is still a guess, inferred from the field name the
  submission comes back with. It has never been confirmed and may well be wrong.
- **image / video / image_text / video_text** — nothing. There is no upload flow; the app tells the
  student those types are unsupported rather than pretending.


## Quiz time limit and solved-quiz lockout — done 2026-08-30

### Time limit

`time_limit` (minutes) was parsed and shown as a label but never enforced. `QuizCubit` now runs a
one-second countdown from the moment the questions load, and the quiz screen shows it as a pill
beside the progress bar — tabular figures so it does not twitch, and red for the last minute.

When the clock runs out the quiz submits itself with whatever has been answered, **including the
answer selected on the question the student was still reading** — that selection is only committed
to the answer map on "Next", so it would otherwise have been thrown away.

Two edges worth naming:

- **Nothing answered at all** emits `QuizTimeExpired` instead of submitting. An empty `answers` map
  is rejected by the backend with `422 "The answers field is required."`, so there is nothing to
  grade; the screen says the time is up and goes back rather than showing a validation error.
- **`time_limit` absent or 0** means untimed: no countdown, no pill, no auto-submit.

The timer is cancelled on finish and in `close()`, so leaving mid-quiz cannot fire into a closed
cubit. Verified with a fake clock: 20:00 → 19:55 → 00:55 (urgent) → auto-submit carrying `{1: 11}`,
the empty case, the untimed case, and zero pending timers after an early close.

### Solved quizzes are no longer openable

A quiz pays its points once, and the backend refuses a second attempt on a course or lesson quiz
outright. Letting a student answer everything again only to be rejected at submit wastes their
time and loses their answers.

All three entry points — the quizzes list, the course quizzes in the videos tab, and the lesson
quiz card in the player — now go through `openQuizIfUnsolved` in
`lib/features/app/quizes/presentation/view/quiz_entry.dart`. A solved quiz reports
`quiz_already_solved` and does not open. This relies on `solved`, which the backend added to every
quiz object on 30 Aug, so the state is known before the quiz is opened.

The retry button on the result screen is unaffected: it only appears when the attempt failed, and a
failed attempt leaves `solved` false.


## Course attachments: real downloads — done 2026-08-30

The tab used to print the raw url under each title and, on tap, copy it to the clipboard. Now the
url is never shown and the two types behave differently, because they are different things:

- **`link`** — opens in the browser. Title only; a raw address is noise next to a title the admin
  already wrote.
- **`file`** — downloads to the device with progress, then hands the file to the system viewer.
  Tapping again opens the copy already downloaded rather than fetching it twice; the tab restores
  that state on open, so a file downloaded yesterday still says "tap to open".

New pieces: `lib/core/utils/file_downloader.dart` and an `AttachmentsCubit` holding per-attachment
status. Dependencies added: `path_provider` and `open_filex`.

Decisions worth keeping:

- **The downloader uses its own `Dio`, not `ApiServices`.** Attachment files are public static
  storage; routing them through the shared client would attach the auth interceptor, and a 401 from
  the file host would throw the student out to the login screen over a failed download.
- **Files download to a `.part` and are renamed on completion**, so an interrupted download never
  leaves something that looks finished. Verified against the live 2,411-byte attachment.
- **Documents directory, so no storage permission is needed** on either platform. iOS gained
  `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` so the downloads are reachable in the
  Files app rather than invisible; Android gained a `<queries>` entry for `ACTION_VIEW` with any
  mime type, without which `open_filex` can never resolve a viewer on Android 11+.
- **A file that nothing can open reports exactly that** — the download succeeded, so saying it
  failed would be wrong. The `.zip` in the seeded data is a likely case on a bare device.

Two things found by verifying rather than assuming:

- `Uri.path` is **percent-encoded**, so `Course Notes.pdf` arrived as `Course%20Notes.pdf` and the
  sanitiser turned it into `Course_20Notes.pdf`. Fixed by using `pathSegments`, which is decoded.
- The first sanitiser was an ASCII allow-list, which reduced an Arabic filename to `____.pdf`. It
  now strips only what a filesystem actually rejects, so `دورة.pdf` survives.

Note the server sends no usable `content-length` for these files, so the progress bar runs
indeterminate rather than showing a percentage. The code already handles `total <= 0`; if the
backend adds a length, the bar starts showing real progress with no app change.


## Profile image upload fails — server-side, diagnosed 2026-08-30

`POST auth/profile` with any real photo answers **500 with an nginx HTML page**, not the API's JSON
envelope — so it dies before Laravel's error handler.

**The app is not at fault.** `edit_profile_screen.dart` already picks with `maxWidth: 800,
imageQuality: 60`, which yields roughly 40–100 KB. Bisected against the live API, the ceiling is on
the whole multipart body and sits at about **10.5 KB**:

| Request | Result |
| --- | --- |
| image only, 10,240 B | 200 |
| image only, **10,400 B** | **200** |
| image only, **10,800 B** | **500** |
| image only, 12,000 B | 500 |
| image 10,000 B **+ a `name` field** | 500 — the field's ~200 bytes tip it over |
| 1×1 png (68 B) | 200 |

So it is the request body, not the image: dimensions are irrelevant (a 2000×2000 solid-colour PNG
of 60 KB fails, a 64×64 of 179 B passes), and adding a text field to a passing request breaks it.

**Ask the backend for:** `client_max_body_size` in nginx and `upload_max_filesize` / `post_max_size`
in PHP, all raised to something sane (10M / 10M / 12M). A body cap alone would normally answer
**413**, so the 500 suggests PHP is discarding the body and the controller then fatals — both layers
are worth checking. Whatever the cap becomes, exceeding it should answer 413 with the JSON envelope,
not an html 500.

No app change can work around this: an avatar under 10 KB would be about 100×100 and visibly poor.

Two small correctness fixes made while diagnosing:

- `ErrorHandler` now maps **413** to a `payloadTooLarge` message, so once the backend returns the
  right status the user is told the file is too big instead of getting a generic server error.
- `case 400/401/403` did `response.data['message']` unguarded, which throws when the body is an html
  error page rather than the api envelope — exactly what nginx returns here. Now type-checked.

**Note:** the owner's profile image is currently a tiny test PNG uploaded during this diagnosis
(`.../90uP7r88ljbFZJHaPn1PDfkLKkzIiQNu.png`). It can be replaced from the app once the limit is
raised.


## Leaderboard: long names overflowed — fixed 2026-08-30

The three podium places sat in a `Row` as unconstrained children, so each column sized itself to its
widest child — the name. Two long names ran into each other, which is what the reported screenshot
shows (`علي الهادي نظام` in first and second place colliding).

- Each place is now an `Expanded` with a 3 : 4 : 3 share, so a name is bounded by its own slot.
- The name wraps to two lines then ellipsises, centred; the points line ellipsises at one.
- The avatars are **derived from the slot** rather than the screen width. Sizing them off the screen
  (`available * 0.38`) looked right but made the winner's hexagon wider than its own slot on every
  screen under about 412pt — checked arithmetically across 280–1024pt, it overflowed on 5 of the 7
  common widths. They are now a fraction of the slot itself, which cannot overflow by construction.

The rows below the podium had the same bug in a different shape: `Text(name)` followed by a
`Spacer()`, so a long name pushed the points off the row. The name is now `Expanded` with an
ellipsis and the `Spacer` is gone — `Expanded` already pushes the points to the end.

Verification note: a widget test of this is unreliable in this project, because both widgets pull
asset images and the JSON localisation that a test bundle cannot provide — a widget that fails to
build reports no overflow, so such a test passes for the wrong reason. The sizing was checked
arithmetically instead, which is where the real bug was.


## Backend changes of 30 Aug 2026, revision 2 — applied 2026-08-31

Re-verified everything against the live API first.

### Verified fixed, no code needed

- **The ~10KB request-body cap is gone.** A 3.5MB profile image now uploads and answers
  `profile.updated`. That was the blocker behind the html 500 on avatar upload.
- **Video urls now serve from `api.robooq.com/api/stream/...`** and the master playlist comes back
  200 with every sub-playlist rewritten to an absolute signed url. The app needs no change: there is
  no host allowlist, cleartext config or certificate pinning anywhere in the project to update.

### §2c — quiz points and the refusal response

The refusal case was the important one. A second attempt at a course or lesson quiz answers
**HTTP 200** with `data.success: false` — so the old code would have parsed it as a graded result
and shown the student a **0/0 score card with "try again"**.

- `QuizResultModel` gained `message` and `isRejected` (the inner `success`), and the result screen
  now shows "you already earned the points for this quiz" instead of a score card. The server's own
  message is an English sentence, so the app keeps its own translated wording.
- `canRetry` replaces the old "retry when not passed" rule: retry is offered only while `solved` is
  false. After any attempt the server pays nothing more, and course and lesson quizzes refuse
  outright — offering a button that walks into a refusal is worse than not offering it.
- `wasAlreadyRewarded` survives the meaning change of `solved` (now "has attempted", true from the
  first submission): it also requires `points_earned == 0`, which is false on a paying first attempt.
- Points are proportional now, so the button's "earn N points" shows the real figure rather than
  all-or-nothing.

Verified against all four outcomes, including the live retake response (3/3, `points_earned: 0`):
a paying first attempt, a retake, a refusal, and a failed first attempt.

### §4c — video thumbnails

`video_thumbnail` (lesson) and `demo_video_thumbnail` (course) are parsed and used as the player's
poster frame instead of a black rectangle, and as the intro-video thumbnail in the info tab, which
previously reused the course cover. Both are absent when there is no video and are signed with the
same short expiry as the stream, so they are read from each response rather than cached.

### §0 — the two-hour signature expiry

Signed urls expire two hours after the response was built, so a screen opened and resumed later
fails. `AppVideoPlayer` now reports a failed open through `onFailed`, and `LessonPlayerCubit`
re-fetches the course and swaps in fresh urls, keeping the student on the same lesson. It refreshes
once per lesson per failure, so a genuinely broken stream cannot spin a refetch loop.

### §4d — profile picture

The limit is 10MB and the server downscales to 1600px at quality 82. The picker went from
`maxWidth/Height 800, quality 60` to `1600 / 85` — picking at the server's own target avoids a
second lossy pass while keeping the upload small enough for a phone connection.

### Already correct, checked not assumed

- Validation errors at `data.errors` (§2c) — `ErrorHandler._handleValidationErrors` already reads
  the nested path.
- `solved` on embedded quizzes, `my_submission` / `is_score_released` on homework, the 50% pass mark
  and the `easy`/`mid`/`hard` levels all already match.

### Still owed to the backend (§7)

The homework submission body question is unanswered. The app sends
`{"answers": [{"question_id": 1, "option_id": 9}]}` for multiple choice, `{"content": "..."}` for
text — still an inference, never confirmed — and nothing at all for the image/video types.


## Topic, category and lesson imagery — done 2026-08-31

The backend started serving pictures for topics and product categories, and lessons carry a video
frame. All three are now used, each with a fallback because the dashboard has not filled them all
in — several topics and three of four categories still have `image: null` today.

| Where | Was | Now |
| --- | --- | --- |
| Course card badge (home, courses, favourites, my courses) | hardcoded `AssetsData.programming` on every course | the course's **topic icon** — and **no badge at all** when the topic has no picture (revised 2026-08-31) |
| Course topic filter chips | text only | topic icon beside the label |
| Store category chips | text only | category icon beside the label |
| Lesson row in the videos tab | a play glyph in the skewed shape | the lesson's **video frame** filling the shape, the way a course card shows its cover |

**Lessons have no `image` field** — checked against the live payload. Their picture is
`video_thumbnail`, the poster frame added on 30 Aug, which is what the shape now shows. A lesson
with no video keeps the play glyph, and so does a quiz row.

`lib/core/widgets/filter_chip_icon.dart` is the one place that decides how to draw these: an http
value is fetched and cached, anything else is treated as a bundled asset, and a missing or broken
icon renders nothing so the chip falls back to text rather than showing a broken-image box. The
skewed shape does the same, falling back to its icon while loading and on error.

`MyCourseModel` gained the `topic` object — the API was already sending it, the model just was not
reading it, so my-courses cards would otherwise have kept the hardcoded badge.

Verified against the live payloads: a topic with an icon and one without, a category with one,
course 1 (topic with icon), **course 11 (no topic at all — the card must not crash)**, a my-courses
entry, and a lesson with and without a video frame.


### Badge revision — 2026-08-31

The first pass fell back to the bundled `AssetsData.programming` whenever a topic had no picture.
Replaced with no badge at all: the circle is only drawn when there is a real icon to put in it.

The whole `Positioned` circle is now conditional, not just its contents — a translucent empty circle
sitting over the cover reads as a failed image rather than a design element. The screens simply pass
`course.topic?.imageUrl ?? ''` and the card decides, so there is one rule rather than a fallback
repeated at five call sites (`AssetsData` is no longer imported by three of them).

Covers all three ways a course can lack one, verified: a topic with `image: null`, no `topic` object
at all (course 11), and an empty-string image.


### Lesson frame now takes the shape — 2026-08-31

The first pass counter-skewed the picture along with the glyph, so the frame sat upright as a
straight rounded rectangle inside the slanted shape and the coloured shape showed around its edges.

Now only the glyph is counter-skewed. The picture inherits the outer skew and the container clips
with `Clip.antiAlias`, so the image *is* the slanted shape rather than a rectangle sitting in one.
The colour only shows while loading, on error, and for lessons with no video — the glyph paths,
which still stand upright.

Homework rows use the same widget with no image, so they are unaffected. (The quizzes feature has
its own unrelated `SkewedIcon` in `quize_icon_widget.dart`.)


### Lesson player header — 2026-08-31

Two problems in the same widget, reported from a device.

**The back button and badge floated over the video.** They were `Stack`ed on the player, so they sat
on top of the surface the player draws its own controls across and competed for the same taps. They
are now a plain row *above* the video: `VideoTopNavOverlay` became `VideoTopNav`, and nothing is
layered over the player any more.

**The badge was still the hardcoded `AssetsData.programming`.** It now shows the course's topic icon
and follows the same rule as the cards — no icon, no badge. This also required `CourseDetailsModel`
to parse the `topic` object; it was reading only `topic_id`, although the API has been sending the
whole object.

The identical hardcoded badge on the course-details header was wired at the same time — same asset,
same rule — since leaving one screen on a placeholder while its own player showed the real icon
would have looked like a bug.


## Seven fixes — 2026-08-31

**1. Cart snackbar appeared several times.** `CartCubit` and `FavoritesCubit` are app-wide
singletons, and the store screen stays mounted underneath product details, so one "add to cart"
reached every mounted listener and each showed a message. Both screens now gate their listener on
`ModalRoute.of(context)?.isCurrent`, so only the visible route reports. The favourites listener had
the identical bug and was fixed with it.

**2. Notifications showed the Flutter logo.** `flutter_launcher_icons` writes the real app icon to
`@mipmap/launcher_icon`; `@mipmap/ic_launcher` is the default logo left over from project creation,
and every notification pointed at it — the manifest's default icon, the local-notification channel,
and the initialisation settings. All now use `launcher_icon`, which exists at all five densities.
Worth knowing: Android draws the *status-bar* icon from the alpha channel only, so a full-colour
icon shows as a silhouette there. A dedicated monochrome `ic_stat_*` drawable is the proper fix if
that silhouette looks wrong.

**3. Topic and category colours.** Both now carry a `color` hex from the dashboard. Parsed by
`colorFromHex` and used for the circle behind the topic icon on the course card, the progress card,
the course-details header and the player header. Every one falls back to the existing translucent
white when the colour is unset or unparseable — which is all topics and three of four categories
today, so most of the app looks unchanged until they are filled in.

**4. Video quality is now selectable.** `HlsVariantReader` reads the renditions out of the master
playlist and offers them inside Chewie's own options sheet, next to playback speed, with an "Auto"
entry that hands the choice back to the player. Switching re-opens the stream on that rendition and
**resumes at the same position**. Reading the playlist is best-effort — a failure there never stops
playback — and the menu is hidden below two renditions.
**It will not appear yet:** the live master playlist for lesson 1 contains a single 240p rendition,
so there is nothing to choose. This needs Bunny encoding more than one size; the menu appears on its
own once it does.

**5. News videos were never shown.** Every gallery carries a `video_list` — an mp4 per post,
separate from `media_list` — that the app ignored entirely. Parsed now and rendered as tappable
"Watch video" tiles under the image carousel, opening full screen. Kept out of the image `PageView`
deliberately: a video inside that carousel would start playing as the reader swipes past it.

**6. A solved quiz kept offering itself.** `solved` is computed server-side and travels with the
quiz, so a screen that opened one had no way to know it was finished without re-fetching — the row
still said "open" and let the student straight back in. `openQuizIfUnsolved` now reports back when
the quiz screen closes, and each caller refreshes: the quizzes list re-fetches, the course videos
tab re-fetches the course, and the lesson quiz inside the player reloads the lessons. That last one
is why the player's quiz appeared not to block at all — it *was* blocking, on stale data.

**7. Points went stale after a quiz.** The header reads points from the cached user, which is only
written on login and profile fetches. `QuizResultCubit` now re-fetches the profile after a graded
attempt, which rewrites that cache. Skipped when the attempt was refused or paid nothing, since
there is no new total to fetch.


## Home's three shapes now open their topic — 2026-08-31

The AI / Programming / Robotics cards were decorative. Tapping one now switches to the courses tab
with that topic already selected.

**Addressed by `slug`, not id or index.** Topics carry a `slug` (`robotics`,
`artificial-intelligence`, …) which is stable where ids are not, and the API does not return topics
in id order — it currently answers 3, 2, 5, 4, 1, 6. An index- or position-based guess would open
the wrong topic; hardcoded ids would break against another database. `TopicModel` gained `slug` and
`CoursesCubit.selectTopicBySlug` maps it to the right chip.

`MainNavCubit` carries the request: `openTopic(slug)` switches to the courses tab and leaves the
slug pending. The courses tab lives in an `IndexedStack`, so it is already built and just listens
for it, then clears the request so returning to that tab later does not silently re-apply an old
filter.

One case worth handling: the shapes can be tapped before the courses tab has ever been opened, so
the topic list may not exist yet. A slug requested that early is held and applied as soon as the
topics arrive.

Verified against the live topic ordering: all three slugs resolve to the right topic id (robotics is
id 1 but arrives fifth), an unknown slug fires no request at all, and a slug requested mid-load is
still applied.


## Cart and bell badges — 2026-08-31

Both icons in the top bar now carry a count: the cart's item count and the bell's unread
notifications. `IconBadge` renders it — hidden at zero rather than showing a "0", capped at `99+`
so a large number cannot stretch across the icon, and a plain red dot when the count is not known
yet, which still says "there is something here" without inventing a number.

**The counts have to be right before their screens have ever been opened**, which is the whole
difficulty. Neither number was available app-wide:

- **Cart** — every `CartState` already carries the cart, so the badge reads
  `cart.summary.itemCount` from the app-wide cubit. It just was never loaded until the cart screen
  was opened, so `CartCubit.loadCartIfNeeded()` fetches once, guarded against the repeat calls that
  a top bar on four tabs would otherwise make.
- **Notifications** — a new app-wide `NotificationsBadgeCubit`, deliberately separate from
  `NotificationsCubit`: that one owns the list on its screen and is created per visit, which is
  exactly what the badge cannot depend on.

Kept in step from three directions, so the number does not drift:

- the notifications screen hands over the count it already fetched, rather than making the badge
  fetch again — on load, on load-more, on mark-one-read, on mark-all-read, and on the revert when
  either of those fails;
- returning from the notifications screen refreshes it;
- a push arriving while the app is open increments it immediately, and the next fetch corrects it.

A failed refresh leaves the badge as it was: a wrong count is worse than a stale one, and there is
nothing the student could do about the error.


## Homework: all six types — done 2026-08-31

The app handled `mcq` and `text` and told the student the rest were unsupported. All six now work.

**The contract was never documented, so it was probed.** Posting an empty body to each homework and
reading the validation error names the required fields exactly:

| type | required | error the server gives |
| --- | --- | --- |
| `mcq` | `answers` | — |
| `text` | `content` | "A written answer is required for this homework." |
| `image` | `file` | "A image upload is required for this homework." |
| `video` | `file` | "A video upload is required for this homework." |
| `image_text` | `content` **and** `file` | asks for each in turn |
| `video_text` | `content` **and** `file` | asks for each in turn |

Confirmed end to end afterwards: a real png to `image`, and content + file together to `image_text`,
both accepted and stored with the right mime type.

What changed: `HomeworkType` covers all six with `needsText` / `needsImage` / `needsVideo`; one
`submitHomework({content, filePath})` replaces the text-only method and posts multipart; the screen
renders the text box, the file picker, or both, and each missing half is reported separately rather
than with one vague message. Picking reuses `image_picker` — `pickVideo` for the video types — so no
new dependency. Submissions now parse their `attachment` and show it: an image inline and tappable
to full screen, a video in the player.

Three things worth knowing:

- **Re-submitting updates the existing submission** rather than being refused, verified live. The
  screen still shows the banner once submitted and does not offer a re-submit — that is a product
  decision, but the API allows it if you want it.
- **The backend does not validate the mime type.** A `.txt` was accepted for an `image` homework. So
  the attachment view checks `mime_type` before deciding how to render, rather than assuming the
  type matches the homework.
- **`max_score`, `correction_type` and `attachments` on the homework itself are parsed but unused.**
  Teacher-supplied attachments are empty in all current data.

**Side effect of the probing, on the owner's account:** homework 16 and 18 now have submissions from
these tests (16 was left with a junk `.txt` at one point and has since been overwritten with a real
png). Submitting again from the app replaces them.
