class RenameAnnualKeyFinancial < ActiveRecord::Migration[6.1]
  def change
    rename_table :annual_key_financials, :key_metrics
  end
end
