class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :transaction_type
      t.string :description
      t.decimal :value
      t.decimal :balance
      t.string :category
      t.string :status
      t.string :hash_code

      t.timestamps
    end
    add_index :transactions, :hash_code, unique: true
    add_index :transactions, :status
  end
end
