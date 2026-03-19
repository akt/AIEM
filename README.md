# CLAWBOT — Engineering Manager Weekly Operating System

A full-stack habit tracker, weekly planner, and AI-powered operating system designed for high-output Engineering Managers. Built around a structured weekly operating template with DSAA rituals, DORA/SLO/SPACE scorecards, and Claude AI coaching.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                       MOBILE CLIENTS                             │
│  ┌────────────────────┐          ┌────────────────────┐          │
│  │   Android App      │          │    iOS App          │          │
│  │   Kotlin/Compose   │          │   Swift/SwiftUI     │          │
│  │   MVVM + Hilt DI   │          │   MVVM + Combine    │          │
│  └────────┬───────────┘          └────────┬───────────┘          │
│           │         REST/JSON              │                     │
└───────────┼────────────────────────────────┼─────────────────────┘
            │                                │
            ▼                                ▼
┌──────────────────────────────────────────────────────────────────┐
│                      BACKEND API (Express)                       │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌────────────────┐     │
│  │  Auth    │ │  CRUD    │ │  AI Coach  │ │  BullMQ Jobs   │     │
│  │  (JWT)   │ │  Routes  │ │  (Claude)  │ │  (Reminders,   │     │
│  │          │ │  11 sets │ │            │ │   Streaks,     │     │
│  └────┬─────┘ └────┬─────┘ └─────┬──────┘ │   Summaries)  │     │
│       │            │              │         └──────┬────────┘     │
│       ▼            ▼              ▼                ▼              │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ ┌──────────────┐       │
│  │PostgreSQL│ │  Knex    │ │ Anthropic  │ │    Redis     │       │
│  │  (Data)  │ │  (ORM)   │ │   API      │ │   (Queue)    │       │
│  └──────────┘ └──────────┘ └───────────┘ └──────────────┘       │
└──────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer      | Technology                          | Purpose                              |
|------------|-------------------------------------|--------------------------------------|
| Backend    | Node.js + TypeScript + Express      | REST API server                      |
| Database   | PostgreSQL 16                       | Persistent data store                |
| Queue      | Redis 7 + BullMQ                    | Job scheduling, reminders            |
| AI         | Anthropic Claude (claude-sonnet-4-20250514)    | Coaching, summaries, trend analysis  |
| Validation | Zod                                 | Request body/query/param validation  |
| Auth       | JWT (access + refresh tokens)       | Stateless authentication             |
| Android    | Kotlin + Jetpack Compose + Hilt     | Native Android client                |
| iOS        | Swift + SwiftUI + Combine           | Native iOS client                    |
| Infra      | Docker Compose                      | Local development orchestration      |

## Prerequisites

- **Docker** & **Docker Compose** (for backend + DB + Redis)
- **Node.js 20+** (if running backend outside Docker)
- **Android Studio** Hedgehog+ (for Android app)
- **Xcode 15+** (for iOS app, macOS only)
- **Anthropic API key** (for AI features)

## Quick Start

### 1. Clone & configure

```bash
git clone <repo-url> && cd AIEM
cp .env.example .env
# Edit .env — set your ANTHROPIC_API_KEY and JWT secrets
```

### 2. Start backend services

```bash
docker-compose up -d
# Postgres, Redis, and the API will start with health checks
# API available at http://localhost:3000
# Migrations run automatically on startup
```

### 3. Verify

```bash
curl http://localhost:3000/api/health
# → {"status":"ok","timestamp":"..."}
```

### 4. Mobile apps

**Android:**
```bash
cd android
# Open in Android Studio, sync Gradle, run on emulator/device
# Update BASE_URL in NetworkModule.kt to your backend IP
```

**iOS:**
```bash
cd ios
open EMOps.xcodeproj
# Build & run in Xcode on simulator/device
# Update baseURL in APIService.swift to your backend IP
```

## API Documentation

All endpoints are prefixed with `/api`. Authentication via `Authorization: Bearer <token>` header.

### Auth
| Method | Endpoint               | Description              |
|--------|------------------------|--------------------------|
| POST   | `/api/auth/register`   | Create account           |
| POST   | `/api/auth/login`      | Login, get tokens        |
| POST   | `/api/auth/refresh`    | Refresh access token     |
| GET    | `/api/auth/profile`    | Get user profile         |
| PUT    | `/api/auth/profile`    | Update profile/settings  |
| PUT    | `/api/auth/push-token` | Register push token      |

