# EventHub — AI Agent Guide

This file is the entry point for coding agents working in the `eventhub-app` repository.
Keep it short; detailed constraints live in `RULES.md`.

## Project at a glance

- **Product:** EventHub, a cross-platform event discovery, ticket-booking, and QR check-in app.
- **Course:** Cross-Platform Mobile App Development; team of 1–2.
- **Stack:** Flutter/Dart, Material 3, Riverpod, go_router. Supabase and Gemini are planned for the full version.
- **Current goal:** A reviewable **Demo v0.1** with polished UI and clearly labeled simulated workflows, followed by a production-oriented implementation after lecturer feedback.
- **Primary demo target:** Android. iOS project structure exists, but iOS execution has not been verified.

## Read these files before changing code

1. `RULES.md` — required working rules and quality gates.
2. `TASK.md` — task IDs, priorities, and checkbox status.
3. `PLAN.md` — scope, stages, dependencies, and acceptance goals.
4. `CHANGELOG.md` — completed work and verification history (in Vietnamese).
5. `README.md` — environment setup and run instructions.
6. `docs/demo_scope.md` — existing demo scope, if present.
7. `docs/EventHub.docx` — original long-form product specification **if copied into the repo**; it is not required for every task.

## Source of truth

- The user's latest instruction defines the active task.
- `RULES.md` defines ongoing engineering and documentation practices.
- `TASK.md` records task completion; `PLAN.md` records scope and sequence.
- `CHANGELOG.md` records observed results, not promises.
- For Demo v0.1, the approved demo scope takes precedence over full-version features in the original specification.
- If documents conflict in a way that changes scope or security, pause and ask for clarification.

## Reported baseline (2026-11-11)

- `DEMO-01` was reported complete: Flutter 3.47.6 Stable, Dart 3.13.5, Riverpod 3.5.0, go_router 18.1.4.
- Three placeholder tabs exist: Discovery, My Tickets, Organizer.
- `flutter analyze`, `flutter test`, Android x64 debug build, and Pixel 7 emulator run were reported successful.
- Some Android SDK licenses remain pending; Chrome/Visual Studio are not needed for the current Android demo.
- This baseline is **user-reported**, not an independent audit of the repository.
- **Next task:** `DEMO-02` (visual direction and UI design system). Do not start it until instructed.

## Working agreement

Implement only the assigned task. Inspect existing code, preserve unrelated changes, run relevant checks, then update `TASK.md` and `CHANGELOG.md` only when results are verified. Stop and report; do not automatically begin the next task.
