# CLAUDE CODE — QUICK START PROMPT

Copy and paste this as your FIRST message to Claude Code after opening the project:

---

Read the file `CLAWBOT_PROJECT_PLAN.md` in full. This is a 1,600-line comprehensive project specification for "EMOps" — an Engineering Manager Weekly Operating System.

Your mission for the next 6 hours:

**Hour 1-2: Backend**
- Initialize a Node.js + TypeScript + Express backend in `backend/`
- Set up PostgreSQL with Knex migrations (all tables from Part 2)
- Implement JWT auth (register, login, refresh, profile)
- Implement full CRUD for: weekly sheets, outcomes, decisions, habits, habit logs, DSAA daily logs
- Seed default EM habits on user creation
- Set up docker-compose.yml with postgres + redis + api

**Hour 3: Backend Intelligence**
- Set up Redis + BullMQ for job scheduling
- Implement the reminder/notification engine (Part 3 defaults)
- Integrate Anthropic Claude API for: weekly summaries, daily coaching, DSAA suggestions, trend insights
- Implement trend aggregation and streak calculator jobs
- Wire up all /api/ai/* endpoints

**Hour 4: Android App**
- Create Kotlin + Jetpack Compose project in `android/`
- Implement: theme, navigation, auth, dashboard, weekly sheet editor, habits tracker, DSAA ritual (with 15-min timer), trends charts
- Use Retrofit for API, Room for offline cache, Hilt for DI

**Hour 5: iOS App**
- Create Swift + SwiftUI project in `ios/`
- Mirror all Android screens: dashboard, weekly sheet, habits, DSAA ritual, trends
- Use URLSession for API, CoreData for offline, Swift Charts for trends

**Hour 6: Integration & Polish**
- End-to-end test flow
- Push notification wiring (FCM + APNs)
- Error handling, loading states
- Onboarding flow
- README with setup instructions
- Final cleanup

Follow the exact database schema, API endpoints, screen designs, AI prompts, and color theme defined in the document. The app name is "EMOps" and the package ID is `com.emops.app`.

Start now with the backend project scaffolding.

---

## TIPS FOR THE SESSION

1. **Keep the doc open** — Reference Parts 2-6 constantly for schemas and designs
2. **Don't skip the AI integration** — The Claude API summaries/coaching are a core feature
3. **Offline-first** — Mobile apps must cache data locally (Room/CoreData)
4. **Timezone-aware** — User is in Maldives (UTC+5), all reminders use user timezone
5. **DSAA timer is local** — The 15-minute countdown runs on-device, duration logged to API on completion
6. **Error budget colors** — Healthy=green, Burning=amber, Exhausted=red (see theme in Part 4)
7. **Max 3 outcomes, max 3 decisions** — Enforced at DB level with CHECK constraints
8. **Friday scorecard** — The scorecard section only appears/is editable on Fridays
9. **Carry-forward** — When completing a week, unfinished outcomes/decisions auto-suggest for next week
