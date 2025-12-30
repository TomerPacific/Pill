# Copilot Instructions for Pill Repository

## Repository Overview

**Pill** is a Flutter mobile application that helps users track and manage their daily prescribed medication. It reminds users whether they have taken their pills and provides a clean interface for pill management. The app is published on Google Play Store and supports both Android and iOS platforms.

### Key Information
- **Type**: Flutter mobile application (Android/iOS)
- **Source Code Size**: ~1.4MB source directory, 23 Dart files
- **Framework**: Flutter (stable channel)
- **Language**: Dart SDK >=3.0.0 <4.0.0
- **State Management**: flutter_bloc (^9.1.0)
- **Target Platforms**: 
  - Android: compileSdk 35, targetSdk 35, minSdk determined by Flutter SDK
  - iOS: Standard Flutter iOS configuration

## Project Architecture

### Directory Structure
```
Pill/
├── lib/                      # Main application code
│   ├── bloc/                 # BLoC state management
│   │   ├── clearPills/      # Pill clearing logic
│   │   ├── pill/            # Pill management logic
│   │   └── theme/           # Theme management
│   ├── model/               # Data models
│   │   ├── pill_taken.dart
│   │   └── pill_to_take.dart
│   ├── page/                # UI pages/screens
│   │   ├── main_page.dart
│   │   └── settings_page.dart
│   ├── service/             # Business logic services
│   │   ├── date_service.dart
│   │   └── shared_preferences_service.dart
│   ├── widget/              # Reusable UI components
│   │   ├── adding_pill_form.dart
│   │   ├── day_widget.dart
│   │   ├── pill_taken_widget.dart
│   │   └── pill_to_take_widget.dart
│   ├── main.dart            # Application entry point
│   ├── constants.dart       # Application constants
│   ├── custom_icons.dart    # Custom icon definitions
│   └── utils.dart           # Utility functions
├── test/                    # Test files
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── assets/                  # Images, icons, fonts
├── docs/                    # Documentation (privacy policy)
├── web/                     # Web platform support files
└── pubspec.yaml            # Dependencies and project config
```

### Key Components
- **Entry Point**: `lib/main.dart` - Initializes services and sets up BLoC providers
- **State Management**: Uses BLoC pattern with three main blocs (PillBloc, ThemeBloc, ClearPillsBloc)
- **Data Persistence**: SharedPreferences for local storage
- **Constants**: Centralized in `lib/constants.dart` (keys, titles, dimensions)
- **Configuration**: `pubspec.yaml` for dependencies and assets

### Platform-Specific Configuration
- **Android**: 
  - Gradle 8.11.1
  - Kotlin 2.1.0
  - Java 17 (sourceCompatibility/targetCompatibility)
  - Android Gradle Plugin 8.9.1
- **iOS**: Standard Flutter iOS configuration

## Build & Validation Process

### Prerequisites
- Flutter SDK (stable channel recommended)
- Java 17 (for Android builds)
- Android SDK with API level 35

### Essential Commands (In Order)

**ALWAYS run these commands in sequence when making changes:**

1. **Install Dependencies** (ALWAYS run first after cloning or when pubspec.yaml changes):
   ```bash
   flutter pub get
   ```
   - Downloads and updates all packages
   - Required before any other Flutter command
   - Takes ~10-30 seconds

2. **Analyze Code** (ALWAYS run before committing):
   ```bash
   flutter analyze
   ```
   - Performs static code analysis
   - Checks for errors, warnings, and code quality issues
   - Must complete with no errors for CI to pass
   - Takes ~5-10 seconds

3. **Run Tests** (ALWAYS run before committing):
   ```bash
   flutter test
   ```
   - Runs all unit and widget tests in `/test` directory
   - Must pass all tests for CI to pass
   - Takes ~10-20 seconds
   - Tests include: pill_widget_test, utils_test, date_service_test, shared_preferences_test, adding_pill_form_test

### Complete Build Sequence
To validate changes completely, run in this exact order:
```bash
flutter pub get
flutter analyze
flutter test
```

### CI/CD Pipeline
The repository uses GitHub Actions for continuous integration:
- **Trigger**: On pull_request events
- **Workflow File**: `.github/workflows/flutter_build.yml`
- **Steps**:
  1. Checkout code
  2. Setup Java 17 (Zulu distribution)
  3. Setup Flutter (stable channel)
  4. Run `flutter pub get`
  5. Run `flutter analyze`
  6. Run `flutter test`

**IMPORTANT**: All three steps must succeed for the build to pass. The workflow takes approximately 60-90 seconds to complete.

## Common Development Tasks

### Making Code Changes
1. Always run `flutter pub get` if dependencies changed
2. After making changes, run `flutter analyze` to catch issues early
3. Update or add tests in `/test` directory if needed
4. Run `flutter test` to validate all tests pass
5. Commit only after all validation passes

### Adding Dependencies
1. Edit `pubspec.yaml` to add the new dependency
2. Run `flutter pub get` to download it
3. Update code to use the dependency
4. Run full validation sequence (analyze + test)

### Testing Guidelines
- Tests are located in `/test` directory
- Test file naming: `*_test.dart`
- Widget tests use `TestWidgetsFlutterBinding.ensureInitialized()`
- SharedPreferences mocks: Use `SharedPreferences.setMockInitialValues({})`
- Current test coverage includes widgets, services, and utilities

## Important Notes & Best Practices

### State Management
- Uses BLoC pattern consistently throughout the app
- All BLoCs are provided at the app level in `main.dart`
- Events and states are defined per BLoC

### Code Style
- No specific linter configuration file, relies on Flutter defaults
- Constants are centralized in `constants.dart`
- Utility functions in `utils.dart`

### Data Persistence
- All persistent data uses SharedPreferences
- Date-based tracking for pill management
- Keys are defined as constants in `constants.dart`

### Assets
- Images: `assets/images/` (pill_to_take.png, pill_taken.png)
- Custom fonts: `fonts/CustomIcons.ttf`
- Icons: Custom launcher icons configured via flutter_launcher_icons

### Known Build Requirements
- Java 17 is REQUIRED (Java 11 will cause build failures)
- Flutter stable channel is recommended
- Android builds require Kotlin 2.1.0 and Android Gradle Plugin 8.9.1

### Troubleshooting
If builds fail:
1. Ensure Java 17 is installed and active
2. Run `flutter clean` then `flutter pub get`
3. Check that all tests in `/test` directory pass locally
4. Verify `flutter analyze` shows no errors

## Using These Instructions
These instructions were generated through thorough exploration and validation of the repository's build process and CI workflows. When working on this codebase:
- Follow the documented command sequence for reliable builds
- The analyze and test steps are required - CI will fail without them
- These instructions cover the standard development workflow
- Consult the source code and CI logs for deeper understanding or when troubleshooting issues
- The build process is well-tested and documented above

## Quick Reference

**File Locations**:
- Main entry: `lib/main.dart`
- Constants: `lib/constants.dart`
- Tests: `test/`
- Android config: `android/app/build.gradle`
- Dependencies: `pubspec.yaml`
- CI workflow: `.github/workflows/flutter_build.yml`

**Critical Commands**:
```bash
flutter pub get       # Install/update dependencies
flutter analyze       # Static analysis (must pass)
flutter test          # Run tests (must pass)
```

**CI Status**: Check that all three commands succeed before merging PRs.
