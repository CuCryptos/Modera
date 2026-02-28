# Modera SwiftUI Prototype

This folder contains a SwiftUI iOS prototype for **Modera** focused on motion and feel.

## What is included

- Home (Balance View)
- Task Completion Moment
- Weekly Reset Ritual
- Reusable `BalanceRingView`
- Simple `BalanceViewModel` with sample data (`55/45` start)

## Run in Xcode

1. Open `Modera.xcodeproj` in Xcode.
2. Select the `Modera` scheme.
3. Choose an iOS Simulator target (iOS 17+ recommended).
4. Build and run.

## File map

- `ModeraApp.swift`: app entry
- `ContentView.swift`: `NavigationStack` root
- `Style.swift`: color tokens for the prototype
- `ViewModels/BalanceViewModel.swift`: state and balance math
- `Views/BalanceRingView.swift`: reusable animated ring
- `Views/HomeBalanceView.swift`: home screen
- `Views/TaskCompletionMomentView.swift`: task impact animation sequence
- `Views/WeeklyResetView.swift`: weekly reset flow and reflection prompts
