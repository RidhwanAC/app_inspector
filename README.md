# App Inspector

App Inspector is a Flutter-based application designed for efficient data inspection and management. It leverages a robust local architecture with SQLite for persistence, secure session management for authentication, and modern Material 3 design principles for a polished user experience.

## 🚀 Key Features

### 1. Authentication & Session Management

The application implements a secure login flow that persists user state across app restarts.

- **SessionManager**: A utility class (`lib/utils/session_manager.dart`) handles the storage and retrieval of login tokens/flags.
- **Auto-Login**: On application startup (`main.dart`), the app asynchronously checks `SessionManager.isLoggedIn()`.
- **State Handling**: While checking the session, a loading state is displayed. Once resolved, the app seamlessly routes the user to either the `LoginScreen` or `HomeScreen`.

### 2. Local Database (SQLite)

The app uses **SQLite** for offline-first data persistence, ensuring data integrity and availability without constant network access.

- **Implementation**: Utilizes the `sqflite` package to manage the local database.
- **Functionality**: Supports CRUD (Create, Read, Update, Delete) operations for core application entities.

### 3. UI/UX & Animations

- **Material 3**: The app is themed using `ColorScheme.fromSeed` with a primary seed color of `#6750A4`, ensuring a modern and accessible color palette.
- **Slivers**: Complex scrolling effects are implemented using Flutter's Sliver architecture (e.g., `SliverAppBar`, `SliverList`) to provide performant and collapsible headers in the `HomeScreen`.
- **Transitions**: Screen switches (e.g., from Loading to Login) are wrapped in `AnimatedSwitcher` for smooth fade transitions.

## 🛠 Technical Architecture

### Application Flow

1.  **Entry Point**: `main()` calls `runApp(const MyApp())`.
2.  **Initialization**: `_MyAppState` initializes and sets `loading = true`.
3.  **Session Check**: `_checkLogin()` is called in `initState`.
4.  **Routing**:
    - If `SessionManager` returns `true` -> Navigate to `HomeScreen`.
    - If `SessionManager` returns `false` -> Navigate to `LoginScreen`.

### Directory Structure

```text
lib/
├── database/        # SQLite database helpers and models
├── screens/         # UI Screens (Login, Home, etc.)
├── utils/           # Utilities (SessionManager, Constants)
└── main.dart        # Entry point and Theme configuration
```

### Theme Configuration

The global theme is defined in `main.dart`:

- **Input Decoration**: Filled text fields with `12px` rounded corners.
- **Colors**: Derived from a deep purple seed color.
- **Surface**: Light grey surface color (`#F8F9FF`).

## 📦 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK

### Installation

1.  **Clone the repository:**

    ```bash
    git clone <repository-url>
    cd app_inspector
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

---

Generated for App Inspector Project.
