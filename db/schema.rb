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

ActiveRecord::Schema.define(version: 2021_07_17_220146) do

  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "symbol"
    t.string "name"
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
    t.decimal "roic_avg10"
    t.decimal "roic_avg5"
    t.decimal "roic_avg3"
    t.decimal "equity_avg_growth10"
    t.decimal "equity_avg_growth5"
    t.decimal "equity_avg_growth3"
    t.decimal "free_cash_flow_avg_growth10"
    t.decimal "free_cash_flow_avg_growth5"
    t.decimal "free_cash_flow_avg_growth3"
    t.decimal "eps_avg_growth10"
    t.decimal "eps_avg_growth5"
    t.decimal "eps_avg_growth3"
    t.decimal "revenue_avg_growth10"
    t.decimal "revenue_avg_growth5"
    t.decimal "revenue_avg_growth3"
    t.decimal "debt_ratio"
    t.boolean "great", default: false
    t.decimal "graham_number"
    t.decimal "intrinsic_value"
    t.decimal "eps_growth_rate"
    t.decimal "default_pe"
    t.decimal "avg_pe"
    t.decimal "future_pe"
    t.decimal "future_eps"
    t.decimal "future_price"
    t.decimal "pe"
    t.decimal "eps"
    t.decimal "eps_override"
    t.decimal "eps_growth_rate_override"
    t.decimal "future_pe_override"
    t.datetime "earnings_announcement"
    t.datetime "financials_pulled_at"
    t.boolean "is_actively_trading"
    t.boolean "is_etf"
    t.string "website"
    t.decimal "dividend_yield_avg"
    t.decimal "insider_trading"
  end

  create_table "company_lists", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "list_id", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_company_lists_on_company_id"
    t.index ["list_id"], name: "index_company_lists_on_list_id"
  end

  create_table "key_metrics", force: :cascade do |t|
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
    t.boolean "quarterly", default: false
    t.decimal "equity_growth"
    t.decimal "eps_growth"
    t.decimal "revenue_growth"
    t.decimal "free_cash_flow_growth"
    t.decimal "graham_number"
    t.decimal "pe_ratio"
    t.decimal "dividend_yield"
    t.index "\"company\", \"date\"", name: "index_annual_key_financials_on_company_and_date"
    t.index ["company_id"], name: "index_key_metrics_on_company_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.integer "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_notes_on_company_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "company_id", null: false
    t.integer "account_id", null: false
    t.integer "number_of_shares"
    t.decimal "price"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "dt", precision: 6, null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["company_id"], name: "index_transactions_on_company_id"
  end

  add_foreign_key "company_lists", "companies"
  add_foreign_key "company_lists", "lists"
  add_foreign_key "key_metrics", "companies"
  add_foreign_key "notes", "companies"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "companies"
end
