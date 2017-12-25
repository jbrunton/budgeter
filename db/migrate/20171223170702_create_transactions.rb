class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :account_name
      t.date :date
      t.integer :date_index
      t.string :transaction_type
      t.string :description
      t.decimal :value
      t.decimal :balance

      t.string :category
      t.string :predicted_category

      t.references :project, foreign_key: true

      t.timestamps
    end
    add_index :transactions, :status
  end
end
