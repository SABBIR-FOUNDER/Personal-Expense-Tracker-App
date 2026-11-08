# Personal Expense Tracker

A Flutter Android application for recording daily income and expenses. It stores transactions locally using SQLite through the `sqflite` package, so entries remain available after the app is closed and reopened.

## Features

- Dashboard summary for total income, total expense and current balance.
- Add income or expense transactions with title, amount, category, type and date.
- View the full transaction list, ordered by date (newest first).
- Open transaction details, edit existing records or delete them after confirmation.
- Form validation for title, positive numeric amount, category and transaction type.
- Local SQLite persistence using `expense_tracker.db` and the `transactions` table.
- Responsive Material 3 interface.

## Technology

- Flutter / Dart
- Material Design 3
- `sqflite` for SQLite storage
- `path` for database file paths

No server, login, network connection or cloud database is required.

## Database schema

```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  amount REAL NOT NULL CHECK (amount > 0),
  category TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  date TEXT NOT NULL
);
```

The database is created automatically on the first app launch in the platform's application database directory.

## Requirements

- Flutter SDK (the project was prepared for Flutter 3.47.x / Dart 3.13.x).
- Android Studio or VS Code with the Flutter and Dart extensions.
- Android SDK and an Android emulator or physical Android device.
- Java 17 for the included Android Gradle configuration.

## Run the app

1. Extract the project ZIP.
2. Open the `expense_tracker` folder (the folder containing `pubspec.yaml`) in Android Studio or VS Code.
3. Open a terminal in that folder and run:

   ```bash
   flutter doctor -v
   flutter pub get
   flutter run
   ```

`flutter pub get` resolves the packages and creates/updates `pubspec.lock` for the installed Flutter/Dart SDK. Machine-specific `android/local.properties` is intentionally not included; Flutter generates it for your computer.

## Run tests and analysis

```bash
dart format .
flutter analyze
flutter test
```

## Build a debug APK

```bash
flutter build apk --debug
```

APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Upload to GitHub

Create an empty repository on GitHub, then run these commands from the project root:

```bash
git init
git add .
git commit -m "Initial Personal Expense Tracker app"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

Replace the remote URL with your own repository URL. The project has not been published to GitHub automatically.
