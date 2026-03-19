import { getAnthropicClient, aiConfig } from '../config/ai';
import { v4 as uuid } from 'uuid';
import db from '../config/database';

// ── Prompts (exact from project plan) ───────────────────────

const WEEKLY_SUMMARY_SYSTEM_PROMPT = `
You are an operating coach for a hardcore Engineering Manager who owns Web3/DEX, Exchange, Fiat On/Off Ramp, Crypto Pay, and AI Platform products.

Your job is to analyze their completed weekly operating sheet and provide:
1. A concise summary (3-5 sentences) of what was accomplished vs planned
2. Top wins and blockers
3. Error budget / reliability health assessment
4. DSAA effectiveness rating (did they Delete/Simplify enough?)
5. One specific recommendation for next week
6. A coaching note on sustainability (deep work hours, reactive budget adherence)

Be direct, data-driven, no fluff. Use the SRE/DORA/SPACE frameworks implicitly.
Format as JSON: { "summary": "...", "wins": [...], "blockers": [...], "reliability_health": "...", "dsaa_rating": "...", "recommendation": "...", "coaching_note": "..." }
`;

const TREND_ANALYSIS_PROMPT = `
You are a data analyst for an Engineering Manager's personal operating system.

Given N weeks of trend data (deep work hours, habit completion rates, DSAA actions, outcomes completed, error budget status, DORA metrics, friction pulse), identify:
1. The strongest positive trend
2. The most concerning declining trend
3. A pattern the manager might not have noticed
4. One specific, actionable suggestion

Be concise and data-specific. Reference actual numbers from the data.
Format as JSON: { "positive_trend": "...", "concerning_trend": "...", "hidden_pattern": "...", "suggestion": "..." }
`;

// ── Weekly Summary ──────────────────────────────────────────

