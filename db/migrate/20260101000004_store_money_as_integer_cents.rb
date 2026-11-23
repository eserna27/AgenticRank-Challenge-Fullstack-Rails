class StoreMoneyAsIntegerCents < ActiveRecord::Migration[7.1]
  def up
    # Convert existing peso floats into integer cents, keeping column names.
    execute "UPDATE campaigns SET goal = ROUND(goal::numeric * 100)"
    change_column :campaigns, :goal, :bigint

    execute "UPDATE investments SET amount = ROUND(amount::numeric * 100)"
    change_column :investments, :amount, :bigint

    remove_index :investments, :idempotency_key
    add_index :investments, :idempotency_key, unique: true
  end

  def down
    change_column :campaigns, :goal, :float
    execute "UPDATE campaigns SET goal = goal / 100.0"

    change_column :investments, :amount, :float
    execute "UPDATE investments SET amount = amount / 100.0"

    remove_index :investments, :idempotency_key
    add_index :investments, :idempotency_key
  end
end
