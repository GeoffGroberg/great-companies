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

ActiveRecord::Schema.define(version: 2021_02_23_004041) do

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
    t.decimal "roic_avg10"
    t.decimal "roic_avg5"
    t.decimal "roic_avg2"
    t.decimal "equity_avg_growth10"
    t.decimal "equity_avg_growth5"
    t.decimal "equity_avg_growth2"
    t.decimal "free_cash_flow_avg_growth10"
    t.decimal "free_cash_flow_avg_growth5"
    t.decimal "free_cash_flow_avg_growth2"
    t.decimal "eps_avg_growth10"
    t.decimal "eps_avg_growth5"
    t.decimal "eps_avg_growth2"
    t.decimal "revenue_avg_growth10"
    t.decimal "revenue_avg_growth5"
    t.decimal "revenue_avg_growth2"
    t.decimal "debt_ratio"
    t.boolean "great", default: false
    t.decimal "graham_number"
    t.decimal "intrinsic_value"
    t.decimal "pe_ttm"
    t.decimal "eps_ttm"
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
    t.boolean "ttm", default: false
    t.decimal "equity_growth"
    t.decimal "eps_growth"
    t.decimal "revenue_growth"
    t.decimal "free_cash_flow_growth"
    t.decimal "graham_number"
    t.decimal "pe_ratio"
    t.index "\"company\", \"date\"", name: "index_annual_key_financials_on_company_and_date"
    t.index ["company_id"], name: "index_key_metrics_on_company_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "body"
    t.integer "company_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["company_id"], name: "index_notes_on_company_id"
  end

  add_foreign_key "key_metrics", "companies"
  add_foreign_key "notes", "companies"
end
