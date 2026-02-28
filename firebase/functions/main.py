"""
Pet Companion — Firebase Cloud Functions (Gen 2, Python)

Entry point for all Cloud Functions.
"""

from firebase_functions import identity_fn, https_fn, options
from firebase_admin import initialize_app, firestore
from datetime import datetime, timezone

# Re-export scheduled functions so Firebase discovers them
from src.notifications.send_reminders import (  # noqa: F401
    send_event_reminders,
    send_vaccination_reminders,
)

# Import report generator
from src.reports.report_generator import generate_report_pdf  # noqa: F401

# Initialize Firebase Admin SDK
app = initialize_app()


# ── PDF Report Generation ──────────────────────────────────────

@https_fn.on_call(
    memory=options.MemoryOption.MB_512,
    timeout_sec=120,
)
def generate_report(req: https_fn.CallableRequest):
    """Generate a PDF health report for a pet.

    Args (via req.data):
        petId: str — Pet document ID
        startDate: str — ISO 8601 date string
        endDate: str — ISO 8601 date string

    Returns:
        { reportKey: str, downloadUrl: str }
    """
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required",
        )

    pet_id = req.data.get("petId")
    start_str = req.data.get("startDate")
    end_str = req.data.get("endDate")

    if not all([pet_id, start_str, end_str]):
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="petId, startDate, and endDate are required",
        )

    try:
        start_date = datetime.fromisoformat(start_str)
        end_date = datetime.fromisoformat(end_str)
    except ValueError:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="Invalid date format. Use ISO 8601",
        )

    r2_key, download_url = generate_report_pdf(
        pet_id=pet_id,
        start_date=start_date,
        end_date=end_date,
        user_id=req.auth.uid,
    )

    return {"reportKey": r2_key, "downloadUrl": download_url}


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
    secrets=["R2_ACCOUNT_ID", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY", "R2_BUCKET_NAME"],
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
    secrets=["R2_ACCOUNT_ID", "R2_ACCESS_KEY_ID", "R2_SECRET_ACCESS_KEY", "R2_BUCKET_NAME"],
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


# ── Family Functions ─────────────────────────────────────────────

@https_fn.on_call(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
)
def create_family(req: https_fn.CallableRequest) -> dict:
    """Create a family with optional password protection."""
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required.",
        )

    from src.family.invitation_handler import handle_create_family

    try:
        return handle_create_family(req.data or {}, req.auth.uid)
    except ValueError as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message=str(e),
        )


@https_fn.on_call(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]),
)
def join_family_by_code(req: https_fn.CallableRequest) -> dict:
    """Join a family using code + password verification."""
    if req.auth is None:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="Authentication required.",
        )

    from src.family.invitation_handler import handle_join_family_by_code

    try:
        return handle_join_family_by_code(req.data or {}, req.auth.uid)
    except ValueError as e:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message=str(e),
        )

