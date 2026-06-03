# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Analyze / lint
flutter analyze

# Build
flutter build apk
flutter build ios

# Regenerate Hive adapters (only needed if ActivityLog fields change)
dart run build_runner build --delete-conflicting-outputs
```

There are no tests (`test/` only has the default Flutter placeholder — no test suite exists).

## Architecture

### State management

No state management library is used. State flows via:
- `setState` within screens
- Callbacks passed as constructor parameters (e.g. `onStartActivity`, `onLogsChanged`)
- A **global mutable list** `globalLogs` declared at the top of `main.dart`, mutated by `_addLog`/`_removeLog` in `_MainNavigatorState` and propagated by `setState`

### Persistence

**Hive** stores two boxes:
- `activity_logs` — serialized `ActivityLog` objects via `toJson()`/`fromJson()` (manual, not generated adapters)
- `settings` — key/value flags (e.g. `onboarding_complete`)
- `custom_activities` — user-created activity categories

### Navigation

`_MainNavigatorState` uses an `IndexedStack` with 6 slots. The bottom nav covers indices 0–4 (index 2 is a spacer). Index 5 is `ConsciousActionScreen`, opened by the FAB or Home callbacks. Sub-screens (`TimerScreen`, `CompletionScreen`) are pushed via `Navigator.push` and return an `ActivityLog` result via `Navigator.pop(context, log)`.

### Data model

**`Activity`** (in `lib/data/activities.dart`) — static catalog of 9 categories, each with a list of `Practice` objects. Key static map: `Activity.tempoIdeal` maps category names to ideal session minutes (used for UP calculations).

**`Practice`** (in `lib/data/practice.dart`) — a specific practice within a category; carries `energy` (`Ativa`/`Passiva`), `flow` (difficulty), and `organ` (`Mente`/`Corpo`/`Espírito`).

**`ActivityLog`** (in `lib/models/activity_log.dart`) — a recorded session. Key fields: `group` (category name), `energy`, `flow`, `organ`, `durationInSeconds`, `consciousnessLevel` (0–3), `difficultyFeedback` (string).

**UPs (Unit of Progress)** = `log.duration.inMinutes / Activity.tempoIdeal[log.group]`. Computed on-the-fly in `DashboardScreen`, never stored.

### Color system

`HawkinsColors` (in `lib/data/colors.dart`) maps the domain vocabulary to colors:
- `energyColors` — `Ativa` → orange, `Passiva` → teal
- `flowGradient` — difficulty levels (Fácil → Difícil) → colors
- `organGradients` — Mente/Corpo gradients

The name "Hawkins" refers to David R. Hawkins's consciousness scale, which is the conceptual foundation for the consciousness feedback (😴 Automático → ✨ Fluindo).

### Timer module

After refactoring, the timer feature is split across:
- `lib/screens/timer_screen.dart` — state logic only (chronometer, Pomodoro, HIIT, manual modes)
- `lib/screens/completion_screen.dart` — post-activity feedback screen
- `lib/models/timer_mode.dart` — `TimerMode` enum
- `lib/models/hiit_interval.dart` — HIIT interval data class
- `lib/widgets/timer/` — pure presentation widgets (`CircularTimer`, `TimerAppBar`, `TimerModeSelector`, `ControlButton`, `ManualTimePicker`, `FeedbackButton`)

`TimerScreen` returns an `ActivityLog` to its caller via `Navigator.pop`. The double-pop pattern in `_saveLogAndClose` (immediate pop + delayed pop) closes both `CompletionScreen` and `TimerScreen`.

### Smart Compass (Match screen)

`SmartCompassScreen` analyzes the last 7 days of `globalLogs` to generate a ranked deck of `SuggestionCard` objects. Cards are swiped Tinder-style. Selecting a card navigates directly to `TimerScreen`.

### Fonts

- Titles: `GoogleFonts.playfairDisplay`
- Body / UI: `GoogleFonts.lato`
- Neumorphic widgets use `flutter_neumorphic` (present but minimally used)

## Known rough edges

- `print()` debug statements exist throughout the codebase (not cleaned up)
- `withOpacity` is used everywhere (deprecated in favor of `.withValues()`, but intentionally left as-is for consistency)
- `OnboardingPremiumScreen` completion calls `runApp()` again to rebuild — intentional workaround for state reset
- `globalLogs` is mutated directly; screens that receive it as a parameter will not reflect additions/deletions unless the parent calls `setState`
