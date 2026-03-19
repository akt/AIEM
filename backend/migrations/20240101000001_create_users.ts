import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.raw('CREATE EXTENSION IF NOT EXISTS "pgcrypto"');
  await knex.schema.createTable('users', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('email', 255).unique().notNullable();
    table.string('password_hash', 255).notNullable();
    table.string('display_name', 100).notNullable();
    table.string('timezone', 50).notNullable().defaultTo('Indian/Maldives');
    table.string('role', 50).notNullable().defaultTo('engineering_manager');
    table.jsonb('surfaces').notNullable().defaultTo(JSON.stringify(["web3_dex","exchange","fiat_onoff_ramp","crypto_pay","ai_platform"]));
    table.text('push_token_android');
    table.text('push_token_ios');
    table.jsonb('notification_preferences').notNullable().defaultTo(JSON.stringify({
      daily_dsaa_reminder: true,
      weekly_fill_reminder: true,
      deep_work_start_alert: true,
      scorecard_friday_reminder: true,
      reactive_window_alerts: true,
      incident_pipeline_check: true
    }));
    table.time('dsaa_trigger_time').notNullable().defaultTo('09:00');
    table.string('dsaa_trigger_event', 255).defaultTo('morning standup');
    table.decimal('deep_work_hours_target', 3, 1).notNullable().defaultTo(1.5);
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('users');
}
