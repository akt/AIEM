import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('ai_interactions', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.string('interaction_type', 50);
    table.jsonb('context_data');
    table.text('ai_response');
    table.string('model_used', 50).defaultTo('claude-sonnet-4-20250514');
    table.integer('tokens_used');
    table.boolean('was_helpful');
    table.text('user_feedback');
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('ai_interactions');
}
