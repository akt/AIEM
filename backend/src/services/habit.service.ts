import db from '../config/database';
import { Habit } from '../types';

export const habitService = {
  async listHabits(userId: string): Promise<Habit[]> {
    const habits = await db('habits')
      .where({ user_id: userId, is_active: true })
      .orderBy('sort_order', 'asc');

    return habits.map(mapHabitRow);
  },

  async createHabit(
    userId: string,
    data: {
      name: string;
      category: string;
      frequency: string;
      description?: string;
      targetValue?: number;
      targetUnit?: string;
      reminderTime?: string;
      customDays?: string[];
    },
  ): Promise<Habit> {
    // Get next sort_order
    const maxOrder = await db('habits')
      .where({ user_id: userId, is_active: true })
      .max('sort_order as max')
      .first();

    const nextOrder = (maxOrder?.max ?? -1) + 1;

    const [row] = await db('habits')
      .insert({
        user_id: userId,
        name: data.name,
        description: data.description ?? '',
        category: data.category,
        frequency: data.frequency,
        custom_days: data.customDays ? JSON.stringify(data.customDays) : null,
        target_value: data.targetValue ?? 1,
        target_unit: data.targetUnit ?? 'boolean',
        reminder_time: data.reminderTime ?? null,
        reminder_enabled: !!data.reminderTime,
        streak_current: 0,
        streak_best: 0,
        is_active: true,
        sort_order: nextOrder,
      })
      .returning('*');

    return mapHabitRow(row);
  },

  async updateHabit(
    habitId: string,
    userId: string,
    data: Partial<{
      name: string;
      description: string;
      category: string;
      frequency: string;
      customDays: string[];
      targetValue: number;
      targetUnit: string;
      reminderTime: string | null;
      reminderEnabled: boolean;
    }>,
  ): Promise<Habit | null> {
    const existing = await db('habits')
      .where({ id: habitId, user_id: userId })
      .first();

    if (!existing) return null;

    const updates: Record<string, unknown> = { updated_at: db.fn.now() };
    if (data.name !== undefined) updates.name = data.name;
    if (data.description !== undefined) updates.description = data.description;
    if (data.category !== undefined) updates.category = data.category;
    if (data.frequency !== undefined) updates.frequency = data.frequency;
    if (data.customDays !== undefined)
      updates.custom_days = JSON.stringify(data.customDays);
    if (data.targetValue !== undefined) updates.target_value = data.targetValue;
    if (data.targetUnit !== undefined) updates.target_unit = data.targetUnit;
    if (data.reminderTime !== undefined)
      updates.reminder_time = data.reminderTime;
    if (data.reminderEnabled !== undefined)
      updates.reminder_enabled = data.reminderEnabled;

    const [row] = await db('habits')
      .where({ id: habitId, user_id: userId })
      .update(updates)
      .returning('*');

    return mapHabitRow(row);
  },

  async deleteHabit(habitId: string, userId: string): Promise<boolean> {
    const count = await db('habits')
      .where({ id: habitId, user_id: userId })
      .update({ is_active: false, updated_at: db.fn.now() });

    return count > 0;
  },

  async reorderHabits(
    userId: string,
    orderedIds: string[],
  ): Promise<void> {
    await db.transaction(async (trx) => {
      for (let i = 0; i < orderedIds.length; i++) {
        await trx('habits')
          .where({ id: orderedIds[i], user_id: userId })
          .update({ sort_order: i, updated_at: db.fn.now() });
      }
    });
  },

  async getHabitStats(
    habitId: string,
    userId: string,
  ): Promise<{
    streakCurrent: number;
    streakBest: number;
    completionRate: number;
    totalCompletions: number;
  } | null> {
    const habit = await db('habits')
      .where({ id: habitId, user_id: userId })
      .first();

    if (!habit) return null;

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const logs = await db('habit_logs')
      .where({ habit_id: habitId, user_id: userId })
      .andWhere('log_date', '>=', thirtyDaysAgo.toISOString().split('T')[0]);

    const completedLast30 = logs.filter((l: { is_completed: boolean }) => l.is_completed).length;
    const completionRate = logs.length > 0 ? completedLast30 / 30 : 0;

    const totalResult = await db('habit_logs')
      .where({ habit_id: habitId, user_id: userId, is_completed: true })
      .count('id as count')
      .first();

    return {
      streakCurrent: habit.streak_current,
      streakBest: habit.streak_best,
      completionRate: Math.round(completionRate * 100) / 100,
      totalCompletions: Number(totalResult?.count ?? 0),
    };
  },
};

function mapHabitRow(row: Record<string, unknown>): Habit {
  return {
    id: row.id as string,
    userId: row.user_id as string,
    name: row.name as string,
    description: (row.description as string) ?? '',
    category: row.category as Habit['category'],
    frequency: row.frequency as Habit['frequency'],
    customDays: row.custom_days
      ? (typeof row.custom_days === 'string'
          ? JSON.parse(row.custom_days)
          : row.custom_days)
      : null,
    targetValue: row.target_value as number,
    targetUnit: row.target_unit as Habit['targetUnit'],
    reminderTime: (row.reminder_time as string) ?? null,
    reminderEnabled: row.reminder_enabled as boolean,
    streakCurrent: row.streak_current as number,
    streakBest: row.streak_best as number,
    isActive: row.is_active as boolean,
    sortOrder: row.sort_order as number,
    createdAt: row.created_at as string,
    updatedAt: row.updated_at as string,
  };
}
