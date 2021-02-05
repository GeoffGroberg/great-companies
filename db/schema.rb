# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_05_034917) do

  create_table "annual_key_financials", force: :cascade do |t|
    t.integer "company_id", null: false
    t.date "date"
    t.decimal "roic"
    t.decimal "equity"
    t.decimal "eps"
    t.decimal "revenue"
    t.decimal "free_cash_flow"
    t.decimal "debt_ratio"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"company\", \"date\"", name: "index_annual_key_financials_on_company_and_date"
    t.index ["company_id"], name: "index_annual_key_financials_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.text "symbol"
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "price"
    t.decimal "dcf"
    t.decimal "mktCap"
    t.decimal "volAvg"
    t.string "industry"
    t.string "sector"
    t.string "exchangeShortName"
    t.string "country"
    t.datetime "ipoDate"
    t.text "description"
  end

  add_foreign_key "annual_key_financials", "companies"
end
