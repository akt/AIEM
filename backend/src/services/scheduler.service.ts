import { Queue, Worker, Job } from 'bullmq';
import IORedis from 'ioredis';
import { REDIS_URL } from '../config/redis';

// BullMQ needs its own IORedis instances (not shared)
function createConnection() {
  return new IORedis(REDIS_URL, { maxRetriesPerRequest: null }) as any;
}

// ── Queues ──────────────────────────────────────────────────
export const reminderQueue = new Queue('reminders', { connection: createConnection() });
export const weeklySummaryQueue = new Queue('weekly-summary', { connection: createConnection() });
export const trendAggregateQueue = new Queue('trend-aggregate', { connection: createConnection() });
export const streakCalculatorQueue = new Queue('streak-calculator', { connection: createConnection() });

// ── Schedule repeating jobs ─────────────────────────────────
export async function initScheduler(): Promise<void> {
  // Process reminders every minute
  await reminderQueue.upsertJobScheduler('reminder-check', {
    every: 60_000,
  }, { name: 'check-reminders' });

  // Weekly trend aggregation — Sunday 23:00 UTC
  await trendAggregateQueue.upsertJobScheduler('weekly-trend', {
    pattern: '0 23 * * 0',
  }, { name: 'aggregate-trends' });

  // Streak calculator — every day at 00:05 UTC
  await streakCalculatorQueue.upsertJobScheduler('daily-streak', {
    pattern: '5 0 * * *',
  }, { name: 'calculate-streaks' });

  console.log('[Scheduler] Repeating jobs initialized');
}

// ── One-off job triggers ────────────────────────────────────
export async function enqueueWeeklySummary(userId: string, sheetId: string): Promise<void> {
  await weeklySummaryQueue.add('generate-summary', { userId, sheetId });
}

export async function enqueueTrendAggregate(userId: string, weekStart: string): Promise<void> {
  await trendAggregateQueue.add('aggregate-user', { userId, weekStart });
}

export { Worker, Job, createConnection };
