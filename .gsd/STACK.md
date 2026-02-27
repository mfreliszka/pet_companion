# STACK.md — Technology Inventory

## Frontend
| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.38.9 | Cross-platform mobile framework |
| Dart | (bundled with Flutter) | Programming language |
| flutter_riverpod | latest | Reactive state management & DI |
| GoRouter | latest | Declarative routing |
| Hive | latest | Local cache / offline storage |
| image_picker | latest | Photo capture/selection |
| image_cropper | latest | Pet photo face cropping |
| flutter_image_compress | latest | Client-side photo compression |
| pdf | latest | PDF report generation |
| fl_chart | latest | Weight & expense charts |
| firebase_core | latest | Firebase initialization |
| firebase_auth | latest | Google Sign-In |
| cloud_firestore | latest | Firestore client |
| firebase_messaging | latest | Push notifications (FCM) |
| google_sign_in | latest | Google auth provider |
| intl | latest | Date/time formatting |
| uuid | latest | Unique ID generation |
| share_plus | latest | Share PDF reports |
| path_provider | latest | File system paths |
| http | latest | HTTP client for R2 uploads |

## Backend
| Technology | Version | Purpose |
|-----------|---------|---------|
| Firebase Cloud Functions | Gen 2 | Serverless backend |
| Python | 3.11+ | Cloud Functions runtime |
| firebase-admin (Python) | latest | Firebase Admin SDK |
| firebase-functions (Python) | latest | Cloud Functions framework |
| google-cloud-firestore | latest | Firestore access |
| reportlab / fpdf2 | latest | PDF generation |
| boto3 | latest | Cloudflare R2 (S3-compatible) |

## Infrastructure
| Technology | Purpose |
|-----------|---------|
| Cloud Firestore | Primary database |
| Firebase Authentication | User auth (Google Sign-In) |
| Firebase Cloud Messaging | Push notifications |
| Cloud Scheduler | Cron jobs for reminders |
| Cloudflare R2 | Photo and document storage |
| GitHub Actions | CI/CD pipelines |

## Development
| Tool | Purpose |
|------|---------|
| VS Code / Android Studio | IDE |
| Firebase Emulator Suite | Local development |
| FlutterFire CLI | Firebase config generation |
