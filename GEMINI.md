# Butler App Architecture & Guidelines

This project is a macOS Flutter AI Chat Application.

## Architecture Context
- **AI Integration**: Uses Genkit Dart (`genkit` and `genkit_google_genai`) running in a separate, dedicated Dart Isolate (`lib/genkit_isolate.dart`). 
  - Ensure that any intensive AI calls or new AI plugins are integrated into the isolate to prevent main thread jank.
- **Database**: Uses SQLite for local storage, integrated via FFI (`sqlite3` and `sqlite3_flutter_libs`). 
  - The `sqlite3.c` amalgamation is bundled directly via `sqlite3_flutter_libs`. Do not use `sqflite` (which uses MethodChannels) as we are strictly using FFI for this project.
  - The database helper is located at `lib/db.dart`.
- **Target Platform**: macOS primarily. The network entitlements (`com.apple.security.network.client`) have been enabled in the Runner to allow Genkit network calls.

## Guidelines
- **Formatting**: Always run `dart format .` after writing or modifying Dart code to ensure the codebase remains uniformly styled.
- Always default to using MVVM (Model View ViewModel) when developing UI widgets.
- Consider calling setState as an expensive operation that requires the flutter tree to re-render.  Calling setState should not be done in a tight loop. 
- Setting state re-renders the corresponding widget and any subwidgets.  Attempt to ensure state is as isolated to "leaf" widgets as much as possible to minimize the rerender impact.
- Never block the main UI thread - always offload expensive work to a background isolate. 
- When adding new chat features, ensure state management in `lib/main.dart` is correctly synced with the SQLite database.
- Database read/write operations for chat histories should remain lightweight; complex migrations should be added to `lib/db.dart`.
- The `GenkitIsolate` handles conversation contexts and streams/receives prompts via `SendPort` and `ReceivePort`. Ensure message serialization when sending data between isolates.
- The design of the app should be minimal and zen-like. Dark, rich colors. Dark background with a smooth simple lightweight frosted glass for foreground UI elements.
- Use the State Pattern whenever dealing with complex state. Prefer this abstraction to making large, complex conditional statements.
- Prefer to use ChangeNotifier and ValueNotifier when state needs to be shared with the UI.

## Golden Tests
- When adding or modifying UI, ensure you write or update **Golden Tests** to prevent visual regressions.
- Generate or update master golden images locally by running `flutter test --update-goldens`.
- Note: Golden tests are highly sensitive to OS font rendering. Because this is primarily a macOS application, CI workflows (`flutter_ci.yml`) are configured to run on `macos-latest` to ensure your locally generated macOS golden files match the CI environment.