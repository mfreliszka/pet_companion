---
phase: 1
plan: 1
wave: 1
depends_on: []
files_modified:
  - mobile/ (entire Flutter project scaffold)
  - firebase/firebase.json
  - firebase/firestore.rules
  - firebase/firestore.indexes.json
  - firebase/.firebaserc
  - firebase/functions/main.py
  - firebase/functions/requirements.txt
autonomous: false
user_setup:
  - service: cloudflare_r2
    why: "Photo and document storage — cannot be provisioned by AI"
    action: "Create R2 bucket named 'pet-companion' in Cloudflare dashboard. Note API credentials (Account ID, Access Key ID, Secret Access Key) for Phase 2 Cloud Functions."
    dashboard_url: "https://dash.cloudflare.com → R2 Object Storage → Create Bucket"

must_haves:
  truths:
    - "Flutter project exists at mobile/ with proper folder structure"
    - "firebase_options.dart is generated and Firebase initializes in main.dart"
    - "Firestore security rules are deployed with initial user collection rules"
    - "Cloud Functions skeleton exists with Python Gen 2 runtime"
    - "flutter run -d chrome launches without errors"
    - "pubspec.yaml contains all required dependencies for Phase 1"
  artifacts:
    - "mobile/lib/main.dart with Firebase initialization"
    - "mobile/pubspec.yaml with all dependencies"
    - "firebase/firestore.rules with user collection rules"
    - "firebase/functions/main.py with on_user_created function stub"
---

# Plan 1.1: Project Scaffold + Firebase Setup

<objective>
Create the Flutter project, configure Firebase (Auth + Firestore), set up Cloud Functions skeleton, and establish the full project folder structure.

Purpose: Foundation that all subsequent plans build on. Nothing else can start without a working Flutter project connected to Firebase.
Output: Buildable Flutter app with Firebase initialized, Cloud Functions skeleton, Firestore rules deployed.
</objective>

<context>
Load for context:
- .gsd/SPEC.md (vision, tech stack, constraints)
- .gsd/ARCHITECTURE.md (folder structure, Firestore schema, Cloud Functions list)
- .gsd/DECISIONS.md (Phase 1 decisions — drawer nav, dark mode, web support)
- my_specs.md (project structure tree)
</context>

<tasks>

<task type="auto">
  <name>Create Flutter project and configure dependencies</name>
  <files>
    mobile/ (Flutter project)
    mobile/pubspec.yaml
    mobile/lib/main.dart
  </files>
  <action>
    1. Run `flutter create mobile --org com.petcompanion --project-name pet_companion --platforms android,ios,web`
    2. Update pubspec.yaml with these dependencies:
       - flutter_riverpod (state management)
       - riverpod_annotation (code generation)
       - go_router (navigation)
       - firebase_core
       - firebase_auth
       - cloud_firestore
       - google_sign_in
       - hive_flutter (local cache)
       - image_picker
       - image_cropper
       - flutter_image_compress
       - fl_chart (weight charts)
       - pdf (report generation)
       - share_plus
       - path_provider
       - http (for R2 uploads)
       - intl (date formatting)
       - uuid
       - google_fonts
       - cached_network_image
    3. Add dev_dependencies:
       - riverpod_generator
       - build_runner
       - json_serializable
       - flutter_lints
    4. Create the full folder structure under mobile/lib/:
       - core/theme/
       - core/constants/
       - core/routing/
       - core/utils/
       - core/widgets/buttons/
       - core/widgets/cards/
       - core/widgets/inputs/
       - core/widgets/dialogs/
       - core/widgets/loading/
       - core/widgets/layout/
       - core/widgets/media/
       - features/auth/screens/, providers/, services/
       - features/home/screens/, providers/
       - features/pets/models/, screens/, providers/, services/
       - features/family/models/, screens/, providers/, services/
       - features/journal/models/, screens/, providers/, services/
       - features/health/models/, screens/, providers/, services/
       - features/schedule/models/, screens/, providers/, services/
       - features/notifications/providers/, services/
       - features/expenses/models/, screens/, providers/, services/
       - features/contacts/models/, screens/, providers/, services/
       - features/reports/screens/, providers/, services/
       - features/premium/screens/, providers/, services/
       - services/
    5. Add placeholder .gitkeep files in empty directories
    6. Run `flutter pub get` to verify dependencies resolve
    AVOID: Don't use `flutter create .` in the root — the project MUST be in `mobile/` subdirectory per ARCHITECTURE.md.
    AVOID: Don't add firebase_messaging yet — FCM is Phase 4.
  </action>
  <verify>
    cd mobile && flutter pub get succeeds without errors
    cd mobile && flutter analyze shows no errors (warnings OK)
    Folder structure matches ARCHITECTURE.md
  </verify>
  <done>
    Flutter project at mobile/ with all dependencies resolved.
    Full folder structure created per ARCHITECTURE.md.
    `flutter pub get` succeeds.
  </done>
