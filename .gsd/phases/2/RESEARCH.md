# Phase 2 Research — Pet Profiles & Family System

> **Discovery Level**: 2 (Standard Research)
> **Date**: 2026-02-27

## Key Findings

### 1. Cloudflare R2 Presigned URLs (for photo upload)

R2 is S3-compatible → use `boto3` in Cloud Functions:

```python
import boto3

s3 = boto3.client(
    "s3",
    endpoint_url=f"https://{ACCOUNT_ID}.r2.cloudflarestorage.com",
    aws_access_key_id=R2_ACCESS_KEY_ID,
    aws_secret_access_key=R2_SECRET_ACCESS_KEY,
    region_name="auto",
)

# Upload presigned URL
url = s3.generate_presigned_url(
    "put_object",
    Params={"Bucket": BUCKET_NAME, "Key": object_key, "ContentType": content_type},
    ExpiresIn=3600,
)

# Download presigned URL
url = s3.generate_presigned_url(
    "get_object",
    Params={"Bucket": BUCKET_NAME, "Key": object_key},
    ExpiresIn=3600,
)
```

**Dependency**: Add `boto3` to `requirements.txt`.
**Secrets**: Store R2 credentials as Firebase environment config (`functions.config()` or GCP Secret Manager).

### 2. Flutter Photo Pipeline

Dependencies already in `pubspec.yaml`:
- `image_picker` — camera/gallery selection
- `image_cropper` — face-center crop
- `flutter_image_compress` — JPEG compression
- `http` — PUT request to presigned URL

**Flow**:
1. Pick image → `image_picker`
2. Crop (square for profile) → `image_cropper`
3. Compress (max 1024px, ~80% quality) → `flutter_image_compress`
4. Request presigned upload URL from Cloud Function
5. PUT compressed bytes to presigned URL
6. Store resulting public URL in Firestore pet document

### 3. Family Invitation Strategies

Two invitation methods per SPEC:
1. **Email invitation** — send invite to email, stored in `families/{id}/invitations/{id}`
2. **Code + password** — family has a `familyCode` and `hashedPassword`; user enters both to join

**Implementation**: Cloud Function `process_family_invitation` handles both flows.
For code+password join, the client calls a Cloud Function that:
- Looks up family by code
- Verifies hashed password (bcrypt)
- Adds user to `memberIds` array
- Updates user's `familyIds`

### 4. Existing Patterns to Follow

| Pattern | Source | Reuse For |
|---------|--------|-----------|
| Service class with DI | `AuthService` | `PetService`, `FamilyService`, `StorageService` |
| Riverpod providers | `auth_providers.dart` | Pet/Family providers |
| `FirebaseService` helpers | `firebase_service.dart` | CRUD operations |
| GoRouter placeholder swap | `app_router.dart` | Replace `/pets` and `/family` placeholders |

### 5. Decisions

- **Pet photos served via presigned download URLs** (not public) — more secure, matches R2 approach
- **Thumbnail generation**: Client-side only (compress to 200px for thumbnail) — simpler than server-side
- **Family password hashing**: `bcrypt` in Cloud Function — industry standard
