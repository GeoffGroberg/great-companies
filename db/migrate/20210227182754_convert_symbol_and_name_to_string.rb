class ConvertSymbolAndNameToString < ActiveRecord::Migration[6.1]
  def change
    change_column :companies, :name, :string
    change_column :companies, :symbol, :string
  end
end
