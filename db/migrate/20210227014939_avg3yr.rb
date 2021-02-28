class Avg3yr < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :roic_avg2, :roic_avg3
    rename_column :companies, :equity_avg_growth2, :equity_avg_growth3
    rename_column :companies, :free_cash_flow_avg_growth2, :free_cash_flow_avg_growth3
    rename_column :companies, :eps_avg_growth2, :reps_avg_growth3
    rename_column :companies, :revenue_avg_growth2, :revenue_avg_growth3
  end
end
