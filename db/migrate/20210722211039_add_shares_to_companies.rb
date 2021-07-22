class AddSharesToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :shares_outstanding, :integer
    add_column :companies, :institutional_shares, :integer
  end
end