export async function generateWeeklySummary(userId: string, sheetId: string): Promise<string> {
  const sheet = await db('weekly_sheets').where({ id: sheetId, user_id: userId }).first();
  if (!sheet) throw new Error('Sheet not found');

  const outcomes = await db('weekly_outcomes').where({ sheet_id: sheetId });
  const decisions = await db('leadership_decisions').where({ sheet_id: sheetId });
  const dsaaLogs = await db('dsaa_daily_logs')
    .where({ user_id: userId, sheet_id: sheetId });

  const contextData = {
    sheet: {
      weekLabel: sheet.week_label,
      status: sheet.status,
      surfacesInScope: sheet.surfaces_in_scope,
      constraintStatement: sheet.constraint_statement,
      errorBudgetStatus: sheet.constraint_error_budget_status,
      dsaaFocus: sheet.dsaa_focus_this_week,
      dsaaQueue: sheet.dsaa_queue,
      scorecard: sheet.scorecard,
      timeBlocks: sheet.time_blocks,
      incidentChecklist: sheet.incident_checklist,
    },
    outcomes: outcomes.map((o: Record<string, unknown>) => ({
      text: o.outcome_text,
      status: o.status,
      impact: o.impact,
    })),
    decisions: decisions.map((d: Record<string, unknown>) => ({
      text: d.decision_text,
      status: d.status,
      result: d.decision_result,
    })),
    dsaaLogs: dsaaLogs.map((l: Record<string, unknown>) => ({
      action: l.dsaa_action,
      friction: l.friction_point,
      leverage: l.expected_leverage,
      duration: l.duration_minutes,
    })),
  };

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: WEEKLY_SUMMARY_SYSTEM_PROMPT,
    messages: [
      {
        role: 'user',
        content: `Analyze this completed weekly operating sheet:\n\n${JSON.stringify(contextData, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  // Save to sheet
  await db('weekly_sheets').where({ id: sheetId }).update({ ai_weekly_summary: aiText });

  // Log interaction
  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'weekly_summary',
    context_data: JSON.stringify(contextData),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── Trend Insight ───────────────────────────────────────────

export async function generateTrendInsight(userId: string, weeks: number = 12): Promise<string> {
  const trends = await db('weekly_trends')
    .where({ user_id: userId })
    .orderBy('week_start', 'desc')
    .limit(weeks);

  if (trends.length === 0) {
    return JSON.stringify({ positive_trend: 'Not enough data', concerning_trend: 'N/A', hidden_pattern: 'N/A', suggestion: 'Complete at least 2 weeks to see trends.' });
  }

  const contextData = trends.map((t: Record<string, unknown>) => ({
    weekStart: t.week_start,
    deepWorkHours: t.deep_work_hours_total,
    dsaaCompleted: t.dsaa_rituals_completed,
    habitsRate: t.habits_completion_rate,
    outcomesCompleted: t.outcomes_completed,
    outcomesTotal: t.outcomes_total,
    decisionsMade: t.decisions_made,
    errorBudget: t.error_budget_status,
    doraScores: t.dora_scores,
    streakDays: t.streak_days,
    frictionPulse: t.friction_pulse_avg,
  }));

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: TREND_ANALYSIS_PROMPT,
    messages: [
      {
        role: 'user',
        content: `Analyze ${trends.length} weeks of trend data:\n\n${JSON.stringify(contextData, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'trend_insight',
    context_data: JSON.stringify(contextData),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── Constraint Analysis ─────────────────────────────────────

export async function generateConstraintAnalysis(userId: string, sheetId: string): Promise<string> {
  const sheet = await db('weekly_sheets').where({ id: sheetId, user_id: userId }).first();
  if (!sheet) throw new Error('Sheet not found');

  const contextData = {
    constraint: sheet.constraint_statement,
    evidence: sheet.constraint_evidence,
    sloService: sheet.slo_service,
    sloTargets: sheet.slo_targets,
    errorBudgetStatus: sheet.constraint_error_budget_status,
    exhaustedAction: sheet.exhausted_action,
  };

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: `You are an SRE/reliability coach for an Engineering Manager. Analyze their constraint deep-dive data and provide:
1. Assessment of whether the constraint is correctly identified
2. Error budget health interpretation
3. Recommended actions based on budget status (healthy → invest, burning → throttle, exhausted → freeze)
4. One question the manager should ask their team this week

Format as JSON: { "constraint_assessment": "...", "budget_health": "...", "recommended_actions": [...], "team_question": "..." }`,
    messages: [
      {
        role: 'user',
        content: `Analyze this constraint deep-dive:\n\n${JSON.stringify(contextData, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'constraint_analysis',
    context_data: JSON.stringify(contextData),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── Habit Insight ───────────────────────────────────────────

export async function generateHabitInsight(userId: string, period: string = 'month'): Promise<string> {
  const daysBack = period === 'quarter' ? 90 : period === 'month' ? 30 : 7;
  const since = new Date();
  since.setDate(since.getDate() - daysBack);

  const habits = await db('habits').where({ user_id: userId, is_active: true });
  const logs = await db('habit_logs')
    .where({ user_id: userId })
    .where('log_date', '>=', since.toISOString().slice(0, 10));

  const habitMap = new Map(habits.map((h: Record<string, unknown>) => [h.id, h]));
  const summary = habits.map((h: Record<string, unknown>) => {
    const habitLogs = logs.filter((l: Record<string, unknown>) => l.habit_id === h.id);
    const completed = habitLogs.filter((l: Record<string, unknown>) => l.is_completed).length;
    return {
      name: h.name,
      category: h.category,
      frequency: h.frequency,
      totalLogs: habitLogs.length,
      completed,
      streak: h.streak_current,
      bestStreak: h.streak_best,
    };
  });

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: `You are a habit coach for a hardcore Engineering Manager. Analyze their habit tracking data and provide:
1. Overall consistency rating (1-10)
2. Strongest habit (most consistent)
3. Weakest habit (needs attention)
4. One pattern or correlation you notice
5. One actionable suggestion to improve

Format as JSON: { "consistency_rating": N, "strongest_habit": "...", "weakest_habit": "...", "pattern": "...", "suggestion": "..." }`,
    messages: [
      {
        role: 'user',
        content: `Analyze habit data over the last ${daysBack} days:\n\n${JSON.stringify(summary, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'habit_insight',
    context_data: JSON.stringify(summary),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}

// ── Scorecard Insight ───────────────────────────────────────

export async function generateScorecardInsight(userId: string, sheetId: string): Promise<string> {
  const sheet = await db('weekly_sheets').where({ id: sheetId, user_id: userId }).first();
  if (!sheet || !sheet.scorecard) throw new Error('Scorecard not found');

  const client = getAnthropicClient();
  const response = await client.messages.create({
    model: aiConfig.model,
    max_tokens: aiConfig.maxTokens,
    system: `You are a metrics coach for an Engineering Manager using DORA, SLO, SPACE, and AI Health frameworks. Analyze the weekly scorecard and provide:
1. Overall health rating (green/yellow/red)
2. Top metric highlight (what's going well)
3. Top metric concern (what needs attention)
4. Week-over-week interpretation
5. One thing to focus on next week

Format as JSON: { "health_rating": "...", "highlight": "...", "concern": "...", "interpretation": "...", "focus_next_week": "..." }`,
    messages: [
      {
        role: 'user',
        content: `Analyze this weekly scorecard:\n\n${JSON.stringify(sheet.scorecard, null, 2)}`,
      },
    ],
  });

  const aiText = response.content[0].type === 'text' ? response.content[0].text : '';
  const tokensUsed = (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0);

  await db('ai_interactions').insert({
    id: uuid(),
    user_id: userId,
    interaction_type: 'scorecard_insight',
    context_data: JSON.stringify(sheet.scorecard),
    ai_response: aiText,
    model_used: aiConfig.model,
    tokens_used: tokensUsed,
  });

  return aiText;
}
