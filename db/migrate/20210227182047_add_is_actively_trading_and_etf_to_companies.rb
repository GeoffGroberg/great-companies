class AddIsActivelyTradingAndEtfToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :is_actively_trading, :boolean
    add_column :companies, :is_etf, :boolean
  end
end
