# Tenant Management System

A Flutter Android application for landlords to manage tenants, generate bills, and track payments.

## Features

- Multi-tenant management with separate login for landlords and tenants
- Automated bill generation with advance balance tracking
- Payment status tracking (Paid/Partial/Unpaid)
- Month-to-month balance carryover
- Secure authentication with Firebase

## Tech Stack

- **Flutter** - Cross-platform framework
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Provider** - State management

## Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Android Studio](https://developer.android.com/studio) or VS Code
- [Firebase Account](https://firebase.google.com/)
- Android device or emulator

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/aliyan-rehman/tenant-management-system.git
cd tenant-management-system
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and create a new project
3. Enable **Email/Password** authentication:
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password**
4. Create **Firestore Database**:
   - Go to **Firestore Database** → **Create database**
   - Start in **test mode**

#### Add Android App to Firebase

1. In Firebase Console, click "Add app" → Select Android
2. Enter package name: `com.example.tenant_mgmt_sys`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

#### Configure Firebase in the App
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration
flutterfire configure
```

Select your Firebase project when prompted.

#### Setup Auth Service

1. Copy the template file:
```bash
   cp lib/core/services/auth_service.dart.template lib/core/services/auth_service.dart
```

2. Get your Firebase Web API Key:
   - Go to Firebase Console → Project Settings → General
   - Scroll to "Your apps" section
   - Copy the "Web API Key"

3. Open `lib/core/services/auth_service.dart`

4. Replace the API key:
```dart
   static const String _apiKey = "YOUR_FIREBASE_WEB_API_KEY_HERE";
```

### 4. Run the App
```bash
flutter run
```

## Project Structure
```
lib/
├── core/
│   ├── providers/       # State management
│   ├── services/        # Firebase services
│   └── utils/           # Helper functions
├── screens/
│   ├── auth/           # Login & Register
│   ├── landlord/       # Tenant management
│   └── billing/        # Bill generation
├── widgets/            # Reusable components
└── main.dart
```

## Security Notes

**Important:** The following files contain sensitive data and are NOT included in this repository:

- `android/app/google-services.json` - Download from Firebase Console
- `lib/firebase_options.dart` - Generate with `flutterfire configure`
- `lib/core/services/auth_service.dart` - Copy from template and add your API key

These files are listed in `.gitignore` and must be created locally following the setup instructions above.

## Firestore Security Rules

Update your Firestore rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /landlords/{landlordId} {
      allow read, write: if request.auth != null && request.auth.uid == landlordId;
      
      match /tenants/{houseNo} {
        allow read: if request.auth != null;
        allow write: if request.auth != null && request.auth.uid == landlordId;
        
        match /TenantBills/{billId} {
          allow read: if request.auth != null;
          allow write: if request.auth != null && request.auth.uid == landlordId;
        }
      }
    }
  }
}
```

## Database Structure
```
Firestore:
├── users/{userId}
│   ├── name, email, role
│   └── landlordId (for tenants)
│
└── landlords/{landlordId}
    └── tenants/{houseNo}
        ├── Tenant details
        └── TenantBills/{monthYear}
            └── Bill details
```

## Common Issues

**Issue: "No Firebase App has been created"**
- Solution: Run `flutterfire configure` again

**Issue: Build fails**
- Solution: Ensure `google-services.json` is in `android/app/`
- Run `flutter clean` then `flutter pub get`

**Issue: Firestore permission denied**
- Solution: Update Firestore security rules (see above)

**Issue: "API key not valid"**
- Solution: Verify you replaced the API key in `auth_service.dart` with your actual Firebase Web API Key

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

**Aliyan Rehman**
- GitHub: [@aliyan-rehman](https://github.com/aliyan-rehman)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

⭐ **Star this repo if you find it helpful!**
