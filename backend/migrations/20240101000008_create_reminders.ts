import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('reminders', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.string('title', 255).notNullable();
    table.text('body');
    table.string('reminder_type', 50);
    table.string('schedule_type', 20);
    table.time('scheduled_time');
    table.jsonb('scheduled_days');
    table.date('scheduled_date');
    table.string('linked_entity_type', 50);
    table.uuid('linked_entity_id');
    table.boolean('is_active').defaultTo(true);
    table.timestamp('last_fired_at', { useTz: true }).nullable();
    table.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('reminders');
}
