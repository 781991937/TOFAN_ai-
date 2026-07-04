---
name: Flutter on Replit setup
description: How to install Flutter and preview it in Replit's webview when a project needs a Flutter app.
---

Flutter is not offered as a language "module" in this environment (`listAvailableModules` returns nothing for "flutter"). Install it as a Nix system dependency instead: `installSystemDependencies(["flutter"])`. This pulls in a working `flutter`/`dart` binary (observed: Flutter 3.32 stable, Dart 3.8).

For the Replit preview (webview, must be port 5000, host 0.0.0.0), scaffold the project with web support (`flutter create --platforms android,ios,web .`) and run it as a workflow with:
`flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000`

**Why:** Replit's preview pane is an iframed proxy of a web port; Flutter's web-server device is the only way to expose a Flutter UI there without a mobile emulator. Non-web platforms (android/ios) can't be previewed directly in this environment.

**How to apply:** Any time a task asks for a Flutter/Dart mobile app in this environment, default to this install + web-server workflow pattern unless the user specifically wants only native mobile builds (in which case there's no live preview available here).
