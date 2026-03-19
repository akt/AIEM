import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { validate } from '../middleware/validation.middleware';
import { authenticate } from '../middleware/auth.middleware';
import * as authService from '../services/auth.service';

const router = Router();

// ============================================================
// Validation schemas
// ============================================================

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  displayName: z.string().min(1),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

const updateProfileSchema = z.object({
  display_name: z.string().min(1).optional(),
  timezone: z.string().optional(),
  notification_preferences: z.record(z.boolean()).optional(),
  dsaa_trigger_time: z.string().optional(),
  dsaa_trigger_event: z.string().optional(),
  deep_work_hours_target: z.number().positive().optional(),
  surfaces: z.array(z.string()).optional(),
});

const pushTokenSchema = z.object({
  platform: z.enum(['android', 'ios']),
  token: z.string().min(1),
});

// ============================================================
// Routes
// ============================================================

router.post('/register', validate(registerSchema), async (req: Request, res: Response) => {
  try {
    const { email, password, displayName } = req.body;
    const user = await authService.register(email, password, displayName);
    return res.status(201).json({ user });
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

router.post('/login', validate(loginSchema), async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    return res.status(200).json(result);
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

router.post('/refresh', validate(refreshSchema), async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    const tokens = await authService.refreshToken(refreshToken);
    return res.status(200).json(tokens);
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

router.get('/profile', authenticate, async (req: Request, res: Response) => {
  try {
    const user = await authService.getProfile(req.user!.id);
    return res.status(200).json({ user });
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

router.put('/profile', authenticate, validate(updateProfileSchema), async (req: Request, res: Response) => {
  try {
    const user = await authService.updateProfile(req.user!.id, req.body);
    return res.status(200).json({ user });
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

router.put('/push-token', authenticate, validate(pushTokenSchema), async (req: Request, res: Response) => {
  try {
    const { platform, token } = req.body;
    const user = await authService.updatePushToken(req.user!.id, platform, token);
    return res.status(200).json({ user });
  } catch (err: any) {
    const status = err.status || 500;
    return res.status(status).json({ error: err.message });
  }
});

export default router;
