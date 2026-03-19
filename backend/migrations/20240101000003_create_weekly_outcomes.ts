import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('weekly_outcomes', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('sheet_id').notNullable().references('id').inTable('weekly_sheets').onDelete('CASCADE');
    table.integer('position').notNullable();
    table.text('outcome_text');
    table.text('impact');
    table.text('definition_of_done');
    table.text('owner');
    table.text('risk_and_mitigation');
    table.string('status', 20).notNullable().defaultTo('in_progress');
    table.timestamp('completed_at', { useTz: true }).nullable();
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());

    table.unique(['sheet_id', 'position']);
  });

  await knex.raw('ALTER TABLE weekly_outcomes ADD CONSTRAINT check_position_1_3 CHECK (position >= 1 AND position <= 3)');
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('weekly_outcomes');
}
