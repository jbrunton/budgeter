class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :transaction_type
      t.string :description
      t.decimal :value
      t.decimal :balance
      t.string :category
      t.string :sha

      t.timestamps
    end
    add_index :transactions, :sha
  end
end
