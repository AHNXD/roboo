# Feature API Mapping

This file maps current Flutter feature folders to `Roboo-API-Collection.json` so agents can add one feature at a time without guessing endpoints, response shapes, or integration risk.

For endpoint request/response examples, read `.ai/api-integration.md` first.

## Status Labels

- `UI-only`: screen exists, but data is hardcoded/static or purely local.
- `Placeholder data layer`: feature has `temp_repo` / `temp_cubit` scaffolding that is not a real backend integration.
- `Partially integrated`: real repo/Cubit code exists but does not fully match current UI or Postman.
- `Ready for integration`: UI exists and the collection has a direct endpoint match.
- `Indirect integration`: no dedicated endpoint, but the UI can be built from one or more nearby endpoints.
- `No backend evidence`: current collection does not support this feature.
- `Needs clarification`: collection exists but has auth, request, or product-flow ambiguity.

## Collection Folders By App Relevance

- `1. Authentication`: public auth, verification, reset-password.
- `2. My Profile`: protected profile, password update, logout.
- `3. Exploration (Public)`: public browse APIs for courses, products, categories, topics, places, galleries, FAQs, privacy, terms.
- `4. Student Learning (Protected)`: protected enrollment, lessons, course progress, quizzes.
- `5. Shopping & Shop (Protected)`: protected favorites and orders.
- `6. Social & Meta`: leaderboard and feedback; folder is bearer-protected.

There are no admin folders in the current collection export. Do not invent admin-backed mobile behavior from older docs.

## Best Next Integrations

### 1. News / Galleries

- Flutter feature: `lib/features/app/news`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folder: `3. Exploration (Public)`
- Endpoints:
  - `GET galleries`
- Main response data:
  - Laravel-style pagination
  - `data[]`: `id`, `title`, `title_ar`, `description`, `description_ar`, `media_list`, timestamps
- Likely files:
  - `lib/features/app/news/presentation/view/news_screen.dart`
  - `lib/features/app/news/presentation/view/widgets/news_card_widget.dart`
  - replace `news/data/repos/temp_*`
  - replace `news/presentation/view-model/temp_cubit/*`
- Integration notes:
  - Preserve current news UI where possible.
  - Add a gallery/news model local to the news feature.
  - Handle loading, success, empty, and error states.
  - Use first available media item for card image only if the UI needs an image.

### 2. Store / Products

- Flutter feature: `lib/features/app/store`
- Related detail feature: `lib/features/app/product-details`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folder: `3. Exploration (Public)`
- Endpoints:
  - `GET products`
  - `GET products/{product_id}`
  - optional filter support later with `GET categories`
- Main response data:
  - products list uses Laravel-style pagination
  - product fields: `id`, `category_id`, `name`, `name_ar`, `description`, `description_ar`, `price`, `specifications`, `specifications_ar`, `media_list`, `category`
- Likely files:
  - `lib/features/app/store/presentation/view/store_screen.dart`
  - `lib/features/app/store/presentation/view/widgets/product_card_widget.dart`
  - `lib/features/app/store/presentation/view/widgets/store_filter_lits_widget.dart`
  - `lib/features/app/product-details/presentation/view/product_details_screen.dart`
  - replace `store/data/repos/temp_*`
  - replace `product-details/data/repos/temp_*` only if detail is integrated in the same explicit task
- Integration notes:
  - List and detail can be integrated separately if the user asks for one surface.
  - Do not wire favorites or checkout while integrating public product browsing unless requested.
  - `price` arrives as a string.
  - `specifications` appears as array in public product examples and object inside some order product examples; parse defensively where reused.

### 3. FAQs

- Flutter feature: `lib/features/shared/faq`
- Current status: `Ready for integration`
- Postman folder: `3. Exploration (Public)`
- Endpoint:
  - `GET faqs`
- Main response data:
  - Laravel-style pagination
  - `data[]`: `id`, `title`, `title_ar`, `description`, `description_ar`, timestamps
- Likely files:
  - `lib/features/shared/faq/presentation/view/faq_screen.dart`
  - `lib/features/shared/faq/presentation/view/widgets/faq_tile_widget.dart`
  - add feature-local data/repo/Cubit files if absent
- Integration notes:
  - This is a simple read-only integration.
  - Keep localization behavior by choosing `title` or `title_ar` based on current locale, not by adding new hardcoded strings.

### 4. Privacy Policy / Terms

- Flutter feature: `lib/features/shared/privacy_policy`
- Current status: `Ready for integration` for privacy; `Indirect integration` if adding terms screen
- Postman folder: `3. Exploration (Public)`
- Endpoints:
  - `GET privacy-policy`
  - `GET terms-of-use`
- Main response data:
  - `slug`, `body_en`, `body_ar`, `updated_at`
