# App name: Pet Companion

I want to create an Flutter Android + iOS app for pet owners, that have trouble with maintaining all the things around their pets. There can be a lot of things to do around pets especially when they are sick. The user will be able to keep a pet journal and add information (with photos attached) for example about pet's current mood, going for a walk, nails cutting, feeling sick, vomiting, peeing issues, medication, current weight, uploading document from the veterinarian etc. The user will be able to generate a pdf report for certain period of time, exporting health data for veterinary appointments.
The app will send notifications to users about feeding the pet on previously set hours. If a family member will feed the pet, then the notification for other family members will go off.

App features:
- Daily mood tracker - Simple emoji-based mood selection (happy, sad, anxious, energetic, calm) with 1-5 scale and optional notes.
- Simple weight tracking - Add weight entries with date and display them in a basic line chart.
- Basic energy level tracker - Daily energy rating (low, normal, high) with optional notes about unusual tiredness or hyperactivity.
- Quick symptom logger - Simple form to log symptoms (vomiting, diarrhea, lethargy, etc.) with date, time, and optional photo.
- Basic appetite tracking - Daily checkboxes for "ate well," "ate some," "didn't eat" with optional notes about food type and amount.
- Simple expense tracking - Log pet-related expenses with categories (food, vet, toys, grooming) and basic monthly/yearly totals.
- Basic notes journal - Simple daily or weekly notes about your pet's behavior, activities, or anything noteworthy.
- Simple medication log - Track when medications were given with checkoff lists and basic missed dose alerts.
- Contact list for pet services - Store contact info for vet, groomer, pet sitter, emergency vet
- Simple vaccination record - List of vaccinations with dates due and completed, basic reminder alerts.
- Basic medical records storage - Upload and organize vet documents, test results, and medical photos with simple tagging.
- Microchip information storage - Store microchip number, registry info, and contact details in easily accessible format.
- Simple behavior incident log - Record behavioral issues (barking, jumping, accidents) with date, context, and simple notes.
- Basic daily routine templates - Pre-made routine checklists (morning, evening) that be customized and checked off.
- Simple family member assignments - Assign basic tasks (feeding, walking) to family members with simple check-off system.
- Simple care schedule overview - Basic calendar view showing who's responsible for what and when.
- User can have paid premium profile
- Flutter app will compress photos to a reasonable size before uploading them to the cloud storage
- Firebase cloud functions will use `Cache-Control` header to control endpoint caching. It is desired to reduce the number of requests to the database and cloud storage.
- I am designing the app for 1000 concurrent users, but I want the app to be scalable in the future for 10000 users. So please take care of performance.

User stories:
- user can create account with google (via firebase authentication)
- User can add multiple pets, each with name, species, gender, microchip_id (optional), breed (optional), weight (optional) and photo (optional). When adding a pet photo, the user will be able to center the photo on pets face and crop the photo. The flutter app will compress the photo to a reasonable size before uploading it to the cloud storage.
- User can create a family (and become an admin)
- Family admin can add another user to the family via e-mail, or FamilyID and password
- User can be an admin of multiple families
- User can be a member of multiple families
- There can be multiple admins of a family as well as multiple members of a family
- Admin can add multiple pets to the family
- Admin can make another user an admin of a family
- A pet can be assigned to only one family
- User can add events assigned to a pet so each family member would be notified with push notification, for example 10 AM feeding with medicine added, or 11 AM give medication
- User can add cyclic events for the pet/family
- User can add a reminder for the family, for example to buy food for the pet, or go to the veterinarian
- If a user will be added to existing family, he will see all previously set family events and pets and recieve push notifications
- User can turn off specific cyclic event notification only for him
- Admin can adjust family notifications settings - can set which member will receive which notification
- Some features will be available only for premium users
- User can add info to the pet journal with photo attached, for example "10:30 AM vomits (with vomits photo)"
- User can add to journal a PetCareRecord with all applicable fields, photos of a veterinarian's note, next_due_date, veterinarian, cost


Tech stack:
- Flutter 3.38.9 for mobile app
- Firebase cloud functions as a backend
- Firebase for database, authentication and push notifications
- Cloudflare R2 for photos and files storage
- To minimize Cloud Functions costs and improve speed, the app implements a local cache (e.g., `hive` or memory cache via Riverpod `keepAlive`)
- `flutter_riverpod` (Riverpod) for reactive state and dependency injection.

Project structure tree:
```
pet_companion/                # Root directory, folder containing this file
├── .gitignore                # Global gitignore (ignores IDE files, .venv, dart_tool, node_modules)
├── README.md                 # Main project documentation and local setup instructions
├── .github/                  # CI/CD pipelines (e.g., GitHub Actions)
│   └── workflows/            # Automated deployment scripts for mobile and firebase
│
├── mobile/                   # 📱 FLUTTER APP (The Client)
│   ├── android/              
│   ├── ios/                  
│   ├── web/                  # For rapid UI testing using Antigravity's Browser Agent
│   ├── lib/                  
│   │   ├── main.dart
│   │   ├── firebase_options.dart # Auto-generated by FlutterFire CLI
│   │   ├── core/             # Theme, constants, routing (e.g., GoRouter)
│   │   ├── features/         # UI screens organized by feature (auth, home, profile)
│   │   └── services/         # Logic for Firebase Auth, Firestore, and calling Cloud Functions
│   └── pubspec.yaml          
│
└── firebase/                 # 🔥 FIREBASE INFRASTRUCTURE & BACKEND
    ├── functions/            # Firebase Cloud Functions (Gen 2 - Python recommended for AI)
    │   ├── main.py           # Entry point for your Python cloud functions
    │   ├── requirements.txt  # Python dependencies (firebase-admin, requests, AI tools, etc.)
    │   ├── venv/             # Local Python virtual environment
    │   └── src/              # Complex backend logic separated into Python modules
    ├── firestore.rules       # Security rules for mobile app accessing Firestore (CRITICAL)
    ├── firestore.indexes.json# Database indexes for complex queries
    ├── firebase.json         # Tells Firebase CLI what files to deploy
    └── .firebaserc           # Links this folder to your Firebase Project ID
```