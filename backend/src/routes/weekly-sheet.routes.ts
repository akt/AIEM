import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import * as sheetService from '../services/weekly-sheet.service';

const router = Router();

// All routes require authentication
router.use(authenticate);

// ---------------------------------------------------------------------------
// Zod schemas
// ---------------------------------------------------------------------------

const createSheetSchema = z.object({
  week_start: z.string().optional(),
  surfaces_in_scope: z.array(z.string()).optional(),
  oncall_ownership: z.string().optional(),
  key_dependencies: z.string().optional(),
  non_negotiable_constraints: z.string().optional(),
});

const updateSheetSchema = z.object({
  surfaces_in_scope: z.array(z.string()).optional(),
  oncall_ownership: z.string().optional(),
  key_dependencies: z.string().optional(),
  non_negotiable_constraints: z.string().optional(),
  status: z.enum(['draft', 'active', 'completed', 'archived']).optional(),
});

const constraintSchema = z.object({
  constraint_statement: z.string().optional(),
  constraint_evidence: z
    .object({
      sli_dashboards: z.string().optional(),
      incident_pattern: z.string().optional(),
      queue_lag: z.string().optional(),
      cost_regression: z.string().optional(),
    })
    .optional(),
  constraint_slo_service: z.string().optional(),
  constraint_slo_targets: z.string().optional(),
  constraint_error_budget_status: z
    .enum(['healthy', 'burning', 'exhausted'])
    .optional(),
  constraint_exhausted_action: z.string().optional(),
});

const dsaaQueueSchema = z.object({
  dsaa_queue: z
    .object({
      delete: z.array(z.string()),
      simplify: z.array(z.string()),
      accelerate: z.array(z.string()),
      automate: z.array(z.string()),
    })
    .optional(),
  dsaa_focus_this_week: z
    .enum(['delete', 'simplify', 'accelerate', 'automate'])
    .optional(),
});

const aiPlanSchema = z.object({
  ai_tasks: z
    .array(
      z.object({
        task: z.string(),
        enabled: z.boolean(),
        owner: z.string(),
      }),
    )
    .optional(),
  ai_guardrails_checked: z.array(z.string()).optional(),
});

const timeBlocksSchema = z.object({
  time_blocks: z.record(
    z.string(),
    z.object({
      deep_work: z.string().optional(),
      free_thinking: z.string().optional(),
      reactive_budget: z.string().optional(),
      key_meeting: z.string().optional(),
    }),
  ),
});

const incidentSchema = z.object({
  incident_checklist: z.object({
    p0p1_reviewed: z.boolean().optional(),
    postmortem_scheduled: z.boolean().optional(),
    action_items_owned: z.boolean().optional(),
    runbooks_updated: z.boolean().optional(),
    prevention_bet_chosen: z.boolean().optional(),
  }),
});

const adrSchema = z.object({
  adr_checklist: z.object({
    adr_link_exists: z.boolean().optional(),
    alternatives_considered: z.boolean().optional(),
    rollout_rollback_plan: z.boolean().optional(),
    observability_plan: z.boolean().optional(),
    data_contracts_checked: z.boolean().optional(),
  }),
});

const scorecardSchema = z.object({
  scorecard: z.record(z.string(), z.unknown()),
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

// GET / -- list sheets
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const page = Math.max(1, parseInt(req.query.page as string, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit as string, 10) || 20));
    const result = await sheetService.listSheets(req.user!.id, page, limit);
    res.json(result);
  }),
);

// GET /current -- current week
router.get(
  '/current',
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.getCurrentSheet(req.user!.id);
    res.json(sheet);
  }),
);

// GET /:id -- specific sheet
router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.getSheetById(req.params.id, req.user!.id);
    res.json(sheet);
  }),
);

// POST / -- create sheet
router.post(
  '/',
  validate(createSheetSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.createSheet(req.user!.id, req.body);
    res.status(201).json(sheet);
  }),
);

// PUT /:id -- update general
router.put(
  '/:id',
  validate(updateSheetSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateSheet(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/constraint -- update constraint
router.put(
  '/:id/constraint',
  validate(constraintSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateConstraint(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/dsaa-queue -- update dsaa queue
router.put(
  '/:id/dsaa-queue',
  validate(dsaaQueueSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateDsaaQueue(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/ai-plan -- update ai plan
router.put(
  '/:id/ai-plan',
  validate(aiPlanSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateAiPlan(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/time-blocks -- update time blocks
router.put(
  '/:id/time-blocks',
  validate(timeBlocksSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateTimeBlocks(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/incident -- update incident
router.put(
  '/:id/incident',
  validate(incidentSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateIncident(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/adr -- update adr
router.put(
  '/:id/adr',
  validate(adrSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateAdr(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// PUT /:id/scorecard -- update scorecard
router.put(
  '/:id/scorecard',
  validate(scorecardSchema),
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.updateScorecard(req.params.id, req.user!.id, req.body);
    res.json(sheet);
  }),
);

// POST /:id/complete -- complete sheet
router.post(
  '/:id/complete',
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.completeSheet(req.params.id, req.user!.id);
    res.json(sheet);
  }),
);

// POST /:id/carry-forward -- carry forward
router.post(
  '/:id/carry-forward',
  asyncHandler(async (req, res) => {
    const sheet = await sheetService.carryForward(req.params.id, req.user!.id);
    res.json(sheet);
  }),
);

export default router;