- Likely files:
  - `lib/features/shared/privacy_policy/presentation/view/privacy_policy_screen.dart`
  - add local repo/Cubit/model if integrating dynamic content
- Integration notes:
  - Current folder only has a privacy-policy screen.
  - Do not add terms navigation unless the task asks for it.

### 5. Leaderboard

- Flutter feature: `lib/features/app/leaderboard`
- Current status: `Ready for integration`, `Needs clarification`, `Placeholder data layer`
- Postman folder: `6. Social & Meta`
- Endpoint:
  - `GET leaderboard`
- Main response data:
  - `leaderboard[]`: `name`, `points`, `image`
- Likely files:
  - `lib/features/app/leaderboard/presentation/view/leaderboard_screen.dart`
  - `lib/features/app/leaderboard/presentation/view/widgets/leaderboard_list_item_widget.dart`
  - `lib/features/app/leaderboard/presentation/view/widgets/podium_item_widget.dart`
  - existing `competitor_model.dart`
  - replace `leaderboard/data/repos/temp_*`
  - replace `leaderboard/presentation/view-model/temp_cubit/*`
- Risk:
  - Collection description says public ranking, but the folder declares bearer auth.
- Integration notes:
  - Let `ApiServices` attach a token if present.
  - Verify backend behavior before blocking anonymous users in UI.

## Auth And Profile Features

### Login

- Flutter feature: `lib/features/auth`
- Current status: `Partially integrated`
- Postman folder: `1. Authentication`
- Endpoint:
  - `POST auth/login`
- Request:
  - `email`, `password`, optional/currently shown `fcm_token`
- Success data:
  - `user`
  - `token`
- Current mismatch:
  - Existing app auth code has phone-based assumptions in places, while Postman login is email-based.
- Integration notes:
  - Store `token` using the existing cache/token pattern.
  - Keep the Cubit as the ViewModel.
  - Do not call login repo directly from widgets except through existing Cubit wiring.

### Register

- Flutter feature: `lib/features/auth`
- Current status: `Partially integrated`
- Postman folder: `1. Authentication`
- Endpoint:
  - `POST auth/register`
- Request:
  - `name`, `name_ar`, `email`, `password`, `password_confirmation`, `birthdate`, `gender`, `language`, `heard_about`, `fcm_token`
- Success data:
  - `user`
  - nested `message`
  - no token shown in example
- Integration notes:
  - Postman says OTP may be required after registration.
  - Valid `heard_about`: `social_media`, `family`, `friends`, `school`, `competitions`, `other`.
  - Valid `gender`: `male`, `female`.

### Email Verification

- Flutter feature: auth verification/OTP UI if present or added
- Current status: `Partially integrated`
- Postman folder: `1. Authentication`
- Endpoints:
  - `POST auth/verify-code`
  - `POST auth/resend-verification`
- Request:
  - verify: `email`, `code`
  - resend: `email`
- Success data:
  - verify returns `user` and `token`
  - resend returns `null`
- Integration notes:
  - `auth.code_expired` is a documented error message for expired code.
  - Do not reuse legacy phone verification endpoints.

### Forgot / Reset Password

- Flutter feature: `lib/features/auth/presentation/views/forget-password`
- Current status: `Partially integrated`, nested placeholder Cubit
- Postman folder: `1. Authentication`
- Endpoints:
  - `POST auth/forgot-password`
  - `POST auth/reset-password`
- Request:
  - forgot: `email`
  - reset: `email`, `code`, `password`, `password_confirmation`
- Success data:
  - forgot returns `null`
  - reset returns `user` and `token`
- Risk:
  - `Forgot Password` request declares bearer auth even though it is under no-auth Authentication and represents a public recovery flow.
- Integration notes:
  - Verify auth requirement before forcing logged-in access.
  - Replace nested `temp_cubit` only inside this feature.

### Google Login

- Flutter feature: auth login/register surface
- Current status: `Ready for integration`, `Needs clarification`
- Postman folder: `1. Authentication`
- Endpoint:
  - `POST auth/google`
- Request:
  - `token`, `fcm_token`
- Risk:
  - No response example exists.
- Integration notes:
  - Do not assume the response shape beyond likely auth envelope until backend confirms it.

### Profile

- Flutter feature: `lib/features/app/profile`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folder: `2. My Profile`
- Endpoints:
  - `GET auth/me`
  - `POST auth/profile`
  - `POST auth/request-password-update`
  - `POST auth/update-password`
  - `POST auth/logout`
- Main response data:
  - profile endpoints return `user`
  - password update returns `user` and `token`
  - request password update returns `null`
- Likely files:
  - `lib/features/app/profile/presentation/view/profile_menu_screen.dart`
  - `lib/features/app/profile/presentation/view/edit_profile_screen.dart`
  - profile widgets
  - replace `profile/data/repos/temp_*`
  - replace `profile/presentation/view-model/temp_cubit/*`
