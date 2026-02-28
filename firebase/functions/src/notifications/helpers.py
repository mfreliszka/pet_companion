"""
Notification helpers — FCM message dispatch and token management.
"""

from firebase_admin import messaging, firestore


def send_fcm_notification(
    token: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """
    Send a single FCM notification. Returns True on success.
    Handles unregistered tokens by removing them from Firestore.
    """
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data=data or {},
        token=token,
    )

    try:
        messaging.send(message)
        return True
    except messaging.UnregisteredError:
        # Token is invalid → should be cleaned up
        _remove_stale_token(token)
        return False
    except Exception as e:
        print(f"FCM send error: {e}")
        return False


def get_family_member_tokens(family_id: str) -> list[str]:
    """Fetch all FCM tokens for members of a family."""
    db = firestore.client()
    family_doc = db.collection("families").document(family_id).get()

    if not family_doc.exists:
        return []

    family_data = family_doc.to_dict()
    member_ids = [m.get("uid", "") for m in family_data.get("members", [])]

    tokens = []
    for uid in member_ids:
        if not uid:
            continue
        user_doc = db.collection("users").document(uid).get()
        if user_doc.exists:
            user_tokens = user_doc.to_dict().get("fcmTokens", [])
            tokens.extend(user_tokens)

    return tokens


def send_to_family(
    family_id: str,
    title: str,
    body: str,
    data: dict | None = None,
    exclude_uid: str | None = None,
) -> int:
    """
    Send FCM notification to all members of a family.
    Returns number of successful sends.
    """
    db = firestore.client()
    family_doc = db.collection("families").document(family_id).get()

    if not family_doc.exists:
        return 0

    family_data = family_doc.to_dict()
    member_ids = [m.get("uid", "") for m in family_data.get("members", [])]

    sent = 0
    for uid in member_ids:
        if not uid or uid == exclude_uid:
            continue
        user_doc = db.collection("users").document(uid).get()
        if user_doc.exists:
            user_tokens = user_doc.to_dict().get("fcmTokens", [])
            for token in user_tokens:
                if send_fcm_notification(token, title, body, data):
                    sent += 1

    return sent


def _remove_stale_token(token: str):
    """Remove an unregistered FCM token from all user documents."""
    db = firestore.client()
    users = db.collection("users").where("fcmTokens", "array_contains", token).stream()

    for user_doc in users:
        db.collection("users").document(user_doc.id).update(
            {"fcmTokens": firestore.firestore.ArrayRemove([token])}
        )
