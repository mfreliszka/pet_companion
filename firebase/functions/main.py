"""
Pet Companion — Firebase Cloud Functions (Gen 2, Python)

Entry point for all Cloud Functions.
"""

from firebase_functions import identity_fn, https_fn, options
from firebase_admin import initialize_app, firestore
from datetime import datetime, timezone

# Initialize Firebase Admin SDK
app = initialize_app()


@identity_fn.before_user_created()
def on_user_created(event: identity_fn.AuthBlockingEvent) -> identity_fn.BeforeCreateResponse | None:
    """
    Triggered when a new user is created via Firebase Authentication.
    Creates a corresponding user document in Firestore.
    """
    db = firestore.client()
    user = event.data

    user_doc = {
        "uid": user.uid,
        "email": user.email or "",
        "displayName": user.display_name or "",
        "photoUrl": user.photo_url or "",
        "familyIds": [],
        "fcmTokens": [],
        "isPremium": False,
        "premiumExpiresAt": None,
        "createdAt": datetime.now(timezone.utc),
        "updatedAt": datetime.now(timezone.utc),
    }

    db.collection("users").document(user.uid).set(user_doc)

    return None


@https_fn.on_call(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
)
def get_user_profile(req: https_fn.CallableRequest) -> dict:
    """
    Returns the authenticated user's profile from Firestore.
    Callable function — requires authentication.
    """
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required.",
        )

    db = firestore.client()
    user_doc = db.collection("users").document(req.auth.uid).get()

    if not user_doc.exists:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.NOT_FOUND,
            message="User profile not found.",
        )

    return user_doc.to_dict()


# ── R2 Storage Functions ─────────────────────────────────────────

@https_fn.on_call(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
)
def generate_r2_upload_url(req: https_fn.CallableRequest) -> dict:
    """
    Generate a presigned upload URL for Cloudflare R2.

    Expects: { path: str, contentType: str }
    Returns: { url: str, key: str }
    """
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required.",
        )

    data = req.data or {}
    path = data.get("path")
    content_type = data.get("contentType", "image/jpeg")

    if not path:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="'path' is required (e.g. 'pets/{petId}/profile/{uuid}.jpg').",
        )

    from src.storage.r2_client import R2Client

    r2 = R2Client()
    url = r2.generate_upload_url(key=path, content_type=content_type)

    return {"url": url, "key": path}


@https_fn.on_call(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
)
def generate_r2_download_url(req: https_fn.CallableRequest) -> dict:
    """
    Generate a presigned download URL for Cloudflare R2.

    Expects: { key: str }
    Returns: { url: str }
    """
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required.",
        )

    data = req.data or {}
    key = data.get("key")

    if not key:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="'key' is required.",
        )

    from src.storage.r2_client import R2Client

    r2 = R2Client()
    url = r2.generate_download_url(key=key)

    return {"url": url}

