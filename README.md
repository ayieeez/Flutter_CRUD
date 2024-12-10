# Flutter_CRUD Application

This project is a Flutter-based CRUD (Create, Read, Update, Delete) application integrated with Firebase Realtime Database for backend services. The app allows users to manage equipment bookings with the ability to add, view, update, and delete bookings.

## Features

- Firebase Authentication for user login
- Firebase Realtime Database for data storage
- CRUD operations for managing equipment bookings
- Simple UI with navigation for CRUD operations

## Technologies Used

- **Flutter**: Cross-platform mobile framework for building the app
- **Firebase**: Real-time cloud database and authentication service
- **Dart**: Programming language for Flutter apps

## Prerequisites

Before you begin, ensure you have the following installed:

1. [Flutter](https://flutter.dev/docs/get-started/install)
2. [Dart](https://dart.dev/get-dart)
3. A Firebase project with Firebase Authentication and Realtime Database enabled
4. Android/iOS emulator or a physical device to run the app

## Setup Instructions

### Step 1: Clone the Repository

Clone this repository to your local machine:

```bash
git clone https://github.com/your-username/Flutter_CRUD.git
cd Flutter_CRUD
```

### Step 2: Install Dependencies

Install the required dependencies using the following command:

```bash
flutter pub get
```

### Step 3: Firebase Setup

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/) and create a new project (or use an existing one).
   
2. **Add Firebase to Your Flutter App**:
   - Follow the instructions in the Firebase console to add Firebase to your Flutter app. This includes:
     - Registering your app in Firebase.
     - Downloading the `google-services.json` for Android and placing it in the `android/app` directory.
     - For iOS, follow the steps in the Firebase setup documentation.

3. **Enable Firebase Services**:
   - Go to Firebase Authentication in the Firebase Console and enable the sign-in method you want (e.g., Email/Password).
   - Set up Firebase Realtime Database in Firebase Console to store and manage equipment booking data.

### Step 4: Initialize Firebase in Your Flutter App

Ensure Firebase is initialized in your `main.dart` file:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}
```

### Step 5: Run the App

Run the app on your emulator or physical device:

```bash
flutter run
```

### Step 6: Firebase Authentication

- On the login page (`login_page.dart`), users will be prompted to log in. Firebase Authentication is set up for user login.
  
### Step 7: CRUD Operations

This app performs basic CRUD operations on the equipment bookings using Firebase Realtime Database:

1. **Create Booking**: Allows users to add new equipment bookings.
2. **Read Bookings**: Displays a list of existing equipment bookings from the Realtime Database.
3. **Update Booking**: Users can update booking details.
4. **Delete Booking**: Allows users to delete a booking from the list.

## Project Structure

Here’s a breakdown of the main files and their functionality:

- **`main.dart`**: Initializes Firebase and sets up the initial screen (`LoginPage`).
- **`login_page.dart`**: Contains the login UI and Firebase authentication logic.
- **`sign_up_page.dart`**: Contains the sign-up page UI and logic for user registration.
- **`student_landing_page.dart`**: The landing page for students with CRUD operations for equipment bookings.
- **`staff_landing_page.dart`**: The landing page for staff with CRUD operations for equipment bookings.
- **`admin_landing_page.dart`**: The landing page for the admin to manage bookings, users, and other CRUD operations.

## Troubleshooting

### Firebase Initialization Issues

If Firebase initialization fails:

- Ensure the `google-services.json` file is correctly placed in the `android/app` directory.
- Check your Firebase project's settings and make sure Firebase is properly configured for Android/iOS.

### Firebase Authentication Issues

If authentication does not work:

- Verify that Firebase Authentication is enabled in your Firebase Console.
- Make sure the login method (Email/Password, Google, etc.) is configured correctly.

### Android/iOS Build Issues

- Make sure your Flutter environment is correctly set up by running `flutter doctor`.
- Ensure that you have the necessary tools for building on Android and iOS.
