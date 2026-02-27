# SPEC.md — Project Specification

> **Status**: `FINALIZED`

## Vision
Pet Companion is a Flutter mobile app (Android + iOS) that helps pet owners — especially those with sick or high-maintenance pets — organize, track, and share every aspect of pet care within a family. From daily mood logs and medication schedules to veterinary document storage and expense tracking, the app provides a single source of truth for pet health and wellbeing with real-time family collaboration and push notifications.

## Goals
1. **Unified Pet Journal** — A single, chronological timeline per pet combining mood, symptoms, appetite, weight, energy, behavior, medications, vet visits, and free-form notes with photo attachments.
2. **Family Collaboration** — Multi-user families where events, schedules, and notifications are shared in real-time; task assignments and check-offs prevent duplicated care (e.g., double-feeding).
3. **Smart Notifications** — Push notifications for feeding schedules, medication reminders, and upcoming events; auto-dismissal when another family member completes a task.
4. **Health Data Export** — Generate PDF reports for configurable date ranges, exporting health data for veterinary appointments.
5. **Premium Monetization** — A paid tier that unlocks advanced features while keeping the core experience free.
6. **Performance & Scalability** — Design for 1,000 concurrent users day-one, architecturally ready for 10,000+.

## Non-Goals (Out of Scope)
- AI-powered diagnostics or health recommendations
- Social/community features (sharing pets publicly)
- E-commerce or pet product marketplace
- Integration with third-party veterinary systems or APIs
- Web app version (Flutter web is used only for rapid UI testing)
- Multi-language / i18n (English only for v1)

## Users
- **Primary**: Pet owners (individuals or families) who want organized, trackable pet care
- **Secondary**: Families who share pet care responsibilities and need coordination
- **Personas**: Solo pet owner with a chronically ill pet; multi-pet family with kids helping with care; couple coordinating feeding/walking schedules

## Tech Stack
- **Frontend**: Flutter 3.38.9 (Android + iOS + Web for testing)
- **State Management**: `flutter_riverpod` (Riverpod) for reactive state and DI
- **Backend**: Firebase Cloud Functions (Gen 2, Python)
- **Database**: Cloud Firestore
- **Auth**: Firebase Authentication (Google Sign-In)
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **File Storage**: Cloudflare R2 (photos, documents)
- **Local Cache**: Hive or Riverpod `keepAlive` for offline-first UX
- **Performance**: Cache-Control headers on Cloud Functions, client-side photo compression

## Constraints
- Flutter 3.38.9 target SDK
- Firebase free tier budget awareness (Spark → Blaze migration path)
- Cloudflare R2 for file storage (not Firebase Storage)
- Python Cloud Functions (Gen 2)
- Client-side photo compression before upload
- Must support both Android and iOS from v1
- Designed for 1,000 concurrent users, scalable to 10,000+

## Success Criteria
- [ ] User can sign in with Google and manage multiple pets with photos
- [ ] Family system works: create, invite, assign roles, share pets/events
- [ ] Pet journal captures mood, symptoms, weight, appetite, energy, behavior, medications, vet records with photos
- [ ] Push notifications for scheduled events with auto-dismissal on completion
- [ ] PDF health report generation for configurable date ranges
- [ ] Expense tracking with monthly/yearly totals
- [ ] Daily routine templates with family member task assignments
- [ ] Premium feature gating works end-to-end
- [ ] App performs well under 1,000 concurrent users
