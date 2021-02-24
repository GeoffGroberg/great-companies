class AddDttoTransaction < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :dt, :datetime, precision: 6
  end
end
