class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.text :ticker
      t.text :name

      t.timestamps
    end
  end
end
