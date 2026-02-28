"""
Scheduled Cloud Functions for sending push notification reminders.

Uses Firebase Cloud Scheduler (@scheduler_fn) for periodic execution.
"""

from datetime import datetime, timezone, timedelta

from firebase_functions import scheduler_fn
from firebase_admin import firestore

from .helpers import send_fcm_notification, get_family_member_tokens


@scheduler_fn.on_schedule(schedule="every 5 minutes")
def send_event_reminders(event: scheduler_fn.ScheduledEvent) -> None:
    """
    Check for upcoming events and send reminders.

    Runs every 5 minutes. For each active event:
    - One-time: send reminder if oneTimeDate - reminderMinutesBefore is in the current 5-min window
    - Cyclic: simplified — only handles one-time events for MVP
    """
    db = firestore.client()
    now = datetime.now(timezone.utc)
    window_start = now
    window_end = now + timedelta(minutes=5)

    # Query one-time active events with reminders
    events = (
        db.collection("events")
        .where("isActive", "==", True)
        .where("isCyclic", "==", False)
        .stream()
    )

    for event_doc in events:
        data = event_doc.to_dict()
        one_time_date = data.get("oneTimeDate")
        reminder_minutes = data.get("reminderMinutesBefore", 5)

        if one_time_date is None:
            continue

        # Calculate reminder time
        event_time = one_time_date
        if hasattr(event_time, "timestamp"):
            # Firestore Timestamp
            event_time = event_time.replace(tzinfo=timezone.utc) if event_time.tzinfo is None else event_time
        
        reminder_time = event_time - timedelta(minutes=reminder_minutes)

        if window_start <= reminder_time < window_end:
            # Send reminder to assigned member or all family members
            family_id = data.get("familyId", "")
            assigned_to = data.get("assignedTo")
            title = data.get("title", "Event Reminder")

            if assigned_to:
                # Send only to assigned member
                user_doc = db.collection("users").document(assigned_to).get()
                if user_doc.exists:
                    tokens = user_doc.to_dict().get("fcmTokens", [])
                    for token in tokens:
                        send_fcm_notification(
                            token,
                            f"⏰ Reminder: {title}",
                            f"Coming up in {reminder_minutes} minutes",
                            {"eventId": event_doc.id, "type": "event_reminder"},
                        )
            else:
                # Send to all family members
                tokens = get_family_member_tokens(family_id)
                for token in tokens:
                    send_fcm_notification(
                        token,
                        f"⏰ Reminder: {title}",
                        f"Coming up in {reminder_minutes} minutes",
                        {"eventId": event_doc.id, "type": "event_reminder"},
                    )

    print(f"Event reminders check completed at {now.isoformat()}")


@scheduler_fn.on_schedule(schedule="every day 09:00")
def send_vaccination_reminders(event: scheduler_fn.ScheduledEvent) -> None:
    """
    Daily check for upcoming vaccinations.

    Sends reminders for vaccinations due within 7 days.
    """
    db = firestore.client()
    now = datetime.now(timezone.utc)
    week_from_now = now + timedelta(days=7)

    # Query vaccinations with upcoming due dates
    vaccinations = (
        db.collection("vaccinations")
        .where("nextDueDate", ">=", now)
        .where("nextDueDate", "<=", week_from_now)
        .stream()
    )

    for vacc_doc in vaccinations:
        data = vacc_doc.to_dict()
        
        # Skip if reminder already sent
        if data.get("reminderSent", False):
            continue

        pet_id = data.get("petId", "")
        vacc_name = data.get("name", "Vaccination")
        next_due = data.get("nextDueDate")

        # Get pet to find family
        pet_doc = db.collection("pets").document(pet_id).get()
        if not pet_doc.exists:
            continue
        
        pet_data = pet_doc.to_dict()
        family_id = pet_data.get("familyId", "")
        pet_name = pet_data.get("name", "Your pet")

        if not family_id:
            continue

        # Send to all family members
        tokens = get_family_member_tokens(family_id)
        days_until = (next_due - now).days if next_due else 0
        
        for token in tokens:
            send_fcm_notification(
                token,
                f"💉 {pet_name}: {vacc_name} due soon",
                f"Due in {days_until} days",
                {"petId": pet_id, "type": "vaccination_reminder"},
            )

        # Mark reminder as sent
        vacc_doc.reference.update({"reminderSent": True})

    print(f"Vaccination reminders check completed at {now.isoformat()}")
