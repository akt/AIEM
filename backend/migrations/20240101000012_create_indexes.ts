import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.raw('CREATE INDEX idx_weekly_sheets_user_week ON weekly_sheets(user_id, week_start DESC)');
  await knex.raw('CREATE INDEX idx_weekly_sheets_status ON weekly_sheets(status)');
  await knex.raw('CREATE INDEX idx_habit_logs_user_date ON habit_logs(user_id, log_date DESC)');
  await knex.raw('CREATE INDEX idx_habit_logs_habit_date ON habit_logs(habit_id, log_date DESC)');
  await knex.raw('CREATE INDEX idx_dsaa_logs_user_date ON dsaa_daily_logs(user_id, log_date DESC)');
  await knex.raw('CREATE INDEX idx_reminders_user_active ON reminders(user_id, is_active) WHERE is_active = TRUE');
  await knex.raw('CREATE INDEX idx_notification_log_user ON notification_log(user_id, sent_at DESC)');
  await knex.raw('CREATE INDEX idx_weekly_trends_user ON weekly_trends(user_id, week_start DESC)');
}

export async function down(knex: Knex): Promise<void> {
  await knex.raw('DROP INDEX IF EXISTS idx_weekly_sheets_user_week');
  await knex.raw('DROP INDEX IF EXISTS idx_weekly_sheets_status');
  await knex.raw('DROP INDEX IF EXISTS idx_habit_logs_user_date');
  await knex.raw('DROP INDEX IF EXISTS idx_habit_logs_habit_date');
  await knex.raw('DROP INDEX IF EXISTS idx_dsaa_logs_user_date');
  await knex.raw('DROP INDEX IF EXISTS idx_reminders_user_active');
  await knex.raw('DROP INDEX IF EXISTS idx_notification_log_user');
  await knex.raw('DROP INDEX IF EXISTS idx_weekly_trends_user');
}
