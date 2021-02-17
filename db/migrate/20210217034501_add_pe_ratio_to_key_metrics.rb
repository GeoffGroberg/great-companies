class AddPeRatioToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :pe_ratio, :decimal
  end
end
