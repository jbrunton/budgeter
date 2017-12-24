# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171223170702) do

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "directory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date"
    t.string "transaction_type"
    t.string "description"
    t.decimal "value"
    t.decimal "balance"
    t.string "statement_name"
    t.integer "statement_index"
    t.string "category"
    t.string "predicted_category"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_transactions_on_project_id"
    t.index [nil], name: "index_transactions_on_status"
  end

end
