class AddPeToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :pe, :decimal
    add_column :companies, :eps, :decimal
  end
end
