/**
 * Simple Knex migration to create users and products for demo
 */
exports.up = function(knex) {
  return knex.schema
    .createTable('users', function(table) {
      table.increments('id').primary();
      table.string('email').notNullable().unique();
      table.string('password_hash');
      table.string('full_name');
      table.string('phone');
      table.string('role').defaultTo('customer');
      table.timestamps(true, true);
    })
    .createTable('products', function(table) {
      table.increments('id').primary();
      table.string('sku').unique();
      table.string('name').notNullable();
      table.text('description');
      table.decimal('price', 12, 2).notNullable();
      table.integer('stock').defaultTo(0);
      table.json('metadata');
      table.timestamp('created_at').defaultTo(knex.fn.now());
    });
};

exports.down = function(knex) {
  return knex.schema
    .dropTableIfExists('products')
    .dropTableIfExists('users');
};
