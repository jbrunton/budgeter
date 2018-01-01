class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :directory
      t.string :ignore_words
      t.integer :seed

      t.timestamps
    end
  end
end
