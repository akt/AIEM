import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { dsaaService } from '../services/dsaa.service';

const router = Router();

router.use(authenticate);

// Schemas
const createDsaaLogSchema = z.object({
  frictionPoint: z.string().min(1).max(1000),
  dsaaAction: z.enum(['delete', 'simplify', 'accelerate', 'automate']),
  microArtifactType: z.string().max(255).optional(),
  microArtifactDescription: z.string().max(2000).optional(),
  expectedLeverage: z.string().max(1000).optional(),
  durationMinutes: z.number().int().positive().optional(),
});

const updateDsaaLogSchema = z.object({
  frictionPoint: z.string().min(1).max(1000).optional(),
  dsaaAction: z.enum(['delete', 'simplify', 'accelerate', 'automate']).optional(),
  microArtifactType: z.string().max(255).optional(),
  microArtifactDescription: z.string().max(2000).optional(),
  expectedLeverage: z.string().max(1000).optional(),
  durationMinutes: z.number().int().positive().nullable().optional(),
  startedAt: z.string().nullable().optional(),
  completedAt: z.string().nullable().optional(),
});

// GET /today -- get today's log
router.get('/today', async (req: Request, res: Response) => {
  try {
    const log = await dsaaService.getToday(req.user!.id);
    res.json({ data: log });
  } catch (err) {
    console.error('Error getting today DSAA log:', err);
    res.status(500).json({ error: 'Failed to get today DSAA log' });
  }
});

// POST /log -- create log
router.post('/log', validate(createDsaaLogSchema), async (req: Request, res: Response) => {
  try {
    const log = await dsaaService.createLog(req.user!.id, req.body);
    res.status(201).json({ data: log });
  } catch (err) {
    console.error('Error creating DSAA log:', err);
    res.status(500).json({ error: 'Failed to create DSAA log' });
  }
});

// PUT /log/:id -- update log
router.put('/log/:id', validate(updateDsaaLogSchema), async (req: Request, res: Response) => {
  try {
    const log = await dsaaService.updateLog(req.params.id, req.user!.id, req.body);
    if (!log) {
      return res.status(404).json({ error: 'DSAA log not found' });
    }
    res.json({ data: log });
  } catch (err) {
    console.error('Error updating DSAA log:', err);
    res.status(500).json({ error: 'Failed to update DSAA log' });
  }
});

// GET /history -- paginated history
router.get('/history', async (req: Request, res: Response) => {
  try {
    const page = Math.max(1, parseInt(req.query.page as string, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string, 10) || 20));
    const result = await dsaaService.getHistory(req.user!.id, page, limit);
    res.json(result);
  } catch (err) {
    console.error('Error getting DSAA history:', err);
    res.status(500).json({ error: 'Failed to get DSAA history' });
  }
});

// GET /stats -- DSAA statistics
router.get('/stats', async (req: Request, res: Response) => {
  try {
    const stats = await dsaaService.getStats(req.user!.id);
    res.json({ data: stats });
  } catch (err) {
    console.error('Error getting DSAA stats:', err);
    res.status(500).json({ error: 'Failed to get DSAA stats' });
  }
});

export default router;
