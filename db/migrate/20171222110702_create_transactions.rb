class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :type
      t.string :description
      t.decimal :value
      t.decimal :balance
      t.string :category

      t.timestamps
    end
  end
end
