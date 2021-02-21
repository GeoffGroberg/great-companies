class AddMoreStuffToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :eps_ttm, :decimal
    add_column :companies, :eps_growth_rate, :decimal
    add_column :companies, :default_pe, :decimal
    add_column :companies, :avg_pe, :decimal
    add_column :companies, :future_pe, :decimal
    add_column :companies, :future_eps, :decimal
    add_column :companies, :future_price, :decimal
  end
end
