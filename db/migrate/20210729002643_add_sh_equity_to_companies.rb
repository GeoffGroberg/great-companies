class AddShEquityToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :shareholders_equity_per_share, :decimal
  end
end
