class AddIntrinsicValueToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :intrinsic_value, :decimal
  end
end
