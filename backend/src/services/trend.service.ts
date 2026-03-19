import { v4 as uuid } from 'uuid';
import db from '../config/database';

// ── Weekly trend aggregation ────────────────────────────────

export async function aggregateWeeklyTrends(userId: string, weekStart: string): Promise<void> {
  const weekEnd = new Date(weekStart);
  weekEnd.setDate(weekEnd.getDate() + 6);
  const weekEndStr = weekEnd.toISOString().slice(0, 10);

  // Deep work hours from habit logs
  const deepWorkHabit = await db('habits')
    .where({ user_id: userId, category: 'deep_work', name: 'Deep Work Block' })
    .first();

  let deepWorkHours = 0;
  if (deepWorkHabit) {
    const dwLogs = await db('habit_logs')
      .where({ habit_id: deepWorkHabit.id })
      .whereBetween('log_date', [weekStart, weekEndStr])
      .where('is_completed', true);
    deepWorkHours = dwLogs.reduce((sum: number, l: Record<string, unknown>) => sum + (Number(l.value) || 1.5), 0);
  }

  // DSAA rituals
  const dsaaLogs = await db('dsaa_daily_logs')
    .where({ user_id: userId })
    .whereBetween('log_date', [weekStart, weekEndStr]);
  const dsaaCompleted = dsaaLogs.length;

  // Habits completion rate
  const allHabits = await db('habits').where({ user_id: userId, is_active: true });
  const habitLogs = await db('habit_logs')
    .where({ user_id: userId })
    .whereBetween('log_date', [weekStart, weekEndStr]);
  const completedLogs = habitLogs.filter((l: Record<string, unknown>) => l.is_completed).length;
  const expectedLogs = allHabits.length * 5; // rough weekday estimate
  const habitsRate = expectedLogs > 0 ? Math.round((completedLogs / expectedLogs) * 10000) / 100 : 0;

  // Outcomes
  const sheet = await db('weekly_sheets')
    .where({ user_id: userId, week_start: weekStart })
    .first();

  let outcomesCompleted = 0;
  let outcomesTotal = 0;
  let decisionsMade = 0;
  let decisionsTotal = 0;
  let incidentsReviewed = false;
  let errorBudgetStatus = 'unknown';
  let doraScores = {};
  let frictionPulseAvg = 0;

  if (sheet) {
    const outcomes = await db('weekly_outcomes').where({ sheet_id: sheet.id });
    outcomesTotal = outcomes.length;
    outcomesCompleted = outcomes.filter((o: Record<string, unknown>) => o.status === 'done').length;

    const decisions = await db('leadership_decisions').where({ sheet_id: sheet.id });
    decisionsTotal = decisions.length;
    decisionsMade = decisions.filter((d: Record<string, unknown>) => d.status === 'decided').length;

    incidentsReviewed = sheet.incident_checklist?.p0p1Reviewed || false;
    errorBudgetStatus = sheet.constraint_error_budget_status || 'unknown';
    doraScores = sheet.scorecard?.dora || {};
  }

  // Friction pulse average from DSAA logs (1-5 estimated from action type)
  if (dsaaLogs.length > 0) {
    const frictionScores = dsaaLogs.map((l: Record<string, unknown>) => {
      // Heuristic: delete=1 (low friction remaining), simplify=2, accelerate=3, automate=4
      const map: Record<string, number> = { delete: 1, simplify: 2, accelerate: 3, automate: 4 };
      return map[l.dsaa_action as string] || 2.5;
    });
    frictionPulseAvg = Math.round((frictionScores.reduce((a: number, b: number) => a + b, 0) / frictionScores.length) * 10) / 10;
  }

  // Streak days
  const streakDays = await calculateCurrentStreak(userId);

  // AI assists
  const [{ count: aiCount }] = await db('ai_interactions')
    .where({ user_id: userId })
    .whereRaw("created_at >= ? AND created_at <= ?", [weekStart, weekEndStr + ' 23:59:59'])
    .count('id as count');

  // Upsert trend row
  const existing = await db('weekly_trends')
    .where({ user_id: userId, week_start: weekStart })
    .first();

  const data = {
    deep_work_hours_total: deepWorkHours,
    dsaa_rituals_completed: dsaaCompleted,
    habits_completion_rate: habitsRate,
    outcomes_completed: outcomesCompleted,
    outcomes_total: outcomesTotal,
    decisions_made: decisionsMade,
    decisions_total: decisionsTotal,
    incidents_reviewed: incidentsReviewed,
    error_budget_status: errorBudgetStatus,
    dora_scores: JSON.stringify(doraScores),
    ai_assists_count: Number(aiCount),
    streak_days: streakDays,
    friction_pulse_avg: frictionPulseAvg,
  };

  if (existing) {
    await db('weekly_trends').where({ id: existing.id }).update(data);
  } else {
    await db('weekly_trends').insert({
      id: uuid(),
      user_id: userId,
      week_start: weekStart,
      ...data,
    });
  }
}

