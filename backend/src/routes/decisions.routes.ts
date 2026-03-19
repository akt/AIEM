import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import * as decisionsService from '../services/decisions.service';

const router = Router({ mergeParams: true });

// All routes require authentication
router.use(authenticate);

// ---------------------------------------------------------------------------
// Zod schemas
// ---------------------------------------------------------------------------

const createDecisionSchema = z.object({
  position: z.number().int().min(1).max(3),
  decision_text: z.string().min(1),
  by_when: z.string().min(1),
  inputs_needed: z.string().min(1),
});

const updateDecisionSchema = z.object({
  decision_text: z.string().min(1).optional(),
  by_when: z.string().min(1).optional(),
  inputs_needed: z.string().min(1).optional(),
});

const resolveDecisionSchema = z.object({
  decision_result: z.string().min(1),
});

// ---------------------------------------------------------------------------
// Async handler wrapper
// ---------------------------------------------------------------------------

const asyncHandler =
  (fn: (req: Request, res: Response, next: NextFunction) => Promise<void>) =>
  (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };

// ---------------------------------------------------------------------------
// Routes
// ---------------------------------------------------------------------------

// GET /:sheetId/decisions
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const decisions = await decisionsService.listDecisions(
      req.params.sheetId,
      req.user!.id,
    );
    res.json(decisions);
  }),
);

// POST /:sheetId/decisions
router.post(
  '/',
  validate(createDecisionSchema),
  asyncHandler(async (req, res) => {
    const decision = await decisionsService.createDecision(
      req.params.sheetId,
      req.user!.id,
      req.body,
    );
    res.status(201).json(decision);
  }),
);

// PUT /:sheetId/decisions/:id
router.put(
  '/:id',
  validate(updateDecisionSchema),
  asyncHandler(async (req, res) => {
    const decision = await decisionsService.updateDecision(
      req.params.sheetId,
      req.params.id,
      req.user!.id,
      req.body,
    );
    res.json(decision);
  }),
);

// PUT /:sheetId/decisions/:id/resolve
router.put(
  '/:id/resolve',
  validate(resolveDecisionSchema),
  asyncHandler(async (req, res) => {
    const decision = await decisionsService.resolveDecision(
      req.params.sheetId,
      req.params.id,
      req.user!.id,
      req.body.decision_result,
    );
    res.json(decision);
  }),
);

export default router;
