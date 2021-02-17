class AddPeRatioToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :pe_ratio, :decimal
  end
end
