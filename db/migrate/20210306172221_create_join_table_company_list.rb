class CreateJoinTableCompanyList < ActiveRecord::Migration[6.1]
  def change
    remove_column :lists, :companies_id
    create_join_table :companies, :lists do |t|
      # t.index [:company_id, :list_id]
      # t.index [:list_id, :company_id]
    end
  end
end
