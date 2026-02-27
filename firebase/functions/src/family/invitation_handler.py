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
    Join a family using code + password.

    Args:
        data: { code: str, password: str }
        uid: Authenticated user's UID.

    Returns:
        { familyId: str, familyName: str }
    """
    code = data.get("code")
    password = data.get("password")

    if not code or not password:
        raise ValueError("'code' and 'password' are required.")

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

    # Verify password
    hashed_password = family_data.get("hashedPassword")
    if hashed_password:
        if not bcrypt.checkpw(
            password.encode("utf-8"), hashed_password.encode("utf-8")
        ):
            raise ValueError("Incorrect password.")
    else:
        raise ValueError("This family does not support code-based joining.")

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
