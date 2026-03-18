# CLAWBOT: Engineering Manager Weekly Operating System — Full-Stack Application

## PROJECT BRIEF FOR CLAUDE CODE (6-HOUR SESSION)

**Goal:** Build a production-grade habit tracker, weekly planner, and AI-powered operating system for an Engineering Manager who owns Web3/DEX/Exchange/Fiat On-Off Ramp/Crypto-Pay and AI initiatives. The app must run on Backend (API), Android (Kotlin), and iOS (Swift). It is designed around a specific weekly operating template (included below) and must support reminders, time alerts, AI summaries, long-term trend tracking, and a 15-minute daily DSAA ritual.

**User Profile:**
- Role: Engineering Manager (hardcore, high-output)
- Timezone: Maldives (IST+0 / MVT, UTC+5)
- Deep work: 1–2 hours/day
- Mindset: DSAA (Delete → Simplify → Accelerate → Automate)
- Product surfaces: Web3/DEX, Exchange, Fiat On/Off Ramp, Crypto Pay, AI Platform/Agents
- Key ritual: 15-minute daily DSAA micro-task

**Session Strategy (6 hours):**
- Hour 1: Project scaffolding, database schema, shared data models
- Hour 2: Backend API (core endpoints, auth, push notification service)
- Hour 3: Backend AI integration (summaries, coaching, trend analysis)
- Hour 4: Android app (Kotlin + Jetpack Compose, core screens)
- Hour 5: iOS app (Swift + SwiftUI, core screens)
- Hour 6: Integration testing, push notifications, polishing

---

## PART 1: ARCHITECTURE OVERVIEW

### System Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    MOBILE CLIENTS                         │
│  ┌─────────────────┐       ┌─────────────────┐           │
│  │   Android App   │       │    iOS App       │           │
│  │  Kotlin/Compose │       │  Swift/SwiftUI   │           │
│  │  Room DB local  │       │  CoreData local  │           │
│  └───────┬─────────┘       └───────┬──────────┘           │
│          │         REST/JSON        │                     │
│          └────────────┬─────────────┘                     │
│                       │                                   │
│          ┌────────────▼────────────┐                     │
│          │      API GATEWAY        │                     │
│          │    (Authentication)     │                     │
│          └────────────┬────────────┘                     │
│                       │                                   │
│  ┌────────────────────▼─────────────────────┐            │
│  │           BACKEND (Node.js/TS)           │            │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐  │           │
│  │  │  Weekly   │ │  Habit   │ │ Reminder │  │           │
│  │  │  Planner  │ │ Tracker  │ │  Engine  │  │           │
│  │  │  Service  │ │ Service  │ │ Service  │  │           │
│  │  └──────────┘ └──────────┘ └──────────┘  │           │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐  │           │
│  │  │   AI     │ │  DSAA    │ │  Score   │  │           │
│  │  │ Summary  │ │  Ritual  │ │  Card    │  │           │
│  │  │ Service  │ │ Service  │ │ Service  │  │           │
│  │  └──────────┘ └──────────┘ └──────────┘  │           │
│  └────────────────────┬─────────────────────┘            │
│                       │                                   │
│  ┌────────────────────▼─────────────────────┐            │
│  │         PostgreSQL Database               │            │
│  │  + Redis (caching/job queues)             │            │
│  │  + Claude AI API (summaries/coaching)     │            │
│  │  + FCM/APNs (push notifications)          │            │
│  └───────────────────────────────────────────┘            │
└──────────────────────────────────────────────────────────┘
```

### Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Backend | Node.js + TypeScript + Express | Fast dev, great TS ecosystem |
| Database | PostgreSQL | Relational integrity for structured weekly data |
| Cache/Queue | Redis + BullMQ | Job scheduling for reminders/notifications |
| AI | Anthropic Claude API (claude-sonnet-4-20250514) | Summaries, coaching, trend analysis |
| Push Notifications | Firebase Cloud Messaging (FCM) + APNs | Cross-platform push |
| Android | Kotlin + Jetpack Compose + Room + Hilt | Modern Android stack |
| iOS | Swift + SwiftUI + CoreData + Combine | Modern Apple stack |
| Auth | JWT + refresh tokens | Stateless, mobile-friendly |

---

## PART 2: DATABASE SCHEMA (PostgreSQL)

### Core Tables

```sql
-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    timezone VARCHAR(50) NOT NULL DEFAULT 'Indian/Maldives',
    role VARCHAR(50) NOT NULL DEFAULT 'engineering_manager',
    -- Product surfaces the user manages
    surfaces JSONB NOT NULL DEFAULT '["web3_dex","exchange","fiat_onoff_ramp","crypto_pay","ai_platform"]',
    -- Notification preferences
    push_token_android TEXT,
    push_token_ios TEXT,
    notification_preferences JSONB NOT NULL DEFAULT '{
        "daily_dsaa_reminder": true,
        "weekly_fill_reminder": true,
        "deep_work_start_alert": true,
        "scorecard_friday_reminder": true,
        "reactive_window_alerts": true,
        "incident_pipeline_check": true
    }',
    -- DSAA ritual settings
    dsaa_trigger_time TIME NOT NULL DEFAULT '09:00',
    dsaa_trigger_event VARCHAR(255) DEFAULT 'morning standup',
    deep_work_hours_target DECIMAL(3,1) NOT NULL DEFAULT 1.5,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- WEEKLY OPERATING SHEETS (the core entity)
-- ============================================================
CREATE TABLE weekly_sheets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start DATE NOT NULL,  -- always a Monday
    week_label VARCHAR(50),    -- e.g., "2026-W12"
    status VARCHAR(20) NOT NULL DEFAULT 'draft', -- draft, active, completed, archived
    
    -- Week Identity
    surfaces_in_scope JSONB NOT NULL DEFAULT '[]',
    oncall_ownership TEXT,
    key_dependencies TEXT,
    non_negotiable_constraints TEXT,
    
    -- Single Weekly Constraint Deep-Dive
    constraint_statement TEXT,
    constraint_evidence JSONB DEFAULT '{}',
    -- Example: {"sli_dashboards":"...","incident_pattern":"...","queue_lag":"...","cost_regression":"..."}
    constraint_slo_service TEXT,
    constraint_slo_targets TEXT,
    constraint_error_budget_status VARCHAR(20) DEFAULT 'healthy', -- healthy, burning, exhausted
    constraint_exhausted_action VARCHAR(50), -- freeze_changes, reliability_sprint, escalate
    
    -- DSAA Queue
    dsaa_queue JSONB NOT NULL DEFAULT '{"delete":[],"simplify":[],"accelerate":[],"automate":[]}',
    dsaa_focus_this_week VARCHAR(20), -- delete, simplify, accelerate, automate
    
    -- AI Leverage Plan
    ai_tasks JSONB NOT NULL DEFAULT '[]',
    -- Example: [{"task":"pr_summary","enabled":true,"owner":"TL-A"},...]
    ai_guardrails_checked JSONB NOT NULL DEFAULT '[]',
    
    -- Calendar Time Blocks
    time_blocks JSONB NOT NULL DEFAULT '{}',
    -- Schema per day: {"mon":{"deep_work":"10:00-12:00","free_thinking":"","reactive":"14:00-14:30,16:00-16:30","key_meeting":""}}
    
    -- Incident / Postmortem Pipeline
    incident_checklist JSONB NOT NULL DEFAULT '{
        "p0p1_reviewed": false,
        "postmortem_scheduled": false,
        "action_items_owned": false,
        "runbooks_updated": false,
        "prevention_bet_chosen": false
    }',
    
    -- ADR / Architecture Review
    adr_checklist JSONB NOT NULL DEFAULT '{
        "adr_link_exists": false,
        "alternatives_considered": false,
        "rollout_rollback_plan": false,
        "observability_plan": false,
        "data_contracts_checked": false
    }',
    
    -- Weekly Scorecard (filled Friday)
    scorecard JSONB DEFAULT NULL,
    -- Schema: {"dora":{"deploy_freq":{},"lead_time":{},"change_fail_rate":{},"time_to_restore":{}},"slo":{"compliance":{},"error_budget_burn":{}},"space":{"deep_work_hours":{},"friction_pulse":{}},"ai_health":{"assisted_pct":{},"risk_catches":{}}}
    
    -- AI-generated summary (end of week)
    ai_weekly_summary TEXT,
    ai_coaching_notes TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    
    UNIQUE(user_id, week_start)
);

