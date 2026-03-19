import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
  getWeeklyTrends,
  getHabitTrends,
  getDsaaTrends,
  getDeepWorkTrends,
  getOutcomeTrends,
  getDashboardData,
} from '../services/trend.service';

const router = Router();
router.use(authenticate);

// GET /api/trends/weekly?weeks=12
router.get('/weekly', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const weeks = parseInt(req.query.weeks as string) || 12;
    const trends = await getWeeklyTrends(req.user!.id, weeks);
    res.json(trends);
  } catch (err) {
    next(err);
  }
});

// GET /api/trends/habits?period=month
router.get('/habits', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const period = (req.query.period as string) || 'month';
    const data = await getHabitTrends(req.user!.id, period);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/trends/dsaa?period=quarter
router.get('/dsaa', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const period = (req.query.period as string) || 'quarter';
    const data = await getDsaaTrends(req.user!.id, period);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/trends/deep-work?period=month
router.get('/deep-work', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const period = (req.query.period as string) || 'month';
    const data = await getDeepWorkTrends(req.user!.id, period);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/trends/outcomes?period=quarter
router.get('/outcomes', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const period = (req.query.period as string) || 'quarter';
    const data = await getOutcomeTrends(req.user!.id, period);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

// GET /api/trends/dashboard
router.get('/dashboard', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = await getDashboardData(req.user!.id);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

export default router;
