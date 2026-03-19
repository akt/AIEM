import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
  generateWeeklySummary,
  generateTrendInsight,
  generateConstraintAnalysis,
  generateHabitInsight,
  generateScorecardInsight,
} from '../services/ai-summary.service';
import {
  generateDailyCoaching,
  generateDsaaSuggestion,
} from '../services/ai-coaching.service';

const router = Router();
router.use(authenticate);

// POST /api/ai/weekly-summary
router.post('/weekly-summary', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { sheetId } = req.body;
    if (!sheetId) return res.status(400).json({ error: 'sheetId required' });
    const result = await generateWeeklySummary(req.user!.id, sheetId);
    res.json({ insight: JSON.parse(result) });
  } catch (err) {
    if (err instanceof SyntaxError) {
      // AI returned non-JSON, return raw
      return res.json({ insight: (err as any).message });
    }
    next(err);
  }
});

// POST /api/ai/daily-coaching
router.post('/daily-coaching', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await generateDailyCoaching(req.user!.id);
    res.json({ coaching: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

// POST /api/ai/dsaa-suggest
router.post('/dsaa-suggest', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { frictionPoint } = req.body;
    const result = await generateDsaaSuggestion(req.user!.id, frictionPoint);
    res.json({ suggestion: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

// POST /api/ai/constraint-analysis
router.post('/constraint-analysis', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { sheetId } = req.body;
    if (!sheetId) return res.status(400).json({ error: 'sheetId required' });
    const result = await generateConstraintAnalysis(req.user!.id, sheetId);
    res.json({ analysis: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

// POST /api/ai/trend-insight
router.post('/trend-insight', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const weeks = parseInt(req.body.weeks) || 12;
    const result = await generateTrendInsight(req.user!.id, weeks);
    res.json({ insight: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

// POST /api/ai/habit-insight
router.post('/habit-insight', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const period = req.body.period || 'month';
    const result = await generateHabitInsight(req.user!.id, period);
    res.json({ insight: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

// POST /api/ai/scorecard-insight
router.post('/scorecard-insight', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { sheetId } = req.body;
    if (!sheetId) return res.status(400).json({ error: 'sheetId required' });
    const result = await generateScorecardInsight(req.user!.id, sheetId);
    res.json({ insight: JSON.parse(result) });
  } catch (err) {
    next(err);
  }
});

export default router;
