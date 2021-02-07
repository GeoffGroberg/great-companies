class RoicAvg < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :roic_avg_growth10, :roic_avg10
    rename_column :companies, :roic_avg_growth5, :roic_avg5
    rename_column :companies, :roic_avg_growth2, :roic_avg2
  end
end
