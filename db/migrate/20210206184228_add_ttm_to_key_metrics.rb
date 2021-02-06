class AddTtmToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :ttm, :boolean, :default => false
  end
end
