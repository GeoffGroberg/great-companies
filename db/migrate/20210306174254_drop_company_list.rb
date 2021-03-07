class DropCompanyList < ActiveRecord::Migration[6.1]
  def change
    drop_table :companies_lists
  end
end
