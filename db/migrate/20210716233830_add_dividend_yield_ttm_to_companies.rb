class AddDividendYieldTtmToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :dividend_yield_ttm, :decimal
  end
end
