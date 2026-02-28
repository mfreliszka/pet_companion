"""
PDF Health Report Generator

Generates a pet health report PDF from Firestore data, uploads to R2,
and returns a presigned download URL.
"""

import io
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.colors import HexColor
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
)
from firebase_admin import firestore

from src.storage.r2_client import R2Client


def _get_db():
    return firestore.client()


def generate_report_pdf(
    pet_id: str,
    start_date: datetime,
    end_date: datetime,
    user_id: str,
) -> tuple[str, str]:
    """Generate a pet health PDF report and upload to R2.

    Returns:
        Tuple of (r2_key, download_url)
    """
    db = _get_db()

    # ── Fetch data ──────────────────────────────────────────────
    pet_doc = db.collection("pets").document(pet_id).get()
    if not pet_doc.exists:
        raise ValueError(f"Pet {pet_id} not found")
    pet = pet_doc.to_dict()
    pet_name = pet.get("name", "Unknown")

    # Journal entries in range
    journal_entries = (
        db.collection("journalEntries")
        .where("petId", "==", pet_id)
        .where("date", ">=", start_date)
        .where("date", "<=", end_date)
        .order_by("date", direction=firestore.Query.DESCENDING)
        .limit(200)
        .stream()
    )
    entries = [{"id": e.id, **e.to_dict()} for e in journal_entries]

    # Weight history
    weight_entries = [e for e in entries if e.get("type") == "weight"]

    # Medications
    medications = (
        db.collection("medications")
        .where("petId", "==", pet_id)
        .order_by("name")
        .stream()
    )
    meds = [{"id": m.id, **m.to_dict()} for m in medications]

    # Vaccinations
    vaccinations = (
        db.collection("vaccinations")
        .where("petId", "==", pet_id)
        .order_by("name")
        .stream()
    )
    vax = [{"id": v.id, **v.to_dict()} for v in vaccinations]

    # ── Render PDF ───────────────────────────────────────────────
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4,
                            leftMargin=20 * mm, rightMargin=20 * mm,
                            topMargin=20 * mm, bottomMargin=20 * mm)

    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        "ReportTitle", parent=styles["Title"],
        textColor=HexColor("#6750A4"), fontSize=20
    )
    heading_style = ParagraphStyle(
        "CustomHeading", parent=styles["Heading2"],
        textColor=HexColor("#6750A4"), fontSize=14, spaceAfter=6
    )

    elements = []

    # Title
    elements.append(Paragraph(f"Health Report: {pet_name}", title_style))
    date_range = f"{start_date.strftime('%b %d, %Y')} — {end_date.strftime('%b %d, %Y')}"
    elements.append(Paragraph(date_range, styles["Normal"]))
    elements.append(Spacer(1, 12))

    # Pet Info
    elements.append(Paragraph("Pet Information", heading_style))
    info_data = [
        ["Name", pet_name],
        ["Species", pet.get("species", "—")],
        ["Breed", pet.get("breed", "—")],
        ["Date of Birth", _format_date(pet.get("dateOfBirth"))],
    ]
    info_table = Table(info_data, colWidths=[80 * mm, 80 * mm])
    info_table.setStyle(TableStyle([
        ("FONTSIZE", (0, 0), (-1, -1), 10),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("FONT", (0, 0), (0, -1), "Helvetica-Bold"),
    ]))
    elements.append(info_table)
    elements.append(Spacer(1, 12))

    # Weight History
    if weight_entries:
        elements.append(Paragraph("Weight History", heading_style))
        w_data = [["Date", "Weight (kg)"]]
        for w in weight_entries[:20]:
            w_data.append([
                _format_date(w.get("date")),
                str(w.get("weight", "—")),
            ])
        w_table = Table(w_data, colWidths=[80 * mm, 80 * mm])
        w_table.setStyle(TableStyle([
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("BACKGROUND", (0, 0), (-1, 0), HexColor("#E8DEF8")),
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#CCCCCC")),
        ]))
        elements.append(w_table)
        elements.append(Spacer(1, 12))

    # Medications
    if meds:
        elements.append(Paragraph("Current Medications", heading_style))
        m_data = [["Name", "Dosage", "Frequency"]]
        for m in meds:
            m_data.append([
                m.get("name", "—"),
                m.get("dosage", "—"),
                m.get("frequency", "—"),
            ])
        m_table = Table(m_data, colWidths=[55 * mm, 55 * mm, 55 * mm])
        m_table.setStyle(TableStyle([
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("BACKGROUND", (0, 0), (-1, 0), HexColor("#E8DEF8")),
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#CCCCCC")),
        ]))
        elements.append(m_table)
        elements.append(Spacer(1, 12))

    # Vaccinations
    if vax:
        elements.append(Paragraph("Vaccinations", heading_style))
        v_data = [["Name", "Date Given", "Next Due"]]
        for v in vax:
            v_data.append([
                v.get("name", "—"),
                _format_date(v.get("dateGiven")),
                _format_date(v.get("nextDueDate")),
            ])
        v_table = Table(v_data, colWidths=[55 * mm, 55 * mm, 55 * mm])
        v_table.setStyle(TableStyle([
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("BACKGROUND", (0, 0), (-1, 0), HexColor("#E8DEF8")),
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ("GRID", (0, 0), (-1, -1), 0.5, HexColor("#CCCCCC")),
        ]))
        elements.append(v_table)
        elements.append(Spacer(1, 12))

    # Journal Summary
    non_weight = [e for e in entries if e.get("type") != "weight"]
    if non_weight:
        elements.append(Paragraph(f"Journal Entries ({len(non_weight)})", heading_style))
        for entry in non_weight[:30]:
            entry_type = entry.get("type", "note")
            entry_date = _format_date(entry.get("date"))
            entry_notes = entry.get("notes", "")[:200]
            elements.append(Paragraph(
                f"<b>{entry_date}</b> [{entry_type}] {entry_notes}",
                styles["Normal"],
            ))
            elements.append(Spacer(1, 4))

    # Footer
    elements.append(Spacer(1, 20))
    elements.append(Paragraph(
        f"Generated on {datetime.now().strftime('%b %d, %Y at %H:%M')}",
        ParagraphStyle("Footer", parent=styles["Normal"], fontSize=8,
                       textColor=HexColor("#888888")),
    ))

    doc.build(elements)
    pdf_bytes = buffer.getvalue()
    buffer.close()

    # ── Upload to R2 ─────────────────────────────────────────────
    r2 = R2Client()
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    r2_key = f"reports/{pet_id}/{timestamp}_health_report.pdf"

    # Upload PDF bytes directly
    r2._client.put_object(
        Bucket=r2.bucket_name,
        Key=r2_key,
        Body=pdf_bytes,
        ContentType="application/pdf",
    )

    download_url = r2.generate_download_url(r2_key, expires_in=7200)

    return r2_key, download_url


def _format_date(value) -> str:
    """Format a Firestore timestamp or datetime to string."""
    if value is None:
        return "—"
    if hasattr(value, "strftime"):
        return value.strftime("%b %d, %Y")
    return str(value)
