# R.T. Lapeña Construction & Supply Daily Time Record App

A Flutter mobile application for managing daily construction reports with local SQLite storage and PDF export functionality.

## Features

- **Local Storage**: All data stored locally using SQLite database
- **Daily Reports**: Create and manage daily construction reports
- **Weather Logging**: Track weather conditions throughout work shifts
- **Work Progress**: Log hourly work activities with photo attachments
- **Issue Management**: Document issues and safety concerns with annotated photos
- **PDF Export**: Generate and share professional PDF reports
- **Photo Annotation**: Draw on photos to highlight issues and problems
- **Offline Operation**: Works completely offline, no internet required

## Architecture

### Models
- `DailyReport`: Main report data model
- `WeatherEntry`: Weather condition tracking
- `WorkEntry`: Work progress with photos
- `IssuePhoto`: Safety/issue documentation

### Services
- `DatabaseService`: SQLite database operations
- `PdfService`: PDF generation and sharing

### Screens
- `ReportFormScreen`: Main form for creating/editing reports
- `ReportsListScreen`: List of saved reports
- `SplashScreen`: App startup screen

### Widgets
- `WeatherLogWidget`: Interactive weather condition selector
- `WorkLogWidget`: Work progress logging with photo capture
- `IssuePhotoWidget`: Issue photo capture with drawing annotation

## Setup Instructions

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Build for Release**
   ```bash
   # For Android
   flutter build apk --release
   
   # For iOS
   flutter build ios --release
   ```

## Dependencies

- `sqflite`: Local SQLite database
- `path_provider`: File system access
- `image_picker`: Camera integration
- `pdf`: PDF document generation
- `printing`: PDF sharing and printing
- `signature`: Drawing/annotation on photos
- `share_plus`: File sharing
- `permission_handler`: Camera/storage permissions
- `intl`: Date formatting
- `flutter_colorpicker`: Color selection for annotations

## Permissions

### Android
- Camera access for photo capture
- Storage access for file management

### iOS
- Camera usage for photo capture
- Photo library access for image selection

## Database Schema

```sql
CREATE TABLE daily_reports(
  id TEXT PRIMARY KEY,
  report_date TEXT NOT NULL,
  unit_type TEXT NOT NULL,
  contractor_name TEXT NOT NULL,
  block_number TEXT NOT NULL,
  lot_number TEXT NOT NULL,
  weather_log TEXT NOT NULL,      -- JSON array
  work_log TEXT NOT NULL,         -- JSON array
  issue_photos TEXT NOT NULL,     -- JSON array
  personnel_count INTEGER NOT NULL,
  issues TEXT NOT NULL,
  safety_notes TEXT NOT NULL,
  timestamp TEXT NOT NULL
);
```

## Data Structure

### Weather Log
```json
[
  {
    "time": "7:30 - 8:30 AM",
    "group": "inner",
    "condition": "fair"
  }
]
```

### Work Log
```json
[
  {
    "time": "7:30 - 8:30 AM",
    "group": "inner", 
    "log": "Foundation work started",
    "photos": [
      {
        "id": "photo_12345",
        "url": "/path/to/photo.jpg",
        "name": "foundation_work.jpg"
      }
    ]
  }
]
```

### Issue Photos
```json
[
  {
    "id": "issue_12345",
    "url": "/path/to/annotated_photo.png"
  }
]
```

## Usage Flow

1. **Create New Report**: Fill in project details (date, contractor, block/lot)
2. **Weather Logging**: Tap weather status buttons to cycle through conditions
3. **Work Progress**: Add work descriptions and photos for each time slot
4. **Issues & Safety**: Document problems with annotated photos
5. **Save Report**: Store locally in SQLite database
6. **Export PDF**: Generate professional report for sharing

## File Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App-wide constants and themes
├── models/
│   └── daily_report.dart       # Data models
├── services/
│   ├── database_service.dart   # SQLite operations
│   └── pdf_service.dart        # PDF generation
├── screens/
│   ├── report_form_screen.dart # Main form screen
│   └── reports_list_screen.dart # Reports list
├── widgets/
│   ├── weather_log_widget.dart # Weather tracking
│   ├── work_log_widget.dart    # Work progress logging
│   └── issue_photo_widget.dart # Issue photo annotation
├── utils/
│   └── app_utils.dart          # Utility functions
└── main.dart                   # App entry point
```

## Customization

### Colors
Edit `lib/constants/app_constants.dart` to change the app color scheme:
```dart
class AppColors {
  static const Color primary = Color(0xFFA97142);  // Bronze theme
  static const Color primaryDark = Color(0xFF8A5F36);
  // ... other colors
}
```

### Weather Conditions
Add new weather types in `app_constants.dart`:
```dart
class WeatherConditions {
  static const Map<String, WeatherInfo> weatherMap = {
    'sunny': WeatherInfo(name: 'Sunny', color: Colors.orange, textColor: Colors.white),
    // ... other conditions
  };
}
```

### Time Slots
Modify work hour slots in `app_constants.dart`:
```dart
class TimeSlots {
  static const List<TimeSlotInfo> slots = [
    TimeSlotInfo(label: '7:00 - 8:00 AM', group: 'morning'),
    // ... other slots
  ];
}
```

## Notes

- All data is stored locally - no cloud synchronization
- Photos are stored as Base64 in the database for simplicity
- PDF generation uses the printing package for cross-platform compatibility
- Drawing on photos creates new annotated images stored locally
- App works completely offline after installation

## Development

To modify the app:

1. Update models in `models/` directory
2. Modify database schema in `database_service.dart`
3. Update UI components in `widgets/` directory
4. Customize PDF layout in `pdf_service.dart`
5. Add new screens in `screens/` directory

The app follows Flutter best practices with clear separation of concerns between models, services, and UI components.
