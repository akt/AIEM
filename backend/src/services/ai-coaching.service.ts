import { getAnthropicClient, aiConfig } from '../config/ai';
import { v4 as uuid } from 'uuid';
import db from '../config/database';

// ── Prompt (exact from project plan) ────────────────────────

const DSAA_COACHING_PROMPT = `
You are an engineering manager operating coach using the DSAA framework (Delete → Simplify → Accelerate → Automate).

Given the manager's current context (today's constraint, calendar, friction list), suggest ONE high-leverage 15-minute action.

Rules:
- Prefer Delete and Simplify over Accelerate and Automate
- The action must be completable in exactly 15 minutes
- It must produce a concrete micro-artifact
- Include a 1-line message template they can send to their team

Format as JSON: { "dsaa_action": "delete|simplify|accelerate|automate", "action_description": "...", "micro_artifact": "...", "team_message": "...", "expected_leverage": "..." }
`;

// ── Daily Coaching ──────────────────────────────────────────

export async function generateDailyCoaching(userId: string): Promise<string> {
  // Gather today's context
  const today = new Date().toISOString().slice(0, 10);
  const weekStart = getWeekStart(today);

  const sheet = await db('weekly_sheets')
    .where({ user_id: userId })
    .where('week_start', '<=', today)
    .orderBy('week_start', 'desc')
    .first();

  const todayDsaa = await db('dsaa_daily_logs')
    .where({ user_id: userId, log_date: today })
    .first();

  const recentDsaa = await db('dsaa_daily_logs')
    .where({ user_id: userId })
    .orderBy('log_date', 'desc')
    .limit(5);

  const contextData = {
    date: today,
    constraint: sheet?.constraint_statement || 'No constraint set',
    errorBudgetStatus: sheet?.constraint_error_budget_status || 'unknown',
    dsaaFocus: sheet?.dsaa_focus_this_week || 'simplify',
    dsaaQueue: sheet?.dsaa_queue || {},
    todayCompleted: !!todayDsaa,
    recentActions: recentDsaa.map((l: Record<string, unknown>) => ({
      date: l.log_date,
      action: l.dsaa_action,
      friction: l.friction_point,
    })),
  };

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: DSAA_COACHING_PROMPT,
    messages: [
      {
        role: 'user',
        content: `Today's context for DSAA coaching:\n\n${JSON.stringify(contextData, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  // Save coaching notes to sheet
  if (sheet) {
    await db('weekly_sheets').where({ id: sheet.id }).update({ ai_coaching_notes: aiText });
  }

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'daily_coaching',
    context_data: JSON.stringify(contextData),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── DSAA Suggest ────────────────────────────────────────────

export async function generateDsaaSuggestion(userId: string, frictionPoint?: string): Promise<string> {
  const today = new Date().toISOString().slice(0, 10);

  const sheet = await db('weekly_sheets')
    .where({ user_id: userId })
    .where('week_start', '<=', today)
    .orderBy('week_start', 'desc')
    .first();

  const contextData = {
    frictionPoint: frictionPoint || 'Not specified — suggest based on DSAA queue',
    dsaaQueue: sheet?.dsaa_queue || {},
    dsaaFocus: sheet?.dsaa_focus_this_week || 'simplify',
    constraint: sheet?.constraint_statement || 'No constraint set',
  };

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: DSAA_COACHING_PROMPT,
    messages: [
      {
        role: 'user',
        content: `Suggest a DSAA action for this friction point:\n\n${JSON.stringify(contextData, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'dsaa_suggest',
    context_data: JSON.stringify(contextData),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── Helpers ─────────────────────────────────────────────────

function getWeekStart(dateStr: string): string {
  const d = new Date(dateStr);
  const day = d.getUTCDay();
  const diff = d.getUTCDate() - day + (day === 0 ? -6 : 1); // Monday start
  d.setUTCDate(diff);
  return d.toISOString().slice(0, 10);
}
