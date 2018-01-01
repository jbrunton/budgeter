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

ActiveRecord::Schema.define(version: 20171226173302) do

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "account_type"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_accounts_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "directory"
    t.string "ignore_words"
    t.integer "seed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.date "date"
    t.integer "date_index"
    t.string "description"
    t.decimal "value"
    t.decimal "balance"
    t.string "category"
    t.string "predicted_category"
    t.boolean "verified"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index [nil], name: "index_transactions_on_status"
  end

end
