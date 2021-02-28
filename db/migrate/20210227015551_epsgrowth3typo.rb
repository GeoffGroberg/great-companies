class Epsgrowth3typo < ActiveRecord::Migration[6.1]
  def change
    rename_column :companies, :reps_avg_growth3, :eps_avg_growth3
  end
end
