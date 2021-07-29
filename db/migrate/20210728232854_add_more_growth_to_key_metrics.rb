class AddMoreGrowthToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :receivables_growth, :decimal
    add_column :key_metrics, :inventory_growth, :decimal
    add_column :key_metrics, :asset_growth, :decimal
  end
end
