# YouthFinance Flutter App

The cross-platform mobile client for YouthFinance — built with Flutter and Riverpod.

## What's Inside

This Flutter app provides a beautiful, responsive mobile experience for the YouthFinance financial wellness platform. It follows a **feature-based architecture** where each domain (auth, budgets, goals, etc.) lives in its own folder with clear separation of presentation, business logic, and data layers.

## Tech Stack

- **Framework:** Flutter 3.12+
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Networking:** Dio
- **Secure Storage:** flutter_secure_storage
- **Charts:** fl_chart
- **Animations:** flutter_animate
- **Icons:** Lucide Icons

## Project Structure

```
frontend/
└── lib/
    └── features/
        ├── auth/           # Login, signup, token management
        ├── home/           # Dashboard, quick actions, insights
        ├── transactions/   # Income & expense flows
        ├── budget/         # Monthly budget management
        ├── goals/          # Savings goals & progress
        ├── savings/        # Savings contributions
        ├── fun_fund/       # Discretionary fun funds
        ├── emergency/      # Emergency fund
        ├── investment/     # External investments
        ├── analytics/      # Spending insights, trends, projections
        ├── learning/       # Financial education content
        ├── notifications/  # Alert management
        ├── profile/        # User profile & settings
        ├── splash/         # App launch screen
        └── shell/          # App shell & navigation
```

## Getting Started

See the main [YouthFinance README](../README.md) for full project setup instructions.

Quick commands:

```bash
flutter pub get
flutter run
```

## Development Notes

- Each feature folder contains `model/`, `provider/` (or `repository/`), and `presentation/` layers.
- API responses are deserialized into strongly-typed models.
- State changes propagate via Riverpod providers, which invalidate and refresh automatically after mutations.
