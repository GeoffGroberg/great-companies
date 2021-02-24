class RemoveDtFromTransactions < ActiveRecord::Migration[6.1]
  def change
    remove_column :transactions, :dt
  end
end
