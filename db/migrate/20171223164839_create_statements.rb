class CreateStatements < ActiveRecord::Migration[5.1]
  def change
    create_table :statements do |t|
      t.string :filename
      t.text :content
      t.date :first_date
      t.date :last_date
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
