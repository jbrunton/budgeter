class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :transaction_type
      t.string :description
      t.decimal :value
      t.decimal :balance

      t.string :statement_name
      t.integer :statement_index
      t.string :store_name
      t.integer :store_index
      t.string :category

      t.references :project, foreign_key: true

      t.timestamps
    end
    add_index :transactions, :status
  end
end
