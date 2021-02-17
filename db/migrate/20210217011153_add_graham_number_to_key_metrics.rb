class AddGrahamNumberToKeyMetrics < ActiveRecord::Migration[6.1]
  def change
    add_column :key_metrics, :graham_number, :decimal
  end
end
