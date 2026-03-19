import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { habitLogService } from '../services/habit-log.service';

const router = Router();

router.use(authenticate);

// Schemas
const createLogSchema = z.object({
  habitId: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  value: z.number().nullable().optional(),
  isCompleted: z.boolean(),
  notes: z.string().max(1000).optional(),
});

const updateLogSchema = z.object({
  value: z.number().nullable().optional(),
  isCompleted: z.boolean().optional(),
  notes: z.string().max(1000).optional(),
});

const bulkLogSchema = z.object({
  logs: z.array(
    z.object({
      habitId: z.string().uuid(),
      date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      value: z.number().nullable().optional(),
      isCompleted: z.boolean(),
      notes: z.string().max(1000).optional(),
    }),
  ).min(1).max(100),
});

// GET / -- get logs (query params: date, from, to)
router.get('/', async (req: Request, res: Response) => {
  try {
    const { date, from, to } = req.query;

    if (date && typeof date === 'string') {
      const logs = await habitLogService.getLogsByDate(req.user!.id, date);
      return res.json({ data: logs });
    }

    if (from && to && typeof from === 'string' && typeof to === 'string') {
      const logs = await habitLogService.getLogsByDateRange(req.user!.id, from, to);
      return res.json({ data: logs });
    }

    // Default to today
    const today = new Date().toISOString().split('T')[0];
    const logs = await habitLogService.getLogsByDate(req.user!.id, today);
    res.json({ data: logs });
  } catch (err) {
    console.error('Error getting habit logs:', err);
    res.status(500).json({ error: 'Failed to get habit logs' });
  }
});

// POST / -- create single log
router.post('/', validate(createLogSchema), async (req: Request, res: Response) => {
  try {
    const log = await habitLogService.createLog(req.user!.id, req.body);
    res.status(201).json({ data: log });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Failed to create log';
    console.error('Error creating habit log:', err);
    if (message.includes('not found') || message.includes('not owned')) {
      return res.status(404).json({ error: message });
    }
    res.status(500).json({ error: 'Failed to create habit log' });
  }
});

// POST /bulk -- bulk log
router.post('/bulk', validate(bulkLogSchema), async (req: Request, res: Response) => {
  try {
    const logs = await habitLogService.bulkLog(req.user!.id, req.body.logs);
    res.status(201).json({ data: logs });
  } catch (err) {
    const message = err instanceof Error ? err.message : 'Failed to create logs';
    console.error('Error bulk creating habit logs:', err);
    if (message.includes('not found') || message.includes('not owned')) {
      return res.status(404).json({ error: message });
    }
    res.status(500).json({ error: 'Failed to create habit logs' });
  }
});

// GET /summary -- aggregated summary
router.get('/summary', async (req: Request, res: Response) => {
  try {
    const period = (req.query.period as string) || 'week';
    if (!['week', 'month', 'quarter'].includes(period)) {
      return res.status(400).json({ error: 'Invalid period. Must be week, month, or quarter.' });
    }
    const summary = await habitLogService.getSummary(
      req.user!.id,
      period as 'week' | 'month' | 'quarter',
    );
    res.json({ data: summary });
  } catch (err) {
    console.error('Error getting summary:', err);
    res.status(500).json({ error: 'Failed to get summary' });
  }
});

// PUT /:id -- update log
router.put('/:id', validate(updateLogSchema), async (req: Request, res: Response) => {
  try {
    const log = await habitLogService.updateLog(req.params.id, req.user!.id, req.body);
    if (!log) {
      return res.status(404).json({ error: 'Habit log not found' });
    }
    res.json({ data: log });
  } catch (err) {
    console.error('Error updating habit log:', err);
    res.status(500).json({ error: 'Failed to update habit log' });
  }
});

export default router;