-- ============================================================
-- TOP 3 OUTCOMES (per weekly sheet)
-- ============================================================
CREATE TABLE weekly_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sheet_id UUID NOT NULL REFERENCES weekly_sheets(id) ON DELETE CASCADE,
    position INTEGER NOT NULL CHECK (position BETWEEN 1 AND 3),
    outcome_text TEXT NOT NULL,
    impact TEXT,
    definition_of_done TEXT,
    owner TEXT,
    risk_and_mitigation TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'in_progress', -- in_progress, done, blocked, carried_over
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(sheet_id, position)
);

-- ============================================================
-- LEADERSHIP DECISIONS (max 3 per week)
-- ============================================================
CREATE TABLE leadership_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sheet_id UUID NOT NULL REFERENCES weekly_sheets(id) ON DELETE CASCADE,
    position INTEGER NOT NULL CHECK (position BETWEEN 1 AND 3),
    decision_text TEXT NOT NULL,
    by_when DATE,
    inputs_needed TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, decided, deferred
    decision_result TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(sheet_id, position)
);

-- ============================================================
-- DAILY DSAA RITUAL LOG
-- ============================================================
CREATE TABLE dsaa_daily_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sheet_id UUID REFERENCES weekly_sheets(id) ON DELETE SET NULL,
    log_date DATE NOT NULL,
    
    -- The 15-minute ritual
    friction_point TEXT NOT NULL,
    dsaa_action VARCHAR(20) NOT NULL, -- delete, simplify, accelerate, automate
    micro_artifact_type VARCHAR(50), -- cancel_meeting, pr_checklist, adr_stub, runbook_update, test_case
    micro_artifact_description TEXT,
    expected_leverage TEXT,
    
    -- Time tracking
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    duration_minutes INTEGER,
    
    -- AI coaching suggestion (optional)
    ai_suggested_action TEXT,
    ai_suggestion_accepted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, log_date)
);

-- ============================================================
-- HABITS (recurring trackable items)
-- ============================================================
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL, -- deep_work, reliability, delivery, security, ai_safety, leadership, health, learning
    frequency VARCHAR(20) NOT NULL DEFAULT 'daily', -- daily, weekday, weekly, custom
    custom_days JSONB, -- e.g., ["mon","wed","fri"]
    target_value DECIMAL(10,2), -- e.g., 1.5 (hours), 3 (count)
    target_unit VARCHAR(30), -- hours, count, boolean, percentage
    reminder_time TIME,
    reminder_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    streak_current INTEGER NOT NULL DEFAULT 0,
    streak_best INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- HABIT LOGS (daily check-ins)
-- ============================================================
CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    value DECIMAL(10,2), -- actual value achieved
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(habit_id, log_date)
);

-- ============================================================
-- REMINDERS & ALERTS
-- ============================================================
CREATE TABLE reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    reminder_type VARCHAR(50) NOT NULL,
    -- Types: weekly_fill, scorecard_fill, dsaa_ritual, deep_work_start, deep_work_end,
    --        reactive_window, habit_check, incident_review, custom
    
    -- Scheduling
    schedule_type VARCHAR(20) NOT NULL, -- once, daily, weekly, custom
    scheduled_time TIME,
    scheduled_days JSONB, -- ["mon","tue",...] for weekly
    scheduled_date DATE, -- for one-time
    
    -- Linking
    linked_entity_type VARCHAR(50), -- weekly_sheet, habit, outcome, decision
    linked_entity_id UUID,
    
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_fired_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- NOTIFICATION LOG (audit trail)
-- ============================================================
CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reminder_id UUID REFERENCES reminders(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    channel VARCHAR(20) NOT NULL, -- push, in_app
    status VARCHAR(20) NOT NULL, -- sent, delivered, failed, dismissed, actioned
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    actioned_at TIMESTAMPTZ
);

-- ============================================================
-- AI INTERACTION LOG (for summaries, coaching, etc.)
-- ============================================================
CREATE TABLE ai_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    interaction_type VARCHAR(50) NOT NULL,
    -- Types: weekly_summary, daily_coaching, trend_analysis, dsaa_suggestion,
    --        constraint_analysis, scorecard_insight, habit_insight
    
    context_data JSONB NOT NULL, -- input sent to AI (sanitized, no secrets)
    ai_response TEXT NOT NULL,
    model_used VARCHAR(50) NOT NULL DEFAULT 'claude-sonnet-4-20250514',
    tokens_used INTEGER,
    
    -- User feedback
    was_helpful BOOLEAN,
    user_feedback TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- LONG-TERM TRENDS (weekly aggregates for dashboards)
-- ============================================================
CREATE TABLE weekly_trends (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start DATE NOT NULL,
    
    -- Aggregated metrics
    deep_work_hours_total DECIMAL(5,1),
    dsaa_rituals_completed INTEGER DEFAULT 0,
    habits_completion_rate DECIMAL(5,2), -- percentage
    outcomes_completed INTEGER DEFAULT 0,
    outcomes_total INTEGER DEFAULT 0,
    decisions_made INTEGER DEFAULT 0,
    decisions_total INTEGER DEFAULT 0,
    incidents_reviewed BOOLEAN DEFAULT FALSE,
    error_budget_status VARCHAR(20),
    dora_scores JSONB,
    ai_assists_count INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,
    friction_pulse_avg DECIMAL(3,1),
    
    -- AI-generated weekly insight (1-2 paragraphs)
    ai_trend_insight TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, week_start)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_weekly_sheets_user_week ON weekly_sheets(user_id, week_start DESC);
