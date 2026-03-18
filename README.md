# RUETHive

**Centralized Academic Information & Smart Scheduling for RUET Students**

A cross-platform Flutter application for Rajshahi University of Engineering & Technology (RUET), serving three user roles — Student, Class Representative (CR), and Admin — with role-specific dashboards, schedule management, notice publishing, and a notification system.

> **Course:** CSE 2100 — Software Development Project I  
> **Team:** Dipannita Biswas (2303030) · Md. Labib Hassan (2303052) · Arafat Rahman (2303009)  
> **Department:** CSE, 23 Series — RUET

---

## Table of Contents

- [About the App](#about-the-app)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Current State — What Works](#current-state--what-works)
- [Dependencies](#dependencies)

---

## About the App

RUETHive solves a real problem at RUET: academic schedules and notices are scattered across WhatsApp groups, notice boards, and word of mouth. Students miss classes, CRs have no formal channel to post updates, and admins have no central moderation tool.

The app provides a structured, role-aware platform where:
- **Students** see their schedule, read notices, and get notified of changes
- **Class Representatives (CRs)** post and manage schedules and notices for their section
- **Admins** moderate all content, manage users, and publish university-wide notices

The app runs on **Android** (primary) and **Windows desktop** (secondary, with a full sidebar layout and embedded calendar).

---

## Features

### All Roles
- Personalized dashboard with today's schedule
- Full weekly schedule view with daily filter and date picker
- Notice board with type filtering (Urgent, Department, University)
- Notification centre with per-type toggle settings
- Profile screen with academic info and notification preferences
- Light / dark theme toggle with animated icon transition
- Responsive layout — mobile bottom nav, desktop sidebar

### Student
- Read-only access to all of the above
- Desktop: 3-column dashboard (today's classes · calendar · selected date detail)

### Class Representative (CR)
- Everything the student has
- Post new schedules (time, room, day, subject, teacher)
- Post notices (title, body, type, file attachment)
- Manage own posted content (edit, delete)
- Quick Post FAB with bottom sheet on mobile

### Admin
- Separate admin dashboard with system stats
- Approve / reject pending CR content
- Edit or delete any schedule or notice across all sections
- Mark notices as urgent, set scope (Department / University-wide)
- Full user management: add, edit, delete, promote to CR, demote to Student
- Quick Action FAB: Create Schedule / Post Notice / Add User

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart 3.x) |
| Material Design | Material 3 (Material You) |
| State Management | Riverpod (`flutter_riverpod ^2.5.1`) |
| Date Formatting | `intl ^0.19.0` |
| File Picker | `file_picker ^8.0.0+1` |
| Backend (planned) | Firebase Auth + Firestore + FCM |
| Platforms | Android · Windows · macOS |

---

## Project Structure

```
lib/
├── main.dart
├── core/                        # Foundation layer — never imports from screens/
│   ├── constants.dart           # Breakpoints, border radii, animation durations
│   |
│   |
│   ├── responsive/
│   │   └── responsive.dart      # Responsive.builder(), isMobile/isDesktop helpers
│   ├── state/
│   │   ├── navigation_provider.dart   # Back-stack navigation history
│   │   ├── notification_provider.dart # Notification list + per-type settings
│   │   ├── role_provider.dart         # UserRole enum (student / cr / admin)
│   │   ├── theme_provider.dart        # Light/dark ThemeMode + isDarkModeProvider
│   │   └── user_provider.dart         # currentUserProvider → swap point for Firebase Auth
│   ├── theme/
│   │   ├── app_theme.dart       # AppTheme.light(role) / .dark(role)
│   │   ├── role_colours.dart    # Seed colour per role (blue / green / purple)
│   │   └── typography.dart      # 5 named text styles built from active ColorScheme
│   └── ui/
│       ├── shadows.dart         # AppShadows.card / .floating / .subtle
│       └── spacing.dart         # AppSpacing.xs/sm/md/lg/xl/xxl (4pt base grid)
│
├── data/
│   └── dummy_data.dart          # Stub data — replace with Firestore StreamProviders
│
├── models/
│   ├── notice_model.dart        # NoticeModel, NoticeType enum
│   └── schedule_model.dart      # ScheduleModel (day, time, room, section, subject)
    └── app_user.dart            # AppUser model — single source of truth for identity
│
├── screens/
│   ├── dashboard_screen.dart
│   ├── notices_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart      # Thin orchestrator → screens/profile/
│   ├── schedule_screen.dart
│   ├── admin/
│   │   ├── admin_create_notice_screen.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── admin_scaffold.dart
│   │   └── management/
│   │       ├── admin_notice_management_screen.dart
│   │       ├── admin_schedule_management_screen.dart
│   │       └── admin_user_management_screen.dart
│   ├── cr/
│   │   ├── cr_create_schedule_screen.dart  # Contains CR create schedule + notice forms
│   │   ├── cr_management_screen.dart
│   │   └── cr_scaffold.dart
│   └── profile/
│       ├── profile_academic_card.dart
│       ├── profile_contact_card.dart
│       ├── profile_header.dart
│       ├── profile_menu_card.dart
│       └── profile_settings_card.dart
│
└── widgets/
    ├── app_card.dart
    ├── app_scaffold.dart       
    ├── bottom_nav.dart
    ├── calendar_grid.dart       # Custom-built month calendar — no external package
    ├── loading_states.dart      # 7 shimmer skeleton types + AppEmptyState
    ├── notification_bell.dart
    ├── schedule_card.dart
    ├── toggle_switch.dart
    └── scaffold/
        ├── base_desktop_app_bar.dart   # Shared desktop top bar for all 3 roles
        ├── base_mobile_app_bar.dart    # Shared mobile top bar for all 3 roles
        └── base_side_nav.dart          # Shared 280px desktop sidebar for all 3 roles
```



| Value | What you see |
|---|---|
| `UserRole.student` | Student dashboard, read-only, blue theme |
| `UserRole.cr` | CR dashboard with Manage tab + Quick Post FAB, green theme |
| `UserRole.admin` | Admin dashboard with full management screens + Quick Action FAB, purple theme |



> **Note:** The dummy user is always `Dipannita Biswas / 2303030 / CSE 23 Section A`. To change the displayed user data during development, edit `AppUser.dummy` in `lib/core/models/app_user.dart`.

---

## Current State — What Works

The entire **UI layer** is complete and functional with stub data:

-  All screens built for all three roles
-  Role-based colour theming (blue / green / purple, light + dark)
-  Responsive layouts — mobile and desktop
-  Custom calendar grid with today highlight and event dots
-  Shimmer loading skeletons on all data-bearing screens
-  Empty states on all lists
-  Schedule date picker (themed to match active role colour)
-  Notification centre with read/unread state and per-type toggles
-  File picker in CR and Admin create forms
-  Approve / reject workflow UI (buttons wired, no backend yet)
-  User management CRUD dialogs (local state, no backend yet)
-  Animated theme toggle (sun/moon with rotation + fade)
-  Back button driven by navigation history stack


## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.5.1   # State management — 5 providers
  file_picker: ^8.0.0+1      # File attachment in CR/Admin create forms
  intl: ^0.19.0              # DateFormat for weekday name matching in schedule queries
  table_calendar: ^3.1.3      #calendar format for small calendar in schedule_screen.dart

dev_dependencies:
  flutter_lints: ^3.0.0      # Lint rules
```

The calendar is **custom-built** (`widgets/calendar_grid.dart`) 

---

*RUETHive — CSE 2100, Software Development Project I · RUET CSE 23 Series*
