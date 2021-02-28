class DropPettMandEpsttm < ActiveRecord::Migration[6.1]
  def change
    remove_column :companies, :eps_ttm
    remove_column :companies, :pe_ttm
  end
end
