class AddDebtRatioToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :debt_ratio, :decimal, :default => nil
  end
end
