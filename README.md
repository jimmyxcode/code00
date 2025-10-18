# LifeEveryday

An iOS app (SwiftUI + Core Data + CloudKit) to track recurring life events (e.g., haircut, car wash, toothbrush changes).

## Features
- One-tap Quick Record
- Average interval, next due, countdown
- Elegant progress UI with glass-style design
- iCloud sync (NSPersistentCloudKitContainer)
- Safe local persistence
- Statistics and analytics

## Build
- Xcode 16+ / iOS 17+  
- Open `LifeEveryday.xcodeproj` and run **LifeEveryday** target.

## Structure
- `Logic/` — Stats & time conversions
- `UI/` — SwiftUI views and components
- `Persistence/` — Core Data & Sync management
- `Assets.xcassets/` — App icons and images

## Key Components
- **EventCardV2**: Main event display with progress bar
- **PillProgressBar**: Glass-style progress indicator
- **StatsEngine**: Statistical calculations and formatting
- **DataStore**: Core Data management
- **PersistenceController**: CloudKit integration

## License
MIT License - see LICENSE file for details.
