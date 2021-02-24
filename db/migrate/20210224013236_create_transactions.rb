class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :company, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.integer :number_of_shares
      t.decimal :price

      t.timestamps
    end
  end
end
