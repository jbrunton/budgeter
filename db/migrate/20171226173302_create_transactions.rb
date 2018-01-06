class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.integer :date_index
      t.string :description
      t.decimal :value
      t.decimal :balance

      t.string :assigned_category
      t.string :predicted_category

      t.references :account, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
    add_index :transactions, :status
  end
end
