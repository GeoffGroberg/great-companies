class AddValuationOverridesToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :eps_override, :decimal
    add_column :companies, :eps_growth_rate_override, :decimal
    add_column :companies, :future_pe_override, :decimal
  end
end
