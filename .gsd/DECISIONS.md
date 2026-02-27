# DECISIONS.md — Architecture Decision Records

## Format
| ID | Decision | Context | Date |
|----|----------|---------|------|
| ADR-01 | Top-level collections for cross-family queries | Events, expenses, pets, and contacts are top-level (not family subcollections) to enable collection group queries and Cloud Function triggers. Denormalized `familyId` on each doc for security rules. | 2026-02-27 |
| ADR-02 | Cloudflare R2 via signed URLs | Instead of Firebase Storage, using Cloudflare R2 with Cloud Functions generating signed upload/download URLs. More cost-effective at scale. | 2026-02-27 |
| ADR-03 | Unified journal with type discriminator | Single `journalEntries` subcollection under pets with `type` field and polymorphic `data` map, rather than separate collections per entry type. Simpler timeline queries. | 2026-02-27 |
| ADR-04 | Event completions as subcollection | Tracking cyclic event completions in a subcollection under events rather than modifying the event document. Prevents write conflicts and enables history. | 2026-02-27 |
| ADR-05 | Python Cloud Functions Gen 2 | Using Python runtime for Cloud Functions for consistency with data processing and PDF generation libraries. | 2026-02-27 |
| ADR-06 | Client-side photo compression | Compressing photos on the Flutter side before upload to reduce bandwidth, storage costs, and upload time. Max 1024px, ~80% JPEG quality. | 2026-02-27 |
