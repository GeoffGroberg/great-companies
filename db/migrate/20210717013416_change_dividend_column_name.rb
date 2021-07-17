class ChangeDividendColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :dividend_yield_ttm, :dividend_yield_avg
  end
end
