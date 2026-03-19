import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('leadership_decisions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('sheet_id').notNullable().references('id').inTable('weekly_sheets').onDelete('CASCADE');
    table.integer('position').notNullable();
    table.text('decision_text');
    table.date('by_when');
    table.text('inputs_needed');
    table.string('status', 20).notNullable().defaultTo('pending');
    table.text('decision_result');
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());

    table.unique(['sheet_id', 'position']);
  });

  await knex.raw('ALTER TABLE leadership_decisions ADD CONSTRAINT check_position_1_3 CHECK (position >= 1 AND position <= 3)');
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('leadership_decisions');
}
