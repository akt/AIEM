import db from '../config/database';
import {
  NotFoundError,
  ForbiddenError,
  ConflictError,
  ValidationError,
} from '../middleware/error.middleware';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function mondayOfWeek(date: Date): Date {
  const d = new Date(date);
  const day = d.getDay(); // 0=Sun … 6=Sat
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  d.setDate(diff);
  d.setHours(0, 0, 0, 0);
  return d;
}

function isoWeekLabel(date: Date): string {
  // ISO week number calculation
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`;
}

function formatDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

const SHEET_COLUMNS = [
  'id',
  'user_id',
  'week_start',
  'week_label',
  'status',
  'surfaces_in_scope',
  'oncall_ownership',
  'key_dependencies',
  'non_negotiable_constraints',
  'constraint_statement',
  'constraint_evidence',
  'constraint_slo_service',
  'constraint_slo_targets',
  'constraint_error_budget_status',
  'constraint_exhausted_action',
  'dsaa_queue',
  'dsaa_focus_this_week',
  'ai_tasks',
  'ai_guardrails_checked',
  'time_blocks',
  'incident_checklist',
  'adr_checklist',
  'scorecard',
  'ai_weekly_summary',
  'ai_coaching_notes',
  'created_at',
  'updated_at',
  'completed_at',
];

async function verifyOwnership(sheetId: string, userId: string) {
  const sheet = await db('weekly_sheets').where({ id: sheetId }).first();
  if (!sheet) {
    throw new NotFoundError('Weekly sheet not found');
  }
  if (sheet.user_id !== userId) {
    throw new ForbiddenError('You do not own this weekly sheet');
  }
  return sheet;
}

// ---------------------------------------------------------------------------
// Service functions
// ---------------------------------------------------------------------------

export async function listSheets(
  userId: string,
  page: number = 1,
  limit: number = 20,
) {
  const offset = (page - 1) * limit;

  const [sheets, countResult] = await Promise.all([
    db('weekly_sheets')
      .where({ user_id: userId })
      .orderBy('week_start', 'desc')
      .limit(limit)
      .offset(offset),
    db('weekly_sheets')
      .where({ user_id: userId })
      .count('id as total')
      .first(),
  ]);

  return {
    data: sheets,
    pagination: {
      page,
      limit,
      total: Number(countResult?.total ?? 0),
    },
  };
}

export async function getCurrentSheet(userId: string) {
  const monday = mondayOfWeek(new Date());
  const weekStart = formatDate(monday);

  let sheet = await db('weekly_sheets')
    .where({ user_id: userId, week_start: weekStart })
    .first();

  if (!sheet) {
    const weekLabel = isoWeekLabel(monday);

    const defaultSheet = {
      user_id: userId,
      week_start: weekStart,
      week_label: weekLabel,
      status: 'draft',
      surfaces_in_scope: JSON.stringify([]),
      oncall_ownership: '',
      key_dependencies: '',
      non_negotiable_constraints: '',
      constraint_statement: '',
      constraint_evidence: JSON.stringify({
        sli_dashboards: '',
        incident_pattern: '',
        queue_lag: '',
        cost_regression: '',
      }),
      constraint_slo_service: '',
      constraint_slo_targets: '',
      constraint_error_budget_status: 'healthy',
      constraint_exhausted_action: '',
      dsaa_queue: JSON.stringify({
        delete: [],
        simplify: [],
        accelerate: [],
        automate: [],
      }),
      dsaa_focus_this_week: null,
      ai_tasks: JSON.stringify([]),
      ai_guardrails_checked: JSON.stringify([]),
      time_blocks: JSON.stringify({}),
      incident_checklist: JSON.stringify({
        p0p1_reviewed: false,
        postmortem_scheduled: false,
        action_items_owned: false,
        runbooks_updated: false,
        prevention_bet_chosen: false,
      }),
      adr_checklist: JSON.stringify({
        adr_link_exists: false,
        alternatives_considered: false,
        rollout_rollback_plan: false,
        observability_plan: false,
        data_contracts_checked: false,
      }),
      scorecard: null,
      ai_weekly_summary: null,
      ai_coaching_notes: null,
    };

    [sheet] = await db('weekly_sheets').insert(defaultSheet).returning('*');
  }

  return sheet;
}

export async function getSheetById(sheetId: string, userId: string) {
  const sheet = await verifyOwnership(sheetId, userId);

  const [outcomes, decisions] = await Promise.all([
    db('outcomes').where({ sheet_id: sheetId }).orderBy('position', 'asc'),
    db('decisions').where({ sheet_id: sheetId }).orderBy('position', 'asc'),
  ]);

  return { ...sheet, outcomes, decisions };
}

export async function createSheet(
  userId: string,
  data: {
    week_start?: string;
    surfaces_in_scope?: string[];
    oncall_ownership?: string;
    key_dependencies?: string;
    non_negotiable_constraints?: string;
  },
) {
  const weekStart = data.week_start
    ? formatDate(mondayOfWeek(new Date(data.week_start)))
    : formatDate(mondayOfWeek(new Date()));

  const weekLabel = isoWeekLabel(new Date(weekStart));

  // Check for duplicates
  const existing = await db('weekly_sheets')
    .where({ user_id: userId, week_start: weekStart })
    .first();

  if (existing) {
    throw new ConflictError(`A sheet already exists for week ${weekLabel}`);
  }

  const [sheet] = await db('weekly_sheets')
    .insert({
      user_id: userId,
      week_start: weekStart,
      week_label: weekLabel,
      status: 'draft',
      surfaces_in_scope: JSON.stringify(data.surfaces_in_scope ?? []),
      oncall_ownership: data.oncall_ownership ?? '',
      key_dependencies: data.key_dependencies ?? '',
      non_negotiable_constraints: data.non_negotiable_constraints ?? '',
      constraint_statement: '',
      constraint_evidence: JSON.stringify({
        sli_dashboards: '',
        incident_pattern: '',
        queue_lag: '',
        cost_regression: '',
      }),
      constraint_slo_service: '',
      constraint_slo_targets: '',
      constraint_error_budget_status: 'healthy',
      constraint_exhausted_action: '',
      dsaa_queue: JSON.stringify({
        delete: [],
        simplify: [],
        accelerate: [],
        automate: [],
      }),
      dsaa_focus_this_week: null,
      ai_tasks: JSON.stringify([]),
      ai_guardrails_checked: JSON.stringify([]),
      time_blocks: JSON.stringify({}),
      incident_checklist: JSON.stringify({
        p0p1_reviewed: false,
        postmortem_scheduled: false,
        action_items_owned: false,
        runbooks_updated: false,
        prevention_bet_chosen: false,
      }),
      adr_checklist: JSON.stringify({
        adr_link_exists: false,
        alternatives_considered: false,
        rollout_rollback_plan: false,
        observability_plan: false,
        data_contracts_checked: false,
      }),
      scorecard: null,
      ai_weekly_summary: null,
      ai_coaching_notes: null,
    })
    .returning('*');

  return sheet;
}

export async function updateSheet(
  sheetId: string,
  userId: string,
  data: {
    surfaces_in_scope?: string[];
    oncall_ownership?: string;
    key_dependencies?: string;
    non_negotiable_constraints?: string;
    status?: string;
  },
) {
  await verifyOwnership(sheetId, userId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.surfaces_in_scope !== undefined) {
    updateData.surfaces_in_scope = JSON.stringify(data.surfaces_in_scope);
  }
  if (data.oncall_ownership !== undefined) updateData.oncall_ownership = data.oncall_ownership;
  if (data.key_dependencies !== undefined) updateData.key_dependencies = data.key_dependencies;
  if (data.non_negotiable_constraints !== undefined) updateData.non_negotiable_constraints = data.non_negotiable_constraints;
  if (data.status !== undefined) updateData.status = data.status;

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function updateConstraint(
  sheetId: string,
  userId: string,
  data: {
    constraint_statement?: string;
    constraint_evidence?: Record<string, string>;
    constraint_slo_service?: string;
    constraint_slo_targets?: string;
    constraint_error_budget_status?: string;
    constraint_exhausted_action?: string;
  },
) {
  await verifyOwnership(sheetId, userId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.constraint_statement !== undefined) updateData.constraint_statement = data.constraint_statement;
  if (data.constraint_evidence !== undefined) updateData.constraint_evidence = JSON.stringify(data.constraint_evidence);
  if (data.constraint_slo_service !== undefined) updateData.constraint_slo_service = data.constraint_slo_service;
  if (data.constraint_slo_targets !== undefined) updateData.constraint_slo_targets = data.constraint_slo_targets;
  if (data.constraint_error_budget_status !== undefined) updateData.constraint_error_budget_status = data.constraint_error_budget_status;
  if (data.constraint_exhausted_action !== undefined) updateData.constraint_exhausted_action = data.constraint_exhausted_action;

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function updateDsaaQueue(
  sheetId: string,
  userId: string,
  data: {
    dsaa_queue?: Record<string, string[]>;
    dsaa_focus_this_week?: string;
  },
) {
  await verifyOwnership(sheetId, userId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.dsaa_queue !== undefined) updateData.dsaa_queue = JSON.stringify(data.dsaa_queue);
  if (data.dsaa_focus_this_week !== undefined) updateData.dsaa_focus_this_week = data.dsaa_focus_this_week;

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function updateAiPlan(
  sheetId: string,
  userId: string,
  data: {
    ai_tasks?: Array<{ task: string; enabled: boolean; owner: string }>;
    ai_guardrails_checked?: string[];
  },
) {
  await verifyOwnership(sheetId, userId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.ai_tasks !== undefined) updateData.ai_tasks = JSON.stringify(data.ai_tasks);
  if (data.ai_guardrails_checked !== undefined) updateData.ai_guardrails_checked = JSON.stringify(data.ai_guardrails_checked);

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function updateTimeBlocks(
  sheetId: string,
  userId: string,
  data: {
    time_blocks: Record<string, unknown>;
  },
) {
  await verifyOwnership(sheetId, userId);

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update({
      time_blocks: JSON.stringify(data.time_blocks),
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}

export async function updateIncident(
  sheetId: string,
  userId: string,
  data: {
    incident_checklist: Record<string, boolean>;
  },
) {
  await verifyOwnership(sheetId, userId);

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update({
      incident_checklist: JSON.stringify(data.incident_checklist),
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}

export async function updateAdr(
  sheetId: string,
  userId: string,
  data: {
    adr_checklist: Record<string, boolean>;
  },
) {
  await verifyOwnership(sheetId, userId);

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update({
      adr_checklist: JSON.stringify(data.adr_checklist),
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}

export async function updateScorecard(
  sheetId: string,
  userId: string,
  data: {
    scorecard: Record<string, unknown>;
  },
) {
  await verifyOwnership(sheetId, userId);

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update({
      scorecard: JSON.stringify(data.scorecard),
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}

export async function completeSheet(sheetId: string, userId: string) {
  const sheet = await verifyOwnership(sheetId, userId);

  if (sheet.status === 'completed') {
    throw new ConflictError('Sheet is already completed');
  }

  const [updated] = await db('weekly_sheets')
    .where({ id: sheetId })
    .update({
      status: 'completed',
      completed_at: db.fn.now(),
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}

export async function carryForward(sheetId: string, userId: string) {
  const sheet = await verifyOwnership(sheetId, userId);

  // Calculate next week's Monday
  const currentMonday = new Date(sheet.week_start);
  const nextMonday = new Date(currentMonday);
  nextMonday.setDate(nextMonday.getDate() + 7);
  const nextWeekStart = formatDate(nextMonday);
  const nextWeekLabel = isoWeekLabel(nextMonday);

  // Check if next week sheet already exists
  const existing = await db('weekly_sheets')
    .where({ user_id: userId, week_start: nextWeekStart })
    .first();

  if (existing) {
    throw new ConflictError(`A sheet already exists for week ${nextWeekLabel}`);
  }

  // Get incomplete outcomes and pending decisions
  const [incompleteOutcomes, pendingDecisions] = await Promise.all([
    db('outcomes')
      .where({ sheet_id: sheetId })
      .whereIn('status', ['in_progress', 'blocked']),
    db('decisions')
      .where({ sheet_id: sheetId })
      .where({ status: 'pending' }),
  ]);

  // Create new sheet
  const [newSheet] = await db('weekly_sheets')
    .insert({
      user_id: userId,
      week_start: nextWeekStart,
      week_label: nextWeekLabel,
      status: 'draft',
      surfaces_in_scope: sheet.surfaces_in_scope,
      oncall_ownership: sheet.oncall_ownership,
      key_dependencies: sheet.key_dependencies,
      non_negotiable_constraints: sheet.non_negotiable_constraints,
      constraint_statement: '',
      constraint_evidence: JSON.stringify({
        sli_dashboards: '',
        incident_pattern: '',
        queue_lag: '',
        cost_regression: '',
      }),
      constraint_slo_service: sheet.constraint_slo_service,
      constraint_slo_targets: sheet.constraint_slo_targets,
      constraint_error_budget_status: 'healthy',
      constraint_exhausted_action: '',
      dsaa_queue: JSON.stringify({
        delete: [],
        simplify: [],
        accelerate: [],
        automate: [],
      }),
      dsaa_focus_this_week: null,
      ai_tasks: JSON.stringify([]),
      ai_guardrails_checked: JSON.stringify([]),
      time_blocks: JSON.stringify({}),
      incident_checklist: JSON.stringify({
        p0p1_reviewed: false,
        postmortem_scheduled: false,
        action_items_owned: false,
        runbooks_updated: false,
        prevention_bet_chosen: false,
      }),
      adr_checklist: JSON.stringify({
        adr_link_exists: false,
        alternatives_considered: false,
        rollout_rollback_plan: false,
        observability_plan: false,
        data_contracts_checked: false,
      }),
      scorecard: null,
      ai_weekly_summary: null,
      ai_coaching_notes: null,
    })
    .returning('*');

  // Carry forward incomplete outcomes
  if (incompleteOutcomes.length > 0) {
    const outcomeInserts = incompleteOutcomes.map(
      (o: Record<string, unknown>, idx: number) => ({
        sheet_id: newSheet.id,
        position: idx + 1,
        outcome_text: o.outcome_text,
        impact: o.impact,
        definition_of_done: o.definition_of_done,
        owner: o.owner,
        risk_and_mitigation: o.risk_and_mitigation,
        status: 'carried_over',
        completed_at: null,
      }),
    );
    await db('outcomes').insert(outcomeInserts);
  }

  // Carry forward pending decisions
  if (pendingDecisions.length > 0) {
    const decisionInserts = pendingDecisions.map(
      (d: Record<string, unknown>, idx: number) => ({
        sheet_id: newSheet.id,
        position: idx + 1,
        decision_text: d.decision_text,
        by_when: d.by_when,
        inputs_needed: d.inputs_needed,
        status: 'deferred',
        decision_result: null,
      }),
    );
    await db('decisions').insert(decisionInserts);
  }

  // Return the new sheet with carried items
  return getSheetById(newSheet.id, userId);
}
