class AddDividendYieldToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :dividend_yield, :decimal
  end
end
