---
name: Riverpod 3.x legacy APIs
description: Where StateProvider/StateNotifier live in Riverpod 3.x and why flutter_riverpod/flutter_riverpod.dart alone isn't enough.
---

In Riverpod 3.x (observed with `flutter_riverpod: ^3.3.2`), the classic `StateProvider`, `StateNotifier`, and `StateNotifierProvider` APIs are no longer exported from `package:flutter_riverpod/flutter_riverpod.dart`. They still exist but were moved to `package:flutter_riverpod/legacy.dart`.

**Why:** Riverpod 3 pushes the `Notifier`/`AsyncNotifier` (code-gen friendly) APIs as the primary pattern; the older StateNotifier-based APIs are kept only for migration compatibility behind a separate import.

**How to apply:** If a project uses the classic StateNotifier pattern (simpler to hand-write without build_runner) on Riverpod 3.x, add `import 'package:flutter_riverpod/legacy.dart';` alongside the main import, or migrate the provider to `NotifierProvider`/`Notifier` instead.
