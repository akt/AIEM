import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('habits', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.string('name', 200).notNullable();
    table.text('description');
    table.string('category', 50);
    table.string('frequency', 20).notNullable().defaultTo('daily');
    table.jsonb('custom_days');
    table.decimal('target_value', 10, 2);
    table.string('target_unit', 30);
    table.time('reminder_time');
    table.boolean('reminder_enabled').defaultTo(true);
    table.integer('streak_current').defaultTo(0);
    table.integer('streak_best').defaultTo(0);
    table.boolean('is_active').defaultTo(true);
    table.integer('sort_order').defaultTo(0);
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('habits');
}