### Weekly Sheets
| Method | Endpoint                              | Description              |
|--------|---------------------------------------|--------------------------|
| GET    | `/api/weekly-sheets`                  | List sheets (paginated)  |
| GET    | `/api/weekly-sheets/current`          | Get current week's sheet |
| POST   | `/api/weekly-sheets`                  | Create new sheet         |
| PUT    | `/api/weekly-sheets/:id`              | Update sheet             |
| PUT    | `/api/weekly-sheets/:id/constraint`   | Update constraint        |
| PUT    | `/api/weekly-sheets/:id/dsaa-queue`   | Update DSAA queue        |
| PUT    | `/api/weekly-sheets/:id/ai-plan`      | Update AI plan           |
| PUT    | `/api/weekly-sheets/:id/time-blocks`  | Update time blocks       |
| PUT    | `/api/weekly-sheets/:id/incident`     | Update incident checklist|
| PUT    | `/api/weekly-sheets/:id/adr`          | Update ADR checklist     |
| PUT    | `/api/weekly-sheets/:id/scorecard`    | Update scorecard         |
| POST   | `/api/weekly-sheets/:id/complete`     | Mark sheet completed     |
| POST   | `/api/weekly-sheets/:id/carry-forward`| Carry forward to new week|

### Outcomes & Decisions (nested under sheets)
| Method | Endpoint                                          | Description        |
|--------|---------------------------------------------------|--------------------|
| GET    | `/api/weekly-sheets/:sheetId/outcomes`            | List outcomes      |
| POST   | `/api/weekly-sheets/:sheetId/outcomes`            | Create outcome     |
| PUT    | `/api/weekly-sheets/:sheetId/outcomes/:id`        | Update outcome     |
| PUT    | `/api/weekly-sheets/:sheetId/outcomes/:id/status` | Update status      |
| DELETE | `/api/weekly-sheets/:sheetId/outcomes/:id`        | Delete outcome     |
| GET    | `/api/weekly-sheets/:sheetId/decisions`           | List decisions     |
| POST   | `/api/weekly-sheets/:sheetId/decisions`           | Create decision    |
| PUT    | `/api/weekly-sheets/:sheetId/decisions/:id`       | Update decision    |
| PUT    | `/api/weekly-sheets/:sheetId/decisions/:id/resolve` | Resolve decision |

### Habits & Logs
| Method | Endpoint                  | Description              |
|--------|---------------------------|--------------------------|
| GET    | `/api/habits`             | List habits              |
| POST   | `/api/habits`             | Create habit             |
| PUT    | `/api/habits/:id`         | Update habit             |
| DELETE | `/api/habits/:id`         | Deactivate habit         |
| GET    | `/api/habits/:id/stats`   | Get habit statistics     |
| PUT    | `/api/habits/reorder`     | Reorder habits           |
| GET    | `/api/habit-logs`         | Get logs (by date/range) |
| POST   | `/api/habit-logs`         | Create log entry         |
| POST   | `/api/habit-logs/bulk`    | Bulk create logs         |
| PUT    | `/api/habit-logs/:id`     | Update log               |
| GET    | `/api/habit-logs/summary` | Aggregated summary       |

### DSAA Ritual
| Method | Endpoint            | Description          |
|--------|---------------------|----------------------|
| GET    | `/api/dsaa/today`   | Get today's DSAA log |
| POST   | `/api/dsaa/log`     | Create DSAA log      |
| PUT    | `/api/dsaa/log/:id` | Update DSAA log      |
| GET    | `/api/dsaa/history` | Paginated history    |
| GET    | `/api/dsaa/stats`   | DSAA statistics      |

### AI Coach
| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| POST   | `/api/ai/weekly-summary`        | Generate weekly summary  |
| POST   | `/api/ai/daily-coaching`        | Get daily coaching       |
| POST   | `/api/ai/dsaa-suggest`          | DSAA action suggestion   |
| POST   | `/api/ai/constraint-analysis`   | Constraint deep-dive     |
| POST   | `/api/ai/trend-insight`         | Trend analysis           |
| POST   | `/api/ai/habit-insight`         | Habit pattern insight    |
| POST   | `/api/ai/scorecard-insight`     | Scorecard analysis       |

