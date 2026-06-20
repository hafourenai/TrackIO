# Technology Stack

## Overview

| Category | Technology | Version | Purpose |
|---|---|---|---|
| **Language** | Dart | 3.0+ | Type-safe, null-safe programming language |
| **UI Framework** | Flutter | 3.0+ | Cross-platform mobile UI framework |
| **Design System** | Material 3 | — | Modern, adaptive design language |
| **State Management** | Riverpod | 2.6 | Compile-time safe dependency injection & state management |
| **Routing** | GoRouter | 14.8 | Declarative, type-safe routing with nested navigation |
| **Database** | SQLite (sqflite) | 2.4 | Local relational database |
| **Charts** | fl_chart | 0.69 | Lightweight charting (bar, pie, line) |
| **AI** | Google Generative AI | Latest | Gemini 2.5 Flash API |
| **OCR** | Google ML Kit | 0.13 | On-device text recognition |
| **Image Picking** | image_picker | 0.8 | Camera & gallery access |
| **Preferences** | shared_preferences | 2.4 | Simple key-value persistence |
| **Connectivity** | connectivity_plus | 6.1 | Network state monitoring |
| **Date/Number** | intl | 0.19 | Indonesian locale formatting |

---

## Detailed Stack Analysis

### Dart 3.0+

**Why Dart:**
- Type-safe with null safety — eliminates null reference errors at compile time
- JIT compilation for fast development (hot reload) + AOT for production performance
- Rich standard library with async/await, streams, and collections

**Usage in TrackIO:**
- All business logic, UI, and data access written in Dart
- Records, patterns, and sealed classes used where appropriate
- `async`/`await` throughout for database and API calls

---

### Flutter with Material 3

**Why Flutter:**
- Single codebase for Android and iOS (future-proof)
- Hardware-accelerated rendering via Skia/Impeller — no WebView bridge
- Rich widget library with customizable theming
- Hot reload for instant development feedback

**Usage in TrackIO:**
- All UI built with Flutter widgets (no HTML/WebView)
- Material 3 theming with `ColorScheme.fromSeed()`
- Dark and light mode support following system theme

---

### Riverpod 2.x

**Why Riverpod (over Provider / BLoC):**
- **Compile-time safety** — provider name typos caught at compile time
- **No BuildContext dependency** — providers work outside widgets
- **Fine-grained reactivity** — only rebuild widgets that depend on changed data
- **Built-in loading/error states** via `AsyncValue`

**Key providers used:**

| Provider | Count | Purpose |
|---|---|---|
| `Provider` | 3 | Singleton services & controllers |
| `StreamProvider` | 2 | Reactive data streams (dashboard + transactions) |
| `StateNotifierProvider` | 2 | Mutable state (chat + OCR) |
| `StateProvider` | 4 | Filter/search state |
| `FutureProvider` | 3 | Async computations (score, prediction, recommendation) |

---

### GoRouter

**Why GoRouter:**
- Declarative route definitions — all routes in one place (`app.dart`)
- `ShellRoute` for persistent bottom navigation with per-tab state preservation
- `NoTransitionPage` for instant tab switching
- Type-safe path parameters (e.g., `/transactions/edit/:id`)

---

### SQLite (sqflite)

**Why SQLite:**
- **Offline-first** — no internet required for core features
- **Zero setup** — no server, no cloud account
- **Relational** — supports efficient queries, indexes, and aggregations

**Database details:**
- Single table `transactions` with 8 columns
- 3 indexes for query performance (`date`, `type`, `category`)
- Balance, metrics computed via Dart queries, not SQL aggregation

---

### fl_chart

**Why fl_chart:**
- Pure Dart — no native dependencies
- Supports bar, pie, line, and scatter charts
- Lightweight (no WebView)
- Customizable colors, touch interactions, animations

**Charts in TrackIO:**
| Chart | Type | Data |
|---|---|---|
| `IncomeExpenseChart` | Bar chart | 4 weekly expense buckets |
| `CategoryPieChart` | Pie/donut | Expense by category |
| `PredictionChart` | Line chart | Daily expenses over month |

---

### Google Generative AI (Gemini)

**Why Gemini:**
- **Free tier** — sufficient for personal use
- **Bahasa Indonesia support** — responds in Indonesian
- **Large context window** — can process entire financial context
- **API key based** — no OAuth complexity

**Model:** `gemini-2.5-flash` — fast, cost-effective for conversational use cases

---

### Google ML Kit Text Recognition

**Why ML Kit:**
- **On-device processing** — no internet required, no data leaves the device
- **High accuracy** — optimized for printed text on receipts
- **Fast** — results in under 2 seconds on modern devices

---

### Architecture Principles

| Principle | Application |
|---|---|
| **Clean Architecture** | 3-layer separation with dependency inversion |
| **Single Source of Truth** | Database is the SSoT; cache is derived |
| **Unidirectional Data Flow** | UI → Action → Provider → Repository → DB |
| **Reactive** | Streams propagate changes to all listeners |
| **Local-First** | All data stored locally; network optional |
