class MovePosition < ActiveRecord::Migration[6.1]
  def change
    remove_column :companies, :position
    add_column :companies_lists, :position, :integer
  end
end