CREATE INDEX idx_weekly_sheets_status ON weekly_sheets(status);
CREATE INDEX idx_habit_logs_user_date ON habit_logs(user_id, log_date DESC);
CREATE INDEX idx_habit_logs_habit_date ON habit_logs(habit_id, log_date DESC);
CREATE INDEX idx_dsaa_logs_user_date ON dsaa_daily_logs(user_id, log_date DESC);
CREATE INDEX idx_reminders_user_active ON reminders(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX idx_notification_log_user ON notification_log(user_id, sent_at DESC);
CREATE INDEX idx_weekly_trends_user ON weekly_trends(user_id, week_start DESC);
```

### Seed Data: Default Habits for Engineering Manager

```sql
-- These are created automatically when a new user signs up
INSERT INTO habits (user_id, name, description, category, frequency, target_value, target_unit, reminder_time, sort_order) VALUES
-- Deep Work & Productivity
(:user_id, 'Deep Work Block', 'Complete 1-2h of focused deep work (architecture, reliability, code review)', 'deep_work', 'weekday', 1.5, 'hours', '09:30', 1),
(:user_id, 'DSAA 15-Minute Ritual', 'Pick 1 friction point, apply DSAA, produce 1 micro-artifact', 'deep_work', 'weekday', 1, 'boolean', NULL, 2),
(:user_id, 'Free-Thinking Walk', 'Walk/whiteboard session for strategy synthesis', 'deep_work', 'custom', 1, 'boolean', NULL, 3), -- custom_days: ["tue","thu"]

-- Reliability & SRE
(:user_id, 'SLO/Error Budget Check', 'Review SLO dashboards and error budget burn status', 'reliability', 'weekday', 1, 'boolean', '10:00', 4),
(:user_id, 'Incident Pipeline Review', 'Check P0/P1 incidents, postmortem status, action items', 'reliability', 'weekly', 1, 'boolean', '09:00', 5), -- custom_days: ["fri"]

-- Delivery & DORA
(:user_id, 'PR Review Queue Clear', 'Clear or delegate pending PR reviews (24h SLA for P0)', 'delivery', 'weekday', 1, 'boolean', '11:00', 6),
(:user_id, 'Weekly Scorecard Fill', 'Fill DORA metrics, SLO compliance, SPACE-lite, AI health', 'delivery', 'weekly', 1, 'boolean', '16:00', 7), -- custom_days: ["fri"]

-- Security
(:user_id, 'Security Guardrails Check', 'Verify AI outputs reviewed, no secrets in prompts, least privilege', 'security', 'weekday', 1, 'boolean', NULL, 8),

-- AI Safety
(:user_id, 'AI Output Validation', 'Review and validate any AI-generated code/docs before merge', 'ai_safety', 'weekday', 1, 'boolean', NULL, 9),

-- Leadership
(:user_id, 'Leadership Decision Progress', 'Check status of weekly leadership decisions (max 3)', 'leadership', 'weekday', 1, 'boolean', '15:00', 10),
(:user_id, 'Team Friction Pulse Check', 'Quick check-in on team friction signals (1-5 scale)', 'leadership', 'weekly', 1, 'count', '14:00', 11), -- custom_days: ["wed"]

-- Health & Sustainability
(:user_id, 'Reactive Budget Respected', 'Did I stay within 2x30min reactive windows today?', 'health', 'weekday', 1, 'boolean', '17:00', 12),
(:user_id, 'No Deep Work Interruptions', 'Protected deep work block from non-P0 interruptions', 'health', 'weekday', 1, 'boolean', NULL, 13);
```

---

## PART 3: BACKEND API (Node.js + TypeScript + Express)

### Project Structure

```
backend/
├── src/
│   ├── index.ts                    # App entry point
│   ├── config/
│   │   ├── database.ts             # PostgreSQL connection (pg + knex)
│   │   ├── redis.ts                # Redis connection
│   │   ├── auth.ts                 # JWT config
│   │   └── ai.ts                   # Anthropic API config
│   ├── middleware/
│   │   ├── auth.middleware.ts       # JWT verification
│   │   ├── validation.middleware.ts # Request validation (zod)
│   │   └── error.middleware.ts      # Global error handler
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── weekly-sheet.routes.ts
│   │   ├── outcomes.routes.ts
│   │   ├── decisions.routes.ts
│   │   ├── habits.routes.ts
│   │   ├── habit-logs.routes.ts
│   │   ├── dsaa.routes.ts
│   │   ├── reminders.routes.ts
│   │   ├── ai.routes.ts
│   │   ├── trends.routes.ts
│   │   └── notifications.routes.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── weekly-sheet.service.ts
│   │   ├── habit.service.ts
│   │   ├── dsaa.service.ts
│   │   ├── reminder.service.ts
│   │   ├── notification.service.ts  # FCM + APNs
│   │   ├── ai-summary.service.ts    # Claude AI integration
│   │   ├── ai-coaching.service.ts   # Daily DSAA coaching
│   │   ├── trend.service.ts         # Long-term aggregation
│   │   └── scheduler.service.ts     # BullMQ job scheduling
│   ├── jobs/
│   │   ├── reminder.job.ts          # Process scheduled reminders
│   │   ├── weekly-summary.job.ts    # Generate end-of-week AI summary
│   │   ├── trend-aggregate.job.ts   # Compute weekly trend data
│   │   └── streak-calculator.job.ts # Update habit streaks
│   └── types/
│       └── index.ts                 # Shared TypeScript interfaces
├── migrations/                      # Knex migrations
├── seeds/                           # Seed data
├── package.json
├── tsconfig.json
└── .env.example
```

### API Endpoints

#### Authentication
```
POST   /api/auth/register        # Create account
POST   /api/auth/login            # Login → JWT + refresh token
POST   /api/auth/refresh          # Refresh JWT
PUT    /api/auth/profile          # Update profile, timezone, notification prefs
PUT    /api/auth/push-token       # Register FCM/APNs push token
```

#### Weekly Operating Sheets
```
GET    /api/weekly-sheets                      # List all sheets (paginated)
GET    /api/weekly-sheets/current              # Get current week's sheet (auto-create if missing)
GET    /api/weekly-sheets/:id                  # Get specific sheet with all nested data
POST   /api/weekly-sheets                      # Create new sheet (auto-populates from template)
PUT    /api/weekly-sheets/:id                  # Update sheet fields
PUT    /api/weekly-sheets/:id/constraint       # Update constraint deep-dive section
PUT    /api/weekly-sheets/:id/dsaa-queue       # Update DSAA queue
PUT    /api/weekly-sheets/:id/ai-plan          # Update AI leverage plan
PUT    /api/weekly-sheets/:id/time-blocks      # Update calendar time blocks
PUT    /api/weekly-sheets/:id/incident         # Update incident/postmortem checklist
PUT    /api/weekly-sheets/:id/adr              # Update ADR checklist
PUT    /api/weekly-sheets/:id/scorecard        # Fill Friday scorecard
POST   /api/weekly-sheets/:id/complete         # Mark week as completed → triggers AI summary
POST   /api/weekly-sheets/:id/carry-forward    # Create next week from this week's unfinished items
```

#### Outcomes (nested under weekly sheet)
```
GET    /api/weekly-sheets/:sheetId/outcomes
POST   /api/weekly-sheets/:sheetId/outcomes
PUT    /api/weekly-sheets/:sheetId/outcomes/:id
DELETE /api/weekly-sheets/:sheetId/outcomes/:id
PUT    /api/weekly-sheets/:sheetId/outcomes/:id/status  # Mark done/blocked/carried_over
```

#### Leadership Decisions
```
GET    /api/weekly-sheets/:sheetId/decisions
POST   /api/weekly-sheets/:sheetId/decisions
PUT    /api/weekly-sheets/:sheetId/decisions/:id
PUT    /api/weekly-sheets/:sheetId/decisions/:id/resolve  # Record decision result
```

#### Habits
```
GET    /api/habits                  # List user's habits (with current streaks)
POST   /api/habits                  # Create custom habit
PUT    /api/habits/:id              # Update habit
DELETE /api/habits/:id              # Deactivate habit
PUT    /api/habits/reorder          # Reorder habits (drag-and-drop)
GET    /api/habits/:id/stats        # Get habit statistics (streak, completion rate, trends)
```

#### Habit Logs
```
GET    /api/habit-logs?date=YYYY-MM-DD              # Get all logs for a date
GET    /api/habit-logs?from=DATE&to=DATE             # Date range
POST   /api/habit-logs                                # Log a habit completion
PUT    /api/habit-logs/:id                            # Update log
POST   /api/habit-logs/bulk                           # Bulk log (check-off multiple habits at once)
GET    /api/habit-logs/summary?period=week|month|quarter  # Aggregated summary
```

#### DSAA Daily Ritual
```
GET    /api/dsaa/today               # Get today's log (or empty template)
POST   /api/dsaa/log                 # Log today's DSAA ritual
PUT    /api/dsaa/log/:id             # Update log
GET    /api/dsaa/history             # List past logs (paginated)
GET    /api/dsaa/stats               # DSAA stats (streaks, category distribution, leverage trends)
POST   /api/dsaa/ai-suggest          # Get AI suggestion for today's DSAA action
```

#### Reminders
```
GET    /api/reminders                # List active reminders
POST   /api/reminders                # Create custom reminder
PUT    /api/reminders/:id            # Update reminder
DELETE /api/reminders/:id            # Delete reminder
POST   /api/reminders/setup-defaults # Create default EM reminders
```

#### AI Services
```
POST   /api/ai/weekly-summary       # Generate AI summary for a completed week
POST   /api/ai/daily-coaching       # Get AI coaching for today's focus
POST   /api/ai/dsaa-suggest         # AI suggests best DSAA action
POST   /api/ai/constraint-analysis  # AI analyzes constraint + error budget data
POST   /api/ai/trend-insight        # AI generates insight from long-term trends
POST   /api/ai/habit-insight        # AI analyzes habit patterns and suggests improvements
POST   /api/ai/scorecard-insight    # AI interprets weekly scorecard metrics
```

#### Trends & Analytics
```
GET    /api/trends/weekly?weeks=12          # Last N weeks of trend data
GET    /api/trends/habits?period=month      # Habit completion trends
GET    /api/trends/dsaa?period=quarter      # DSAA action distribution over time
GET    /api/trends/deep-work?period=month   # Deep work hours trend
GET    /api/trends/outcomes?period=quarter  # Outcome completion rates
GET    /api/trends/dashboard                # Combined dashboard data (all key metrics)
```

### AI Service Implementation Details

#### Weekly Summary Prompt (called when week is completed)
```typescript
const WEEKLY_SUMMARY_SYSTEM_PROMPT = `
You are an operating coach for a hardcore Engineering Manager who owns Web3/DEX, Exchange, Fiat On/Off Ramp, Crypto Pay, and AI Platform products.

Your job is to analyze their completed weekly operating sheet and provide:
1. A concise summary (3-5 sentences) of what was accomplished vs planned
2. Top wins and blockers
3. Error budget / reliability health assessment
4. DSAA effectiveness rating (did they Delete/Simplify enough?)
5. One specific recommendation for next week
6. A coaching note on sustainability (deep work hours, reactive budget adherence)

Be direct, data-driven, no fluff. Use the SRE/DORA/SPACE frameworks implicitly.
Format as JSON: { "summary": "...", "wins": [...], "blockers": [...], "reliability_health": "...", "dsaa_rating": "...", "recommendation": "...", "coaching_note": "..." }
`;
```

#### Daily DSAA Coaching Prompt
```typescript
const DSAA_COACHING_PROMPT = `
You are an engineering manager operating coach using the DSAA framework (Delete → Simplify → Accelerate → Automate).

Given the manager's current context (today's constraint, calendar, friction list), suggest ONE high-leverage 15-minute action.

Rules:
- Prefer Delete and Simplify over Accelerate and Automate
- The action must be completable in exactly 15 minutes
- It must produce a concrete micro-artifact
- Include a 1-line message template they can send to their team

Format as JSON: { "dsaa_action": "delete|simplify|accelerate|automate", "action_description": "...", "micro_artifact": "...", "team_message": "...", "expected_leverage": "..." }
`;
```

#### Trend Analysis Prompt
```typescript
const TREND_ANALYSIS_PROMPT = `
You are a data analyst for an Engineering Manager's personal operating system.

Given N weeks of trend data (deep work hours, habit completion rates, DSAA actions, outcomes completed, error budget status, DORA metrics, friction pulse), identify:
1. The strongest positive trend
2. The most concerning declining trend  
3. A pattern the manager might not have noticed
4. One specific, actionable suggestion

Be concise and data-specific. Reference actual numbers from the data.
Format as JSON: { "positive_trend": "...", "concerning_trend": "...", "hidden_pattern": "...", "suggestion": "..." }
`;
```

### Notification/Reminder System

The reminder engine uses BullMQ to schedule jobs. Here are the default reminders:

```typescript
const DEFAULT_REMINDERS = [
    {
        title: "Fill Weekly Operating Sheet",
        body: "Time to set up your Top 3 Outcomes, Constraint Deep-Dive, and DSAA Queue for the week.",
        reminder_type: "weekly_fill",
        schedule_type: "weekly",
        scheduled_time: "20:00",     // Sunday evening
        scheduled_days: ["sun"]
    },
    {
        title: "DSAA 15-Minute Ritual",
        body: "Pick 1 friction point → Apply DSAA → Produce 1 micro-artifact. Go!",
        reminder_type: "dsaa_ritual",
        schedule_type: "daily",
        scheduled_time: "09:00",     // configurable per user
        scheduled_days: ["mon","tue","wed","thu","fri"]
    },
    {
        title: "Deep Work Block Starting",
        body: "Your hardcore deep work block starts now. Silence notifications. Focus.",
        reminder_type: "deep_work_start",
        schedule_type: "weekly",
        scheduled_time: null,        // derived from weekly time_blocks
        scheduled_days: null
    },
    {
        title: "Deep Work Block Ending",
        body: "Deep work block ending in 10 minutes. Wrap up and capture notes.",
        reminder_type: "deep_work_end",
        schedule_type: "weekly",
        scheduled_time: null,
        scheduled_days: null
    },
    {
        title: "Reactive Window Open",
        body: "Reactive window now. Handle Slack, emails, quick decisions. Time-boxed!",
        reminder_type: "reactive_window",
        schedule_type: "daily",
        scheduled_time: "14:00",
        scheduled_days: ["mon","tue","wed","thu","fri"]
    },
    {
        title: "Friday Scorecard Time",
        body: "Fill your weekly scorecard: DORA metrics, SLO compliance, SPACE-lite, AI health.",
        reminder_type: "scorecard_fill",
        schedule_type: "weekly",
        scheduled_time: "16:00",
        scheduled_days: ["fri"]
    },
    {
        title: "Incident Pipeline Check",
        body: "Review P0/P1 incidents, postmortem status, action items. Choose 1 prevention bet.",
        reminder_type: "incident_review",
        schedule_type: "weekly",
        scheduled_time: "10:00",
        scheduled_days: ["fri"]
    },
    {
        title: "Midweek Check",
        body: "Midweek: How's the constraint deep-dive? Any risks to Top 3 Outcomes? Adjust.",
        reminder_type: "custom",
        schedule_type: "weekly",
        scheduled_time: "10:00",
        scheduled_days: ["wed"]
    },
    {
        title: "End-of-Day Habit Check",
        body: "Log your habits for today before you sign off!",
        reminder_type: "habit_check",
        schedule_type: "daily",
        scheduled_time: "18:00",
        scheduled_days: ["mon","tue","wed","thu","fri"]
    }
];
```

---

## PART 4: ANDROID APP (Kotlin + Jetpack Compose)

### Project Structure

```
android/
├── app/src/main/java/com/emops/
│   ├── EMOpsApp.kt                        # Application class
│   ├── MainActivity.kt
│   ├── di/                                # Hilt dependency injection
│   │   ├── AppModule.kt
│   │   ├── NetworkModule.kt
│   │   └── DatabaseModule.kt
│   ├── data/
│   │   ├── local/
│   │   │   ├── AppDatabase.kt             # Room database
│   │   │   ├── dao/
│   │   │   │   ├── WeeklySheetDao.kt
│   │   │   │   ├── HabitDao.kt
│   │   │   │   ├── HabitLogDao.kt
│   │   │   │   ├── DsaaLogDao.kt
│   │   │   │   └── ReminderDao.kt
│   │   │   └── entity/
│   │   │       ├── WeeklySheetEntity.kt
│   │   │       ├── HabitEntity.kt
│   │   │       ├── HabitLogEntity.kt
│   │   │       └── DsaaLogEntity.kt
│   │   ├── remote/
│   │   │   ├── ApiService.kt              # Retrofit API interface
│   │   │   ├── AuthInterceptor.kt
│   │   │   └── dto/                       # Data transfer objects
│   │   └── repository/
│   │       ├── AuthRepository.kt
│   │       ├── WeeklySheetRepository.kt
│   │       ├── HabitRepository.kt
│   │       ├── DsaaRepository.kt
│   │       ├── ReminderRepository.kt
│   │       └── TrendsRepository.kt
│   ├── domain/
│   │   └── model/
│   │       ├── WeeklySheet.kt
│   │       ├── Outcome.kt
│   │       ├── Habit.kt
│   │       ├── HabitLog.kt
│   │       ├── DsaaLog.kt
│   │       └── TrendData.kt
│   ├── ui/
│   │   ├── theme/
│   │   │   ├── Color.kt
│   │   │   ├── Typography.kt
│   │   │   └── Theme.kt
│   │   ├── navigation/
│   │   │   └── NavGraph.kt
│   │   ├── screens/
│   │   │   ├── dashboard/
│   │   │   │   ├── DashboardScreen.kt      # Main hub
│   │   │   │   └── DashboardViewModel.kt
│   │   │   ├── weekly/
│   │   │   │   ├── WeeklySheetScreen.kt     # Full weekly sheet editor
│   │   │   │   ├── WeeklySheetViewModel.kt
│   │   │   │   ├── OutcomesSection.kt
│   │   │   │   ├── ConstraintSection.kt
│   │   │   │   ├── DsaaQueueSection.kt
│   │   │   │   ├── AiPlanSection.kt
│   │   │   │   ├── TimeBlocksSection.kt
│   │   │   │   ├── IncidentSection.kt
│   │   │   │   ├── AdrSection.kt
│   │   │   │   └── ScorecardSection.kt
│   │   │   ├── habits/
│   │   │   │   ├── HabitsScreen.kt          # Daily habit tracker
│   │   │   │   ├── HabitsViewModel.kt
│   │   │   │   ├── HabitDetailScreen.kt
│   │   │   │   └── HabitEditScreen.kt
│   │   │   ├── dsaa/
│   │   │   │   ├── DsaaRitualScreen.kt      # Daily 15-min DSAA
│   │   │   │   ├── DsaaViewModel.kt
│   │   │   │   └── DsaaHistoryScreen.kt
│   │   │   ├── trends/
│   │   │   │   ├── TrendsScreen.kt          # Charts & analytics
│   │   │   │   └── TrendsViewModel.kt
│   │   │   ├── ai/
│   │   │   │   ├── AiCoachScreen.kt         # AI insights & coaching
│   │   │   │   └── AiCoachViewModel.kt
│   │   │   └── settings/
│   │   │       ├── SettingsScreen.kt
│   │   │       └── SettingsViewModel.kt
│   │   └── components/
│   │       ├── StreakBadge.kt
│   │       ├── ProgressRing.kt
│   │       ├── ErrorBudgetIndicator.kt
│   │       ├── DsaaFocusCard.kt
│   │       ├── HabitCheckItem.kt
│   │       ├── WeeklyMiniCalendar.kt
│   │       ├── ScorecardChart.kt
│   │       └── AiInsightCard.kt
│   └── service/
│       ├── EMOpsFirebaseService.kt         # FCM push handling
│       └── ReminderWorker.kt               # WorkManager local reminders
├── app/src/main/res/
│   └── ...
└── build.gradle.kts
```

### Screen Designs

#### 1. Dashboard Screen (Home)
```
┌─────────────────────────────────┐
│  EMOPS                  ⚙️  👤  │
│─────────────────────────────────│
│  Good morning! Week 12, 2026    │
│  ┌────────────────────────────┐ │
│  │ 🔥 DSAA Streak: 14 days   │ │
│  │ Deep Work: 1.5h / 1.5h ✅ │ │
│  │ Habits: 8/13 today        │ │
│  └────────────────────────────┘ │
│                                 │
│  ┌─ This Week's Focus ────────┐ │
│  │ Constraint: Fiat payout    │ │
│  │ latency spikes             │ │
│  │ Error Budget: 🟡 BURNING   │ │
│  │ DSAA Focus: Simplify       │ │
│  └────────────────────────────┘ │
│                                 │
│  ┌─ Top 3 Outcomes ──────────┐ │
│  │ ✅ Onchain Pay demo        │ │
│  │ 🔄 Chat AI review accel.  │ │
│  │ 🔄 Fiat flow health check │ │
│  └────────────────────────────┘ │
│                                 │
│  ┌─ AI Coach ────────────────┐ │
│  │ "Your deep work hours are  │ │
│  │  trending up 23% this      │ │
│  │  month. Focus on the fiat  │ │
│  │  constraint today."        │ │
│  └────────────────────────────┘ │
│                                 │
│  ┌─ Upcoming ────────────────┐ │
│  │ 10:00 Deep Work Block      │ │
│  │ 14:00 Reactive Window      │ │
│  │ 16:00 Scorecard Fill (Fri) │ │
│  └────────────────────────────┘ │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  🏠   📋   ✅   📊   🤖       │
│  Home Sheet Habits Trends AI    │
└─────────────────────────────────┘
```

#### 2. Weekly Sheet Screen (Tabbed/Scrollable)
```
┌─────────────────────────────────┐
│ ← Weekly Sheet   Week 12, 2026  │
│─────────────────────────────────│
│ [Identity][Goals][Constraint]   │
│ [DSAA][AI][Calendar][Score]     │
│─────────────────────────────────│
│                                 │
│  (Each tab shows that section   │
│   of the weekly operating       │
│   template as an editable form) │
│                                 │
│  ┌─ Quick Actions ────────────┐ │
│  │ [Fill from last week]      │ │
│  │ [Carry forward items]      │ │
│  │ [Generate AI summary]      │ │
│  │ [Complete this week]       │ │
│  └────────────────────────────┘ │
└─────────────────────────────────┘
```

#### 3. Daily Habits Screen
```
┌─────────────────────────────────┐
│ ← Today's Habits    Mar 19      │
│─────────────────────────────────│
│  Progress: ████████░░░ 8/13     │
│  Streak: 🔥 14 days             │
│─────────────────────────────────│
│                                 │
│  DEEP WORK & PRODUCTIVITY       │
│  ☑ Deep Work Block     1.5h  ✅│
│  ☑ DSAA 15-Min Ritual        ✅│
│  ☐ Free-Thinking Walk        ⬜│
│                                 │
│  RELIABILITY & SRE              │
│  ☑ SLO/Budget Check          ✅│
│  ☐ Incident Pipeline Review  ⬜│
│                                 │
│  DELIVERY & DORA                │
│  ☑ PR Review Queue Clear     ✅│
│                                 │
│  SECURITY                       │
│  ☑ Security Guardrails       ✅│
│                                 │
│  ... (scrollable)               │
│                                 │
│  [+ Add Custom Habit]           │
│                                 │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  🏠   📋   ✅   📊   🤖       │
└─────────────────────────────────┘
```

#### 4. DSAA Ritual Screen
```
┌─────────────────────────────────┐
│ ← DSAA Ritual       15:00 ⏱️   │
│─────────────────────────────────│
│                                 │
│  ┌─ AI Suggestion ────────────┐ │
│  │ 💡 SIMPLIFY: Merge the 2   │ │
│  │ duplicate SLO dashboards   │ │
│  │ into one shared view.      │ │
│  │                            │ │
│  │ Artifact: Single dashboard │ │
│  │ link + 2-line Slack msg    │ │
│  │                            │ │
│  │ [Accept] [Modify] [Skip]   │ │
│  └────────────────────────────┘ │
│                                 │
│  ── OR CHOOSE YOUR OWN ──      │
│                                 │
│  Friction Point:                │
│  [________________________]     │
│                                 │
│  DSAA Action:                   │
│  [Delete][Simplify][Accel][Auto]│
│                                 │
│  Micro-Artifact:                │
│  [________________________]     │
│                                 │
│  Expected Leverage:             │
│  [________________________]     │
│                                 │
│  [⏱️ Start 15-Min Timer]       │
│                                 │
│  [Save & Complete Ritual]       │
└─────────────────────────────────┘
```

#### 5. Trends Screen
```
┌─────────────────────────────────┐
│ ← Trends & Analytics           │
│─────────────────────────────────│
│ [Week] [Month] [Quarter]        │
│─────────────────────────────────│
│                                 │
│  Deep Work Hours (12 weeks)     │
│  ┌────────────────────────────┐ │
│  │  📈 Line chart showing     │ │
│  │  weekly deep work hours    │ │
│  │  with target line at 7.5h  │ │
│  └────────────────────────────┘ │
│                                 │
│  Habit Completion Rate          │
│  ┌────────────────────────────┐ │
│  │  📊 Bar chart per week     │ │
│  └────────────────────────────┘ │
│                                 │
│  DSAA Distribution              │
│  ┌────────────────────────────┐ │
│  │  🍩 Pie: D/S/A/A split    │ │
│  └────────────────────────────┘ │
│                                 │
│  Outcome Completion             │
│  ┌────────────────────────────┐ │
│  │  ✅ 2/3  ✅ 3/3  ✅ 1/3   │ │
│  └────────────────────────────┘ │
│                                 │
│  ┌─ AI Trend Insight ────────┐ │
│  │ "Your Simplify actions are │ │
│  │  yielding 2x more leverage │ │
│  │  than Automate..."         │ │
│  └────────────────────────────┘ │
└─────────────────────────────────┘
```

### Color Theme

```kotlin
// Engineering Manager Operating System - Dark theme (primary)
val EMOps_Background = Color(0xFF0F1117)
val EMOps_Surface = Color(0xFF1A1D27)
val EMOps_SurfaceVariant = Color(0xFF242836)
val EMOps_Primary = Color(0xFF6C8CFF)       // Action blue
val EMOps_Secondary = Color(0xFF00D4AA)     // Success green
val EMOps_Warning = Color(0xFFFFB84D)       // Warning amber
val EMOps_Error = Color(0xFFFF6B6B)         // Error red
val EMOps_Text = Color(0xFFE8ECF4)
val EMOps_TextSecondary = Color(0xFF8B95A8)

// DSAA Category Colors
val DSAA_Delete = Color(0xFFFF6B6B)         // Red - remove
val DSAA_Simplify = Color(0xFFFFB84D)       // Amber - reduce
val DSAA_Accelerate = Color(0xFF6C8CFF)     // Blue - speed up
val DSAA_Automate = Color(0xFF00D4AA)       // Green - automate

// Error Budget Status
val Budget_Healthy = Color(0xFF00D4AA)
val Budget_Burning = Color(0xFFFFB84D)
val Budget_Exhausted = Color(0xFFFF6B6B)
```

---

## PART 5: iOS APP (Swift + SwiftUI)

### Project Structure

```
ios/EMOps/
├── EMOpsApp.swift
├── ContentView.swift
├── Models/
│   ├── WeeklySheet.swift
│   ├── Outcome.swift
│   ├── LeadershipDecision.swift
│   ├── Habit.swift
│   ├── HabitLog.swift
│   ├── DsaaLog.swift
│   ├── Reminder.swift
│   └── TrendData.swift
├── Services/
│   ├── APIService.swift            # URLSession-based API client
│   ├── AuthService.swift           # JWT management + Keychain
│   ├── NotificationService.swift   # Local + Push notification handling
│   ├── PersistenceController.swift # CoreData stack
│   └── SyncService.swift           # Offline-first sync
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── WeeklySheetViewModel.swift
│   ├── HabitsViewModel.swift
│   ├── DsaaViewModel.swift
│   ├── TrendsViewModel.swift
│   └── AiCoachViewModel.swift
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── WeekSummaryCard.swift
│   │   ├── OutcomesCard.swift
│   │   └── UpcomingCard.swift
│   ├── WeeklySheet/
│   │   ├── WeeklySheetView.swift
│   │   ├── IdentitySection.swift
│   │   ├── OutcomesSection.swift
│   │   ├── ConstraintSection.swift
│   │   ├── DsaaQueueSection.swift
│   │   ├── AiPlanSection.swift
│   │   ├── TimeBlocksSection.swift
│   │   ├── IncidentSection.swift
│   │   ├── AdrSection.swift
│   │   └── ScorecardSection.swift
│   ├── Habits/
│   │   ├── HabitsView.swift
│   │   ├── HabitRow.swift
│   │   ├── HabitDetailView.swift
│   │   └── HabitEditView.swift
│   ├── DSAA/
│   │   ├── DsaaRitualView.swift
│   │   ├── DsaaSuggestionCard.swift
│   │   ├── DsaaTimerView.swift
│   │   └── DsaaHistoryView.swift
│   ├── Trends/
│   │   ├── TrendsView.swift
│   │   ├── DeepWorkChart.swift
│   │   ├── HabitCompletionChart.swift
│   │   ├── DsaaDistributionChart.swift
│   │   └── OutcomeTracker.swift
│   ├── AI/
│   │   ├── AiCoachView.swift
│   │   └── AiInsightCard.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── StreakBadge.swift
│       ├── ProgressRing.swift
│       ├── ErrorBudgetIndicator.swift
│       ├── EMOpsCard.swift
│       └── TabBar.swift
├── CoreData/
│   └── EMOps.xcdatamodeld
├── Resources/
│   ├── Assets.xcassets
│   └── Colors.xcassets
└── Info.plist
```

### iOS follows the same screen designs as Android (see Part 4)

The SwiftUI views mirror the Compose screens. Use Swift Charts (iOS 16+) for trend visualizations.

---

## PART 6: SHARED DATA MODELS (TypeScript — source of truth)

These TypeScript interfaces are the canonical data models. Android (Kotlin data classes) and iOS (Swift structs/Codable) should mirror them exactly.

```typescript
// ============================================================
// Shared Types — used by backend, generated for mobile clients
// ============================================================

export interface User {
    id: string;
    email: string;
    displayName: string;
    timezone: string;
    role: string;
    surfaces: string[];
    notificationPreferences: NotificationPreferences;
    dsaaTriggerTime: string;    // "HH:mm"
    dsaaTriggerEvent: string;
    deepWorkHoursTarget: number;
}

export interface NotificationPreferences {
    dailyDsaaReminder: boolean;
    weeklyFillReminder: boolean;
    deepWorkStartAlert: boolean;
    scorecardFridayReminder: boolean;
    reactiveWindowAlerts: boolean;
    incidentPipelineCheck: boolean;
}

export interface WeeklySheet {
    id: string;
    userId: string;
    weekStart: string;          // "YYYY-MM-DD"
    weekLabel: string;
    status: 'draft' | 'active' | 'completed' | 'archived';

    // Week Identity
    surfacesInScope: string[];
    oncallOwnership: string;
    keyDependencies: string;
    nonNegotiableConstraints: string;

    // Constraint Deep-Dive
    constraintStatement: string;
    constraintEvidence: ConstraintEvidence;
    constraintSloService: string;
    constraintSloTargets: string;
    constraintErrorBudgetStatus: 'healthy' | 'burning' | 'exhausted';
    constraintExhaustedAction: string;

    // DSAA
    dsaaQueue: DsaaQueue;
    dsaaFocusThisWeek: 'delete' | 'simplify' | 'accelerate' | 'automate';

    // AI Plan
    aiTasks: AiTask[];
    aiGuardrailsChecked: string[];

    // Time Blocks
    timeBlocks: Record<string, DayTimeBlock>;

    // Checklists
    incidentChecklist: IncidentChecklist;
    adrChecklist: AdrChecklist;

    // Scorecard
    scorecard: WeeklyScorecard | null;

    // AI-generated
    aiWeeklySummary: string | null;
    aiCoachingNotes: string | null;

    // Nested
    outcomes: Outcome[];
    decisions: LeadershipDecision[];

    createdAt: string;
    updatedAt: string;
    completedAt: string | null;
}

export interface ConstraintEvidence {
    sliDashboards: string;
    incidentPattern: string;
    queueLag: string;
    costRegression: string;
}

export interface DsaaQueue {
    delete: string[];
    simplify: string[];
    accelerate: string[];
    automate: string[];
}

export interface DayTimeBlock {
    deepWork: string;
    freeThinking: string;
    reactiveBudget: string;
    keyMeeting: string;
}

export interface AiTask {
    task: string;
    enabled: boolean;
    owner: string;
}

export interface IncidentChecklist {
    p0p1Reviewed: boolean;
    postmortemScheduled: boolean;
    actionItemsOwned: boolean;
    runbooksUpdated: boolean;
    preventionBetChosen: boolean;
}

export interface AdrChecklist {
    adrLinkExists: boolean;
    alternativesConsidered: boolean;
    rolloutRollbackPlan: boolean;
    observabilityPlan: boolean;
    dataContractsChecked: boolean;
}

export interface WeeklyScorecard {
    dora: {
        deployFreq: MetricEntry;
        leadTime: MetricEntry;
        changeFailRate: MetricEntry;
        timeToRestore: MetricEntry;
    };
    slo: {
        compliance: MetricEntry;
        errorBudgetBurn: MetricEntry;
    };
    space: {
        deepWorkHours: MetricEntry;
        frictionPulse: MetricEntry;
    };
    aiHealth: {
        assistedPct: MetricEntry;
        riskCatches: MetricEntry;
    };
}

export interface MetricEntry {
    definition: string;
    thisWeek: string;
    target: string;
    notes: string;
}

export interface Outcome {
    id: string;
    sheetId: string;
    position: number;
    outcomeText: string;
    impact: string;
    definitionOfDone: string;
    owner: string;
    riskAndMitigation: string;
    status: 'in_progress' | 'done' | 'blocked' | 'carried_over';
    completedAt: string | null;
}

export interface LeadershipDecision {
    id: string;
    sheetId: string;
    position: number;
    decisionText: string;
    byWhen: string;
    inputsNeeded: string;
    status: 'pending' | 'decided' | 'deferred';
    decisionResult: string | null;
}

export interface Habit {
    id: string;
    userId: string;
    name: string;
    description: string;
    category: HabitCategory;
    frequency: 'daily' | 'weekday' | 'weekly' | 'custom';
    customDays: string[] | null;
    targetValue: number;
    targetUnit: 'hours' | 'count' | 'boolean' | 'percentage';
    reminderTime: string | null;
    reminderEnabled: boolean;
    streakCurrent: number;
    streakBest: number;
    isActive: boolean;
    sortOrder: number;
}

export type HabitCategory =
    | 'deep_work'
    | 'reliability'
    | 'delivery'
    | 'security'
    | 'ai_safety'
    | 'leadership'
    | 'health'
    | 'learning';

export interface HabitLog {
    id: string;
    habitId: string;
    userId: string;
    logDate: string;
    value: number | null;
    isCompleted: boolean;
    notes: string;
}

export interface DsaaLog {
    id: string;
    userId: string;
    sheetId: string | null;
    logDate: string;
    frictionPoint: string;
    dsaaAction: 'delete' | 'simplify' | 'accelerate' | 'automate';
    microArtifactType: string;
    microArtifactDescription: string;
    expectedLeverage: string;
    startedAt: string | null;
    completedAt: string | null;
    durationMinutes: number | null;
    aiSuggestedAction: string | null;
    aiSuggestionAccepted: boolean;
}

export interface TrendData {
    weekStart: string;
    deepWorkHoursTotal: number;
    dsaaRitualsCompleted: number;
    habitsCompletionRate: number;
    outcomesCompleted: number;
    outcomesTotal: number;
    decisionsMade: number;
    decisionsTotal: number;
    incidentsReviewed: boolean;
    errorBudgetStatus: string;
    doraScores: Record<string, any>;
    aiAssistsCount: number;
    streakDays: number;
    frictionPulseAvg: number;
    aiTrendInsight: string | null;
}

export interface DashboardData {
    currentSheet: WeeklySheet | null;
    todayHabits: { total: number; completed: number; habits: (Habit & { todayLog: HabitLog | null })[] };
    dsaaStreak: number;
    todayDsaa: DsaaLog | null;
    upcomingReminders: Reminder[];
    aiCoachingNote: string | null;
    weeklyProgress: {
        outcomesCompleted: number;
        outcomesTotal: number;
        deepWorkHoursThisWeek: number;
        deepWorkHoursTarget: number;
    };
}
```

---

## PART 7: IMPLEMENTATION PRIORITIES & CODING ORDER

### Phase 1 (Hours 1-2): Backend Foundation
1. Initialize Node.js/TS project with Express, configure ESLint, tsconfig
2. Set up PostgreSQL connection with Knex migrations
3. Run all migrations to create tables
4. Implement auth (register/login/JWT/refresh)
5. Implement CRUD for weekly sheets (all sections)
6. Implement CRUD for outcomes and decisions
7. Implement CRUD for habits and habit logs
8. Implement DSAA daily log endpoints
9. Seed default habits on user creation

### Phase 2 (Hour 3): Backend Intelligence
1. Set up Redis + BullMQ
2. Implement reminder scheduling engine
3. Implement push notification service (FCM + APNs placeholders)
4. Implement AI summary service (Claude API integration)
5. Implement AI coaching service
6. Implement trend aggregation job
7. Implement streak calculator job
8. Wire up all AI endpoints
9. Add weekly auto-creation (if current week sheet doesn't exist, create on GET)

### Phase 3 (Hour 4): Android App
1. Create project with Compose, Hilt, Room, Retrofit
2. Set up theme (colors above), navigation, bottom bar
3. Implement auth screens (login/register)
4. Implement Dashboard screen
5. Implement Weekly Sheet editor (tabbed form)
6. Implement Habits daily tracker (checkbox list with categories)
7. Implement DSAA ritual screen (with 15-min timer)
8. Implement Trends screen (basic charts)
9. Wire up FCM for push notifications
10. Implement offline-first with Room caching

### Phase 4 (Hour 5): iOS App
1. Create Xcode project with SwiftUI, CoreData, Combine
2. Set up theme, tab navigation
3. Implement auth screens
4. Implement Dashboard view
5. Implement Weekly Sheet editor
6. Implement Habits daily tracker
7. Implement DSAA ritual view (with timer)
8. Implement Trends view (Swift Charts)
9. Wire up APNs for push notifications
10. Implement offline-first with CoreData

### Phase 5 (Hour 6): Integration & Polish
1. End-to-end testing: register → fill sheet → log habits → DSAA → scorecard → AI summary
2. Test push notifications flow
3. Test offline sync
4. Add error handling and loading states
5. Add onboarding flow (first-time setup of timezone, surfaces, DSAA trigger)
6. Write README with setup instructions
7. Docker Compose for backend (postgres + redis + api)
8. Final code review and cleanup

---

## PART 8: ENVIRONMENT & CONFIG

### .env.example (Backend)
```
# Server
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=postgresql://emops:emops@localhost:5432/emops

# Redis
REDIS_URL=redis://localhost:6379

# Auth
JWT_SECRET=your-jwt-secret-here
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# Anthropic AI
ANTHROPIC_API_KEY=your-anthropic-api-key

# Firebase (Android push)
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# APNs (iOS push)
APNS_KEY_ID=
APNS_TEAM_ID=
APNS_BUNDLE_ID=com.emops.app
APNS_KEY_PATH=./AuthKey.p8
```

### docker-compose.yml
```yaml
version: '3.8'
services:
  api:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://emops:emops@postgres:5432/emops
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: emops
      POSTGRES_PASSWORD: emops
      POSTGRES_DB: emops
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  pgdata:
```

---

## PART 9: KEY BUSINESS RULES

1. **Weekly sheet auto-creation:** When GET /current is called and no sheet exists for the current week, auto-create one with status 'draft' and populate surfaces from user profile.

2. **Carry-forward:** When a week is completed, any outcomes with status 'in_progress' or 'blocked' become candidates for next week. Decisions with status 'pending' carry forward.

3. **Streak calculation:** A habit streak is broken when the user misses a scheduled day. Streaks are recalculated daily at midnight (user's timezone) via a scheduled job.

4. **Error budget status propagation:** The constraint_error_budget_status field on the weekly sheet should visually propagate to the dashboard (color-coded badge).

5. **DSAA ritual timing:** The 15-minute timer is local (on-device). When the user completes the ritual and saves, the backend records the duration.

6. **AI summaries are cached:** Once an AI weekly summary is generated, it's stored on the sheet. Regeneration requires explicit user action.

7. **Reminders are timezone-aware:** All reminder scheduling uses the user's configured timezone. BullMQ jobs fire at the correct local time.

8. **Offline-first:** Mobile apps should work offline for reading cached data and logging habits/DSAA. Sync happens when connectivity returns.

9. **Friday scorecard lock:** Once a scorecard is filled and the week is completed, the sheet becomes read-only (status: 'completed'). It can be viewed but not edited.

10. **AI guardrails:** No raw user data (secrets, tokens, internal URLs) is ever sent to the AI API. The AI service sanitizes context before sending.

---

## PART 10: GITHUB REPOSITORY STRUCTURE

```
emops/
├── README.md
├── LICENSE
├── .gitignore
├── docker-compose.yml
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   ├── migrations/
│   └── seeds/
├── android/
│   ├── app/
│   ├── build.gradle.kts
│   └── settings.gradle.kts
└── ios/
    ├── EMOps/
    └── EMOps.xcodeproj/
```

---

## APPENDIX A: THE WEEKLY OPERATING TEMPLATE (Reference)

The full weekly operating template from the user's research document is embedded in the weekly_sheets table schema. Each section of the template maps to fields/JSONB columns as follows:

| Template Section | DB Field(s) |
|---|---|
| Week Identity | surfaces_in_scope, oncall_ownership, key_dependencies, non_negotiable_constraints |
| Top 3 Outcomes | weekly_outcomes table (1-3 rows) |
| Constraint Deep-Dive | constraint_* fields |
| DSAA Queue | dsaa_queue JSONB, dsaa_focus_this_week |
| AI Leverage Plan | ai_tasks JSONB, ai_guardrails_checked JSONB |
| Leadership Decisions | leadership_decisions table (1-3 rows) |
| Calendar Time-Blocks | time_blocks JSONB |
| Incident Pipeline | incident_checklist JSONB |
| ADR/Architecture | adr_checklist JSONB |
| Weekly Scorecard | scorecard JSONB |
| DSAA Daily Ritual | dsaa_daily_logs table |

---

## APPENDIX B: NAMING CONVENTIONS

- **App name:** EMOps (Engineering Manager Operations)
- **Package/Bundle ID:** com.emops.app
- **Backend project:** @emops/api
- **Database name:** emops
- **All API paths:** /api/...
- **Date format in API:** ISO 8601 (YYYY-MM-DD for dates, full ISO for timestamps)
- **ID format:** UUID v4

---

## END OF DOCUMENT

This document is designed to be consumed by Claude Code in a single session. Start with Part 7 (Implementation Priorities) and refer to Parts 2-6 for schemas, endpoints, and screen designs as you build each component.
