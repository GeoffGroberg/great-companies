class AddGrahamNumberToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :graham_number, :decimal
  end
end
