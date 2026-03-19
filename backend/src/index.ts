import dotenv from 'dotenv';
dotenv.config({ path: '../.env' });

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';

import { errorHandler } from './middleware/error.middleware';

// Route imports
import authRoutes from './routes/auth.routes';
import weeklySheetRoutes from './routes/weekly-sheet.routes';
import outcomesRoutes from './routes/outcomes.routes';
import decisionsRoutes from './routes/decisions.routes';
import habitsRoutes from './routes/habits.routes';
import habitLogsRoutes from './routes/habit-logs.routes';
import dsaaRoutes from './routes/dsaa.routes';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/weekly-sheets', weeklySheetRoutes);
app.use('/api/weekly-sheets/:sheetId/outcomes', outcomesRoutes);
app.use('/api/weekly-sheets/:sheetId/decisions', decisionsRoutes);
app.use('/api/habits', habitsRoutes);
app.use('/api/habit-logs', habitLogsRoutes);
app.use('/api/dsaa', dsaaRoutes);

// Global error handler
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`CLAWBOT API running on port ${PORT}`);
});

export default app;
