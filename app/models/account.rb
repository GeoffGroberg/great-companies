class Account < ApplicationRecord
  has_many :transactions
  
  # active positions for an account
  def active_companies
    active_companies = []
    self.transactions.each do |t|
      unless active_companies.include? t.company
        active_companies << t.company
      end
    end
    active_companies
  end

end
