class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.integer :date_index
      t.string :transaction_type
      t.string :description
      t.decimal :value
      t.decimal :balance

      t.string :category
      t.string :predicted_category

      t.string :sha

      t.references :account, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
    add_index :transactions, :status
    add_index :transactions, [:account_id, :sha], unique: true
  end
end