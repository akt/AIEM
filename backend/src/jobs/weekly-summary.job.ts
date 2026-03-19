import { Worker, Job } from 'bullmq';
import { createConnection } from '../services/scheduler.service';
import { generateWeeklySummary } from '../services/ai-summary.service';

export function startWeeklySummaryWorker(): Worker {
  const worker = new Worker(
    'weekly-summary',
    async (job: Job) => {
      const { userId, sheetId } = job.data;
      console.log(`[WeeklySummaryJob] Generating summary for sheet ${sheetId}`);

      const result = await generateWeeklySummary(userId, sheetId);
      console.log(`[WeeklySummaryJob] Summary generated for sheet ${sheetId}`);
      return { sheetId, generated: true };
    },
    { connection: createConnection() },
  );

  worker.on('failed', (job, err) => {
    console.error(`[WeeklySummaryJob] Failed for sheet ${job?.data?.sheetId}:`, err.message);
  });

  return worker;
}