### Trends & Notifications
| Method | Endpoint                          | Description              |
|--------|-----------------------------------|--------------------------|
| GET    | `/api/trends/weekly`              | Weekly trend data        |
| GET    | `/api/trends/habits`              | Habit trends             |
| GET    | `/api/trends/dsaa`                | DSAA trends              |
| GET    | `/api/trends/deep-work`           | Deep work trends         |
| GET    | `/api/trends/outcomes`            | Outcome trends           |
| GET    | `/api/trends/dashboard`           | Dashboard aggregation    |
| GET    | `/api/notifications`              | List notifications       |
| GET    | `/api/notifications/unread-count` | Unread count             |
| PUT    | `/api/notifications/:id/action`   | Mark as actioned         |
| GET    | `/api/reminders`                  | List reminders           |
| POST   | `/api/reminders`                  | Create reminder          |
| PUT    | `/api/reminders/:id`              | Update reminder          |
| DELETE | `/api/reminders/:id`              | Delete reminder          |
| POST   | `/api/reminders/setup-defaults`   | Create default reminders |

### Error Response Format

All errors follow a consistent format:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": { "fieldErrors": {}, "formErrors": [] },
    "requestId": "uuid"
  }
}
```

## Project Structure

```
AIEM/
├── backend/                    # Node.js + TypeScript API
│   ├── src/
│   │   ├── config/             # Database, Redis, Auth, AI config
│   │   ├── middleware/         # Auth, validation, error handling
│   │   ├── routes/             # 11 route modules
│   │   ├── services/           # Business logic + AI integration
│   │   ├── jobs/               # BullMQ workers (reminders, streaks, summaries)
│   │   ├── types/              # Shared TypeScript interfaces
│   │   └── index.ts            # Express app entry point
│   ├── migrations/             # 12 Knex migration files
│   ├── Dockerfile              # Multi-stage production build
│   ├── knexfile.ts             # Database configuration
│   ├── package.json
│   └── tsconfig.json
├── android/                    # Kotlin + Jetpack Compose
│   └── app/src/main/java/com/emops/app/
│       ├── di/                 # Hilt dependency injection
│       ├── ui/
│       │   ├── navigation/     # NavGraph with bottom navigation
│       │   ├── screens/        # Feature screens (dashboard, habits, weekly, etc.)
│       │   ├── components/     # Reusable Compose components
│       │   └── theme/          # Material 3 theming
│       └── data/               # Repositories, API service, Room DB
├── ios/                        # Swift + SwiftUI
│   └── EMOps/
│       ├── Views/              # Feature views (Dashboard, Habits, DSAA, etc.)
│       ├── ViewModels/         # ObservableObject view models
│       ├── Models/             # Codable data models
│       ├── Services/           # API, Auth, Notification, Sync services
│       └── EMOpsApp.swift      # App entry point
├── docker-compose.yml          # Postgres + Redis + API orchestration
├── .env.example                # Environment variable template
└── CLAWBOT_PROJECT_PLAN.md     # Full project specification
```

## Environment Variables

| Variable              | Required | Default                        | Description                    |
|-----------------------|----------|--------------------------------|--------------------------------|
| `DATABASE_URL`        | Yes      | `postgres://...@localhost:5432` | PostgreSQL connection string   |
| `REDIS_URL`           | Yes      | `redis://localhost:6379`        | Redis connection string        |
| `JWT_SECRET`          | Yes      | —                              | Access token signing secret    |
| `JWT_REFRESH_SECRET`  | Yes      | —                              | Refresh token signing secret   |
| `ANTHROPIC_API_KEY`   | Yes      | —                              | Claude API key for AI features |
| `PORT`                | No       | `3000`                         | API server port                |
| `NODE_ENV`            | No       | `development`                  | Environment mode               |

## Background Jobs

The backend runs four BullMQ workers automatically:

| Job                  | Schedule       | Purpose                                    |
|----------------------|----------------|---------------------------------------------|
| Reminder Worker      | Event-driven   | Fires push/in-app notifications             |
| Weekly Summary       | Weekly (Sun)   | Generates AI weekly summary                 |
| Trend Aggregator     | Weekly         | Computes trend metrics                      |
| Streak Calculator    | Daily          | Updates habit streak counts                 |

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make changes and ensure consistency with existing patterns
4. Commit with conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`
5. Push and open a Pull Request

### Code Style

- **Backend:** TypeScript strict mode, Zod validation on all inputs, async/await with centralized error handling
- **Android:** Kotlin with Jetpack Compose, MVVM architecture, Hilt DI
- **iOS:** Swift with SwiftUI, MVVM with `@Published` properties, Combine for async

## License

Private — All rights reserved.
