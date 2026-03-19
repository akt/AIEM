import { Router, Request, Response, NextFunction } from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {
  getNotifications,
  markNotificationActioned,
  getUnreadCount,
} from '../services/notification.service';

const router = Router();
router.use(authenticate);

// GET /api/notifications — list notifications (paginated)
router.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;
    const channel = req.query.channel as string | undefined;

    const notifications = await getNotifications(req.user!.id, { limit, offset, channel });
    res.json(notifications);
  } catch (err) {
    next(err);
  }
});

// GET /api/notifications/unread-count
router.get('/unread-count', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const count = await getUnreadCount(req.user!.id);
    res.json({ count });
  } catch (err) {
    next(err);
  }
});

// PUT /api/notifications/:id/action — mark as actioned
router.put('/:id/action', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const notification = await markNotificationActioned(req.user!.id, req.params.id);
    if (!notification) return res.status(404).json({ error: 'Notification not found' });
    res.json(notification);
  } catch (err) {
    next(err);
  }
});

export default router;
