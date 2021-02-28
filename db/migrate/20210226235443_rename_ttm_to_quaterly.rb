class RenameTtmToQuaterly < ActiveRecord::Migration[6.1]
  def change
    rename_column :key_metrics, :ttm, :quarterly
  end
end
