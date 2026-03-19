import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('weekly_sheets', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.date('week_start').notNullable();
    table.string('week_label', 50);
    table.string('status', 20).notNullable().defaultTo('draft');

    table.jsonb('surfaces_in_scope');
    table.text('oncall_ownership');
    table.text('key_dependencies');
    table.text('non_negotiable_constraints');

    table.text('constraint_statement');
    table.jsonb('constraint_evidence');
    table.string('constraint_slo_service');
    table.string('constraint_slo_targets');
    table.string('constraint_error_budget_status', 20).defaultTo('healthy');
    table.string('constraint_exhausted_action', 50);

    table.jsonb('dsaa_queue');
    table.string('dsaa_focus_this_week', 20);

    table.jsonb('ai_tasks');
    table.jsonb('ai_guardrails_checked');

    table.jsonb('time_blocks');

    table.jsonb('incident_checklist');
    table.jsonb('adr_checklist');

    table.jsonb('scorecard').nullable();

    table.text('ai_weekly_summary');
    table.text('ai_coaching_notes');

    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('completed_at', { useTz: true }).nullable();

    table.unique(['user_id', 'week_start']);
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('weekly_sheets');
}
