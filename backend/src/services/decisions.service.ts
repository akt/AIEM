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

async function verifyDecision(sheetId: string, decisionId: string) {
  const decision = await db('decisions')
    .where({ id: decisionId, sheet_id: sheetId })
    .first();
  if (!decision) {
    throw new NotFoundError('Decision not found');
  }
  return decision;
}

// ---------------------------------------------------------------------------
// Service functions
// ---------------------------------------------------------------------------

export async function listDecisions(sheetId: string, userId: string) {
  await verifySheetOwnership(sheetId, userId);

  const decisions = await db('decisions')
    .where({ sheet_id: sheetId })
    .orderBy('position', 'asc');

  return decisions;
}

export async function createDecision(
  sheetId: string,
  userId: string,
  data: {
    position: number;
    decision_text: string;
    by_when: string;
    inputs_needed: string;
  },
) {
  await verifySheetOwnership(sheetId, userId);

  if (data.position < 1 || data.position > 3) {
    throw new ValidationError('Position must be between 1 and 3');
  }

  // Check for existing decision at that position
  const existing = await db('decisions')
    .where({ sheet_id: sheetId, position: data.position })
    .first();

  if (existing) {
    throw new ValidationError(`A decision already exists at position ${data.position}`);
  }

  const [decision] = await db('decisions')
    .insert({
      sheet_id: sheetId,
      position: data.position,
      decision_text: data.decision_text,
      by_when: data.by_when,
      inputs_needed: data.inputs_needed,
      status: 'pending',
      decision_result: null,
    })
    .returning('*');

  return decision;
}

export async function updateDecision(
  sheetId: string,
  decisionId: string,
  userId: string,
  data: {
    decision_text?: string;
    by_when?: string;
    inputs_needed?: string;
  },
) {
  await verifySheetOwnership(sheetId, userId);
  await verifyDecision(sheetId, decisionId);

  const updateData: Record<string, unknown> = { updated_at: db.fn.now() };

  if (data.decision_text !== undefined) updateData.decision_text = data.decision_text;
  if (data.by_when !== undefined) updateData.by_when = data.by_when;
  if (data.inputs_needed !== undefined) updateData.inputs_needed = data.inputs_needed;

  const [updated] = await db('decisions')
    .where({ id: decisionId, sheet_id: sheetId })
    .update(updateData)
    .returning('*');

  return updated;
}

export async function resolveDecision(
  sheetId: string,
  decisionId: string,
  userId: string,
  result: string,
) {
  await verifySheetOwnership(sheetId, userId);
  await verifyDecision(sheetId, decisionId);

  const [updated] = await db('decisions')
    .where({ id: decisionId, sheet_id: sheetId })
    .update({
      status: 'decided',
      decision_result: result,
      updated_at: db.fn.now(),
    })
    .returning('*');

  return updated;
}
