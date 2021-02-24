class AddDttoTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :transactions, :dt, :datetime, precision: 6, null: false
  end
end
