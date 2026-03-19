import { Knex } from 'knex';

export async function up(knex: Knex): Promise<void> {
  await knex.schema.createTable('notification_log', (table) => {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.uuid('reminder_id').nullable().references('id').inTable('reminders').onDelete('SET NULL');
    table.string('title', 255);
    table.text('body');
    table.string('channel', 20);
    table.string('status', 20);
    table.timestamp('sent_at', { useTz: true }).defaultTo(knex.fn.now());
    table.timestamp('actioned_at', { useTz: true }).nullable();
  });
}

export async function down(knex: Knex): Promise<void> {
  await knex.schema.dropTableIfExists('notification_log');
}