</task>

<task type="checkpoint:human-action">
  <name>Create Firebase project and configure FlutterFire</name>
  <files>
    mobile/lib/firebase_options.dart
    mobile/lib/main.dart
    firebase/firebase.json
    firebase/.firebaserc
  </files>
  <action>
    1. Create a new Firebase project (via Firebase console or `firebase projects:create pet-companion-app`)
    2. Enable Authentication → Google sign-in provider
    3. Create Firestore database (production mode, region: europe-west1 or user's preferred region)
    4. Run `flutterfire configure` from mobile/ directory to generate firebase_options.dart
       - Select the created Firebase project
       - Enable Android, iOS, and Web platforms
    5. Update mobile/lib/main.dart to initialize Firebase:
       ```dart
       void main() async {
         WidgetsFlutterBinding.ensureInitialized();
         await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
         runApp(const ProviderScope(child: PetCompanionApp()));
       }
       ```
    6. Initialize firebase/ directory:
       - Run `firebase init` in firebase/ directory
       - Select Firestore and Functions
       - Choose Python for Cloud Functions runtime
    7. Verify `flutter run -d chrome` launches with Firebase initialized (no runtime errors)
    AVOID: Don't enable FCM yet — that's Phase 4.
    NOTE: User must have Firebase CLI and FlutterFire CLI installed. If not: `npm install -g firebase-tools` and `dart pub global activate flutterfire_cli`
  </action>
  <verify>
    firebase_options.dart exists in mobile/lib/
    `cd mobile && flutter run -d chrome` launches without Firebase errors
    Firebase console shows the project with Auth and Firestore enabled
  </verify>
  <done>
    Firebase project exists with Auth + Firestore enabled.
    firebase_options.dart generated for Android, iOS, Web.
    main.dart initializes Firebase on startup.
    `flutter run -d chrome` works.
  </done>
</task>

<task type="auto">
  <name>Deploy initial Firestore rules and Cloud Functions skeleton</name>
  <files>
    firebase/firestore.rules
    firebase/firestore.indexes.json
    firebase/functions/main.py
    firebase/functions/requirements.txt
  </files>
  <action>
    1. Create firebase/firestore.rules with initial security rules:
       - users collection: read/write only by the authenticated user (request.auth.uid == userId)
       - Deny all other access by default
    2. Create firebase/firestore.indexes.json with the indexes from ARCHITECTURE.md
    3. Create firebase/functions/main.py with:
       - on_user_created: Auth onCreate trigger that creates a user document in Firestore
         (uid, email, displayName, photoUrl, familyIds: [], fcmTokens: [], isPremium: false, createdAt, updatedAt)
       - Use firebase_functions_v2 and firebase_admin
    4. Create firebase/functions/requirements.txt:
       - firebase-admin
       - firebase-functions
       - google-cloud-firestore
    5. Create firebase/functions/src/ directory with __init__.py
    6. Deploy rules: `cd firebase && firebase deploy --only firestore:rules,firestore:indexes`
    AVOID: Don't deploy functions yet if user hasn't set up billing (Blaze plan required for Gen 2 functions). Just create the files.
  </action>
  <verify>
    firebase/firestore.rules file exists with user collection rules
    firebase/functions/main.py contains on_user_created function
    `cd firebase && firebase deploy --only firestore:rules` succeeds (if project configured)
  </verify>
  <done>
    Firestore rules deployed for users collection.
    Cloud Functions skeleton exists with on_user_created.
    Firestore indexes configuration file created.
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `cd mobile && flutter pub get` succeeds
- [ ] `cd mobile && flutter run -d chrome` launches with Firebase initialized
- [ ] Firebase console shows project with Auth (Google) + Firestore enabled
- [ ] firebase_options.dart exists with correct project config
- [ ] Full folder structure exists per ARCHITECTURE.md
- [ ] Firestore rules deployed for users collection
- [ ] Cloud Functions skeleton exists (main.py + requirements.txt)
</verification>

<success_criteria>
- [ ] All tasks verified
- [ ] Must-haves confirmed
- [ ] Flutter project builds for web, Android can be tested
</success_criteria>
