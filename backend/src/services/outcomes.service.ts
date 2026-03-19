import db from '../config/database';
import {
  NotFoundError,
  ForbiddenError,
  ValidationError,
} from '../middleware/error.middleware';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

async function verifySheetOwnership(sheetId: string, userId: string) {
  const sheet = await db('weekly_sheets').where({ id: sheetId }).first();
  if (!sheet) {
    throw new NotFoundError('Weekly sheet not found');
  }
  if (sheet.user_id !== userId) {
    throw new ForbiddenError('You do not own this weekly sheet');
  }
  return sheet;
}

async function verifyOutcome(sheetId: string, outcomeId: string) {
  const outcome = await db('outcomes')
    .where({ id: outcomeId, sheet_id: sheetId })
    .first();
  if (!outcome) {
    throw new NotFoundError('Outcome not found');
  }
  return outcome;
}

// ---------------------------------------------------------------------------
// Service functions
// ---------------------------------------------------------------------------

export async function listOutcomes(sheetId: string, userId: string) {
  await verifySheetOwnership(sheetId, userId);

  const outcomes = await db('outcomes')
    .where({ sheet_id: sheetId })
    .orderBy('position', 'asc');

  return outcomes;
}

export async function createOutcome(
  sheetId: string,
  userId: string,
  data: {
    position: number;
    outcome_text: string;
    impact: string;
    definition_of_done: string;
    owner: string;
    risk_and_mitigation?: string;
  },
) {
  await verifySheetOwnership(sheetId, userId);

  if (data.position < 1 || data.position > 3) {
    throw new ValidationError('Position must be between 1 and 3');
  }

  // Check for existing outcome at that position
  const existing = await db('outcomes')
    .where({ sheet_id: sheetId, position: data.position })
    .first();

  if (existing) {
    throw new ValidationError(`An outcome already exists at position ${data.position}`);
  }

  const [outcome] = await db('outcomes')
    .insert({
      sheet_id: sheetId,
      position: data.position,
      outcome_text: data.outcome_text,
      impact: data.impact,
      definition_of_done: data.definition_of_done,
      owner: data.owner,
      risk_and_mitigation: data.risk_and_mitigation ?? '',
      status: 'in_progress',
      completed_at: null,
    })
    .returning('*');

  return outcome;
}

export async function updateOutcome(
  sheetId: string,
  outcomeId: string,
  userId: string,
  data: {
    outcome_text?: string;
    impact?: string;
    definition_of_done?: string;
    owner?: string;
    risk_and_mitigation?: string;
  },
) {
  await verifySheetOwnership(sheetId, userId);
  await verifyOutcome(sheetId, outcomeId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.outcome_text !== undefined) updateData.outcome_text = data.outcome_text;
  if (data.impact !== undefined) updateData.impact = data.impact;
  if (data.definition_of_done !== undefined) updateData.definition_of_done = data.definition_of_done;
  if (data.owner !== undefined) updateData.owner = data.owner;
  if (data.risk_and_mitigation !== undefined) updateData.risk_and_mitigation = data.risk_and_mitigation;

  const [updated] = await db('outcomes')
    .where({ id: outcomeId, sheet_id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function deleteOutcome(
  sheetId: string,
  outcomeId: string,
  userId: string,
) {
  await verifySheetOwnership(sheetId, userId);
  await verifyOutcome(sheetId, outcomeId);

  await db('outcomes').where({ id: outcomeId, sheet_id: sheetId }).delete();
}

export async function updateOutcomeStatus(
  sheetId: string,
  outcomeId: string,
  userId: string,
  status: 'in_progress' | 'done' | 'blocked' | 'carried_over',
) {
  await verifySheetOwnership(sheetId, userId);
  await verifyOutcome(sheetId, outcomeId);

  const updateData: Record<string, unknown> = {
    status,
    updated_at: db.fn.now(),
  };

  if (status === 'done') {
    updateData.completed_at = db.fn.now();
  } else {
    updateData.completed_at = null;
  }

  const [updated] = await db('outcomes')
    .where({ id: outcomeId, sheet_id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}
