# LifeEveryday

iOS app (SwiftUI + Core Data + CloudKit) to track recurring life events (haircut, car wash, toothbrush, etc.).

## Features
- One-tap Quick Record
- Avg interval / Next due / Countdown
- Elegant progress bar UI
- iCloud sync (NSPersistentCloudKitContainer)

## Build
- Xcode 16+ / iOS 17+
- Open `LifeEveryday.xcodeproj` (or `.xcworkspace`) and run **LifeEveryday** target.

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