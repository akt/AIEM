import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import db from '../config/database';
import { authConfig } from '../config/auth';

// ============================================================
// Helpers
// ============================================================

function generateAccessToken(user: { id: string; email: string }): string {
  return jwt.sign(
    { id: user.id, email: user.email },
    authConfig.jwtSecret,
    { expiresIn: authConfig.jwtExpiry as unknown as jwt.SignOptions['expiresIn'] },
  );
}

function generateRefreshToken(user: { id: string; email: string }): string {
  return jwt.sign(
    { id: user.id, email: user.email },
    authConfig.jwtRefreshSecret,
    { expiresIn: authConfig.jwtRefreshExpiry as unknown as jwt.SignOptions['expiresIn'] },
  );
}

function stripPasswordHash(row: Record<string, unknown>): Record<string, unknown> {
  const { password_hash, ...rest } = row;
  return rest;
}

// ============================================================
// Public API
// ============================================================

export async function register(email: string, password: string, displayName: string) {
  const existing = await db('users').where({ email }).first();
  if (existing) {
    const err: any = new Error('Email already in use');
    err.status = 409;
    throw err;
  }

  const passwordHash = await bcrypt.hash(password, authConfig.saltRounds);
  const id = uuidv4();

  const [user] = await db('users')
    .insert({
      id,
      email,
      password_hash: passwordHash,
      display_name: displayName,
    })
    .returning('*');

  await seedDefaultHabits(id);

  return stripPasswordHash(user);
}

export async function login(email: string, password: string) {
  const user = await db('users').where({ email }).first();
  if (!user) {
    const err: any = new Error('Invalid email or password');
    err.status = 401;
    throw err;
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    const err: any = new Error('Invalid email or password');
    err.status = 401;
    throw err;
  }

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  return {
    user: stripPasswordHash(user),
    accessToken,
    refreshToken,
  };
}

export async function refreshToken(token: string) {
  try {
    const decoded = jwt.verify(token, authConfig.jwtRefreshSecret) as {
      id: string;
      email: string;
    };

    const user = await db('users').where({ id: decoded.id }).first();
    if (!user) {
      const err: any = new Error('User not found');
      err.status = 401;
      throw err;
    }

    const accessToken = generateAccessToken(user);
    const newRefreshToken = generateRefreshToken(user);

    return { accessToken, refreshToken: newRefreshToken };
  } catch (err: any) {
    if (err.status) throw err;
    const error: any = new Error('Invalid or expired refresh token');
    error.status = 401;
    throw error;
  }
}

export async function getProfile(userId: string) {
  const user = await db('users').where({ id: userId }).first();
  if (!user) {
    const err: any = new Error('User not found');
    err.status = 404;
    throw err;
  }
  return stripPasswordHash(user);
}

export async function updateProfile(
  userId: string,
  data: {
    display_name?: string;
    timezone?: string;
    notification_preferences?: Record<string, boolean>;
    dsaa_trigger_time?: string;
    dsaa_trigger_event?: string;
    deep_work_hours_target?: number;
    surfaces?: string[];
  },
) {
  const [updated] = await db('users')
    .where({ id: userId })
    .update({ ...data, updated_at: db.fn.now() })
    .returning('*');

  if (!updated) {
    const err: any = new Error('User not found');
    err.status = 404;
    throw err;
  }

  return stripPasswordHash(updated);
}

export async function updatePushToken(
  userId: string,
  platform: 'android' | 'ios',
  token: string,
) {
  const column = platform === 'android' ? 'push_token_android' : 'push_token_ios';

  const [updated] = await db('users')
    .where({ id: userId })
    .update({ [column]: token, updated_at: db.fn.now() })
    .returning('*');

  if (!updated) {
    const err: any = new Error('User not found');
    err.status = 404;
    throw err;
  }

  return stripPasswordHash(updated);
}

// ============================================================
// Default Habits
// ============================================================

