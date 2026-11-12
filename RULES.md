# EventHub — Rules for AI Coding Agents

## 1. Scope and authorization

1. Read `AGENTS.md`, `TASK.md`, and `PLAN.md` before implementation.
2. Work on **one explicitly assigned task ID** at a time. Do not pre-build later features.
3. Inspect the repository and `git status` before edits. Preserve user changes; never reset, delete, overwrite, commit, push, or deploy without authorization.
4. State blockers and assumptions. Ask before making scope-changing, security-sensitive, or destructive decisions.
5. Demo v0.1 uses mock/local data. Label simulated booking, tickets, and statistics clearly; never imply real payment, authorization, or verified check-in.

## 2. Engineering

1. Flutter/Dart is mandatory. Android is the immediate demo target; keep code portable to iOS where practical.
2. Use feature-first organization with lightweight Presentation / Domain / Data boundaries **when they provide value**. Avoid empty abstractions and oversized files.
3. Use Riverpod for shared state and go_router for navigation. Do not add dependencies without a task need.
4. Keep widgets presentational; put business rules and data access outside UI widgets.
5. UI text is Vietnamese. Code identifiers, filenames, and inline code comments should be clear English.
6. Keep API keys and service-role credentials out of client code and Git. Full Supabase/Gemini integration is deferred until assigned.
7. Build reusable components and accessible, responsive layouts. Avoid placeholder buttons that appear functional but do nothing.
8. Never fabricate code execution, tests, screenshots, data synchronization, or security guarantees.

## 3. Verification

- Run `flutter pub get` when dependencies change.
- Run `dart format` on changed Dart files, `flutter analyze`, and relevant `flutter test` checks.
- Run/build on Android when the task changes navigation, rendering, plugins, or platform behavior and a device is available.
- Report commands, outcomes, skipped checks, environment limitations, and known defects explicitly.
- Do not mark a task complete while required acceptance checks fail. A blocked/partial result remains unchecked.

## 4. Documentation contract

- `AGENTS.md`: entry point and document index; update when project structure or reading order changes.
- `RULES.md`: lasting rules; edit only when the user approves a rule change.
- `TASK.md`: concise checkboxes. Mark `[x]` only after successful verification; do not silently create a new scope.
- `PLAN.md`: goals, stage boundaries, dependencies, and decisions; update when a plan is approved to change.
- `CHANGELOG.md`: **Vietnamese only**, newest task first, using the standard structure below.
- `README.md`: reflect new setup/run instructions when they change.

For each completed task, prepend an entry with `## [TASK-ID] - YYYY-MM-DD` and the same three Vietnamese section headings used in the existing `CHANGELOG.md`: implemented work, actual verification, and limitations/notes. Keep the entire changelog entry in Vietnamese.

Do not revise old changelog entries except to correct verified inaccuracies.

## 5. Task response format

End each task with: **Status** (Complete / Partial / Blocked), **Changed files**, **Implemented**, **Verification**, **Limitations**, and **How to review**. Stop after reporting; wait for user acceptance.
