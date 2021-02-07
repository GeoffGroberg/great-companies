class AddGrowthToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :equity_growth, :decimal, :default => nil
    add_column :key_metrics, :eps_growth, :decimal, :default => nil
    add_column :key_metrics, :revenue_growth, :decimal, :default => nil
    add_column :key_metrics, :free_cash_flow_growth, :decimal, :default => nil
  end
end
