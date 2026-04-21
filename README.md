# VibeCheck AI

A modern Flutter camera app with a purple neon theme, featuring Snapchat-style photo capture and history management.

## Features

- **Camera**: Snapchat-inspired camera interface with front/back camera toggle
- **Purple Neon Theme**: Modern, dark theme with purple and neon accents
- **Photo History**: Grid view of all captured photos with timestamps
- **Photo Detail View**: Full-screen photo viewer with zoom and delete functionality
- **Persistent Storage**: Photos are saved locally and persist across app restarts

## Getting Started

### Prerequisites

- Flutter SDK 3.10.3 or higher
- Android Studio / Xcode for mobile development
- A physical device or emulator with camera support

### Installation

1. Clone or navigate to the project directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Permissions

The app requires camera permissions:
- **Android**: Camera permission is configured in `AndroidManifest.xml`
- **iOS**: Camera and photo library permissions are configured in `Info.plist`

## Project Structure

```
lib/
├── main.dart                          # App entry point and theme configuration
├── screens/
│   ├── home_screen.dart              # Bottom navigation container
│   ├── camera_screen.dart            # Camera capture interface
│   ├── history_screen.dart           # Photo grid view
│   └── photo_detail_screen.dart      # Full-screen photo viewer
└── services/
    └── photo_service.dart            # Photo storage management
```

## Theme Colors

- Primary: `#9D4EDD` (Purple)
- Secondary: `#E0AAFF` (Light Purple/Neon)
- Background: `#10002B` (Dark Purple)
- Surface: `#240046` (Medium Purple)

## Usage

1. **Take Photos**: Tap the large purple button on the camera screen
2. **Switch Camera**: Use the flip icon to switch between front and back cameras
3. **View History**: Navigate to the History tab to see all captured photos
4. **View Details**: Tap any photo to view it full-screen with zoom
5. **Delete Photos**: Use the delete button in the photo detail view
