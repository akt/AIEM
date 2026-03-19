import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import * as outcomesService from '../services/outcomes.service';

const router = Router({ mergeParams: true });

// All routes require authentication
router.use(authenticate);

// ---------------------------------------------------------------------------
// Zod schemas
// ---------------------------------------------------------------------------

const createOutcomeSchema = z.object({
  position: z.number().int().min(1).max(3),
  outcome_text: z.string().min(1),
  impact: z.string().min(1),
  definition_of_done: z.string().min(1),
  owner: z.string().min(1),
  risk_and_mitigation: z.string().optional(),
});

const updateOutcomeSchema = z.object({
  outcome_text: z.string().min(1).optional(),
  impact: z.string().min(1).optional(),
  definition_of_done: z.string().min(1).optional(),
  owner: z.string().min(1).optional(),
  risk_and_mitigation: z.string().optional(),
});

const updateStatusSchema = z.object({
  status: z.enum(['in_progress', 'done', 'blocked', 'carried_over']),
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

// GET /:sheetId/outcomes
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const outcomes = await outcomesService.listOutcomes(
      req.params.sheetId,
      req.user!.id,
    );
    res.json(outcomes);
  }),
);

// POST /:sheetId/outcomes
router.post(
  '/',
  validate(createOutcomeSchema),
  asyncHandler(async (req, res) => {
    const outcome = await outcomesService.createOutcome(
      req.params.sheetId,
      req.user!.id,
      req.body,
    );
    res.status(201).json(outcome);
  }),
);

// PUT /:sheetId/outcomes/:id
router.put(
  '/:id',
  validate(updateOutcomeSchema),
  asyncHandler(async (req, res) => {
    const outcome = await outcomesService.updateOutcome(
      req.params.sheetId,
      req.params.id,
      req.user!.id,
      req.body,
    );
    res.json(outcome);
  }),
);

// DELETE /:sheetId/outcomes/:id
router.delete(
  '/:id',
  asyncHandler(async (req, res) => {
    await outcomesService.deleteOutcome(
      req.params.sheetId,
      req.params.id,
      req.user!.id,
    );
    res.status(204).send();
  }),
);

// PUT /:sheetId/outcomes/:id/status
router.put(
  '/:id/status',
  validate(updateStatusSchema),
  asyncHandler(async (req, res) => {
    const outcome = await outcomesService.updateOutcomeStatus(
      req.params.sheetId,
      req.params.id,
      req.user!.id,
      req.body.status,
    );
    res.json(outcome);
  }),
);

export default router;