export async function seedDefaultHabits(userId: string) {
  const now = new Date().toISOString();

  const defaults = [
    {
      name: 'Deep Work Block',
      description: 'Complete 1-2h of focused deep work (architecture, reliability, code review)',
      category: 'deep_work',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1.5,
      target_unit: 'hours',
      reminder_time: '09:30',
      reminder_enabled: true,
      sort_order: 1,
    },
    {
      name: 'DSAA 15-Minute Ritual',
      description: 'Pick 1 friction point, apply DSAA, produce 1 micro-artifact',
      category: 'deep_work',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: null,
      reminder_enabled: false,
      sort_order: 2,
    },
    {
      name: 'Free-Thinking Walk',
      description: 'Walk/whiteboard session for strategy synthesis',
      category: 'deep_work',
      frequency: 'custom',
      custom_days: JSON.stringify(['tue', 'thu']),
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: null,
      reminder_enabled: false,
      sort_order: 3,
    },
    {
      name: 'SLO/Error Budget Check',
      description: 'Review SLO dashboards and error budget burn status',
      category: 'reliability',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '10:00',
      reminder_enabled: true,
      sort_order: 4,
    },
    {
      name: 'Incident Pipeline Review',
      description: 'Check P0/P1 incidents, postmortem status, action items',
      category: 'reliability',
      frequency: 'weekly',
      custom_days: JSON.stringify(['fri']),
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '09:00',
      reminder_enabled: true,
      sort_order: 5,
    },
    {
      name: 'PR Review Queue Clear',
      description: 'Clear or delegate pending PR reviews (24h SLA for P0)',
      category: 'delivery',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '11:00',
      reminder_enabled: true,
      sort_order: 6,
    },
    {
      name: 'Weekly Scorecard Fill',
      description: 'Fill DORA metrics, SLO compliance, SPACE-lite, AI health',
      category: 'delivery',
      frequency: 'weekly',
      custom_days: JSON.stringify(['fri']),
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '16:00',
      reminder_enabled: true,
      sort_order: 7,
    },
    {
      name: 'Security Guardrails Check',
      description: 'Verify AI outputs reviewed, no secrets in prompts, least privilege',
      category: 'security',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: null,
      reminder_enabled: false,
      sort_order: 8,
    },
    {
      name: 'AI Output Validation',
      description: 'Review and validate any AI-generated code/docs before merge',
      category: 'ai_safety',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: null,
      reminder_enabled: false,
      sort_order: 9,
    },
    {
      name: 'Leadership Decision Progress',
      description: 'Check status of weekly leadership decisions (max 3)',
      category: 'leadership',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '15:00',
      reminder_enabled: true,
      sort_order: 10,
    },
    {
      name: 'Team Friction Pulse Check',
      description: 'Quick check-in on team friction signals (1-5 scale)',
      category: 'leadership',
      frequency: 'weekly',
      custom_days: JSON.stringify(['wed']),
      target_value: 1,
      target_unit: 'count',
      reminder_time: '14:00',
      reminder_enabled: true,
      sort_order: 11,
    },
    {
      name: 'Reactive Budget Respected',
      description: 'Did I stay within 2x30min reactive windows today?',
      category: 'health',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: '17:00',
      reminder_enabled: true,
      sort_order: 12,
    },
    {
      name: 'No Deep Work Interruptions',
      description: 'Protected deep work block from non-P0 interruptions',
      category: 'health',
      frequency: 'weekday',
      custom_days: null,
      target_value: 1,
      target_unit: 'boolean',
      reminder_time: null,
      reminder_enabled: false,
      sort_order: 13,
    },
  ];

  const rows = defaults.map((h) => ({
    id: uuidv4(),
    user_id: userId,
    ...h,
    streak_current: 0,
    streak_best: 0,
    is_active: true,
    created_at: now,
    updated_at: now,
  }));

  await db('habits').insert(rows);
}
