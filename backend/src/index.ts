import dotenv from 'dotenv';
dotenv.config({ path: '../.env' });

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';

import { errorHandler, notFoundHandler } from './middleware/error.middleware';
import { v4 as uuidv4 } from 'uuid';

// Route imports
import authRoutes from './routes/auth.routes';
import weeklySheetRoutes from './routes/weekly-sheet.routes';
import outcomesRoutes from './routes/outcomes.routes';
import decisionsRoutes from './routes/decisions.routes';
import habitsRoutes from './routes/habits.routes';
import habitLogsRoutes from './routes/habit-logs.routes';
import dsaaRoutes from './routes/dsaa.routes';
import remindersRoutes from './routes/reminders.routes';
import aiRoutes from './routes/ai.routes';
import trendsRoutes from './routes/trends.routes';
import notificationsRoutes from './routes/notifications.routes';

// Job workers
import { startReminderWorker } from './jobs/reminder.job';
import { startWeeklySummaryWorker } from './jobs/weekly-summary.job';
import { startTrendAggregateWorker } from './jobs/trend-aggregate.job';
import { startStreakCalculatorWorker } from './jobs/streak-calculator.job';

// Scheduler
import { initScheduler } from './services/scheduler.service';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use((req, _res, next) => { req.headers['x-request-id'] = req.headers['x-request-id'] || uuidv4(); next(); });

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok',
      version: '0.1.1', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/weekly-sheets', weeklySheetRoutes);
app.use('/api/weekly-sheets/:sheetId/outcomes', outcomesRoutes);
app.use('/api/weekly-sheets/:sheetId/decisions', decisionsRoutes);
app.use('/api/habits', habitsRoutes);
app.use('/api/habit-logs', habitLogsRoutes);
app.use('/api/dsaa', dsaaRoutes);
app.use('/api/reminders', remindersRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/trends', trendsRoutes);
app.use('/api/notifications', notificationsRoutes);

// Global error handler
app.use(notFoundHandler);
app.use(errorHandler);

// Start server + background workers
app.listen(PORT, async () => {
  console.log(`CLAWBOT API running on port ${PORT}`);

  // Initialize BullMQ workers and scheduler
  try {
    startReminderWorker();
    startWeeklySummaryWorker();
    startTrendAggregateWorker();
    startStreakCalculatorWorker();
    await initScheduler();
    console.log('[Workers] All job workers started');
  } catch (err) {
    console.warn('[Workers] Failed to start (Redis may not be available):', (err as Error).message);
  }
});

export default app;
