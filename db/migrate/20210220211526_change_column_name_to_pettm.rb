class ChangeColumnNameToPettm < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :pe_ratio, :pe_ttm
  end
end
