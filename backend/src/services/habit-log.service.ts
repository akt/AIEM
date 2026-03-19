import db from '../config/database';
import { HabitLog } from '../types';

export const habitLogService = {
  async getLogsByDate(userId: string, date: string): Promise<(HabitLog & { habit: Record<string, unknown> })[]> {
    const rows = await db('habit_logs')
      .join('habits', 'habit_logs.habit_id', 'habits.id')
      .where({ 'habit_logs.user_id': userId, 'habit_logs.log_date': date })
      .select(
        'habit_logs.*',
        'habits.name as habit_name',
        'habits.category as habit_category',
        'habits.target_value as habit_target_value',
        'habits.target_unit as habit_target_unit',
      );

    return rows.map((row: Record<string, unknown>) => ({
      ...mapLogRow(row),
      habit: {
        name: row.habit_name,
        category: row.habit_category,
        targetValue: row.habit_target_value,
        targetUnit: row.habit_target_unit,
      },
    }));
  },

  async getLogsByDateRange(
    userId: string,
    from: string,
    to: string,
  ): Promise<(HabitLog & { habit: Record<string, unknown> })[]> {
    const rows = await db('habit_logs')
      .join('habits', 'habit_logs.habit_id', 'habits.id')
      .where({ 'habit_logs.user_id': userId })
      .andWhere('habit_logs.log_date', '>=', from)
      .andWhere('habit_logs.log_date', '<=', to)
      .select(
        'habit_logs.*',
        'habits.name as habit_name',
        'habits.category as habit_category',
        'habits.target_value as habit_target_value',
        'habits.target_unit as habit_target_unit',
      );

    return rows.map((row: Record<string, unknown>) => ({
      ...mapLogRow(row),
      habit: {
        name: row.habit_name,
        category: row.habit_category,
        targetValue: row.habit_target_value,
        targetUnit: row.habit_target_unit,
      },
    }));
  },

  async createLog(
    userId: string,
    data: {
      habitId: string;
      date: string;
      value?: number | null;
      isCompleted: boolean;
      notes?: string;
    },
  ): Promise<HabitLog> {
    // Verify habit ownership
    const habit = await db('habits')
      .where({ id: data.habitId, user_id: userId })
      .first();

    if (!habit) {
      throw new Error('Habit not found or not owned by user');
    }

    const [row] = await db('habit_logs')
      .insert({
        habit_id: data.habitId,
        user_id: userId,
        log_date: data.date,
        value: data.value ?? null,
        is_completed: data.isCompleted,
        notes: data.notes ?? '',
      })
      .returning('*');

    // Update streak if completed
    if (data.isCompleted) {
      await updateStreak(data.habitId, userId, data.date);
    }

    return mapLogRow(row);
  },

  async updateLog(
    logId: string,
    userId: string,
    data: Partial<{
      value: number | null;
      isCompleted: boolean;
      notes: string;
    }>,
  ): Promise<HabitLog | null> {
    const existing = await db('habit_logs')
      .where({ id: logId, user_id: userId })
      .first();

    if (!existing) return null;

    const updates: Record<string, unknown> = { updated_at: db.fn.now() };
    if (data.value !== undefined) updates.value = data.value;
    if (data.isCompleted !== undefined) updates.is_completed = data.isCompleted;
    if (data.notes !== undefined) updates.notes = data.notes;

    const [row] = await db('habit_logs')
      .where({ id: logId, user_id: userId })
      .update(updates)
      .returning('*');

    // Recalculate streak if completion status changed
    if (data.isCompleted !== undefined) {
      await updateStreak(existing.habit_id, userId, existing.log_date);
    }

    return mapLogRow(row);
  },

  async bulkLog(
    userId: string,
    logs: Array<{
      habitId: string;
      date: string;
      value?: number | null;
      isCompleted: boolean;
      notes?: string;
    }>,
  ): Promise<HabitLog[]> {
    const results: HabitLog[] = [];

    await db.transaction(async (trx) => {
      for (const log of logs) {
        // Verify ownership
        const habit = await trx('habits')
          .where({ id: log.habitId, user_id: userId })
          .first();

        if (!habit) {
          throw new Error(`Habit ${log.habitId} not found or not owned by user`);
        }

        const [row] = await trx('habit_logs')
          .insert({
            habit_id: log.habitId,
            user_id: userId,
            log_date: log.date,
            value: log.value ?? null,
            is_completed: log.isCompleted,
            notes: log.notes ?? '',
          })
          .returning('*');

        results.push(mapLogRow(row));

        if (log.isCompleted) {
          await updateStreakInTrx(trx, log.habitId, userId, log.date);
        }
      }
    });

    return results;
  },

  async getSummary(
    userId: string,
    period: 'week' | 'month' | 'quarter',
  ): Promise<Record<string, { total: number; completed: number; rate: number }>> {
    const now = new Date();
    let from: Date;

    switch (period) {
      case 'week':
        from = new Date(now);
        from.setDate(from.getDate() - 7);
        break;
      case 'month':
        from = new Date(now);
        from.setMonth(from.getMonth() - 1);
        break;
      case 'quarter':
        from = new Date(now);
        from.setMonth(from.getMonth() - 3);
        break;
    }

    const rows = await db('habit_logs')
      .join('habits', 'habit_logs.habit_id', 'habits.id')
      .where({ 'habit_logs.user_id': userId })
      .andWhere('habit_logs.log_date', '>=', from.toISOString().split('T')[0])
      .select('habits.category', 'habit_logs.is_completed');

    const summary: Record<string, { total: number; completed: number; rate: number }> = {};

    for (const row of rows) {
      const cat = row.category as string;
      if (!summary[cat]) {
        summary[cat] = { total: 0, completed: 0, rate: 0 };
      }
      summary[cat].total++;
      if (row.is_completed) {
        summary[cat].completed++;
      }
    }

    // Calculate rates
    for (const cat of Object.keys(summary)) {
      summary[cat].rate =
        summary[cat].total > 0
          ? Math.round((summary[cat].completed / summary[cat].total) * 100) / 100
          : 0;
    }

    return summary;
  },
};