// ── Streak calculator ───────────────────────────────────────

export async function calculateCurrentStreak(userId: string): Promise<number> {
  const logs = await db('dsaa_daily_logs')
    .where({ user_id: userId })
    .orderBy('log_date', 'desc')
    .limit(365);

  if (logs.length === 0) return 0;

  let streak = 0;
  const today = new Date();
  const checkDate = new Date(today);

  for (let i = 0; i < 365; i++) {
    const dateStr = checkDate.toISOString().slice(0, 10);
    const dayOfWeek = checkDate.getUTCDay();

    // Skip weekends
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      checkDate.setDate(checkDate.getDate() - 1);
      continue;
    }

    const hasLog = logs.some((l: Record<string, unknown>) => {
      const logDate = typeof l.log_date === 'string' ? l.log_date : (l.log_date as Date).toISOString().slice(0, 10);
      return logDate === dateStr;
    });

    if (hasLog) {
      streak++;
    } else {
      // Allow today to be missing (not yet logged)
      if (i === 0) {
        checkDate.setDate(checkDate.getDate() - 1);
        continue;
      }
      break;
    }
    checkDate.setDate(checkDate.getDate() - 1);
  }

  return streak;
}

// ── Update all habit streaks ────────────────────────────────

export async function updateAllStreaks(userId?: string): Promise<void> {
  const usersQuery = userId
    ? db('users').where({ id: userId })
    : db('users');

  const users = await usersQuery.select('id');

  for (const user of users) {
    const habits = await db('habits').where({ user_id: user.id, is_active: true });

    for (const habit of habits) {
      const logs = await db('habit_logs')
        .where({ habit_id: habit.id, is_completed: true })
        .orderBy('log_date', 'desc')
        .limit(365);

      if (logs.length === 0) {
        await db('habits').where({ id: habit.id }).update({ streak_current: 0 });
        continue;
      }

      let streak = 0;
      const checkDate = new Date();

      for (let i = 0; i < 365; i++) {
        const dateStr = checkDate.toISOString().slice(0, 10);
        const dayOfWeek = checkDate.getUTCDay();

        // Check if habit applies to this day
        const isApplicable = isHabitApplicable(habit, dayOfWeek);
        if (!isApplicable) {
          checkDate.setDate(checkDate.getDate() - 1);
          continue;
        }

        const hasLog = logs.some((l: Record<string, unknown>) => {
          const logDate = typeof l.log_date === 'string' ? l.log_date : (l.log_date as Date).toISOString().slice(0, 10);
          return logDate === dateStr;
        });

        if (hasLog) {
          streak++;
        } else {
          if (i === 0) {
            checkDate.setDate(checkDate.getDate() - 1);
            continue;
          }
          break;
        }
        checkDate.setDate(checkDate.getDate() - 1);
      }

      const bestStreak = Math.max(habit.streak_best || 0, streak);
      await db('habits').where({ id: habit.id }).update({
        streak_current: streak,
        streak_best: bestStreak,
      });
    }
  }
}

