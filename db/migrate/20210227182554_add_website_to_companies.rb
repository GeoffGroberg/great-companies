class AddWebsiteToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :website, :string
  end
end
