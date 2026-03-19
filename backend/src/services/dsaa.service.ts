import db from '../config/database';
import { DsaaLog } from '../types';

export const dsaaService = {
  async getToday(userId: string): Promise<DsaaLog | null> {
    const today = new Date().toISOString().split('T')[0];

    const row = await db('dsaa_logs')
      .where({ user_id: userId, log_date: today })
      .first();

    return row ? mapDsaaRow(row) : null;
  },

  async createLog(
    userId: string,
    data: {
      frictionPoint: string;
      dsaaAction: 'delete' | 'simplify' | 'accelerate' | 'automate';
      microArtifactType?: string;
      microArtifactDescription?: string;
      expectedLeverage?: string;
      durationMinutes?: number;
    },
  ): Promise<DsaaLog> {
    const today = new Date().toISOString().split('T')[0];

    // Auto-link to current week's sheet if exists
    const currentSheet = await db('weekly_sheets')
      .where({ user_id: userId, status: 'active' })
      .orderBy('week_start', 'desc')
      .first();

    const [row] = await db('dsaa_logs')
      .insert({
        user_id: userId,
        sheet_id: currentSheet?.id ?? null,
        log_date: today,
        friction_point: data.frictionPoint,
        dsaa_action: data.dsaaAction,
        micro_artifact_type: data.microArtifactType ?? '',
        micro_artifact_description: data.microArtifactDescription ?? '',
        expected_leverage: data.expectedLeverage ?? '',
        duration_minutes: data.durationMinutes ?? null,
        ai_suggestion_accepted: false,
      })
      .returning('*');

    return mapDsaaRow(row);
  },

  async updateLog(
    logId: string,
    userId: string,
    data: Partial<{
      frictionPoint: string;
      dsaaAction: 'delete' | 'simplify' | 'accelerate' | 'automate';
      microArtifactType: string;
      microArtifactDescription: string;
      expectedLeverage: string;
      durationMinutes: number | null;
      startedAt: string | null;
      completedAt: string | null;
    }>,
  ): Promise<DsaaLog | null> {
    const existing = await db('dsaa_logs')
      .where({ id: logId, user_id: userId })
      .first();

    if (!existing) return null;

    const updates: Record<string, unknown> = {};
    if (data.frictionPoint !== undefined) updates.friction_point = data.frictionPoint;
    if (data.dsaaAction !== undefined) updates.dsaa_action = data.dsaaAction;
    if (data.microArtifactType !== undefined) updates.micro_artifact_type = data.microArtifactType;
    if (data.microArtifactDescription !== undefined)
      updates.micro_artifact_description = data.microArtifactDescription;
    if (data.expectedLeverage !== undefined) updates.expected_leverage = data.expectedLeverage;
    if (data.durationMinutes !== undefined) updates.duration_minutes = data.durationMinutes;
    if (data.startedAt !== undefined) updates.started_at = data.startedAt;
    if (data.completedAt !== undefined) updates.completed_at = data.completedAt;

    if (Object.keys(updates).length === 0) {
      return mapDsaaRow(existing);
    }

    const [row] = await db('dsaa_logs')
      .where({ id: logId, user_id: userId })
      .update(updates)
      .returning('*');

    return mapDsaaRow(row);
  },

  async getHistory(
    userId: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<{ data: DsaaLog[]; total: number; page: number; limit: number }> {
    const offset = (page - 1) * limit;

    const [rows, countResult] = await Promise.all([
      db('dsaa_logs')
        .where({ user_id: userId })
        .orderBy('log_date', 'desc')
        .limit(limit)
        .offset(offset),
      db('dsaa_logs')
        .where({ user_id: userId })
        .count('id as count')
        .first(),
    ]);

    return {
      data: rows.map(mapDsaaRow),
      total: Number(countResult?.count ?? 0),
      page,
      limit,
    };
  },

  async getStats(userId: string): Promise<{
    totalCompleted: number;
    streak: number;
    categoryDistribution: Record<string, number>;
    averageDuration: number | null;
    thisWeekCount: number;
  }> {
    // Total completed (has completed_at)
    const totalResult = await db('dsaa_logs')
      .where({ user_id: userId })
      .whereNotNull('completed_at')
      .count('id as count')
      .first();

    const totalCompleted = Number(totalResult?.count ?? 0);

    // Calculate streak: consecutive days with at least one DSAA log
    const streak = await calculateDsaaStreak(userId);

    // Category distribution
    const categories = await db('dsaa_logs')
      .where({ user_id: userId })
      .select('dsaa_action')
      .count('id as count')
      .groupBy('dsaa_action');

    const categoryDistribution: Record<string, number> = {};
    for (const row of categories) {
      categoryDistribution[row.dsaa_action as string] = Number(row.count);
    }

    // Average duration
    const avgResult = await db('dsaa_logs')
      .where({ user_id: userId })
      .whereNotNull('duration_minutes')
      .avg('duration_minutes as avg')
      .first();

    const averageDuration = avgResult?.avg ? Math.round(Number(avgResult.avg)) : null;

    // This week's count
    const now = new Date();
    const dayOfWeek = now.getDay();
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    const weekStartStr = weekStart.toISOString().split('T')[0];

    const weekResult = await db('dsaa_logs')
      .where({ user_id: userId })
      .andWhere('log_date', '>=', weekStartStr)
      .count('id as count')
      .first();

    const thisWeekCount = Number(weekResult?.count ?? 0);

    return {
      totalCompleted,
      streak,
      categoryDistribution,
      averageDuration,
      thisWeekCount,
    };
  },
};

async function calculateDsaaStreak(userId: string): Promise<number> {
  // Get distinct log dates ordered desc
  const dates = await db('dsaa_logs')
    .where({ user_id: userId })
    .select('log_date')
    .distinct('log_date')
    .orderBy('log_date', 'desc');

  if (dates.length === 0) return 0;

  let streak = 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let expectedDate = today;

  for (const row of dates) {
    const logDate = new Date(row.log_date);
    logDate.setHours(0, 0, 0, 0);

    const diffDays = Math.round(
      (expectedDate.getTime() - logDate.getTime()) / (1000 * 60 * 60 * 24),
    );

    if (diffDays === 0) {
      streak++;
      expectedDate = new Date(expectedDate);
      expectedDate.setDate(expectedDate.getDate() - 1);
    } else if (diffDays === 1 && streak === 0) {
      // Allow starting from yesterday if no log today yet
      streak = 1;
      expectedDate = new Date(logDate);
      expectedDate.setDate(expectedDate.getDate() - 1);
    } else {
      break;
    }
  }

  return streak;
}

function mapDsaaRow(row: Record<string, unknown>): DsaaLog {
  return {
    id: row.id as string,
    userId: row.user_id as string,
    sheetId: (row.sheet_id as string) ?? null,
    logDate: row.log_date as string,
    frictionPoint: row.friction_point as string,
    dsaaAction: row.dsaa_action as DsaaLog['dsaaAction'],
    microArtifactType: (row.micro_artifact_type as string) ?? '',
    microArtifactDescription: (row.micro_artifact_description as string) ?? '',
    expectedLeverage: (row.expected_leverage as string) ?? '',
    startedAt: (row.started_at as string) ?? null,
    completedAt: (row.completed_at as string) ?? null,
    durationMinutes: (row.duration_minutes as number) ?? null,
    aiSuggestedAction: (row.ai_suggested_action as string) ?? null,
    aiSuggestionAccepted: (row.ai_suggestion_accepted as boolean) ?? false,
    createdAt: row.created_at as string,
  };
}
