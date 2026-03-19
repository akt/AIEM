import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import * as reminderService from '../services/reminder.service';

const router = Router();
router.use(authenticate);

// GET /api/reminders — list active reminders
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reminders = await reminderService.listReminders(req.user!.id);
    res.json(reminders);
  } catch (err) {
    next(err);
  }
});

// POST /api/reminders — create custom reminder
router.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reminder = await reminderService.createReminder(req.user!.id, req.body);
    res.status(201).json(reminder);
  } catch (err) {
    next(err);
  }
});

// PUT /api/reminders/:id — update reminder
router.put('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reminder = await reminderService.updateReminder(req.user!.id, req.params.id, req.body);
    if (!reminder) return res.status(404).json({ error: 'Reminder not found' });
    res.json(reminder);
  } catch (err) {
    next(err);
  }
});

// DELETE /api/reminders/:id — delete reminder
router.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    await reminderService.deleteReminder(req.user!.id, req.params.id);
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

// POST /api/reminders/setup-defaults — create all 9 default EM reminders
router.post('/setup-defaults', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reminders = await reminderService.setupDefaults(req.user!.id);
    res.json(reminders);
  } catch (err) {
    next(err);
  }
});

export default router;
