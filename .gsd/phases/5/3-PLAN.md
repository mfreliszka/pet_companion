---
phase: 5
plan: 3
wave: 2
---

# Plan 5.3: PDF Health Report Generation

## Objective
Implement PDF health report generation via a Cloud Function. Users select a date range and pet, the Cloud Function queries Firestore (journal entries, weight, medications, vaccinations), renders a PDF, uploads to R2, and returns a download URL. Flutter screen provides the UX.

## Context
- .gsd/SPEC.md — "PDF health report generation for configurable date ranges"
- mobile/lib/features/reports/ (empty scaffold)
- firebase/functions/main.py (existing Cloud Functions pattern)
- firebase/functions/src/ (R2 client pattern)
- mobile/lib/core/routing/app_router.dart

## Tasks

<task type="auto">
  <name>Cloud Function: generate_pet_report</name>
  <files>
    firebase/functions/src/reports/report_generator.py
    firebase/functions/src/reports/__init__.py
    firebase/functions/main.py
    firebase/functions/requirements.txt
  </files>
  <action>
    1. Add `reportlab` to requirements.txt (PDF generation library)
    2. Create report_generator.py:
       - generate_pet_report(pet_id, start_date, end_date, user_id) function
       - Queries Firestore: pet doc, journal entries in range, weight history, medications, vaccinations
       - Renders PDF with ReportLab: header (pet name, date range), sections for journal entries, weight chart data, medication list, vaccination schedule
       - Uploads PDF to R2 via existing R2Client
       - Returns R2 key
    3. Create Cloud Function in main.py:
       - generate_report (on_call, authenticated)
       - Accepts: { petId, startDate, endDate }
       - Returns: { reportKey, downloadUrl }
    4. Add __init__.py for reports module
    
    Follow the existing R2 upload pattern from generate_r2_upload_url.
  </action>
  <verify>python -c "import reportlab" (dependency check)</verify>
  <done>Cloud Function compiles, accepts date range, generates PDF, returns download URL</done>
</task>

<task type="auto">
  <name>Report screen and router integration</name>
  <files>
    mobile/lib/features/reports/screens/generate_report_screen.dart
    mobile/lib/core/routing/app_router.dart
  </files>
  <action>
    1. GenerateReportScreen:
       - Pet selector dropdown (from family pets)
       - Date range picker (start/end)
       - "Generate Report" button (calls Cloud Function)
       - Loading state with progress indicator
       - Download/share button once report URL is returned
       - Recent reports list (optional — stored in Firestore subcollection)
    2. Wire route:
       - /reports (replace placeholder if exists, or add new)
       - Add to drawer navigation if not already present
    
    Use cloud_functions package to call generate_report.
  </action>
  <verify>flutter build web 2>&1 | tail -3</verify>
  <done>Report screen renders, calls Cloud Function, shows download link — build passes</done>
</task>

## Success Criteria
- [ ] Cloud Function generates PDF with pet health data
- [ ] PDF uploaded to R2 with download URL returned
- [ ] Flutter screen with pet selector, date range picker, generation progress
- [ ] Route wired at /reports
- [ ] flutter build web succeeds with 0 errors
