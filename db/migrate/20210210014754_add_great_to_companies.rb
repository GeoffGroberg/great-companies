class AddGreatToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :great, :boolean, :default => false
  end
end
