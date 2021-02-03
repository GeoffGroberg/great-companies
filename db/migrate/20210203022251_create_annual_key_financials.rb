class CreateAnnualKeyFinancials < ActiveRecord::Migration[6.1]
  def change
    create_table :annual_key_financials do |t|
      t.references :company, null: false, foreign_key: true
      t.date :date
      t.decimal :roic
      t.decimal :equity
      t.decimal :eps
      t.decimal :revenue
      t.decimal :free_cash_flow
      t.decimal :debt_ratio

      t.timestamps
    end
    add_index :annual_key_financials, [:company, :date], unique: true
  end
end
