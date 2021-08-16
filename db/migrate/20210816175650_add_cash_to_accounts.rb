class AddCashToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :cash, :decimal
  end
end