async function updateStreak(
  habitId: string,
  userId: string,
  logDate: string,
): Promise<void> {
  await updateStreakInTrx(db, habitId, userId, logDate);
}

async function updateStreakInTrx(
  trx: typeof db,
  habitId: string,
  userId: string,
  logDate: string,
): Promise<void> {
  // Check if previous day was also completed
  const prevDate = new Date(logDate);
  prevDate.setDate(prevDate.getDate() - 1);
  const prevDateStr = prevDate.toISOString().split('T')[0];

  const prevLog = await trx('habit_logs')
    .where({
      habit_id: habitId,
      user_id: userId,
      log_date: prevDateStr,
      is_completed: true,
    })
    .first();

  const habit = await trx('habits').where({ id: habitId }).first();
  if (!habit) return;

  let newStreak: number;
  if (prevLog) {
    // Previous day was completed, increment streak
    newStreak = habit.streak_current + 1;
  } else {
    // No previous day completion, start new streak
    newStreak = 1;
  }

  const updates: Record<string, unknown> = {
    streak_current: newStreak,
    updated_at: trx.fn.now(),
  };

  if (newStreak > habit.streak_best) {
    updates.streak_best = newStreak;
  }

  await trx('habits').where({ id: habitId }).update(updates);
}

function mapLogRow(row: Record<string, unknown>): HabitLog {
  return {
    id: row.id as string,
    habitId: row.habit_id as string,
    userId: row.user_id as string,
    logDate: row.log_date as string,
    value: row.value as number | null,
    isCompleted: row.is_completed as boolean,
    notes: (row.notes as string) ?? '',
    createdAt: row.created_at as string,
    updatedAt: row.updated_at as string,
  };
}
