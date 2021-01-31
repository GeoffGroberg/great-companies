class AddStuffToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :price, :decimal
    add_column :companies, :dcf, :decimal
    add_column :companies, :mktCap, :decimal
    add_column :companies, :volAvg, :decimal
    add_column :companies, :industry, :string
    add_column :companies, :sector, :string
    add_column :companies, :exchangeShortName, :string
    add_column :companies, :country, :string
    add_column :companies, :ipoDate, :datetime
  end
end
