import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('dsaa_daily_logs', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('sheet_id').nullable().references('id').inTable('weekly_sheets').onDelete('SET NULL');
    table.date('log_date').notNullable();

    table.text('friction_point');
    table.string('dsaa_action', 20);
    table.string('micro_artifact_type', 50);
    table.text('micro_artifact_description');
    table.text('expected_leverage');

    table.timestamp('started_at', { useTz: true }).nullable();
    table.timestamp('completed_at', { useTz: true }).nullable();
    table.integer('duration_minutes');

    table.text('ai_suggested_action');
    table.boolean('ai_suggestion_accepted').defaultTo(false);

    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());

    table.unique(['user_id', 'log_date']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('dsaa_daily_logs');
}
