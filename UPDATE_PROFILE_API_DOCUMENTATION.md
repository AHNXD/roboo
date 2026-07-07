# Update Profile API Documentation

This document covers the mobile/app APIs related to reading and updating the authenticated user's profile, including profile fields, profile image, FCM token, and authenticated password update.

## Base URL

```text
{{host}}/api
```

## Required Headers

All endpoints in this document require Sanctum authentication.

For JSON requests:

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <user_token>
```

For image upload requests:

```http
Accept: application/json
Authorization: Bearer <user_token>
Content-Type: multipart/form-data
```

## Standard Response Shape

Success:

```json
{
  "success": true,
  "message": "profile.updated",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "field": [
        "Error message."
      ]
    }
  }
}
```

## Shared Error States

### 401 Unauthenticated

Returned when the bearer token is missing, invalid, or expired.

```json
{
  "success": false,
  "message": "Unauthenticated",
  "data": null
}
```

### 405 Method Not Allowed

Returned when the endpoint exists but is called with the wrong HTTP method.

```json
{
  "success": false,
  "message": "Method not allowed",
  "data": null
}
```

### 500 Server Error

Returned for unexpected server errors. In production, the response message is `Server error`.

```json
{
  "success": false,
  "message": "Server error",
  "data": null
}
```

## User Object

Profile endpoints return the Laravel `User` model. The exact response can include additional model columns, but the important profile fields are:

```json
{
  "id": 12,
  "name": "Ahmed Mobile",
  "name_ar": "Ahmed Arabic",
  "email": "ahmed@example.com",
  "google_id": null,
  "birthdate": "1998-03-15",
  "gender": "female",
  "role_id": 2,
  "fcm_token": "fcm-token-xyz",
  "points": 0,
  "language": "en",
  "heard_about": [
    "social_media",
    "friends"
  ],
  "email_verified_at": "2026-07-07T09:00:00.000000Z",
  "verification_code": null,
  "verification_code_expires_at": null,
  "created_at": "2026-07-07T09:00:00.000000Z",
  "updated_at": "2026-07-07T10:00:00.000000Z",
  "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
}
```

Notes:
- `password`, `remember_token`, and raw `media` are hidden.
- `image` is an appended URL from the user's `image` media collection.
- `birthdate` is formatted as `YYYY-MM-DD`.
- `heard_about` is stored and returned as an array.
- `email` is not updateable from the profile update endpoint.
- `password` is not updateable from the profile update endpoint. Use the password update flow below.

## Endpoints Summary

| Method | Endpoint | Purpose |
| :--- | :--- | :--- |
| `GET` | `/api/auth/me` | Get current authenticated user profile |
| `POST` | `/api/auth/profile` | Update profile fields, image, and FCM token |
| `POST` | `/api/auth/request-password-update` | Send verification code for password update |
| `POST` | `/api/auth/update-password` | Update password using verification code |

## 1. Get Current Profile

Returns the authenticated user's current profile.

```http
GET /api/auth/me
```

### Request Body

No body.

### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "auth.user_info",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "name_ar": "Ahmed Arabic",
      "email": "ahmed@example.com",
      "google_id": null,
      "birthdate": "1998-03-15",
      "gender": "female",
      "role_id": 2,
      "fcm_token": "fcm-token-xyz",
      "points": 0,
      "language": "en",
      "heard_about": [
        "social_media",
        "friends"
      ],
      "email_verified_at": "2026-07-07T09:00:00.000000Z",
      "verification_code": null,
      "verification_code_expires_at": null,
      "created_at": "2026-07-07T09:00:00.000000Z",
      "updated_at": "2026-07-07T10:00:00.000000Z",
      "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
    }
  }
}
```

### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `405` | Wrong HTTP method |

## 2. Update Profile

Updates any subset of the authenticated user's profile fields. This endpoint supports both JSON and `multipart/form-data`.

```http
POST /api/auth/profile
```

Use JSON when updating only text, date, enum, array, or FCM fields.

Use `multipart/form-data` when uploading `image`.

### Request Body Fields

| Field | Type | Required | Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | string | No | Max `255` | User display name |
| `name_ar` | string | No | Max `255` | Arabic display name |
| `birthdate` | date | No | Must be before today | Date in `YYYY-MM-DD` format |
| `gender` | string | No | `male` or `female` | User gender |
| `language` | string | No | `ar` or `en` | Preferred app language |
| `heard_about` | array | No | Array of allowed values | How the user heard about the app |
| `heard_about.*` | string | No | `social_media`, `family`, `friends`, `school`, `competitions`, `other` | One selected source |
| `image` | file | No | Image file, max `4096` KB | Profile image |
| `fcm_token` | string | No | Nullable string | Device token for push notifications |

