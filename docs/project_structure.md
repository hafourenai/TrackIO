# Project Structure

```
TrackIO/
├── android/                          # Android platform wrapper
│   ├── app/
│   │   ├── build.gradle.kts          # App-level Gradle config
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # App permissions & configuration
│   │       └── kotlin/com/trackio/app/MainActivity.kt
│   ├── build.gradle.kts              # Project-level Gradle config
│   └── settings.gradle.kts           # Gradle settings
│
├── docs/                             # Project documentation
│   ├── architecture.md
│   ├── features.md
│   ├── installation_guide.md
│   ├── project_structure.md
│   ├── technology_stack.md
│   └── troubleshooting.md
│
├── lib/                              # Main Dart source code
│   ├── main.dart                     # Application entry point
│   ├── app.dart                      # MaterialApp, router, shell (bottom nav)
│   │
│   ├── core/                         # Shared across all features
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # App name, version
│   │   │   ├── color_constants.dart       # Color palette
│   │   │   └── category_constants.dart    # Category defs, icons, colors
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Light & dark Material 3 themes
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart    # Rupiah formatting
│   │   │   └── date_formatter.dart        # Date formatting (Indonesian locale)
│   │   └── network/
│   │       └── connectivity_service.dart  # Internet connectivity check
│   │
│   ├── data/                         # Data layer
│   │   ├── database/
│   │   │   └── app_database.dart          # SQLite database init & schema
│   │   ├── models/
│   │   │   └── transaction_model.dart     # DB ↔ Entity mapping
│   │   └── repositories/
│   │       └── transaction_repository_impl.dart  # Repository implementation
│   │
│   ├── domain/                       # Domain layer (business logic)
│   │   ├── entities/
│   │   │   └── transaction.dart           # Core domain entity
│   │   ├── repositories/
│   │   │   └── transaction_repository.dart # Repository interface
│   │   └── usecases/
│   │       └── get_dashboard_data.dart     # Dashboard computation logic
│   │
│   └── features/                     # Feature modules (7 features)
│       │
│       ├── ai_chat/                  # AI Financial Advisor
│       │   ├── data/
│       │   │   └── gemini_service.dart     # Google Gemini API client
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── chat_provider.dart   # Chat state & API interaction
│       │       ├── screens/
│       │       │   └── chat_screen.dart     # Chat UI
│       │       └── widgets/
│       │           ├── chat_bubble.dart     # Message bubble
│       │           └── chat_input.dart      # Text input + send button
│       │
│       ├── dashboard/                # Home / Overview
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── dashboard_provider.dart  # Reactive dashboard data
│       │       ├── screens/
│       │       │   └── dashboard_screen.dart    # Main dashboard
│       │       └── widgets/
│       │           ├── balance_card.dart        # Balance summary
│       │           ├── category_pie_chart.dart  # Expense by category
│       │           ├── income_expense_chart.dart# Weekly bar chart
│       │           ├── prediction_card.dart     # Prediction link
│       │           ├── score_card.dart          # Score link
│       │           └── summary_section.dart     # Monthly summary
│       │
│       ├── ocr/                      # Receipt Scanner
│       │   ├── data/
│       │   │   └── ocr_service.dart         # ML Kit text recognition
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── ocr_provider.dart     # OCR state management
│       │       ├── screens/
│       │       │   └── ocr_screen.dart       # Scanning UI
│       │       └── widgets/
│       │           ├── image_source_picker.dart  # Camera/gallery picker
│       │           └── ocr_result_card.dart     # Editable result form
│       │
│       ├── prediction/               # Spending Prediction
│       │   ├── data/
│       │   │   └── prediction_engine.dart   # Prediction calculation
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── prediction_provider.dart  # Prediction state
│       │       ├── screens/
│       │       │   └── prediction_screen.dart    # Prediction UI
│       │       └── widgets/
│       │           └── prediction_chart.dart     # Daily expense line chart
│       │
│       ├── recommendation/           # Smart Recommendations
│       │   ├── data/
│       │   │   └── recommendation_engine.dart   # Rule-based engine
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── recommendation_provider.dart
│       │       ├── screens/
│       │       │   └── recommendation_screen.dart
│       │       └── widgets/
│       │           └── recommendation_card.dart  # Insight card
│       │
│       ├── score/                    # Financial Health Score
│       │   ├── data/
│       │   │   └── score_calculator.dart     # Score algorithm
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── score_provider.dart
│       │       ├── screens/
│       │       │   └── score_screen.dart      # Score UI
│       │       └── widgets/
│       │           ├── score_breakdown.dart   # Component bars
│       │           └── score_gauge.dart       # Circular gauge
│       │
│       └── transactions/             # Transaction CRUD
│           └── presentation/
│               ├── providers/
│               │   └── transaction_provider.dart  # List + filter state
│               ├── screens/
│               │   ├── transaction_list_screen.dart # List with search & filters
│               │   └── add_edit_transaction_screen.dart  # Add/Edit form
│               └── widgets/
│                   ├── category_picker.dart   # Category bottom sheet
│                   ├── filter_widget.dart     # Filter chips
│                   └── transaction_tile.dart  # Dismissible list tile
│
├── test/                             # Tests
│   └── widget_test.dart
│
├── pubspec.yaml                      # Flutter package manifest
├── pubspec.lock                      # Dependency lock file
├── analysis_options.yaml             # Dart linting rules
├── .gitignore                        # Git ignore rules
├── .metadata                         # Flutter project metadata
└── README.md                         # Project overview
```
