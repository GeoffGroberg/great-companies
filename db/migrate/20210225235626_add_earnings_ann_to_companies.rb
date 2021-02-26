class AddEarningsAnnToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :earnings_announcement, :datetime
    add_column :companies, :financials_pulled_at, :datetime
  end
end
