import { Worker, Job } from 'bullmq';
import { createConnection } from '../services/scheduler.service';
import { updateAllStreaks } from '../services/trend.service';

export function startStreakCalculatorWorker(): Worker {
  const worker = new Worker(
    'streak-calculator',
    async (job: Job) => {
      console.log('[StreakCalculatorJob] Updating all habit streaks...');
      await updateAllStreaks();
      console.log('[StreakCalculatorJob] Streaks updated');
      return { success: true };
    },
    { connection: createConnection() },
  );

  worker.on('failed', (job, err) => {
    console.error('[StreakCalculatorJob] Failed:', err.message);
  });

  return worker;
}
