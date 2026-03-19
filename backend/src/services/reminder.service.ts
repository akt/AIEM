import { v4 as uuid } from 'uuid';
import db from '../config/database';
import { Reminder } from '../types';

// ── Default EM reminders (all 9) ────────────────────────────
const DEFAULT_REMINDERS: Omit<Reminder, 'id' | 'userId' | 'isActive' | 'lastFiredAt' | 'createdAt' | 'updatedAt' | 'linkedEntityType' | 'linkedEntityId' | 'scheduledDate'>[] = [
  {
    title: 'Fill Weekly Operating Sheet',
    body: 'Time to set up your Top 3 Outcomes, Constraint Deep-Dive, and DSAA Queue for the week.',
    reminderType: 'weekly_fill',
    scheduleType: 'weekly',
    scheduledTime: '20:00',
    scheduledDays: ['sun'],
  },
  {
    title: 'DSAA 15-Minute Ritual',
    body: 'Pick 1 friction point → Apply DSAA → Produce 1 micro-artifact. Go!',
    reminderType: 'dsaa_ritual',
    scheduleType: 'daily',
    scheduledTime: '09:00',
    scheduledDays: ['mon', 'tue', 'wed', 'thu', 'fri'],
  },
  {
    title: 'Deep Work Block Starting',
    body: 'Your hardcore deep work block starts now. Silence notifications. Focus.',
    reminderType: 'deep_work_start',
    scheduleType: 'weekly',
    scheduledTime: null,
    scheduledDays: null,
  },
  {
    title: 'Deep Work Block Ending',
    body: 'Deep work block ending in 10 minutes. Wrap up and capture notes.',
    reminderType: 'deep_work_end',
    scheduleType: 'weekly',
    scheduledTime: null,
    scheduledDays: null,
  },
  {
    title: 'Reactive Window Open',
    body: 'Reactive window now. Handle Slack, emails, quick decisions. Time-boxed!',
    reminderType: 'reactive_window',
    scheduleType: 'daily',
    scheduledTime: '14:00',
    scheduledDays: ['mon', 'tue', 'wed', 'thu', 'fri'],
  },
  {
    title: 'Friday Scorecard Time',
    body: 'Fill your weekly scorecard: DORA metrics, SLO compliance, SPACE-lite, AI health.',
    reminderType: 'scorecard_fill',
    scheduleType: 'weekly',
    scheduledTime: '16:00',
    scheduledDays: ['fri'],
  },
  {
    title: 'Incident Pipeline Check',
    body: 'Review P0/P1 incidents, postmortem status, action items. Choose 1 prevention bet.',
    reminderType: 'incident_review',
    scheduleType: 'weekly',
    scheduledTime: '10:00',
    scheduledDays: ['fri'],
  },
  {
    title: 'Midweek Check',
    body: "Midweek: How's the constraint deep-dive? Any risks to Top 3 Outcomes? Adjust.",
    reminderType: 'midweek_check',
    scheduleType: 'weekly',
    scheduledTime: '10:00',
    scheduledDays: ['wed'],
  },
  {
    title: 'End-of-Day Habit Check',
    body: 'Log your habits for today before you sign off!',
    reminderType: 'habit_check',
    scheduleType: 'daily',
    scheduledTime: '18:00',
    scheduledDays: ['mon', 'tue', 'wed', 'thu', 'fri'],
  },
];

// ── CRUD ─────────────────────────────────────────────────────

export async function listReminders(userId: string): Promise<Reminder[]> {
  return db('reminders')
    .where({ user_id: userId, is_active: true })
    .orderBy('scheduled_time', 'asc');
}

export async function createReminder(userId: string, data: Partial<Reminder>): Promise<Reminder> {
  const id = uuid();
  const [row] = await db('reminders')
    .insert({
      id,
      user_id: userId,
      title: data.title,
      body: data.body,
      reminder_type: data.reminderType || 'custom',
      schedule_type: data.scheduleType || 'daily',
      scheduled_time: data.scheduledTime,
      scheduled_days: data.scheduledDays ? JSON.stringify(data.scheduledDays) : null,
      scheduled_date: data.scheduledDate || null,
      linked_entity_type: data.linkedEntityType || null,
      linked_entity_id: data.linkedEntityId || null,
      is_active: true,
    })
    .returning('*');
  return row;
}

export async function updateReminder(userId: string, reminderId: string, data: Partial<Reminder>): Promise<Reminder> {
  const updates: Record<string, unknown> = { updated_at: db.fn.now() };
  if (data.title !== undefined) updates.title = data.title;
  if (data.body !== undefined) updates.body = data.body;
  if (data.scheduledTime !== undefined) updates.scheduled_time = data.scheduledTime;
  if (data.scheduledDays !== undefined) updates.scheduled_days = JSON.stringify(data.scheduledDays);
  if (data.scheduleType !== undefined) updates.schedule_type = data.scheduleType;
  if (data.isActive !== undefined) updates.is_active = data.isActive;

  const [row] = await db('reminders')
    .where({ id: reminderId, user_id: userId })
    .update(updates)
    .returning('*');
  return row;
}

export async function deleteReminder(userId: string, reminderId: string): Promise<void> {
  await db('reminders').where({ id: reminderId, user_id: userId }).del();
}

export async function setupDefaults(userId: string): Promise<Reminder[]> {
  const existing = await db('reminders').where({ user_id: userId }).select('reminder_type');
  const existingTypes = new Set(existing.map((r: { reminder_type: string }) => r.reminder_type));

  const toInsert = DEFAULT_REMINDERS
    .filter((r) => !existingTypes.has(r.reminderType))
    .map((r) => ({
      id: uuid(),
      user_id: userId,
      title: r.title,
      body: r.body,
      reminder_type: r.reminderType,
      schedule_type: r.scheduleType,
      scheduled_time: r.scheduledTime,
      scheduled_days: r.scheduledDays ? JSON.stringify(r.scheduledDays) : null,
      is_active: true,
    }));

  if (toInsert.length > 0) {
    await db('reminders').insert(toInsert);
  }

  return listReminders(userId);
}

// ── Reminder engine: find due reminders ─────────────────────

export async function getDueReminders(): Promise<Array<{ reminder: Record<string, unknown>; user: Record<string, unknown> }>> {
  const now = new Date();
  const currentTime = now.toTimeString().slice(0, 5); // HH:MM
  const dayNames = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  const currentDay = dayNames[now.getUTCDay()];

  const rows = await db('reminders as r')
    .join('users as u', 'r.user_id', 'u.id')
    .where('r.is_active', true)
    .whereNotNull('r.scheduled_time')
    .whereRaw("r.scheduled_time = ?", [currentTime])
    .where(function () {
      this.where('r.schedule_type', 'daily')
        .orWhere(function () {
          this.where('r.schedule_type', 'weekly')
            .whereRaw("r.scheduled_days::jsonb ?? ?", [currentDay]);
        });
    })
    .where(function () {
      this.whereNull('r.last_fired_at')
        .orWhereRaw("r.last_fired_at < now() - interval '30 minutes'");
    })
    .select('r.*', 'u.push_token_android', 'u.push_token_ios', 'u.email', 'u.display_name');

  return rows.map((row: Record<string, unknown>) => ({
    reminder: row,
    user: {
      id: row.user_id,
      email: row.email,
      displayName: row.display_name,
      pushTokenAndroid: row.push_token_android,
      pushTokenIos: row.push_token_ios,
    },
  }));
}

export async function markFired(reminderId: string): Promise<void> {
  await db('reminders').where({ id: reminderId }).update({ last_fired_at: db.fn.now() });
}