Fields not listed above are ignored or rejected by validation depending on the request content. `email` and `password` are not updated here.

### JSON Request Example

```json
{
  "name": "Ahmed Mobile",
  "name_ar": "Ahmed Arabic",
  "birthdate": "1998-03-15",
  "gender": "female",
  "language": "en",
  "heard_about": [
    "social_media",
    "friends"
  ],
  "fcm_token": "fcm-token-xyz"
}
```

### Multipart Request Example

```text
POST /api/auth/profile
Content-Type: multipart/form-data

name=Ahmed Mobile
name_ar=Ahmed Arabic
birthdate=1998-03-15
gender=female
language=en
heard_about[]=social_media
heard_about[]=friends
fcm_token=fcm-token-xyz
image=@/path/to/avatar.jpg
```

### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "profile.updated",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "name_ar": "Ahmed Arabic",
      "email": "ahmed@example.com",
      "google_id": null,
      "birthdate": "1998-03-15",
      "gender": "female",
      "role_id": 2,
      "fcm_token": "fcm-token-xyz",
      "points": 0,
      "language": "en",
      "heard_about": [
        "social_media",
        "friends"
      ],
      "email_verified_at": "2026-07-07T09:00:00.000000Z",
      "verification_code": null,
      "verification_code_expires_at": null,
      "created_at": "2026-07-07T09:00:00.000000Z",
      "updated_at": "2026-07-07T10:00:00.000000Z",
      "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
    }
  }
}
```

### Partial Update Example

Request:

```json
{
  "language": "ar",
  "fcm_token": "new-fcm-token"
}
```

Response:

```json
{
  "success": true,
  "message": "profile.updated",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "email": "ahmed@example.com",
      "language": "ar",
      "fcm_token": "new-fcm-token",
      "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
    }
  }
}
```

### Image Upload Success State

When `image` is uploaded:
- The previous image in the `image` media collection is cleared.
- The new image is stored with a randomized filename.
- The returned `user.image` value points to the new image URL.

Response:

```json
{
  "success": true,
  "message": "profile.updated",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "image": "https://example.com/storage/users/profiles/12/41/new-avatar.jpg"
    }
  }
}
```

### Empty Body Success State

If the request body is empty, the endpoint returns the current user without changing profile fields.

Request:

```json
{}
```

Response:

```json
{
  "success": true,
  "message": "profile.updated",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "email": "ahmed@example.com",
      "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
    }
  }
}
```

### Validation Error: Invalid Profile Fields

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "birthdate": [
        "The birthdate must be before today"
      ],
      "gender": [
        "The gender must be either male or female"
      ],
      "language": [
        "The language must be either ar or en"
      ],
      "heard_about.0": [
        "The selected heard about option is invalid"
      ]
    }
  }
}
```

### Validation Error: Invalid Image

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "image": [
        "The image field must be an image."
      ]
    }
  }
}
```

### Update Failed Response

This response is possible if the service cannot update the profile.

Status: `400 Bad Request`

```json
{
  "success": false,
  "message": "profile.update_failed",
  "data": null
}
```

### Error States

| Status | Case |
| :--- | :--- |
| `400` | Profile update failed in the service |
| `401` | Missing or invalid user token |
| `405` | Wrong HTTP method |
| `422` | Invalid request body, invalid enum value, invalid date, invalid array item, or invalid image |
| `500` | Unexpected server error |

## 3. Request Password Update Code

Sends a 6-digit verification code to the authenticated user so they can update their password.

```http
POST /api/auth/request-password-update
```

Behavior:
- Generates a random 6-digit code.
- Saves the code on the user record.
- Sets `verification_code_expires_at` to 15 minutes from request time.
- Sends `SendPasswordChangeCode` notification.

### Request Body

No body. Send `{}` or an empty request body.

### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "profile.password_update_code_sent",
  "data": null
}
```

### Re-request Code Response

Requesting another code before the previous code is used or expired is allowed. The previous code is replaced.

Status: `200 OK`

```json
{
  "success": true,
  "message": "profile.password_update_code_sent",
  "data": null
}
```

### Error States

| Status | Case |
| :--- | :--- |
| `401` | Missing or invalid user token |
| `405` | Wrong HTTP method |
| `500` | Notification or unexpected server error |

## 4. Update Password

Updates the authenticated user's password using the verification code from `POST /api/auth/request-password-update`.

```http
POST /api/auth/update-password
```

Behavior:
- Validates the submitted code and password.
- Rejects invalid or expired codes.
- Hashes and saves the new password.
- Clears `verification_code` and `verification_code_expires_at`.
- Deletes all existing Sanctum tokens for the user.
- Issues a fresh token in the response.

