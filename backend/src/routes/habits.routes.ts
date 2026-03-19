import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { habitService } from '../services/habit.service';

const router = Router();

router.use(authenticate);

// Schemas
const createHabitSchema = z.object({
  name: z.string().min(1).max(255),
  category: z.enum([
    'deep_work',
    'reliability',
    'delivery',
    'security',
    'ai_safety',
    'leadership',
    'health',
    'learning',
  ]),
  frequency: z.enum(['daily', 'weekday', 'weekly', 'custom']),
  description: z.string().max(1000).optional(),
  targetValue: z.number().positive().optional(),
  targetUnit: z.enum(['hours', 'count', 'boolean', 'percentage']).optional(),
  reminderTime: z.string().optional(),
  customDays: z.array(z.string()).optional(),
});

const updateHabitSchema = z.object({
  name: z.string().min(1).max(255).optional(),
  description: z.string().max(1000).optional(),
  category: z
    .enum([
      'deep_work',
      'reliability',
      'delivery',
      'security',
      'ai_safety',
      'leadership',
      'health',
      'learning',
    ])
    .optional(),
  frequency: z.enum(['daily', 'weekday', 'weekly', 'custom']).optional(),
  customDays: z.array(z.string()).optional(),
  targetValue: z.number().positive().optional(),
  targetUnit: z.enum(['hours', 'count', 'boolean', 'percentage']).optional(),
  reminderTime: z.string().nullable().optional(),
  reminderEnabled: z.boolean().optional(),
});

const reorderSchema = z.object({
  orderedIds: z.array(z.string().uuid()),
});

// GET / -- list habits
router.get('/', async (req: Request, res: Response) => {
  try {
    const habits = await habitService.listHabits(req.user!.id);
    res.json({ data: habits });
  } catch (err) {
    console.error('Error listing habits:', err);
    res.status(500).json({ error: 'Failed to list habits' });
  }
});

// POST / -- create habit
router.post('/', validate(createHabitSchema), async (req: Request, res: Response) => {
  try {
    const habit = await habitService.createHabit(req.user!.id, req.body);
    res.status(201).json({ data: habit });
  } catch (err) {
    console.error('Error creating habit:', err);
    res.status(500).json({ error: 'Failed to create habit' });
  }
});

// PUT /reorder -- reorder habits (must be before /:id)
router.put('/reorder', validate(reorderSchema), async (req: Request, res: Response) => {
  try {
    await habitService.reorderHabits(req.user!.id, req.body.orderedIds);
    res.json({ message: 'Habits reordered successfully' });
  } catch (err) {
    console.error('Error reordering habits:', err);
    res.status(500).json({ error: 'Failed to reorder habits' });
  }
});

// GET /:id/stats -- habit statistics
router.get('/:id/stats', async (req: Request, res: Response) => {
  try {
    const stats = await habitService.getHabitStats(req.params.id, req.user!.id);
    if (!stats) {
      return res.status(404).json({ error: 'Habit not found' });
    }
    res.json({ data: stats });
  } catch (err) {
    console.error('Error getting habit stats:', err);
    res.status(500).json({ error: 'Failed to get habit stats' });
  }
});

// PUT /:id -- update habit
router.put('/:id', validate(updateHabitSchema), async (req: Request, res: Response) => {
  try {
    const habit = await habitService.updateHabit(req.params.id, req.user!.id, req.body);
    if (!habit) {
      return res.status(404).json({ error: 'Habit not found' });
    }
    res.json({ data: habit });
  } catch (err) {
    console.error('Error updating habit:', err);
    res.status(500).json({ error: 'Failed to update habit' });
  }
});

// DELETE /:id -- deactivate habit
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const deleted = await habitService.deleteHabit(req.params.id, req.user!.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Habit not found' });
    }
    res.json({ message: 'Habit deactivated successfully' });
  } catch (err) {
    console.error('Error deleting habit:', err);
    res.status(500).json({ error: 'Failed to delete habit' });
  }
});

export default router;
