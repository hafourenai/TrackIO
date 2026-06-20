# Architecture Overview

TrackIO follows **Clean Architecture** principles with three distinct layers, ensuring separation of concerns, testability, and maintainability.

---

## Layer Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│                                                                 │
│  ┌─────────────────┐  ┌──────────────────┐  ┌───────────────┐  │
│  │     Screens      │  │     Widgets      │  │   Providers    │  │
│  │  (UI Pages)      │  │  (Reusable UI)   │  │  (Riverpod)    │  │
│  └────────┬────────┘  └────────┬─────────┘  └───────┬───────┘  │
│           │                    │                      │          │
│           └────────────────────┴──────────────────────┘          │
│                              │                                    │
│                              ▼ (watches / reads)                  │
│                                                                   │
├─────────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                                │
│                                                                   │
│  ┌────────────────────┐  ┌──────────────────┐  ┌─────────────┐  │
│  │     Entities       │  │  Repository Intfs │  │  Use Cases  │  │
│  │  (Transaction,     │  │  (TransactionRepo │  │ (GetDashboard│  │
│  │   DashboardData)   │  │   ScoreRepository)│  │  Data, etc)  │  │
│  └────────────────────┘  └──────────────────┘  └─────────────┘  │
│                              │                                    │
│                              ▼ (implements)                       │
├─────────────────────────────────────────────────────────────────┤
│                       DATA LAYER                                 │
│                                                                   │
│  ┌────────────────────┐  ┌──────────────────┐  ┌─────────────┐  │
│  │     Database       │  │    Models        │  │  Repository  │  │
│  │  (SQLite/sqflite)  │  │ (TransactionModel│  │   Impls      │  │
│  │                    │  │  → Entity mapper)│  │              │  │
│  └────────────────────┘  └──────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Write Operation (e.g., adding a transaction)

```
User taps "Save"
       │
       ▼
Screen calls Provider (TransactionController.addTransaction)
       │
       ▼
Provider → Repository.saveTransaction()
       │
       ▼
Repository → Database.insert() → invalidates cache → _emit()
       │
       ▼
StreamController<List<Transaction>>.add(newData)
       │
       ▼
StreamProvider emits updated data
       │
       ▼
All listening Widgets rebuild automatically
```

### Read Operation (e.g., loading dashboard)

```
DashboardScreen builds
       │
       ▼
ref.watch(dashboardDataProvider)
       │
       ▼
StreamProvider subscribes to watchTransactions() stream
       │
       ▼
Repository yields current data from DB cache
       │
       ▼
asyncMap transforms data → GetDashboardData.execute()
       │
       ▼
DashboardData emitted → UI renders
```

---

## State Management: Riverpod

| Provider Type | Usage | Example |
|---|---|---|
| `Provider` | Singleton services & dependencies | `transactionRepositoryProvider` |
| `StreamProvider` | Reactive data streams | `dashboardDataProvider`, `transactionListStreamProvider` |
| `StateNotifierProvider` | Mutable state with methods | `chatProvider`, `ocrProvider` |
| `StateProvider` | Simple state values | `transactionSearchQueryProvider` |
| `FutureProvider` | Async operations | `financialScoreFutureProvider` |

### Stream-Based Reactivity

The core of the app's reactivity is a **broadcast stream controller** in `TransactionRepositoryImpl`:

```dart
// Repository emits data after every mutation
Stream<List<Transaction>> watchTransactions() async* {
  await _loadFromDb();
  yield List.from(_cache);
  await for (final txns in _controller.stream) {
    yield txns;
  }
}
```

Both the **transaction list** and **dashboard** listen to the same stream, ensuring all screens stay in sync automatically.

---

## Routing: GoRouter

```
Shell Routes (bottom navigation tabs):
  /                 → DashboardScreen
  /transactions     → TransactionListScreen
  /recommendation   → RecommendationScreen
  /chat             → ChatScreen

Full-screen push routes (no bottom nav):
  /transactions/add       → AddEditTransactionScreen (new)
  /transactions/edit/:id  → AddEditTransactionScreen (edit)
  /ocr                    → OcrScreen
  /score                  → ScoreScreen
  /prediction             → PredictionScreen
```

---

## Database Schema

Single table `transactions`:

```sql
CREATE TABLE transactions (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  title       TEXT NOT NULL,
  date        TEXT NOT NULL,
  type        TEXT NOT NULL,        -- 'income' | 'expense'
  category    TEXT NOT NULL,
  amount      REAL NOT NULL,
  note        TEXT,
  createdAt   TEXT NOT NULL
);

CREATE INDEX idx_date     ON transactions(date);
CREATE INDEX idx_type     ON transactions(type);
CREATE INDEX idx_category ON transactions(category);
```

All financial metrics (balance, income, expenses, projections) are **computed in real-time** from this single table — no redundant aggregate storage.

---

## Theme System

- **Material 3** dynamic theming via `ColorScheme.fromSeed()`
- **Dark teal color scheme** (`#00897B` primary, `#26A69A` secondary, `#121212` background)
- Supports both light and dark modes (follows system theme)
- Consistent card design (borderRadius: 16, elevation: 2)

---

## Key Design Decisions

| Decision | Rationale |
|---|---|
| **Clean Architecture** over flat structure | Clear separation of concerns; easy to swap data sources; testable |
| **Stream-based reactivity** over imperative calls | All screens stay in sync without manual refresh logic |
| **Broadcast stream** over single-subscriber stream | Multiple listeners (dashboard + transaction list) on same data source |
| **`async*` generator** for initial stream emission | Ensures listeners always receive current data immediately, preventing infinite loading |
| **Local-first (SQLite)** over cloud storage | Offline-capable; no account required; instant response |
| **Riverpod** over BLoC / Provider | Compile-time safety; no BuildContext needed for DI; simpler syntax |
