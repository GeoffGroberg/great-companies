class TickerToSymbol < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :ticker, :symbol
  end
end