- Integration notes:
  - `POST auth/profile` is multipart and the example only shows `name`, `image`, `language`.
  - Do not assume every user field is editable.
  - Logout already has an auth repo in `lib/features/auth`; avoid duplicate logout logic unless the task is specifically profile-owned logout UI wiring.

## Course And Learning Features

### Courses List

- Flutter feature: `lib/features/app/courses`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folder: `3. Exploration (Public)`
- Endpoint:
  - `GET courses`
- Query examples:
  - `type=online`
- Main response data:
  - `courses[]`
  - `pagination`
- Likely files:
  - `lib/features/app/courses/presentation/view/courses_screen.dart`
  - `lib/features/app/courses/presentation/view/widgets/courses_filter_tabs_widget.dart`
  - replace `courses/data/repos/temp_*`
  - replace `courses/presentation/view-model/temp_cubit/*`
- Integration notes:
  - Collection mentions topic/type filters, but only `type=online` is shown.
  - If filter tabs need backend data, use `GET topics` or `GET categories` only when the UI requires it.

### Course Details

- Flutter feature: `lib/features/app/course`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folders:
  - public details: `3. Exploration (Public)`
  - protected lessons/progress: `4. Student Learning (Protected)`
- Endpoints:
  - `GET courses/{course_id}`
  - `POST courses/{course_id}/reserve-click`
  - `POST coupons/apply`
  - `GET courses/{course_id}/lessons`
  - `GET lessons/{lesson_id}`
  - `POST courses/{course_id}/mark-watched`
- Likely files:
  - `lib/features/app/course/presentation/view/course_details_screen_screen.dart`
  - `lib/features/app/course/presentation/view/video_player_screen.dart`
  - course widgets under `course/presentation/view/widgets`
  - replace `course/data/repos/temp_*`
  - replace `course/presentation/view-model/temp_cubit/*`
- Integration notes:
  - Public course detail can be integrated before protected lessons.
  - Lessons and video URLs are protected; handle auth-required errors explicitly.
  - `reserve-click` requires `device_id`.
  - `coupons/apply` requires `code`.
  - Do not expose `bunny_video_hls_url` parsing in widgets; keep it in models/repository.

### My Courses

- Flutter feature: `lib/features/app/my-courses`
- Current status: `Indirect integration`, `Placeholder data layer`
- Direct endpoint: none named `my-courses`
- Possible related endpoints:
  - `GET courses/{course_id}` includes `is_unlocked`
  - protected `GET courses/{course_id}/lessons`
  - protected quizzes/progress endpoints
- Risk:
  - The collection does not provide a direct enrolled-courses list.
- Integration notes:
  - Do not invent `my-courses`.
  - Stop and document ambiguity if the requested feature requires a true enrolled-course list.

### Quizzes

- Flutter feature: `lib/features/app/quizes`
- Current status: `Ready for integration`, `Placeholder data layer`
- Postman folder: `4. Student Learning (Protected)`
- Endpoints:
  - `GET quizzes`
  - `GET quizzes/{quiz_id}`
  - `POST quizzes/{quiz_id}/submit`
- Main response data:
  - list: `quizzes[]`, `pagination`
  - detail: quiz fields plus `questions[]`
  - submit: `score`, `total`, `points_earned`, `is_perfect`
- Likely files:
  - `lib/features/app/quizes/presentation/view/quizes_screen.dart`
  - `lib/features/app/quizes/presentation/view/quiz_screen.dart`
  - quiz widgets
  - replace `quizes/data/repos/temp_*`
  - replace `quizes/presentation/view-model/temp_cubit/*`
- Integration notes:
  - Request submit body is `{ "answers": { "question_id": selected_answer_id } }`.
  - Response example includes `is_correct` on answers. Do not show correctness before submit unless the product requires it.

## Store, Cart, And Orders

### Product Favorites

- Flutter feature: could affect `store`, `product-details`, or a future favorites screen
- Current status: `Ready for integration` only when favorite UI is requested
- Postman folder: `5. Shopping & Shop (Protected)`
- Endpoints:
  - `POST products/favorite`
  - `GET favorites`
- Request:
  - `product_ids`: array of product IDs
- Main response data:
  - toggle: `attached`, `detached`
  - favorites list: Laravel-style paginated products
- Integration notes:
  - Do not mix favorite state into public product browsing unless the requested UI includes it.
  - Protected flow needs token handling.

### Cart / Checkout / Orders

- Flutter feature: `lib/features/app/cart`
- Current status: `Ready for integration` for checkout/order actions, `Needs clarification` for persistent cart
- Postman folder: `5. Shopping & Shop (Protected)`
- Endpoints:
  - `POST orders`
  - `GET orders`
  - `GET orders/{order_id}`
