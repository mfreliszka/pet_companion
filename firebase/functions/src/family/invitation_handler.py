"""
Family invitation handler.

Provides Cloud Functions for:
- Creating a family with a hashed password
- Joining a family by code + password
"""

import uuid
import bcrypt
from google.cloud import firestore


db = firestore.Client()


def handle_create_family(data: dict, uid: str) -> dict:
    """
    Create a family with optional password protection.

    Args:
        data: { name: str, password?: str }
        uid: Authenticated user's UID.

    Returns:
        { familyId: str, familyCode: str }
    """
    name = data.get("name")
    password = data.get("password")

    if not name:
        raise ValueError("'name' is required.")

    family_code = uuid.uuid4().hex[:8].upper()

    family_data = {
        "name": name,
        "familyCode": family_code,
        "adminIds": [uid],
        "memberIds": [uid],
        "petIds": [],
        "createdBy": uid,
        "createdAt": firestore.SERVER_TIMESTAMP,
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }

    # Hash password if provided
    if password:
        hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
        family_data["hashedPassword"] = hashed.decode("utf-8")

    # Create family document
    _, family_ref = db.collection("families").add(family_data)

    # Add familyId to user's familyIds
    db.collection("users").document(uid).update(
        {"familyIds": firestore.ArrayUnion([family_ref.id])}
    )

    return {"familyId": family_ref.id, "familyCode": family_code}


def handle_join_family_by_code(data: dict, uid: str) -> dict:
    """
    Join a family using code (+ optional password).

    Args:
        data: { code: str, password?: str }
        uid: Authenticated user's UID.

    Returns:
        { familyId: str, familyName: str }
    """
    code = data.get("code")
    password = data.get("password")

    if not code:
        raise ValueError("'code' is required.")

    # Look up family by code
    families = (
        db.collection("families")
        .where("familyCode", "==", code.upper())
        .limit(1)
        .get()
    )

    if not families:
        raise ValueError("Family not found. Check the code and try again.")

    family_doc = families[0]
    family_data = family_doc.to_dict()

    # Check if already a member
    if uid in family_data.get("memberIds", []):
        raise ValueError("You are already a member of this family.")

    # Verify password only if the family is password-protected
    hashed_password = family_data.get("hashedPassword")
    if hashed_password:
        if not password:
            raise ValueError("This family requires a password to join.")
        if not bcrypt.checkpw(
            password.encode("utf-8"), hashed_password.encode("utf-8")
        ):
            raise ValueError("Incorrect password.")

    # Add user to family
    family_doc.reference.update(
        {
            "memberIds": firestore.ArrayUnion([uid]),
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }
    )

    # Add familyId to user
    db.collection("users").document(uid).update(
        {"familyIds": firestore.ArrayUnion([family_doc.id])}
    )

    return {"familyId": family_doc.id, "familyName": family_data.get("name", "")}


def handle_accept_invitation(data: dict, uid: str) -> dict:
    """
    Accept a pending family invitation.

    Args:
        data: { invitationId: str }
        uid: Authenticated user's UID.

    Returns:
        { familyId: str, familyName: str }
    """
    invitation_id = data.get("invitationId")
    if not invitation_id:
        raise ValueError("'invitationId' is required.")

    # Get invitation
    inv_ref = db.collection("invitations").document(invitation_id)
    inv_doc = inv_ref.get()

    if not inv_doc.exists:
        raise ValueError("Invitation not found.")

    inv_data = inv_doc.to_dict()

    if inv_data.get("status") != "pending":
        raise ValueError("This invitation is no longer pending.")

    family_id = inv_data.get("familyId")
    if not family_id:
        raise ValueError("Invalid invitation — missing family reference.")

    # Get family
    family_ref = db.collection("families").document(family_id)
    family_doc = family_ref.get()

    if not family_doc.exists:
        raise ValueError("Family no longer exists.")

    family_data = family_doc.to_dict()

    # Check if already a member
    if uid in family_data.get("memberIds", []):
        # Mark invitation as accepted and return
        inv_ref.update({"status": "accepted"})
        return {"familyId": family_id, "familyName": family_data.get("name", "")}

    # Add user to family
    family_ref.update(
        {
            "memberIds": firestore.ArrayUnion([uid]),
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }
    )

    # Add familyId to user
    db.collection("users").document(uid).update(
        {"familyIds": firestore.ArrayUnion([family_id])}
    )

    # Mark invitation as accepted
    inv_ref.update({"status": "accepted"})

    return {"familyId": family_id, "familyName": family_data.get("name", "")}

