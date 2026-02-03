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

## Architecture

### Clean Architecture

The project is organised into three strict layers per feature. The domain layer has zero dependency on Flutter or any external package — use cases and entities are plain Dart. The data layer implements the contracts the domain defines. The presentation layer consumes the data layer only through BLoC.

```
lib/
├── main.dart                   # App entry point, initialises DI then runs the app
├── injection_container.dart    # All get_it registrations (singletons + factories)
├── core/                       # Shared utilities and base classes
└── features/
    └── <feature_name>/
        ├── domain/             # Entities, repository interfaces, use cases
        ├── data/               # Models, datasources, concrete repository
        └── presentation/       # BLoC (event/state/bloc), pages, widgets
```

Current feature: **daily_reports** — tracks `LaborEvent` and `SafetyIncident` entities per site.

### SOLID Principles

- **Single Responsibility** — each use case class owns exactly one operation (`AddSiteEvent`, `DeleteSiteEvent`, `GetSiteEvents`, `SyncDailyReports`). `AppDatabase` owns only raw queries; `ReportRepositoryImpl` owns only the mapping between DB rows and domain entities; `DailyReportBloc` owns only UI state transitions.
- **Open/Closed** — `SiteEvent` is an abstract base class. Adding a new event type means extending `SiteEvent` with a new subclass; none of the existing use cases, repository, or BLoC need to change.
- **Liskov Substitution** — use cases accept `SiteEvent` and work correctly with either `LaborEvent` or `SafetyIncident` without type-checking. `ReportRepositoryImpl` is a drop-in replacement for the abstract `ReportRepository` contract.
- **Interface Segregation** — `ReportRepository` is a focused four-method interface scoped entirely to the daily_reports feature. No unrelated responsibilities are mixed in.
- **Dependency Inversion** — use cases depend on the abstract `ReportRepository`, never on `ReportRepositoryImpl` or `AppDatabase` directly. `DailyReportBloc` depends on use case classes, not on repositories. `injection_container.dart` is the only place that wires concrete types to their abstractions.

### Design Patterns

#### Singleton
`injection_container.dart` registers `AppDatabase`, `ReportRepository`, and all four use cases with `registerLazySingleton`. Each is instantiated once on first use and reused for the lifetime of the app. `GetIt.instance` itself (`sl`) is the singleton service locator that every part of the app resolves dependencies from.

```dart
sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()));
sl.registerLazySingleton<AddSiteEvent>(() => AddSiteEvent(sl()));
```

#### Factory
Used in two distinct places:

1. **BLoC registration** — `DailyReportBloc` is registered with `registerFactory`, so a fresh instance is created every time a new page resolves it. This prevents stale state from leaking between screens.

```dart
sl.registerFactory(() => DailyReportBloc(
  getSiteEvents: sl(),
  addSiteEvent: sl(),
  deleteSiteEvent: sl(),
));
```

2. **Entity creation from raw data** — `ReportRepositoryImpl._mapToEntity` reads a `type` discriminator column from the database row and constructs either a `LaborEvent` or a `SafetyIncident` accordingly. `LaborEventModel.fromJson` and `SafetyIncidentModel.fromJson` are the same pattern for JSON deserialisation.

## Unit Testing

Tests live in `test/` and mirror the `lib/` structure. The project uses **mocktail** for mocking and **flutter_test** as the test framework.

### Entity Tests (`test/features/daily_reports/domain/entities/site_event_test.dart`)

Pure unit tests with no mocks or dependencies. Cover the two things entities need to do correctly:

| Test | What it verifies |
|---|---|
| LaborEvent equality | Two `LaborEvent` instances with identical fields are `==` (Equatable contract) |
| SafetyIncident summary | `summary` getter includes the severity value |
| LaborEvent summary | `summary` getter includes worker count and description |

### Use Case Tests (`test/features/daily_reports/usecases/`)

Mock `ReportRepository` with mocktail. Each test isolates one use-case behaviour and verifies the repository is called or explicitly *not* called:

**add_site_event_test.dart**

| Test | What it verifies |
|---|---|
| Future timestamp | `AddSiteEvent` throws `ArgumentError`; `verifyNever` confirms the repository is never reached |
| Zero worker count | Same guard for `LaborEvent` with `workerCount == 0` |
| Valid event | Repository's `addSiteEvent` is called exactly once with the correct event |

**get_site_event_test.dart**

| Test | What it verifies |
|---|---|
| Stream delegation | `GetSiteEvents` returns the `Stream` from the repository unchanged; `verify` confirms `getEventsForSite` was called with the correct `siteId` |

### Running Tests

```bash
# All tests
flutter test

# Single test file
flutter test test/features/daily_reports/usecases/add_site_event_test.dart
```

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

### Lint

```bash
flutter analyze
```

## Platforms

Android, iOS, macOS, Linux, Windows, Web.
