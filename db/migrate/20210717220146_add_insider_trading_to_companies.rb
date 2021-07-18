class AddInsiderTradingToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :insider_trading, :decimal
  end
end