function isHabitApplicable(habit: Record<string, unknown>, dayOfWeek: number): boolean {
  const dayNames = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  const frequency = habit.frequency as string;

  if (frequency === 'daily') return true;
  if (frequency === 'weekday') return dayOfWeek >= 1 && dayOfWeek <= 5;
  if (frequency === 'weekly') {
    const days = habit.custom_days as string[] | null;
    return days ? days.includes(dayNames[dayOfWeek]) : dayOfWeek === 1; // default Monday
  }
  if (frequency === 'custom') {
    const days = habit.custom_days as string[] | null;
    return days ? days.includes(dayNames[dayOfWeek]) : false;
  }
  return true;
}

// ── Trend query helpers ─────────────────────────────────────

export async function getWeeklyTrends(userId: string, weeks: number = 12) {
  return db('weekly_trends')
    .where({ user_id: userId })
    .orderBy('week_start', 'desc')
    .limit(weeks);
}

export async function getHabitTrends(userId: string, period: string = 'month') {
  const daysBack = period === 'quarter' ? 90 : period === 'month' ? 30 : 7;
  const since = new Date();
  since.setDate(since.getDate() - daysBack);

  const habits = await db('habits').where({ user_id: userId, is_active: true });
  const logs = await db('habit_logs')
    .where({ user_id: userId })
    .where('log_date', '>=', since.toISOString().slice(0, 10))
    .orderBy('log_date', 'asc');

  return {
    habits: habits.map((h: Record<string, unknown>) => ({
      id: h.id,
      name: h.name,
      category: h.category,
      streak: h.streak_current,
      bestStreak: h.streak_best,
    })),
    logs,
    period,
  };
}

export async function getDsaaTrends(userId: string, period: string = 'quarter') {
  const daysBack = period === 'quarter' ? 90 : period === 'month' ? 30 : 7;
  const since = new Date();
  since.setDate(since.getDate() - daysBack);

  return db('dsaa_daily_logs')
    .where({ user_id: userId })
    .where('log_date', '>=', since.toISOString().slice(0, 10))
    .orderBy('log_date', 'asc');
}

export async function getDeepWorkTrends(userId: string, period: string = 'month') {
  const daysBack = period === 'quarter' ? 90 : period === 'month' ? 30 : 7;
  const since = new Date();
  since.setDate(since.getDate() - daysBack);

  const deepWorkHabit = await db('habits')
    .where({ user_id: userId, category: 'deep_work', name: 'Deep Work Block' })
    .first();

  if (!deepWorkHabit) return { logs: [], period };

  const logs = await db('habit_logs')
    .where({ habit_id: deepWorkHabit.id })
    .where('log_date', '>=', since.toISOString().slice(0, 10))
    .orderBy('log_date', 'asc');

  return { logs, period, targetHours: deepWorkHabit.target_value };
}

export async function getOutcomeTrends(userId: string, period: string = 'quarter') {
  const daysBack = period === 'quarter' ? 90 : period === 'month' ? 30 : 7;
  const since = new Date();
  since.setDate(since.getDate() - daysBack);

  return db('weekly_trends')
    .where({ user_id: userId })
    .where('week_start', '>=', since.toISOString().slice(0, 10))
    .orderBy('week_start', 'asc')
    .select('week_start', 'outcomes_completed', 'outcomes_total', 'decisions_made', 'decisions_total');
}

export async function getDashboardData(userId: string) {
  const [latestTrend] = await db('weekly_trends')
    .where({ user_id: userId })
    .orderBy('week_start', 'desc')
    .limit(1);

  const trends = await getWeeklyTrends(userId, 4);
  const streak = await calculateCurrentStreak(userId);

  const today = new Date().toISOString().slice(0, 10);
  const todayHabitLogs = await db('habit_logs')
    .where({ user_id: userId, log_date: today });
  const totalHabits = await db('habits').where({ user_id: userId, is_active: true }).count('id as count');

  return {
    latestTrend: latestTrend || null,
    recentTrends: trends,
    dsaaStreak: streak,
    todayHabitsCompleted: todayHabitLogs.filter((l: Record<string, unknown>) => l.is_completed).length,
    todayHabitsTotal: Number(totalHabits[0]?.count || 0),
  };
}