- Request:
  - create order sends `items[]` with `product_id` and `quantity`
- Main response data:
  - created order: `id`, `user_id`, `total_price`, `items`, `user`
  - order history: Laravel-style pagination
  - order detail: order plus `user` and `items`
- Risk:
  - No persistent cart endpoint exists. Current cart UI may be local until checkout.
  - Collection description mentions item price, but request example omits price.
- Integration notes:
  - Keep local cart state separate from order submission unless backend cart endpoints are provided later.
  - Do not send client-calculated price unless backend confirms it.

## Shared / Meta Features

### Complaints / Feedback

- Flutter feature: `lib/features/shared/complaints`
- Current status: `Ready for integration` if complaints are treated as feedback
- Postman folder: `6. Social & Meta`
- Endpoint:
  - `POST feedbacks`
- Request:
  - `rating`, `note`
- Success data:
  - `id`, `user_id`, `rating`, `note`, timestamps
- Risk:
  - UI says complaints, endpoint says feedbacks.
- Integration notes:
  - Confirm product naming before mapping complaints to feedbacks.
  - Folder declares bearer auth, so treat as protected unless backend says otherwise.

### Places / Centers

- Flutter feature: no clear dedicated app feature folder
- Current status: `Ready for integration only if UI is requested`
- Postman folder: `3. Exploration (Public)`
- Endpoint:
  - `GET places`
- Main response data:
  - array of `id`, `name`, `name_ar`, `city`, `city_ar`, `latitude`, `longitude`
- Integration notes:
  - Do not build a places screen proactively.
  - If used inside course details, check whether course `available_places` already provides enough data.

### Topics And Categories

- Flutter usage: filters in courses/store/home
- Current status: `Ready for integration only when a concrete feature needs filters`
- Postman folder: `3. Exploration (Public)`
- Endpoints:
  - `GET categories`
  - `GET topics`
- Integration notes:
  - Use `topics` for course/quiz topic filters.
  - Use `categories` for product/store category filters.
  - Do not create broad shared filter infrastructure before one feature needs it.

### Home

- Flutter feature: `lib/features/app/home`
- Current status: `Indirect integration`, `Placeholder data layer`
- Direct endpoint: none
- Possible source endpoints:
  - `GET courses`
  - `GET products`
  - `GET categories`
  - `GET topics`
  - `GET galleries`
- Integration notes:
  - Do not invent a `home` endpoint.
  - Integrate home only as composition from already integrated feature repositories or explicit endpoint calls scoped to home.
  - Avoid integrating many unrelated features just to populate home unless the task explicitly asks for a home data dashboard.

## Features With No Backend Evidence In This Collection

Do not invent endpoints for these:

- `lib/features/app/roboo-ai`: no chat/AI endpoint
- `lib/features/app/games`: no games endpoint
- `lib/features/shared/on-boarding`: no backend endpoint needed/evidenced
- `lib/features/shared/splash`: no backend endpoint needed/evidenced
- `lib/features/shared/settings`: no settings endpoint except local language behavior
- push notifications/device token update outside auth request examples

## Recommended Integration Order

From safest to riskiest:

1. News / galleries (`GET galleries`)
2. FAQ (`GET faqs`)
3. Privacy policy (`GET privacy-policy`)
4. Store product list (`GET products`)
5. Product details (`GET products/{product_id}`)
6. Courses list (`GET courses`)
7. Course details public data (`GET courses/{course_id}`)
8. Leaderboard (`GET leaderboard`) after auth behavior is checked
9. Auth login/register alignment
10. Forgot/reset password alignment
11. Profile get/update
12. Quizzes protected flow
13. Course lessons/video/progress protected flow
14. Favorites
15. Cart checkout/orders
16. Complaints to feedback, after product naming is confirmed

## Files Commonly Reused Across Integrations

- `lib/core/Api_services/api_services.dart`
- `lib/core/Api_services/auth_interceptor.dart`
- `lib/core/errors/error_handler.dart`
- `lib/core/errors/failuer.dart`
- `lib/core/utils/cache_helper.dart`
- `lib/core/utils/services_locater.dart`
- `lib/core/utils/routs.dart`
- `lib/core/utils/app_localizations.dart`
- `assets/lang/en.json`
- `assets/lang/ar.json`

## Hard Warnings

- Do not treat `temp_*` files as real integration evidence.
- Do not use `Urls` constants when they conflict with Postman.
- Do not infer missing endpoints for Roboo AI, games, persistent cart, or my-courses.
- Do not expose `is_correct` from quiz answer examples unless required.
- Do not require auth for a screen solely because `ApiServices` can attach a token; check the collection folder and risk notes.
- Do not add broad shared models just because several responses contain `id`, `name`, or timestamps.
