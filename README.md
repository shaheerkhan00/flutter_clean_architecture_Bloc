# sitelog

A Flutter application for logging and tracking events on construction sites. Supports recording labor activities and safety incidents per site, with offline-first local storage and cloud synchronisation via Supabase.

## Tech Stack

| Layer | Technology |
|---|---|
| UI & State | Flutter, BLoC |
| Dependency Injection | get_it + injectable |
| Local Database | Drift (SQLite) |
| Networking | Dio + Retrofit |
| Cloud Backend | Supabase |
| Serialisation | json_serializable, freezed |

## Project Structure

Follows **Clean Architecture** with a feature-based layout:

```
lib/
├── main.dart                   # App entry point
├── injection.dart              # Dependency injection registration
├── core/                       # Shared utilities and base classes
└── features/
    └── <feature_name>/
        ├── domain/             # Entities, repository interfaces, use cases
        ├── data/               # Models, datasources, repository implementations
        └── presentation/       # BLoC, pages, widgets
```

Current feature: **daily_reports** — tracks `LaborEvent` and `SafetyIncident` entities per site.

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK ^3.9.2
- A Supabase project (for cloud sync)

### Setup

```bash
# Install dependencies
flutter pub get

# Generate serialisation / DI / database code
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run

```bash
flutter run
```

### Test

```bash
# All tests
flutter test

# Single test file
flutter test test/features/daily_reports/usecases/add_site_event_test.dart
```

### Lint

```bash
flutter analyze
```

## Platforms

Android, iOS, macOS, Linux, Windows, Web.
