import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('weekly_trends', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.date('week_start').notNullable();

    table.decimal('deep_work_hours_total', 5, 1);
    table.integer('dsaa_rituals_completed').defaultTo(0);
    table.decimal('habits_completion_rate', 5, 2);
    table.integer('outcomes_completed').defaultTo(0);
    table.integer('outcomes_total').defaultTo(0);
    table.integer('decisions_made').defaultTo(0);
    table.integer('decisions_total').defaultTo(0);
    table.boolean('incidents_reviewed').defaultTo(false);
    table.string('error_budget_status', 20);
    table.jsonb('dora_scores');
    table.integer('ai_assists_count').defaultTo(0);
    table.integer('streak_days').defaultTo(0);
    table.decimal('friction_pulse_avg', 3, 1);

    table.text('ai_trend_insight');

    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());

    table.unique(['user_id', 'week_start']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('weekly_trends');
}
