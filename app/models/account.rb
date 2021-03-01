class Account < ApplicationRecord
  has_many :transactions
  
  # active positions for an account
  def active_companies
    # companies with transactions
    companies_with_transactions = []
    self.transactions.each do |t|
      unless companies_with_transactions.include? t.company
        companies_with_transactions << t.company
      end
    end
    # companies with more than 0 shares currently
    active_companies = []
    companies_with_transactions.each do |c|
      shares = 0
      c.transactions.each do |t|
        shares += t.number_of_shares
      end
      unless active_companies.include? c
        if shares > 0
          active_companies << c
        end
      end
    end
    active_companies
  end

end

