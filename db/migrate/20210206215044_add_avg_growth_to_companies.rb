class AddAvgGrowthToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :roic_avg_growth10, :decimal, :default => nil
    add_column :companies, :roic_avg_growth5, :decimal, :default => nil
    add_column :companies, :roic_avg_growth2, :decimal, :default => nil
    add_column :companies, :equity_avg_growth10, :decimal, :default => nil
    add_column :companies, :equity_avg_growth5, :decimal, :default => nil
    add_column :companies, :equity_avg_growth2, :decimal, :default => nil
    add_column :companies, :free_cash_flow_avg_growth10, :decimal, :default => nil
    add_column :companies, :free_cash_flow_avg_growth5, :decimal, :default => nil
    add_column :companies, :free_cash_flow_avg_growth2, :decimal, :default => nil
    add_column :companies, :eps_avg_growth10, :decimal, :default => nil
    add_column :companies, :eps_avg_growth5, :decimal, :default => nil
    add_column :companies, :eps_avg_growth2, :decimal, :default => nil
    add_column :companies, :revenue_avg_growth10, :decimal, :default => nil
    add_column :companies, :revenue_avg_growth5, :decimal, :default => nil
    add_column :companies, :revenue_avg_growth2, :decimal, :default => nil
  end
end
