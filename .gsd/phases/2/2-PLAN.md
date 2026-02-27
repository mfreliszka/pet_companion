---
phase: 2
plan: 2
wave: 2
---

# Plan 2.2: Pet Photo Upload (R2 + Cloud Function)

## Objective
Enable pet profile photo upload: pick → crop → compress → upload to Cloudflare R2 via presigned URL → store URL in Firestore. Build the Cloud Function for R2 signed URL generation and the Flutter `StorageService`.

## Context
- .gsd/ARCHITECTURE.md (R2 storage structure, Cloud Functions table)
- .gsd/phases/2/RESEARCH.md (R2 boto3 approach)
- firebase/functions/main.py (existing Cloud Functions)
- firebase/functions/requirements.txt (add boto3)
- mobile/lib/features/pets/screens/add_pet_screen.dart (integrate photo)
- mobile/lib/features/pets/screens/pet_detail_screen.dart (display photo)

## Tasks

<task type="auto">
  <name>Cloud Function: R2 presigned URL generation</name>
  <files>
    firebase/functions/src/storage/__init__.py
    firebase/functions/src/storage/r2_client.py
    firebase/functions/main.py
    firebase/functions/requirements.txt
  </files>
  <action>
    r2_client.py — R2 helper:
    - Initialize boto3 S3 client with R2 endpoint, credentials from environment variables
    - `generate_upload_url(bucket, key, content_type, expires_in=3600) → str`
    - `generate_download_url(bucket, key, expires_in=3600) → str`

    main.py — Add two callable Cloud Functions:
    - `generate_r2_upload_url(req)` — auth required, accepts {path, contentType}, returns {url, key}
      - Path format: `pets/{petId}/profile/{uuid}.jpg`
    - `generate_r2_download_url(req)` — auth required, accepts {key}, returns {url}

    requirements.txt — Add `boto3>=1.28.0`

    Environment variables needed (to be set with `firebase functions:config:set` or GCP Secret Manager):
    - R2_ACCOUNT_ID
    - R2_ACCESS_KEY_ID
    - R2_SECRET_ACCESS_KEY
    - R2_BUCKET_NAME
    
    DO NOT hardcode secrets. Use `os.environ.get()`.
  </action>
  <verify>cd firebase && python -c "from functions.src.storage.r2_client import R2Client; print('import ok')"</verify>
  <done>Cloud Functions for upload/download URL generation are defined, boto3 dependency added</done>
</task>

<task type="auto">
  <name>Flutter StorageService + photo pipeline</name>
  <files>
    mobile/lib/services/storage_service.dart
    mobile/lib/core/utils/image_utils.dart
  </files>
  <action>
    StorageService:
    - `requestUploadUrl({required String path, required String contentType}) → Future<Map<String, String>>` 
      — calls `generate_r2_upload_url` Cloud Function via `FirebaseFunctions.instance.httpsCallable()`
    - `requestDownloadUrl({required String key}) → Future<String>`
      — calls `generate_r2_download_url` Cloud Function
    - `uploadBytes({required String uploadUrl, required Uint8List bytes, required String contentType}) → Future<void>`
      — HTTP PUT to the presigned URL

    image_utils.dart:
    - `pickAndProcessImage({required bool fromCamera, int maxDimension = 1024, int quality = 80}) → Future<Uint8List?>`
      — Uses image_picker → image_cropper (square crop) → flutter_image_compress
    - `createThumbnail(Uint8List source, {int maxDimension = 200, int quality = 70}) → Future<Uint8List>`
      — Smaller version for list views

    Add `cloud_functions` to pubspec.yaml dependencies if not already present.
  </action>
  <verify>flutter analyze mobile/lib/services/storage_service.dart mobile/lib/core/utils/image_utils.dart</verify>
  <done>StorageService can request presigned URLs and upload bytes; image_utils picks, crops, compresses images</done>
</task>

<task type="auto">
  <name>Integrate photo upload into pet screens</name>
  <files>
    mobile/lib/features/pets/screens/add_pet_screen.dart
    mobile/lib/features/pets/screens/pet_detail_screen.dart
    mobile/lib/features/pets/providers/pet_providers.dart
  </files>
  <action>
    AddPetScreen updates:
    - Tap avatar circle → bottom sheet with "Camera" / "Gallery" options
    - On selection: pickAndProcessImage → show preview
    - On save: upload photo + thumbnail to R2, store URLs in pet document
    - Show loading indicator during upload

    PetDetailScreen updates:
    - Display pet photo using CachedNetworkImage with download URL (or placeholder by species)
    - "Change Photo" button in edit mode
    - On photo change: same flow as add

    Provider updates:
    - Add `storageServiceProvider` to pet_providers.dart or a shared providers file
  </action>
  <verify>flutter build web --no-tree-shake-icons</verify>
  <done>Pet photo can be picked, cropped, compressed, uploaded to R2, and displayed from R2</done>
</task>

## Success Criteria
- [ ] Cloud Function generates valid R2 presigned upload/download URLs
- [ ] Flutter can pick, crop, compress an image client-side
- [ ] Photo uploads to R2 via presigned PUT URL
- [ ] Pet document stores photoUrl and photoThumbnailUrl
- [ ] Pet list and detail screens display the photo from R2
