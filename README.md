# Butler AI

Butler AI is a premium, cross-platform desktop AI assistant built with Flutter, SQLite, and Google Genkit. It features a clean, zen-like UI and prioritizes privacy, performance, and security.

## Features

* **Secure Local Storage**: Uses **SQLCipher** for 256-bit AES encryption to store all chat histories locally and securely on your device.
* **Non-Blocking Architecture**: Leverages **Dart Isolates** to run all Genkit AI processing on a dedicated background thread, ensuring the UI remains buttery smooth at all times.
* **Dynamic GLSL Shaders**: Features a completely custom, slow-breathing, zen-like dynamic background shader using Flutter's native `FragmentProgram`.
* **Clean MVVM Design**: Adheres to a strict Model-View-ViewModel (MVVM) architecture, separating AI logic, state management, and UI rendering for maximum testability.
* **Automated CI/CD Pipelines**: Includes a fully configured GitHub Actions workflow that automatically runs unit tests and compiles native runnable binaries for **macOS, Windows, and Linux** on every release.

## Getting Started

### Prerequisites
* Flutter SDK (Stable Channel)
* [Genkit CLI](https://firebase.google.com/docs/genkit) (for AI interactions)

### Running Locally

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run -d macos
   # Or windows / linux depending on your host OS
   ```

### Running Tests

The project has robust unit tests covering the ViewModels and AI abstraction layers.

```bash
flutter test
```

## Architecture

* `lib/main.dart` - Entry point and dependency initialization.
* `lib/db.dart` - Singleton `DatabaseHelper` managing the SQLCipher instance, handling migrations, and storing encrypted messages.
* `lib/genkit_isolate.dart` - The isolated Genkit runner.
* `lib/services/` - Abstractions (like `AiService`) that interface with isolates.
* `lib/viewmodels/` - State management controllers (e.g., `PasswordViewModel`, `ChatViewModel`).
* `lib/views/` - Pure stateless-feeling UI widgets that listen to ViewModels.
* `lib/widgets/` - Reusable components (e.g., `ZenBackground`).
* `shaders/zen_glow.frag` - The raw GLSL code for the animated background.