After this endpoint succeeds, clients should replace the old bearer token with the returned `data.token`.

### Request Body

| Field | Type | Required | Rules | Description |
| :--- | :--- | :--- | :--- | :--- |
| `code` | string | Yes | Exactly 6 characters | Verification code sent to the user |
| `password` | string | Yes | Minimum 8 characters and confirmed | New password |
| `password_confirmation` | string | Yes | Must match `password` | Confirmation of new password |

Example:

```json
{
  "code": "654321",
  "password": "newpassword123",
  "password_confirmation": "newpassword123"
}
```

### Success Response

Status: `200 OK`

```json
{
  "success": true,
  "message": "profile.password_updated_successfully",
  "data": {
    "user": {
      "id": 12,
      "name": "Ahmed Mobile",
      "name_ar": "Ahmed Arabic",
      "email": "ahmed@example.com",
      "birthdate": "1998-03-15",
      "gender": "female",
      "role_id": 2,
      "fcm_token": "fcm-token-xyz",
      "points": 0,
      "language": "en",
      "heard_about": [
        "social_media",
        "friends"
      ],
      "email_verified_at": "2026-07-07T09:00:00.000000Z",
      "verification_code": null,
      "verification_code_expires_at": null,
      "created_at": "2026-07-07T09:00:00.000000Z",
      "updated_at": "2026-07-07T10:10:00.000000Z",
      "image": "https://example.com/storage/users/profiles/12/40/avatar.jpg"
    },
    "token": "13|new_plain_text_sanctum_token"
  }
}
```

### Validation Error: Missing or Invalid Fields

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "code": [
        "The code field is required."
      ],
      "password": [
        "The password field must be at least 8 characters."
      ]
    }
  }
}
```

### Validation Error: Password Confirmation Does Not Match

Status: `422 Unprocessable Entity`

```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "errors": {
      "password": [
        "The password field confirmation does not match."
      ]
    }
  }
}
```

### Invalid Code Response

Returned when the submitted code does not match the current code saved for the user.

Status: `400 Bad Request`

```json
{
  "success": false,
  "message": "auth.invalid_code",
  "data": null
}
```

### Expired Code Response

Returned when the submitted code matches but `verification_code_expires_at` has passed.

Status: `400 Bad Request`

```json
{
  "success": false,
  "message": "auth.code_expired",
  "data": null
}
```

### Error States

| Status | Case |
| :--- | :--- |
| `400` | Invalid code or expired code |
| `401` | Missing or invalid user token |
| `405` | Wrong HTTP method |
| `422` | Missing code, code not 6 characters, missing password, password too short, or password confirmation mismatch |
| `500` | Unexpected server error |

## Recommended Mobile Flow

### Update Profile Fields

1. Call `GET /api/auth/me` to load the current profile.
2. Let the user edit profile fields.
3. Call `POST /api/auth/profile` with only changed fields.
4. Replace the local user object with `data.user`.

### Update Profile Image

1. Pick an image in the app.
2. Send `POST /api/auth/profile` as `multipart/form-data`.
3. Include `image` and any other changed profile fields.
4. Replace the local image URL with `data.user.image`.

### Update Password

1. Call `POST /api/auth/request-password-update`.
2. Ask the user to enter the 6-digit code.
3. Call `POST /api/auth/update-password`.
4. Replace the stored bearer token with `data.token`.
5. If the response is `auth.invalid_code`, ask for the code again.
6. If the response is `auth.code_expired`, request a new code.

## cURL Examples

### Get Current Profile

```bash
curl -X GET "{{host}}/api/auth/me" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <user_token>"
```

### Update Profile as JSON

```bash
curl -X POST "{{host}}/api/auth/profile" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <user_token>" \
  -d '{
    "name": "Ahmed Mobile",
    "birthdate": "1998-03-15",
    "gender": "female",
    "language": "en",
    "heard_about": ["social_media", "friends"],
    "fcm_token": "fcm-token-xyz"
  }'
```

### Upload Profile Image

```bash
curl -X POST "{{host}}/api/auth/profile" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <user_token>" \
  -F "name=Ahmed Mobile" \
  -F "image=@avatar.jpg"
```

### Request Password Update Code

```bash
curl -X POST "{{host}}/api/auth/request-password-update" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <user_token>"
```

### Update Password

```bash
curl -X POST "{{host}}/api/auth/update-password" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <user_token>" \
  -d '{
    "code": "654321",
    "password": "newpassword123",
    "password_confirmation": "newpassword123"
  }'
```
