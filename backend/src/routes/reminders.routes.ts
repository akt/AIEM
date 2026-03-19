import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import * as reminderService from '../services/reminder.service';

const router = Router();
router.use(authenticate);

const createReminderSchema = z.object({
  title: z.string().min(1).max(255),
  body: z.string().max(1000).optional(),
  reminderType: z.string().min(1),
  scheduleType: z.enum(['once', 'daily', 'weekly', 'custom']),
  scheduledTime: z.string().nullable().optional(),
  scheduledDays: z.array(z.string()).nullable().optional(),
  scheduledDate: z.string().nullable().optional(),
  linkedEntityType: z.string().nullable().optional(),
  linkedEntityId: z.string().nullable().optional(),
});

const updateReminderSchema = z.object({
  title: z.string().min(1).max(255).optional(),
  body: z.string().max(1000).optional(),
  reminderType: z.string().min(1).optional(),
  scheduleType: z.enum(['once', 'daily', 'weekly', 'custom']).optional(),
  scheduledTime: z.string().nullable().optional(),
  scheduledDays: z.array(z.string()).nullable().optional(),
  scheduledDate: z.string().nullable().optional(),
  isActive: z.boolean().optional(),
});

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
router.post('/', validate(createReminderSchema), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const reminder = await reminderService.createReminder(req.user!.id, req.body);
    res.status(201).json(reminder);
  } catch (err) {
    next(err);
  }
});

// PUT /api/reminders/:id — update reminder
router.put('/:id', validate(updateReminderSchema), async (req: Request, res: Response, next: NextFunction) => {
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
