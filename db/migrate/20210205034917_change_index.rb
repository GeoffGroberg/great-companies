class ChangeIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :annual_key_financials, name: "index_annual_key_financials_on_company_and_date"
    add_index :annual_key_financials, [:company, :date]
  end
end
