# EventHub — Project Plan

## 1. Product and strategy

EventHub is a Flutter app for discovering events, reserving tickets, viewing QR e-tickets, and organizer operations. The development strategy is **preview first, full implementation after lecturer feedback**. Work is split into small, independently reviewable tasks.

## 2. Current baseline

- `DEMO-01` and `DEMO-02` completed; project and UI checks were run on 2026-11-11.
- Flutter 3.47.6 Stable, Dart 3.13.5, Riverpod 3.5.0, go_router 18.1.4 (reported).
- Android emulator build/run verified by the implementer; iOS run/build is not yet verified.
- The next task is `DEMO-03` (not started).

## 3. Phase A — Demo v0.1

**Audience:** Lecturer reviewing the idea and UX before full development.

**Must demonstrate:**

1. Browse realistic events, search, and open event details.
2. Select one ticket type and 1–4 tickets; confirm a clearly simulated booking.
3. Open “My Tickets” and view an individual QR preview.
4. Switch to a demo Organizer mode; view, create, and edit sample events.
5. Navigate smoothly through a consistent Vietnamese mobile UI.

**Implementation:** Feature-first Flutter; Material 3; Riverpod; go_router; mock repositories with sample data. No required live backend. Preserve a boundary so mock repositories can later be replaced with Supabase implementations.

**Explicitly deferred:** Real Auth/RLS, payments, server-side booking transactions, authoritative QR check-in, Gemini API, admin features, and production analytics. A scanner mock must never display a misleading verified-success result.

### Delivery sequence and rough effort

| Task | Deliverable | Estimate |
| --- | --- | --- |
| DEMO-01 | Bootstrap and navigation | Done |
| DEMO-02 | UI design system | 0.5–1 day |
| DEMO-03 | Mock event data | 0.5 day |
| DEMO-04 | Discovery and details | 1 day |
| DEMO-05 | Booking and QR preview | 1 day |
| DEMO-06 | Organizer demo | 0.5–1 day |
| DEMO-07 | Polish and review | 0.5–1 day |
| DEMO-08 | QA, APK, and presentation | 0.5 day |

Estimates are planning aids, not deadlines. Follow task IDs in `TASK.md`.

### Demo acceptance

- Runs on a supported Android emulator/device.
- All advertised interactive controls work; simulated flows are labeled.
- Core preview journey works: Discovery → Detail → Simulated Booking → QR Wallet.
- Organizer demo screens support sample create/edit actions.
- Relevant tests and `flutter analyze` pass; known limitations are documented.
- APK, run instructions, and a 3–4-minute lecturer walkthrough are available.

## 4. Phase B — Full project

After review, migrate features to Supabase Auth/PostgreSQL/RLS and transaction-safe RPCs. Implement secure ticket issuance and online check-in before Gemini recommendations and richer analytics. Add integration/security tests, reports, and a release build. Use the full specification as a reference, but reconcile its 13-week milestones with the earlier 8-week implementation estimate before committing dates.

## 5. Open decisions

- **Visual identity approved for DEMO-02:** Indigo — Modern Event; primary `#4F46E5`, secondary `#7C3AED`.
- **Academic schedule:** confirm the actual final deadline and rubric.
- **Platform demonstration:** verify whether lecturer requires tested iOS or another platform, not just shared Flutter source.
- **AI requirement:** confirm whether Gemini streaming is mandatory.
- **Production policies:** Organizer approval, cancellation, event start cutoff, and check-in time window remain unapproved.

## 6. Change control

Keep this plan aligned with approved scope changes. `TASK.md` is the execution checklist; `CHANGELOG.md` records actual outcomes. Never treat a planned item as implemented.
