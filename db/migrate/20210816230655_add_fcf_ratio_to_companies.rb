class AddFcfRatioToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :fcf_ratio, :decimal
  end
end
