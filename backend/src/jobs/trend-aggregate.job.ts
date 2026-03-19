import { Worker, Job } from 'bullmq';
import { createConnection } from '../services/scheduler.service';
import db from '../config/database';
import { aggregateWeeklyTrends } from '../services/trend.service';

export function startTrendAggregateWorker(): Worker {
  const worker = new Worker(
    'trend-aggregate',
    async (job: Job) => {
      const { userId, weekStart } = job.data;

      if (userId && weekStart) {
        // Single user aggregation
        console.log(`[TrendAggregateJob] Aggregating for user ${userId}, week ${weekStart}`);
        await aggregateWeeklyTrends(userId, weekStart);
        return { processed: 1 };
      }

      // Batch: aggregate for all users with completed sheets this week
      console.log('[TrendAggregateJob] Running weekly batch aggregation...');
      const lastSunday = getLastSunday();

      const users = await db('users').select('id');
      let processed = 0;

      for (const user of users) {
        try {
          await aggregateWeeklyTrends(user.id, lastSunday);
          processed++;
        } catch (err) {
          console.error(`[TrendAggregateJob] Failed for user ${user.id}:`, err);
        }
      }

      console.log(`[TrendAggregateJob] Aggregated trends for ${processed} users`);
      return { processed };
    },
    { connection: createConnection() },
  );

  worker.on('failed', (job, err) => {
    console.error('[TrendAggregateJob] Failed:', err.message);
  });

  return worker;
}

function getLastSunday(): string {
  const d = new Date();
  const day = d.getUTCDay();
  d.setUTCDate(d.getUTCDate() - day);
  return d.toISOString().slice(0, 10);
}
